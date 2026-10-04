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
