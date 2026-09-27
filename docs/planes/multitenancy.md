# Plan: varias conferencias (multitenancy)

> Estado: **en planificación, sin implementar**. Faltan las decisiones de la sección final.

Objetivo: que cada sesión de la conferencia (FSY 2027, FSY 2028…) tenga su propio nombre, logo y
fechas editables, y que se puedan crear sesiones nuevas, cada una con su propia base de datos.

## Viabilidad

Alta (~85–90 %) sin reescribir la app: 20 tablas con UUID, un solo `Current` para el contexto de la
petición y pocas cosas del evento regadas por el código. El riesgo está en los jobs, Active Storage y
la resolución de la conferencia, no en el volumen de trabajo.

## Lo que hoy está fijo a "FSY 2027 Managua-Caribe"

| Qué | Dónde |
|---|---|
| Fechas, hora de inicio y capacitaciones | `config/initializers/fsy_event.rb` |
| Nombre en los PDF | `ApplicationReport::EVENT` |
| Nombre y región en vistas | `shared/_event_banner`, `shared/_auth_screen`, `shared/_brand`, `dashboards/show`, `dashboards/_next_up`, `pwa/manifest.json.erb` |
| Logos | `fsy-mark.png`, `fsy-lettering.png`, `fsy-logo.svg` |
| Zona horaria | `config/application.rb` (`America/Managua`) |
| Estacas y barrios | enums en `Participant` (específicos de la región) |

Hoy conviven "FSY 2026" y "FSY 2027" en distintos textos; centralizarlo lo corrige.

## Opciones

1. **Una base de datos por conferencia** (sharding nativo de Rails 8) + base de "catálogo" con las
   conferencias. Aislamiento total; respaldar, archivar o borrar un año es una base. Crear una
   conferencia pide reiniciar la app (aceptable: se crean 1–2 por año). **Recomendada.**
2. **Un esquema de Postgres por conferencia** (`ros-apartment`). Sin reinicio, pero todo en una base y
   con una gem de terceros con fricción en Rails 8.
3. **Columna `conference_id` en cada tabla** (`acts_as_tenant`). Lo más simple y permite reportes
   entre años, pero no hay aislamiento real: un `where` olvidado mezcla conferencias.

## Puntos delicados

- **Resolución de la conferencia:** por subdominio obliga a redeploy por cada una (certificados de
  kamal-proxy); por ruta (`/c/fsy-2027/...`) o eligiéndola al iniciar sesión, no. Recomendado: ruta o
  selector.
- **Jobs** (`PushNotificationJob`, `deliver_later`): cada job debe llevar su conferencia y conectarse a
  esa base al ejecutarse.
- **Active Storage:** los blobs viven en cada base; los archivos, en disco compartido. Las URLs de
  `/rails/active_storage` también deben resolver la conferencia.
- **Action Cable** (`turbo_stream_from Current.user`): la conexión necesita la conferencia.
- **Usuarios:** globales o por conferencia (pendiente de decidir).

## Fases

| Fase | Contenido | Valor por sí sola |
|---|---|---|
| 0. Evento configurable | Modelo de ajustes/`Conference` con nombre, región, logo, fechas, capacitaciones y zona horaria; reemplaza constantes y textos fijos; pantalla para editarlo. | Sí: resuelve nombre, logo y fechas. |
| 1. Estacas y barrios como tablas | Migrar enums conservando datos; filtros, formularios, importador y reportes. | Sí, si habrá otras regiones. |
| 2. Catálogo y cambio de base | Base de catálogo, una base por conferencia, `around_action` de conexión; jobs, Cable y Active Storage. | Núcleo. |
| 3. Crear conferencia | Crear base, cargar esquema, sembrar, registrar y reiniciar. `db:migrate` corre en todas. | — |
| 4. Pruebas y deploy | Tests de aislamiento; Kamal y respaldos. | — |

Tiempo estimado: el código sale en 2–4 días de trabajo con Claude; con revisión por fase, pruebas con
datos reales y el deploy, 1–2 semanas de calendario. La fase 0 conviene hacerla primero aunque no se
siga con el resto.

## Decisiones pendientes

1. ¿Cuenta de usuario única para todos los años, o una por conferencia?
2. ¿Las conferencias serán de la misma región, o cambian estacas y barrios?
3. ¿Subdominio, ruta o selector al iniciar sesión?
4. ¿Se necesitan reportes que comparen años? (si sí, pesa más la opción 3)
