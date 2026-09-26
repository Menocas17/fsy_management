# FSY Management

Aplicación web para la gestión de participantes de un **FSY (For the Strength of Youth)** — jóvenes y staff — incluyendo registro, perfiles, información médica/contacto, asignación de estacas/barrios/cuartos y un dashboard con métricas.

Construida con **Ruby on Rails 8** + **Hotwire** (Turbo + Stimulus) + **Tailwind CSS** + **ViewComponent**.

## Stack

| Capa | Tecnología |
|------|-----------|
| Lenguaje / Framework | Ruby 4.0.6 / Rails 8.1.3 |
| Base de datos | PostgreSQL (`pgcrypto`, IDs UUID) |
| Frontend | Hotwire (Turbo + Stimulus), Import Maps, Tailwind CSS v4 |
| Componentes | ViewComponent |
| Iconos / Gráficos | Rails Icons (Lucide), Chartkick |
| Jobs en background | Solid Queue (BD de cola separada) |
| Cache / Cable | Solid Cache / Solid Cable (prod), memoria (dev) |
| Autenticación | `has_secure_password` + sesiones por cookie firmada (concern `Authentication`) |
| Autorización | concern `Authorization` (por rol) |
| Deploy | Kamal + Docker, CI/CD GitHub Actions |
| Tests | Minitest + Capybara/Selenium |

## Requisitos

- **Ruby 4.0.6** (ver `.ruby-version`)
- **PostgreSQL** en ejecución
- Bundler

## Puesta en marcha (desarrollo)

**1. Instalar dependencias:**
```bash
bundle install
```

**2. Crear y preparar las bases de datos** (incluye la BD primaria y la de cola de Solid Queue):
```bash
bin/rails db:prepare
bin/rails db:schema:load:queue   # carga el esquema de Solid Queue (11 tablas)
```
> Si el segundo comando falla por que no existe la BD de cola, primero: `bin/rails db:create`.

**3. Arrancar el servidor + Tailwind + worker de cola:**
```bash
bin/dev
```
> `bin/dev` levanta `web` (rails server), `css` (Tailwind watch) y `worker` (Solid Queue).
> El worker es **necesario** para que los avatares `preprocessed` (miniaturas) y los emails en
> background (`deliver_later`) se procesen.

Comandos manuales alternativos:
```bash
bin/rails server               # solo web
bin/rails solid_queue:start    # solo worker de cola
bin/rails tailwindcss:watch    # solo Tailwind
```

## Verificación de calidad

```bash
bin/rails test                 # suite de tests
bin/rails test:system          # tests de sistema (Capybara/Selenium)
bin/rubocop --no-server        # lint (Rails Omakase)
```

## Modelos principales

- **Participant** — joven o personal; enums para `rol`, `stake` (estaca), `ward` (barrio), `shirt_number` (talla), `gender` (género); columnas `jsonb` vía `store_accessor` (contacto, responsable, médico) y avatar con variantes (`thumb`/`preview`, preprocesadas). Pertenece a una `Company` opcional y participa en `memberships`.
- **Company / AuxiliarCompany** — estructura jerárquica: una `AuxiliarCompany` está supervisada por un `Coordinator` (rol del participante) y agrupa *N* `Company` estándar. Cada `Company` pertence a su `AuxiliarCompany` (`auxiliar_company_id`) y se cubre con consejeros/auxiliares.
- **Membership** — unión polimórfica (`associable`: `Company` o `AuxiliarCompany`) entre una compañía y un `Participant`. Guarda `role` (derivado de `participant.rol`) y `gender` (copia de `participant.gender`); el índice único `(associable_type, associable_id, role, gender)` impide más de un hombre y una mujer por rol/compañía.
- **User** — cuenta con `has_secure_password`, vinculada a un `Participant` (opcional). Roles derivados del participante.
- **Session** — sesión persistente por usuario.

## Secciones de gestión

- **`/companies`** (CompaniesController) — listado de compañías estándar agrupadas por AC (+ "sin compañía auxiliar"), detalle con plantilla 1M/1F de consejeros/auxiliares y jóvenes, CRUD y panel de asignación de personal (`assign_staff`/`remove_staff`).
- **`/auxiliar_companies`** (AuxiliarCompaniesController) — CRUD de auxiliar companies y asignación de su coordinador.
- **`/companies/overview`** (KPIs) — cards + Chartkick (jóvenes y personal por compañía) y tabla de estado Completa/Incompleta.
- **Autorización por rol:** cualquier usuario autenticado ve; **editan** superadmin, `coordinador` y `director` (todo); `auxiliar` su AC y las compañías de sus consejeros; `consejero` su propia compañía; `logistica`/`registrador` solo lectura.

## Deploy (Kamal)

Se usa **Kamal** + GitHub Actions para desplegar a un VPS. La configuración está en `config/deploy.yml`.

- **BD en producción:** PostgreSQL como accessory de Kamal (`postgres:18`), con BDs separadas: primaria, cache, queue y cable.
- **Jobs:** Solid Queue corre dentro del proceso de Puma (`SOLID_QUEUE_IN_PUMA: true`), por lo que no requiere un contenedor de workers dedicado.
- El pipeline de CI (`scan_ruby`, `scan_js`, `lint`, `test`, `system-test`) debe pasar antes de desplegar.

## Estructura relevante

```
app/components/            # ViewComponents (tabla, avatar, botones, spans, info tiles)
app/controllers/concerns/  # Authentication + Authorization (+ allowed_participant_attributes)
app/facades/dashboard_facade.rb  # lógica del dashboard
app/javascript/controllers/      # Stimulus (avatar, confirm, dialog, mobile_menu, toast...)
config/deploy.yml          # despliegue Kamal
Procfile.dev               # web + css + worker para desarrollo
```
