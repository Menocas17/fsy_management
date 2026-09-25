# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

FSY Management — a Rails app for managing participants (youth and staff) of an FSY event: registration, profiles, medical/contact info, stake/ward/room assignment, company staffing, and a KPI dashboard. UI copy, locale strings, and commit messages in this repo are in Spanish; code identifiers are in English.

## Commands

```bash
bin/dev                        # start web (rails server) + css (tailwind watch) + worker (solid_queue) — use this for local dev
bin/rails server                # web only
bin/rails solid_queue:start     # worker only (required for preprocessed avatar thumbnails and deliver_later emails)
bin/rails tailwindcss:watch     # tailwind only

bin/rails test                              # full test suite
bin/rails test test/models/participant_test.rb          # single file
bin/rails test test/models/participant_test.rb:23       # single test at line
bin/rails test:system                       # Capybara/Selenium system tests

bin/rubocop --no-server        # lint (Rails Omakase style)
bin/brakeman --no-pager        # static security scan
bin/bundler-audit               # gem vulnerability scan
bin/importmap audit             # JS dependency vulnerability scan

bin/rails db:prepare            # create/migrate primary DB
bin/rails db:schema:load:queue  # load Solid Queue's separate queue DB schema (needed once per fresh DB; create it first with bin/rails db:create if it doesn't exist)
bin/rails console
```

CI (`.github/workflows`) runs scan_ruby (brakeman, bundler-audit), scan_js (importmap audit), lint (rubocop), and test (Minitest against Postgres) on every PR/push to main — all must pass before deploy.

## Architecture

**Stack:** Rails 8.1 + Hotwire (Turbo/Stimulus) + Tailwind CSS v4 + ViewComponent, Postgres (UUID PKs via `pgcrypto`), Solid Queue/Cache/Cable, Minitest.

**Multiple databases:** the app connects to a `primary` DB plus a separate `queue` DB for Solid Queue (`db/queue_schema.rb`, `config/database.yml`). In development, cache/cable stay in-memory but queue is real — the worker (`bin/dev`'s `worker` process, or `bin/rails solid_queue:start`) must be running for avatar thumbnail preprocessing and background emails to actually process. Production additionally splits out `cache` and `cable` DBs; Solid Queue runs in-process with Puma (`SOLID_QUEUE_IN_PUMA: true`), no separate worker container.

**Auth:** custom, not Devise. `has_secure_password` on `User` + signed-cookie sessions. `Authentication` concern (`app/controllers/concerns/authentication.rb`) handles session resumption/creation via `Current.session`/`Current.user`. `Authorization` concern (`app/controllers/concerns/authorization.rb`) handles role-based permissions — both view-level helper methods (`can_view_companies?`, `full_company_access?`, `can_edit_auxiliar_company?`, `can_edit_company?`, `can_manage_staff?`) and the strong-params allowlist (`allowed_participant_attributes`, used by `ParticipantsController#participant_params`) which grants fields based on the acting user's role.

**Domain model — participants and companies:**
- `Participant`: the core record (youth or staff). Enums for `rol` (director/coordinador/auxiliar/consejero/registrador/logistica/joven), `stake`, `ward`, `shirt_number`, `gender`. Contact/emergency/medical fields live in `jsonb` columns exposed via `store_accessor` (`contact_info`, `person_in_charge`, `medical_info`) rather than real columns. Avatar via Active Storage with `thumb`/`preview` variants, both `preprocessed: true` (see queue DB note above).
- `Company` / `AuxiliarCompany`: a two-level staffing hierarchy. An `AuxiliarCompany` is supervised by a `coordinador`-role participant and groups several standard `Company` records (`company.auxiliar_company_id`).
- `Membership`: polymorphic join (`associable`: `Company` or `AuxiliarCompany`) between a company and a `Participant`, carrying `role`/`gender` copied from the participant (kept in sync via `Participant#sync_membership_gender`). A unique index on `(associable_type, associable_id, role, gender)` enforces at most one man and one woman per role per company — this 1M/1F staffing template is a deliberate business rule, not an oversight.
- Role-scoped query helpers live on `Participant`: `auxiliar_companies_with_counselors` (coordinador's view), `auxiliar_scope` (auxiliar's AC + its counselors + their companies), `counselor_scope` (consejero's own company). `Authorization#can_edit_company?`/`can_edit_auxiliar_company?` consume these scopes to decide edit access — when changing staffing/permissions logic, both the model scope and the authorization concern usually need to change together.

**Role permission summary:** any authenticated user can view everything; editing always goes record by record through `Authorization` (`can_edit_participant?`, `company_edit_level`, `auxiliar_company_edit_level`), never through a blanket "is admin" check. Full access (`User#full_access?`: superadmin `participant_id.nil?`, `director`, `coordinador`) edits every ficha and every company. `auxiliar`: the jóvenes of the companies in their branch, those companies (data + counselor staffing, but not moving them to another branch), and the name of their own auxiliar company. `consejero`: the jóvenes of their own company, plus its chosen name — nothing else, not its staffing nor its auxiliar company. `director_logistica`: their own committee (`logistica`/`director_logistica` fichas), including registering and deleting them. `registrador`: registers and edits jóvenes. `logistica`: read-only. Everyone may edit their own ficha, minus `rol`/`company_id`/`logistics_area_id`. `ParticipantsController#update` re-checks the scope *after* assigning attributes, so no one can edit a record out of their own reach.

**Inventario** (nav "Inventario", formerly the disabled "Logística" entry): `Inventory` → `InventoryItem` → `InventoryMovement`. Stock is never written by hand — `InventoryItem#adjust!` creates a movement and the movement writes `quantity` back, so the number and the history can't disagree; correct a mistake with the opposite movement. An item's `code` (`MAT-0042`, prefix derived from the inventory name) is both its QR payload and its `to_param`, so `/articulos/MAT-0042` is what a scan resolves to (through `inventory_items#lookup`, which also serves the typed-code form and hand scanners). Camera scanning uses `vendor/javascript/jsqr.js` (Safari has no BarcodeDetector); `rqrcode` renders the on-screen QR (SVG) and the printable label sheet (PNG into Prawn). Everyone in logística adjusts stock and adds items; only full access and the logistics director create or delete whole inventories.

**Reportes:** PDFs are built server-side with Prawn by plain Ruby classes in `app/reports/` — subclass `ApplicationReport` and implement `title`/`build`, which gets the letterhead, footer and table styling for free. `ReportsController` sends them inline so the browser prints them. Bulk participant upload lives in `ParticipantImporter` (`roo`), which maps accent-insensitive Spanish headers onto attributes; add a spelling to `HEADERS` rather than asking anyone to rename a column. Note two pinned gems: `json` stays on 2.x (3.0 breaks `ActiveSupport::JSON.decode`, i.e. every jsonb column) and `roo` must stay ≥ 3.0 (2.x pulls a rubyzip with a path-traversal CVE, and we parse uploaded zips).

**Dashboard:** `DashboardFacade` (`app/facades/dashboard_facade.rb`) aggregates `Participant` class-method counts/groupings (by age, stake, role, gender, shirt size, jovenes vs. staff) for `DashboardsController` — add new KPI aggregations here rather than in the controller or view.

**Frontend:** ViewComponents in `app/components/` (table, avatar, buttons, spans, info tiles) pair `.rb` + `.html.erb`. Stimulus controllers in `app/javascript/controllers/` (avatar fade-in, chart, confirm, dialog, mobile_menu, toast). Charts via ApexCharts (importmap pin, rendered by `chart_controller.js` from `data-chart-*` values; colors must be hex, see `ChartsHelper`), icons via Rails Icons (Lucide).

**Deploy:** Kamal + Docker to an Oracle Cloud Always Free instance (Ampere A1, ARM64, user `ubuntu`) — `config/deploy.yml` reads `ORACLE_SERVER_IP`/`APP_HOST` from the env, kamal-proxy terminates SSL (so `force_ssl` is on), Postgres runs as a Kamal accessory with separate primary/cache/queue/cable databases. Server prep lives in `script/oracle/setup_server.sh`, the runbook in `docs/deploy_oracle.md`.
