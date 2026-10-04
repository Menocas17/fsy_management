# Despliegue en Render (+ Neon, Cloudflare R2 y Brevo)

La app corre gratis repartida en cuatro servicios, ninguno pide tarjeta salvo R2 (acepta PayPal):

| Pieza | Servicio | Plan gratis |
|---|---|---|
| App (Puma + Solid Queue) | **Render**, `render.yaml` | 512 MB, 0.1 CPU, se duerme a los 15 min sin visitas |
| Base de datos | **Neon** | 0.5 GB, 100 CU-horas al mes, se duerme a los 5 min y despierta sola |
| Archivos (avatares, etc.) | **Cloudflare R2** | 10 GB |
| Correo (invitaciones, contraseñas) | **Brevo** | 300 correos al día |

Por qué así y no todo en Render:

- La Postgres gratis de Render **se borra a los 30 días**. Neon no caduca.
- El disco de Render **se borra en cada deploy y cada vez que se duerme**: los avatares tienen que vivir
  fuera (R2).
- El plan gratis de Render **bloquea los puertos de correo 25, 465 y 587**, así que Gmail no sirve.
  Brevo acepta SMTP por el **2525**.

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
2. **Create bucket** → nombre `fsy-management`, ubicación *Automatic*. No lo hagas público: la app
   entrega los archivos con enlaces firmados que caducan solos.
3. **Manage R2 API Tokens → Create API token**:
   - Permisos: **Object Read & Write**.
   - Alcance: solo el bucket `fsy-management`.
4. Al crearlo te muestra (una sola vez) el **Access Key ID** y el **Secret Access Key**. El
   **Account ID** está en la página principal de R2. Esos tres son `R2_ACCESS_KEY_ID`,
   `R2_SECRET_ACCESS_KEY` y `R2_ACCOUNT_ID`.

## 3. Brevo (correo)

1. Crea una cuenta en <https://www.brevo.com> (plan Free).
2. **Senders, domains & IPs → Senders → Add a sender**: el correo que va a aparecer como remitente
   (puede ser un Gmail). Brevo manda un código para verificarlo. Ese correo es `MAILER_FROM`.
3. **SMTP & API → SMTP**:
   - El **Login** (algo como `8a1b2c001@smtp-brevo.com`) es `SMTP_USERNAME`. No es tu correo.
   - **Generate a new SMTP key** → esa clave es `SMTP_PASSWORD`.
4. Puede que Brevo pida completar el perfil de la cuenta antes de dejarte mandar correos
   transaccionales; hazlo de una vez.

> Si el remitente es un `@gmail.com`, algunos correos pueden caer en spam porque salen de servidores
> que no son de Google. Con un dominio propio verificado en Brevo (*Domains*) se arregla.

## 4. Render (la app)

1. Crea una cuenta en <https://render.com> **con GitHub**, y dale acceso al repo.
2. **New → Blueprint** → elige el repo. Render lee `render.yaml` y te pide las variables marcadas
   `sync: false`:

   | Variable | Valor |
   |---|---|
   | `RAILS_MASTER_KEY` | el contenido de `config/master.key` |
   | `DATABASE_URL` | la cadena de Neon (paso 1) |
   | `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` | paso 2 |
   | `SMTP_USERNAME`, `SMTP_PASSWORD`, `MAILER_FROM` | paso 3 |

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

Desde tu máquina, con las variables de Brevo:

```bash
SMTP_EN_DESARROLLO=1 SMTP_USERNAME='...' SMTP_PASSWORD='...' MAILER_FROM='tu@correo.com' \
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
