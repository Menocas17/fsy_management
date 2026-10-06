# Despliegue en Render (+ Neon, Cloudflare R2 y Gmail)

La app corre gratis repartida en cuatro servicios, ninguno pide tarjeta salvo R2 (acepta PayPal):

| Pieza | Servicio | Plan gratis |
|---|---|---|
| App (Puma + Solid Queue) | **Render**, `render.yaml` | 512 MB, 0.1 CPU, se duerme a los 15 min sin visitas |
| Base de datos | **Neon** | 0.5 GB, 100 CU-horas al mes, se duerme a los 5 min y despierta sola |
| Archivos (avatares, etc.) | **Cloudflare R2** | 10 GB |
| Correo (invitaciones, contraseñas) | **Gmail** por un Google Apps Script | unos 100 correos al día |

Por qué así y no todo en Render:

- La Postgres gratis de Render **se borra a los 30 días**. Neon no caduca.
- El disco de Render **se borra en cada deploy y cada vez que se duerme**: los avatares tienen que vivir
  fuera (R2).
- El plan gratis de Render **bloquea los puertos de correo 25, 465 y 587**, así que el SMTP de Gmail no
  sirve, y los SMTP gratis que usan el 2525 piden dominio propio (SMTP2GO, Resend) o verificar un teléfono
  (Brevo). La app manda cada correo **por HTTPS** a un Apps Script de tu Gmail, que lo envía.

## Cómo encaja

- **Una sola base de datos.** Neon da una base; cache, cola y cable viven en esquemas propios
  (`solid_cache`, `solid_queue`, `solid_cable`) dentro de ella. Lo arma `config/database.yml` y la
  tarea `db:create_schemas` (`lib/tasks/db_schemas.rake`), que corre sola antes de `db:prepare`.
- **Un solo proceso.** Solid Queue corre dentro de Puma en modo async (hilos, no procesos): unos
  200 MB en total, cuando en modo fork serían más de 500 y Render lo reiniciaría por memoria.
- **Migraciones al arrancar.** `bin/docker-entrypoint` corre `db:prepare` antes del servidor, así que
  cada deploy aplica las migraciones pendientes; la primera vez crea todas las tablas.
- **CI/CD.** Render despliega `main` solo cuando GitHub Actions pasa completo
  (`autoDeployTrigger: checksPass`). No hay job de deploy en `.github/workflows/ci.yml`: el CI *es*
  la puerta.

## 1. Neon (base de datos)

1. Crea una cuenta en <https://neon.com> (con GitHub sirve) y un proyecto:
   - **Region:** AWS US East 2 (Ohio), la misma que Render en `render.yaml`.
   - **Postgres:** la versión más nueva que ofrezca.
2. En *Branches → main → Computes → Edit*, deja el tamaño en **0.25 CU** como máximo: así las
   100 CU-horas del mes rinden 400 horas encendida.
3. *Connect* → apaga **Connection pooling** y copia la cadena. Tiene que ser la que **no** lleva
   `-pooler` en el host (las migraciones y Solid Queue necesitan conexión directa):

   ```
   postgresql://neondb_owner:...@ep-xxxx.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```

   Esa es `DATABASE_URL`.

## 2. Cloudflare R2 (archivos)

1. Crea una cuenta en <https://dash.cloudflare.com>, entra a **R2 Object Storage** y actívalo. Pide un
   método de pago para verificar (tarjeta o **PayPal**); no cobra mientras no pases de 10 GB.
2. **Create bucket** → nombre `fsy-management`, ubicación *Automatic*.
3. Vuelve a la página principal de **R2 Object Storage** (no la del bucket). A la derecha, en
   **Account details**, está el **Account ID** y, junto a **API Tokens**, el botón **Manage** (en
   algunas cuentas es el menú **API → Manage API tokens**). Ahí: **Create Account API token**:
   - Permisos: **Object Read & Write**.
   - Alcance: **Apply to specific buckets only** → `fsy-management`.
   - TTL: *Forever*. Luego **Create API Token**.
4. La página siguiente muestra (una sola vez) el **Token value**, el **Access Key ID** y el **Secret
   Access Key**. Solo necesitas los dos últimos; cópialos antes de salir. Con el Account ID son
   `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` y `R2_ACCOUNT_ID`. Si cerraste la página sin copiarlos,
   el secreto no se puede volver a ver: borra ese token y crea otro.
5. **Acceso público** (bucket → **Settings → Public access**): conecta un dominio propio (**Custom
   Domains**, si el dominio está en Cloudflare) o activa el **R2.dev subdomain**. La dirección que da
   (`https://pub-….r2.dev` o `https://fotos.tu-dominio`) es `R2_PUBLIC_URL`. Con ella las fotos salen
   directo de Cloudflare en vez de pasar por Rails, que en el plan gratis hacía una petición más por cada
   foto. Las llaves de los archivos son aleatorias y no se pueden adivinar, pero quien tenga un enlace
   puede abrir esa foto. Sin `R2_PUBLIC_URL` la app funciona igual, con enlaces firmados.
   R2.dev tiene límite de velocidad: para el evento conviene el dominio propio.

## 3. Gmail por Apps Script (correo)

El código del script está en `docs/apps_script/mail_relay.gs`. Hazlo con el Gmail del que quieres que
salgan los correos: será el remitente.

1. Genera una clave larga, en tu máquina: `bin/rails secret`. Esa es `MAIL_RELAY_SECRET`.
2. En <https://script.google.com> → **Nuevo proyecto**. Ponle nombre (`FSY correo`), borra lo que trae
   y pega todo `docs/apps_script/mail_relay.gs`. Guarda.
3. **Configuración del proyecto** (el engranaje) → **Propiedades de la secuencia de comandos → Agregar
   propiedad**: nombre `SECRET`, valor la clave del paso 1. Guarda.
4. Vuelve al editor, elige la función `autorizar` arriba y dale **Ejecutar**. Google pide permiso:
   **Revisar permisos** → tu cuenta → sale *Google no verificó esta app* (es tuya, es normal) →
   **Configuración avanzada → Ir a FSY correo (no seguro) → Permitir**.
5. **Implementar → Nueva implementación** → tipo **Aplicación web**:
   - Ejecutar como: **Yo**.
   - Quién tiene acceso: **Cualquier persona** (sin esto Google pide iniciar sesión y la app no entra;
     la clave es lo que impide que otro lo use).
   - **Implementar** y copia la **URL de la aplicación web** (`https://script.google.com/macros/s/…/exec`).
     Esa es `MAIL_RELAY_URL`.

Si algún día cambias el código del script, publícalo en **Implementar → Administrar implementaciones →
editar (lápiz) → Versión: Nueva versión**; así la URL no cambia. Una implementación nueva da otra URL.

El límite es de Google: unos **100 destinatarios al día** con un Gmail normal (1500 con Google
Workspace). Cada cuenta del staff recibe una invitación, y después solo hay correos si alguien olvida la
contraseña. Si te pasas, el correo falla con *Service invoked too many times* en **Logs** de Render y
hay que volver a mandarlo al día siguiente.

### Alternativa: SMTP

Con un dominio propio puedes usar un proveedor SMTP por el puerto 2525 (Brevo, SMTP2GO…) en vez del
Apps Script: quita `MAIL_RELAY_URL` y pon `SMTP_USERNAME`, `SMTP_PASSWORD`, `MAILER_FROM` y, si no es
Brevo, `SMTP_ADDRESS` (ver `config/smtp_mail.rb`). Si el proveedor pide una **IP autorizada**, no pongas
la de Render (en el plan gratis es compartida y cambia): desactiva esa restricción.

## 4. Render (la app)

1. Crea una cuenta en <https://render.com> **con GitHub**, y dale acceso al repo.
2. **New → Blueprint** → elige el repo. Render lee `render.yaml` y te pide las variables marcadas
   `sync: false`:

   | Variable | Valor |
   |---|---|
   | `RAILS_MASTER_KEY` | el contenido de `config/master.key` |
   | `DATABASE_URL` | la cadena de Neon (paso 1) |
   | `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_PUBLIC_URL` | paso 2 |
   | `MAIL_RELAY_URL`, `MAIL_RELAY_SECRET` | paso 3 |
   | `SMTP_USERNAME`, `SMTP_PASSWORD`, `MAILER_FROM` | déjalas vacías (solo para la alternativa SMTP) |

   `R2_BUCKET`, `SOLID_QUEUE_IN_PUMA`, `RAILS_MAX_THREADS` y `HTTP_PORT` ya vienen puestas.
3. **Apply.** El primer build tarda unos minutos. Cuando termina, la app queda en
   `https://fsy-management.onrender.com` (o el nombre que Render le dé; aparece arriba en el panel).
   Los enlaces de los correos usan ese dominio solos (`RENDER_EXTERNAL_HOSTNAME`).

Si el deploy falla, el motivo está en **Logs**. Lo más común: falta una variable de R2 (la app no
arranca sin `R2_BUCKET`) o `DATABASE_URL` es la del pooler.

## 5. Crear el superadmin

En producción `db/seeds.rb` no carga los datos de demo: la base arranca vacía. El plan gratis de
Render no tiene consola, así que el superadmin se crea **desde tu máquina, conectada a Neon**:

```bash
RAILS_ENV=production R2_BUCKET=fsy-management \
DATABASE_URL='postgresql://...la de Neon...' \
bin/rails console
```

```ruby
User.create!(email_address: "tu-correo@dominio.com", password: "Una-Clave-Larga-2026", superadmin: true)
```

Usa `config/master.key` de tu máquina. El aviso `Error retrieving instance profile credentials` es
normal: sin las llaves de R2 no puede tocar archivos, y para esto no hace falta. La contraseña necesita 8 caracteres o más, un número, una
mayúscula y un signo. Esa misma forma de abrir la consola sirve para cualquier arreglo a mano en
producción: con cuidado, es la base real.

## 6. Probar el correo

Desde tu máquina, con las variables del paso 3:

```bash
CORREO_EN_DESARROLLO=1 MAIL_RELAY_URL='https://script.google.com/macros/s/…/exec' MAIL_RELAY_SECRET='...' \
bin/rails 'correo:prueba[tu@correo.com]'
```

En producción los correos salen en segundo plano (Solid Queue): si una invitación no llega, el error
está en **Logs** de Render.

## 7. El día a día: CI/CD

```
rama → PR → CI (brakeman, audits, rubocop, tests) → merge a main → CI en main → Render despliega
```

- Cada push y PR corre `.github/workflows/ci.yml`.
- Al hacer merge a `main`, Render espera a que **todos** los checks del commit pasen y entonces
  construye y despliega. Si algo falla en CI, no se despliega nada.
- **Deploy a mano:** *Manual Deploy → Deploy latest commit* en el panel.
- **Volver atrás:** *Events* → un deploy anterior → *Rollback*. Ojo: no deshace migraciones.
- Para que nadie se salte el CI, en GitHub: *Settings → Branches → Add rule* para `main` con
  *Require status checks to pass*.

## 8. Respaldos

Neon guarda un historial corto para restaurar a un momento anterior (*Restore* en el panel), pero no
reemplaza un respaldo propio. Antes de cada evento, y de vez en cuando:

```bash
pg_dump 'postgresql://...la de Neon...' > backup-$(date +%F).sql
```

`pg_dump` tiene que ser de la misma versión mayor que la Postgres de Neon (o más nueva). Los
archivos de R2 no tienen respaldo automático; se pueden bajar desde el panel de Cloudflare.

### Borrar los datos de prueba antes del evento

Para pasar de los datos de prueba a los reales, desde tu máquina y después del `pg_dump`:

```bash
RAILS_ENV=production R2_BUCKET=fsy-management CONFIRMAR=1 \
DATABASE_URL='postgresql://...la de Neon...' \
bin/rails datos:reiniciar
```

Muestra a qué base está conectada y cuánto va a borrar, y solo sigue si escribes `BORRAR`
(`lib/event_reset.rb`). Borra todas las fichas (con sus cuentas y fotos), compañías, registros, enfermería,
asistencia, alertas, gastos, inventarios, cargas masivas y el historial. Se quedan las cuentas de superadmin
(sin ficha), la configuración, las categorías de gasto, las áreas de logística (vacías), las capacitaciones
y la agenda. Las fotos y facturas se borran de R2 en segundo plano la próxima vez que la app esté despierta.

### Cargar los datos de prueba completos

Para dejar la base como un evento ya armado (para probar o hacer una demo):

```bash
RAILS_ENV=production R2_BUCKET=fsy-management CONFIRMAR=1 \
DATABASE_URL='postgresql://...la de Neon...' \
bin/rails datos:sembrar
```

Primero borra lo mismo que `datos:reiniciar` y luego carga **la foto** `db/seed_data/evento.json`
(`lib/event_snapshot.rb`) tal cual, con los mismos ids: 25 compañías en 5 compañías auxiliares, la dirección,
auxiliares y logística en sus áreas, 50 consejeros, 512 jóvenes en sus compañías y cuartos (algunos con
información médica, alimentaria y emocional), la agenda de los seis días (reemplaza la que haya), inventarios
(Medicamentos y Material de curación son los de enfermería), capacitaciones con asistencia, gastos y
asignaciones. No copia cuentas, sesiones, historial, alertas ni fotos. Las áreas de logística, las categorías
de gasto y las capacitaciones se buscan por nombre (o fecha): se usan las que ya existen y se crean las que
falten (te dice cuáles antes de confirmar). Solo sigue si escribes `SEMBRAR`.

**Cambiar la foto.** Ajusta los datos a mano en tu base local y, cuando queden como quieres:

```bash
bin/rails datos:exportar   # reescribe db/seed_data/evento.json desde la base local
```

Revisa el diff y haz commit. Nunca se exporta desde producción (el repo es público): la tarea se niega.
`bin/rails datos:generar` vuelve a armar todo desde cero con los Excel de `docs/cargas_de_prueba`
(`lib/event_seed.rb`), sin la foto.

## 9. Límites del plan gratis y el campamento

- **Se duerme.** Tras 15 minutos sin visitas, la primera petición tarda ~1 minuto. Durante las
  semanas de uso fuerte se puede mantener despierta con un pinger gratis (p. ej. UptimeRobot cada
  5 minutos a `https://…onrender.com/up`). Las 750 horas gratis al mes alcanzan para tenerla
  despierta todo el mes.
- **Ojo con Neon si la app no se duerme:** mientras la app está despierta, Solid Queue consulta la
  base cada segundo y Neon tampoco se duerme. A 0.25 CU son 6 CU-horas al día, así que las 100 del
  mes dan para **~16 días seguidos** encendida. Usa el pinger solo en las semanas que hace falta;
  si un mes entero va a estar despierta, pasa Neon al plan de pago ese mes.
- **Ancho de banda:** el plan Hobby de Render incluye 5 GB de salida al mes. Los avatares salen
  directo de R2 y no cuentan; las páginas pesan poco (Thruster las comprime).
- **Para el campamento** (p. ej. enero): en el panel de Render, *Settings → Instance Type →
  Starter* (USD 7/mes, 0.5 CPU, no se duerme). Se cobra por segundo, así que se puede subir solo las
  semanas del evento y bajar después a Free. Con 0.1 CPU el plan gratis aguanta, pero cada página
  tarda más cuando hay mucha gente a la vez (registro en la fila, reportes en PDF).

## Dominio propio (opcional)

*Settings → Custom Domains* en Render, apuntar el DNS como indica, y poner `APP_HOST` con ese dominio
en *Environment* para que los enlaces de los correos lo usen.
