# DEV_CONTEXT.md — Navegación rápida para nuevas sesiones

> Este archivo mantiene el contexto de trabajo para poder continuar en sesiones nuevas de opencode.
> Actualizarlo cada vez que se complete o cambie una tarea.

---

## Estado actual (Última actualización: Ago 2026)

### ⚠️ CAMBIOS PENDIENTES DE COMMIT — working tree con cambios SIN commitear
**IMPORTANTE:** El usuario decidió NO hacer commit hasta haber revisado manualmente los cambios. TODO lo siguiente está en el working tree sin commitear:

```
󱪉 M  Procfile.dev                                    (worker de Solid Queue)
󱪉 M  README.md                                       (documentado setup/deploy/worker)
󱪉 M  app/components/avatar_component.html.erb        (placeholder iniciales + fade-in)
󱪉 M  app/controllers/concerns/authorization.rb       (allowed_participant_attributes)
󱪉 M  app/models/participant.rb                       (thumb preprocessed; se movió allowed_attributes_for)
󱪉 M  app/views/participants/index.html.erb           (usa partial "filters")
󱪉 M  app/views/participants/staff.html.erb           (usa partial "filters")
󱪉 M  config/database.yml                             (BD queue separada en development)
󱪉 M  config/environments/development.rb              (solid_queue adapter + connects_to)
󱪉 M  test/components/avatar_component_test.rb        (tests reales del avatar)
󱪉 D  app/controllers/PagesController.rb              (borrado - dead code)
󱪉 R  app/controllers/{dashboardsController.rb -> dashboards_controller.rb}
󱪉 R  app/controllers/{participantsController.rb -> participants_controller.rb}
󱪉 D  app/views/pages/index.html.erb                  (borrado - dead code)
󱪉 ?? DEV_CONTEXT.md                                  (este archivo, sin trackear aún)
󱪉 ?? app/controllers/dashboards_controller.rb        (nuevo)
󱪉 ?? app/controllers/participants_controller.rb      (nuevo - update simplificado, sin paginación)
󱪉 ?? app/javascript/controllers/avatar_controller.js (nuevo controller Stimulus)
󱪉 ?? app/views/participants/_filters.html.erb        (nuevo - filtros compartidos)
```

> **⚠️ NOTA (reversión):** La paginación con Pagy fue **revertida por decisión del usuario**
> (`git checkout HEAD` en Gemfile, Gemfile.lock, application_controller, application_helper,
> application.css) y se eliminaron `config/initializers/pagy.rb` y `_pagination.html.erb`.
> `index`/`staff` vuelven a asignar `@participants = ...` directamente (con `.includes` N+1
> preservado). No queda ninguna referencia a pagy en `app/`, `config/`, `test/` ni `Gemfile`.

**✔️ N+1 FIX YA APLICADO por el usuario:** `.includes(:avatar_attachment, :avatar_blob)` ya está
en `index` y `staff` de `participants_controller.rb` (verificado en el controller actual).

**Acción pendiente:** decidir cuándo y cómo dividir/agrupar los commits (hay varias tareas mezcladas).

---

## Tareas realizadas (sesión actual)

### ✅ 1. Renombrado de controladores a convención snake_case
- `dashboardsController.rb` → `dashboards_controller.rb`
- `participantsController.rb` → `participants_controller.rb`
- Hecho con `git mv` (preserva historial de git)
- El archivo `PagesController.rb` tenía un mismatch de mayúsculas entre filesystem y git (caso-insensitive en macOS)

### ✅ 2. Eliminación de dead code: `PagesController`
- Confirmado que **NO** está referenciado en `config/routes.rb` ni en ninguna parte.
- `PagesController#index` no usaba autenticación ni tenía ruta.
- Su vista `app/views/pages/index.html.erb` solo contenía el placeholder: `"This is my first app"`.
- Eliminados:
  - `app/controllers/PagesController.rb`
  - `app/views/pages/index.html.erb`

### ✅ 3. Analizado N+1 en la tabla de participantes
- El N+1 real está en el **avatar** dentro de `TableComponent` (via `AvatarComponent`):
  `@participant.avatar.attached?` y `.variant(:thumb)` disparan queries por fila.
- `participant.user` **NO** se usa en la tabla (se descartó incluir ese preload).
- **FIX pendiente (lo aplica el usuario):** agregar `.includes(:avatar_attachment, :avatar_blob)` en `index` y `staff`.

### ✅ 4. Fix del "flash" de avatar (Opción B — infraestructura de Solid Queue)
El avatar se veía vacío y luego cargaba porque la variante `:thumb` se procesaba on-demand
(no era `preprocessed`). Se marcó como preprocesada en background.
Cambios:
- `app/models/participant.rb`: `variant :thumb, ..., preprocessed: true` (antes solo `:preview` lo era)
- `app/components/avatar_component.html.erb`: `width: 40, height: 40` + `object-cover` (reserva espacio, mejora CLS/SEO)
- `config/environments/development.rb`: agregado
  `config.active_job.queue_adapter = :solid_queue` + `config.solid_queue.connects_to = { database: { writing: :queue } }`
- `config/database.yml`: `development` ahora es multi-db con `primary` (BD actual) + `queue`
  (`fsy_management_development_queue`, `migrations_paths: db/queue_migrate`)
- `Procfile.dev`: agregado `worker: bin/rails solid_queue:start`

**Infraestructura ejecutada en local:**
- Creada BD `fsy_management_development_queue`
- Cargado esquema `db/queue_schema.rb` → las 11 tablas `solid_queue_*` existen
- Worker verificado arrancando: supervisor + dispatcher + worker (`bin/rails solid_queue:start`)

**🎁 BONUS:** Antes los emails de reset (`deliver_later`) se procesaban en el adaptador async en memoria.
Ahora con Solid Queue activo en dev, los jobs se encolan/procesan de verdad.

### ✅ 5. Placeholder de iniciales mientras el avatar carga (opción 2)
Tras el preprocess del avatar, al recargar/limpiar cache la imagen tardaba unos ms en cargar
y se veía un espacio vacío con borde. Se implementó un skeleton con las iniciales del participante:
- `app/components/avatar_component.html.erb`: cuando hay avatar, ahora renderiza un contenedor
  `relative` con `data-controller="avatar"` que muestra:
  - las **iniciales** como fondo (absoluto inset-0, reutiliza `initials` + `avatar_colors_for`)
  - la **imagen** superpuesta (absoluto inset-0) con `opacity-0` que se revela al cargar.
- `app/javascript/controllers/avatar_controller.js` (nuevo): controller Stimulus con target `image`
  y acción `load -> loaded` que quita la clase `opacity-0` (`transition-opacity duration-200`).
- Se reutiliza la lógica existente de iniciales y colores del componente Ruby (sin duplicar).
- `test/components/avatar_component_test.rb`: reemplazados los tests scaffold vacíos por 2 tests
  reales (iniciales sin avatar / controller+img+target con avatar).
- Confirmado que las clases Tailwind usadas (`opacity-0`, `transition`, `inset-0`, `absolute`, etc.)
  están presentes en el build (`app/assets/builds/tailwind.css`).

### ⬅️ 6. Paginación con Pagy (máx. 30 por página) — POR FAVOR REVERTIDA
> **REVERTIDA por decisión del usuario.** Se eliminó toda la paginación:
> - Gema `pagy` quitada de `Gemfile`/`Gemfile.lock`.
> - `include Pagy::Backend`/`Pagy::Frontend`, `pagy_nav_styled`, y el CSS `.pagy.nav` revertidos
>   (`git checkout HEAD`).
> - Eliminados `config/initializers/pagy.rb` y `app/views/participants/_pagination.html.erb`.
> - `index`/`staff` vuelven a `@participants = ...` directo (con `.includes` N+1 preservado), y las
>   vistas quitarn `render "pagination"`.
> - Sin referencias a pagy/pagination en `app/`, `config/`, `test/` ni `Gemfile`.

### ✅ 7. Mover `allowed_attributes_for` del modelo al concern `Authorization`
- Eliminado `Participant.allowed_attributes_for(user)` del modelo (ya no está en `Participant`).
- Nuevo método privado `allowed_participant_attributes` en `app/controllers/concerns/authorization.rb`.
- `participant_params` en el controller ahora usa `allowed_participant_attributes`.
- Verificado con grep: sin referencias rotas a `Participant.allowed_attributes_for`.

### ✅ 8. Extraer filtros a un partial compartido
- `app/views/participants/_filters.html.erb` (nuevo): formulario de búsqueda/filtros reutilizable.
  Acepta `form_url:` y `show_role:` (opcional, para mostrar el filtro de rol en staff).
- `index.html.erb` → `render "filters", form_url: participants_path`
- `staff.html.erb` → `render "filters", form_url: staff_participants_path, show_role: true`
- Ambos renderizan además el partial `pagination` dentro del turbo_frame.

### ✅ 9. Simplificar el bloque `update` en `participants_controller.rb`
- Reestructurada la lógica de `redirect_to` manteniendo comportamiento exacto
  (`myprofile` vs. `participant_path` con `target_return` según `params[:from]`).
- Formateado con rubocop (Layout/EndAlignment).

### ✅ 10. Escribir README
- Reemplazado el README boilerplate por documentación real: stack, requisitos, setup local
  (incluye BD de cola y worker), verificación de calidad, modelos, deploy con Kamal y estructura.

---

## Verificación (todo pasa)
- ✅ Boot OK: `bin/rails runner "...Routes: 68"`
- ✅ Rubocop: 69 archivos, 0 ofensas (con `bin/rubocop --no-server`)
- ✅ Tests: `bin/rails test` → 25 runs, 0 failures, 0 errors
  - Incluye 2 tests reales del `AvatarComponent` (antes eran scaffold vacíos).
  - Nota: hay warnings preexistentes "Test is missing assertions" en otros tests scaffold de componentes (info_tile, form, stake_span, role_span, button, table). No están relacionados con nuestros cambios.

---

## Tech stack (resumen)
- **Ruby 4.0.6 + Rails 8.1.3**
- **PostgreSQL** + `pgcrypto` (IDs UUID)
- **Hotwire** (Turbo + Stimulus), Import Maps, **Tailwind CSS** (`tailwindcss-rails`)
- **ViewComponent**, **Chartkick**, **Rails Icons (Lucide)**
- **Solid Cache/Queue/Cable**, Active Storage (UUID) — Solid Queue activo en dev y prod (adaptador de jobs en background)
- Auth a medida: `has_secure_password` + sessions por cookie firmada (`Current`, concern `Authentication`), autorización por rol (concern `Authorization`)
- Deploy: Kamal + Docker, CI/CD GitHub Actions, Brakeman/Bundler-audit/Importmap-audit, Rubocop
- Tests: Minitest + Capybara/Selenium

### Modelos
- `Participant`: enums (rol, stake, ward, shirt_number, genre), columnas jsonb via `store_accessor` (contact_info, person_in_charge, medical_info), avatar con variantes, scopes de filtrado, `allowed_attributes_for(user)` (lógica de permisos de atributos)
- `User`: `has_secure_password`, belongs_to `participant` (opcional), methods `admin_or_staff_manager?`, `counselers_staff?`
- `Session`: belongs_to user

### Controladores (renombrados)
- `dashboards_controller.rb`, `participants_controller.rb`, `passwords_controller.rb`, `sessions_controller.rb`, `application_controller.rb`
- Concerns: `app/controllers/concerns/{authentication,authorization}.rb`
- Facade: `app/facades/dashboard_facade.rb`

### Rutas (config/routes.rb)
- `root "sessions#new"`, `resource :dashboard`, `resources :participants` (con colección staff/myprofile y member send_password_reset), `resource :session`, `resources :passwords`, mount RailsIcons

### Múltiples bases de datos (multidb)
- **Development:** `primary` (fsy_management_development) + `queue` (fsy_management_development_queue). Cache en memoria.
- **Production:** `primary`, `cache`, `queue`, `cable` (BDs separadas).
- Solid Queue activo en dev y prod (`config.active_job.queue_adapter = :solid_queue` + `connects_to`).

---

## 📋 Próximas tareas / mejoras sugeridas (ordenadas)

### ✅ Completadas en esta sesión
- Mover `allowed_attributes_for` al concern, partial de filtros,
  simplificar `update`, escribir README, N+1 (aplicado por el usuario), rename controllers,
  dead code, flash de avatar + Solid Queue, placeholder de iniciales.
- **Paginación (Pagy): implementada y luego REVERTIDA** por decisión del usuario (ver tarea 6).

### 🔨 En cola (descartadas / excluidas — no hacer)
1. ~~Tipado de componentes ViewComponent~~ → **descartado** (over-ingeniería; decisión del usuario).
2. ~~Tests de integración de `ParticipantsController` / concern `Authorization`~~ → **excluidos** por el usuario.

### 🔧 Tareas nuevas / bugs que el usuario mencione
- (agregar aquí)

---

## Comandos útiles
- **Arrancar dev (web + css + worker):** `bin/dev`
  - Requiere el worker para que los avatares `preprocessed` y los emails se procesen.
- Boot manual: `bin/rails server`
- Worker de cola manual: `bin/rails solid_queue:start`
- Tailwind: `bin/rails tailwindcss:watch`
- Tests: `bin/rails test` / system: `bin/rails test:system`
- Lint: `bin/rubocop --no-server`
- Consola: `bin/rails console`
- DB primario: `bin/rails db:prepare` / `db:migrate`
- DB de cola: `bin/rails db:create` y `bin/rails db:schema:load:queue`
- Crear BD de cola para un dev nuevo: `bin/rails db:create` (crea queue) → `bin/rails db:schema:load:queue`
