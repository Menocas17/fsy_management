---
paths:
  - "config/database.yml"
  - "config/puma.rb"
  - "config/storage.yml"
  - "render.yaml"
  - "Dockerfile"
  - "bin/docker-entrypoint"
  - "lib/tasks/db_schemas.rake"
  - "docs/deploy_render.md"
  - ".github/workflows/**"
---

**Deploy:** Render free tier (Docker, `render.yaml` Blueprint) + Neon Postgres + Cloudflare R2 (Active Storage service `:cloudflare`, `aws-sdk-s3`) + Brevo SMTP; runbook in `docs/deploy_render.md`. Render deploys `main` only after CI passes (`autoDeployTrigger: checksPass`) — there is no deploy job in the workflow. Production uses a single `DATABASE_URL`: cache/queue/cable live in their own Postgres schemas (`schema_search_path` in `config/database.yml`, created by `db:create_schemas`, which `lib/tasks/db_schemas.rake` hooks before `db:prepare`) so each keeps its own `schema_migrations`. Solid Queue runs inside Puma in `solid_queue_mode :async` (threads, not forked processes) to fit in 512 MB. `bin/docker-entrypoint` runs `db:prepare` on every boot; Thruster listens on `HTTP_PORT=10000`. The free tier has no shell, no persistent disk and sleeps after 15 min; one-off production tasks run from a local `RAILS_ENV=production DATABASE_URL=… bin/rails console`.

**Fotos de perfil (subida directa):** `avatar_preview_controller.js` downscales the photo to 1600 px and uploads it straight to R2 with `DirectUpload` as soon as it's picked; the form then submits only the blob's signed id (a hidden field takes the file input's name). If the direct upload fails it falls back to sending the downscaled file with the form, so a missing CORS rule on the bucket (`docs/deploy_render.md`, R2 step 6) degrades, never breaks. `DirectUploadsController` sits on Active Storage's own `/rails/active_storage/direct_uploads` path (app routes win over the engine's) and requires a session and an image ≤ 15 MB — the stock endpoint lets anyone create blobs. Image jobs (`AnalyzeJob`/`TransformJob`) run on their own `images` queue (`config/queue.yml`) with `config.x.image_job_concurrency` threads and the same concurrency limit (`IMAGE_JOB_CONCURRENCY`, default 1 for 512 MB, `auto` = cores − 1), so a burst of push notifications doesn't delay thumbnails. `WEB_CONCURRENCY=auto` (Puma) runs one process per core; Solid Queue `:async` still runs once, in the Puma master.

