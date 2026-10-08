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
  - "docs/deploy_vps.md"
  - ".github/workflows/**"
  - "config/deploy.yml"
  - ".kamal/**"
  - "script/vps/**"
---

**Deploy:** Render free tier (Docker, `render.yaml` Blueprint) + Neon Postgres + Cloudflare R2 (Active Storage service `:cloudflare`, `aws-sdk-s3`) + Brevo SMTP; runbook in `docs/deploy_render.md`. Render deploys `main` only after CI passes (`autoDeployTrigger: checksPass`); the workflow's `deploy` job is for the VPS (below). Production uses a single `DATABASE_URL`: cache/queue/cable live in their own Postgres schemas (`schema_search_path` in `config/database.yml`, created by `db:create_schemas`, which `lib/tasks/db_schemas.rake` hooks before `db:prepare`) so each keeps its own `schema_migrations`. Solid Queue runs inside Puma in `solid_queue_mode :async` (threads, not forked processes) to fit in 512 MB. `bin/docker-entrypoint` runs `db:prepare` on every boot; Thruster listens on `HTTP_PORT=10000`. The free tier has no shell, no persistent disk and sleeps after 15 min; one-off production tasks run from a local `RAILS_ENV=production DATABASE_URL=… bin/rails console`.

**VPS (en camino de reemplazar a Render):** Kamal to a DigitalOcean droplet (`s-4vcpu-8gb`: 4 vCPU / 8 GB, x86), runbook in `docs/deploy_vps.md`. `config/deploy.yml` is tuned to that size — `WEB_CONCURRENCY: 4` (one Puma process per vCPU; Solid Queue `:async` still runs once, in the Puma master), `IMAGE_JOB_CONCURRENCY: 3`, and Postgres memory in the accessory's `cmd`; the per-size table and the resize order live in the guide's «Tamaño del droplet». App and Postgres share the droplet: `postgres:18` is the `db` accessory (container `fsy_management-db`, port bound to 127.0.0.1 only, memory tuned in its `cmd`), and the app reaches it through `DATABASE_URL` built in `.kamal/secrets` — still one database with the cache/queue/cable schemas, so `config/database.yml` is the same for both hosts. kamal-proxy terminates SSL on `APP_HOST`; Thruster listens on 80 (no `HTTP_PORT`). The image is built in GitHub Actions and pushed to ghcr.io; the `deploy` job in `ci.yml` runs `bin/kamal deploy` after every other job passes on `main`, only when the repo variable `KAMAL_DEPLOY` is `true` (until then it is skipped and Render keeps deploying). Accessories are booted once by hand (`kamal deploy` doesn't boot them). Backups: `script/vps/backup.sh`, installed by `script/vps/setup_server.sh` as a nightly cron, runs `pg_dump` inside the db container and uploads with `rclone` to a **private** R2 bucket — never the public photo bucket. One-off tasks run in the container (`bin/kamal app exec --interactive --reuse "..."`).

**Fotos de perfil (subida directa):** `avatar_preview_controller.js` downscales the photo to 1600 px and uploads it straight to R2 with `DirectUpload` as soon as it's picked; the form then submits only the blob's signed id (a hidden field takes the file input's name). If the direct upload fails it falls back to sending the downscaled file with the form, so a missing CORS rule on the bucket (`docs/deploy_render.md`, R2 step 6; `docs/deploy_vps.md` §4b) degrades, never breaks. `DirectUploadsController` sits on Active Storage's own `/rails/active_storage/direct_uploads` path (app routes win over the engine's) and requires a session and an image ≤ 15 MB — the stock endpoint lets anyone create blobs. Image jobs (`AnalyzeJob`/`TransformJob`) run on their own `images` queue (`config/queue.yml`) with `config.x.image_job_concurrency` threads and the same concurrency limit (`IMAGE_JOB_CONCURRENCY`, default 1 for 512 MB, `auto` = cores − 1), so a burst of push notifications doesn't delay thumbnails. `WEB_CONCURRENCY=auto` (Puma) runs one process per core; Solid Queue `:async` still runs once, in the Puma master.

