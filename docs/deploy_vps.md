# Despliegue en un VPS de DigitalOcean (Kamal)

La app y su Postgres en un mismo droplet, desplegados con [Kamal](https://kamal-deploy.org). Se empieza con el
de 6 dólares al mes (1 vCPU, 1 GB) y se agranda para el evento con una variable (`DROPLET_SIZE`, ver «Cambiar
de tamaño»). Reemplaza a Render + Neon (`docs/deploy_render.md`); las fotos siguen
en Cloudflare R2 y el correo sigue saliendo por el Apps Script de Gmail.

| Pieza | Dónde |
|-------|-------|
| App (Rails + Solid Queue dentro de Puma) | Contenedor en el droplet, detrás de kamal-proxy (SSL automático con Let's Encrypt) |
| Base de datos | Contenedor `postgres:18` en el mismo droplet (`fsy_management-db`), datos en `/home/deploy/fsy_management-db/data` |
| Fotos y facturas | Cloudflare R2, bucket `fsy-management` (público, como hoy) |
| Respaldos de la base | Cloudflare R2, bucket **privado** `fsy-management-respaldos`, cada noche a las 3:00 |
| Correo | Apps Script de Gmail (DigitalOcean también bloquea SMTP en cuentas nuevas) |
| Deploy | GitHub Actions: al pasar el CI en `main`, el job `deploy` construye la imagen y corre `kamal deploy` |

Archivos: `config/deploy.yml`, `.kamal/secrets`, `script/vps/setup_server.sh`, `script/vps/backup.sh` y el job
`deploy` de `.github/workflows/ci.yml`.

## 1. Crear el droplet

En DigitalOcean → **Create → Droplets**:

- **Región:** Atlanta si aparece (es la más cercana a Centroamérica); si no, Nueva York. Cada petición
  viaja hasta allá y de vuelta: la región no se puede cambiar después sin migrar.
- **Imagen:** Ubuntu 24.04 (LTS) x64.
- **Tamaño:** Basic → Regular → **1 GB / 1 CPU / 25 GB** (`s-1vcpu-1gb`, 6 dólares). Es el que
  `config/deploy.yml` usa si no le dices otro. Para el evento se agranda sin reinstalar nada («Cambiar de
  tamaño»).
- **Autenticación:** *SSH Key* (agrega la llave pública de tu máquina). Sin contraseña.
- Marca **Monitoring** (gratis): gráficas de CPU, memoria y disco en el panel.

Anota la IP pública.

## 2. El dominio

`APP_HOST` es el dominio con el que se entra a la app; Let's Encrypt necesita que apunte a la IP del droplet
**antes** del primer deploy.

- Con dominio propio: un registro **A** de `fsy.tudominio.com` → la IP.
- Sin dominio: `<ip-con-guiones>.sslip.io` funciona solo (para `164.90.1.2` es `164-90-1-2.sslip.io`).

Es otra dirección que la de Render: quien tenga la app instalada en el teléfono tiene que abrir la nueva e
instalarla de nuevo.

## 3. Preparar el servidor

Desde la carpeta del proyecto:

```bash
scp script/vps/setup_server.sh script/vps/backup.sh root@<IP>:~
ssh root@<IP> 'bash ~/setup_server.sh'
ssh deploy@<IP> docker ps     # debe responder sin error
```

Crea el usuario `deploy` (el que usa Kamal), instala Docker, abre solo SSH/80/443 en el firewall, crea 2 GB
de swap, activa las actualizaciones de seguridad automáticas e instala el respaldo diario.

## 4. Bucket privado para los respaldos

El bucket de las fotos es **público** (`R2_PUBLIC_URL`): un respaldo ahí lo podría bajar cualquiera que
adivine el nombre del archivo, con datos médicos dentro. Los respaldos van a otro bucket:

1. Cloudflare → R2 → **Create bucket** → `fsy-management-respaldos`. **No** le actives acceso público.
2. R2 → **Manage API tokens → Create API token** → permiso *Object Read & Write*, limitado a ese bucket.
3. En el servidor, llena las llaves:

   ```bash
   ssh root@<IP> nano /etc/fsy-backup.env     # endpoint con tu Account ID, access key y secret
   ssh root@<IP> fsy-backup                   # prueba a mano (fallará hasta que exista la base: paso 8)
   ```

Se guardan 7 días en el disco del droplet y 30 en R2. El registro queda en `/var/log/fsy-backup.log`.

## 4b. CORS del bucket de fotos (subida directa)

Las fotos de perfil se suben desde el teléfono directo al bucket `fsy-management`
(`avatar_preview_controller.js`, `DirectUploadsController`), sin pasar por el servidor. Para que el navegador
pueda hacerlo, el bucket tiene que aceptar subidas desde el dominio de la app: Cloudflare → R2 →
`fsy-management` → **Settings → CORS Policy → Edit**:

```json
[
  {
    "AllowedOrigins": ["https://<APP_HOST>"],
    "AllowedMethods": ["PUT"],
    "AllowedHeaders": ["Content-Type", "Content-MD5", "Content-Disposition"],
    "MaxAgeSeconds": 3600
  }
]
```

Mientras Render siga en uso, agrega también su dirección (`https://….onrender.com`) a `AllowedOrigins`. Sin
esta regla no se rompe nada: la subida directa falla y la foto viaja con el formulario como antes, solo que
pasando por el servidor. Para comprobarlo, al elegir una foto en una ficha debe aparecer «Subiendo foto… %» y
luego «Foto lista».

## 5. Llave SSH para GitHub Actions

Una llave solo para desplegar, sin contraseña:

```bash
ssh-keygen -t ed25519 -f fsy_deploy -N "" -C "github-actions"
ssh root@<IP> "cat >> /home/deploy/.ssh/authorized_keys" < fsy_deploy.pub
```

`fsy_deploy` (la privada) va al secret `SSH_PRIVATE_KEY` del paso 6; después bórrala de tu máquina.

## 6. Secrets y variables en GitHub

En el repositorio → **Settings → Secrets and variables → Actions**.

**Secrets:**

| Nombre | Valor |
|--------|-------|
| `SSH_PRIVATE_KEY` | El contenido de `fsy_deploy` (paso 5) |
| `RAILS_MASTER_KEY` | El contenido de `config/master.key` |
| `POSTGRES_PASSWORD` | `openssl rand -hex 32` (solo letras y números: va dentro de una URL). Guárdala también en tu gestor de contraseñas |
| `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_PUBLIC_URL` | Los mismos que tiene hoy Render |
| `MAIL_RELAY_URL`, `MAIL_RELAY_SECRET` | Los mismos que tiene hoy Render |

**Variables** (pestaña *Variables*):

| Nombre | Valor |
|--------|-------|
| `SERVER_IP` | La IP del droplet |
| `APP_HOST` | El dominio del paso 2 |
| `DROPLET_SIZE` | El tamaño del droplet: `s-1vcpu-1gb` (o sin la variable) para el de 6 dólares, `s-4vcpu-8gb` para el de 48 |
| `KAMAL_DEPLOY` | `true`, **recién en el paso 9**. Mientras no exista, el job `deploy` se salta y el CI sigue en verde |

## 7. Levantar Postgres (una vez, desde tu máquina)

Kamal también necesita los secretos en tu terminal. `KAMAL_REGISTRY_PASSWORD` es un token personal de GitHub
(Settings → Developer settings → Personal access tokens → *classic*, con `read:packages` y `write:packages`).

```bash
export SERVER_IP=<IP> APP_HOST=<dominio> DROPLET_SIZE=s-1vcpu-1gb
export KAMAL_REGISTRY_PASSWORD=<token de GitHub>
export RAILS_MASTER_KEY=$(cat config/master.key)
export POSTGRES_PASSWORD=<la del paso 6>
export R2_ACCOUNT_ID=... R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=... R2_PUBLIC_URL=...
export MAIL_RELAY_URL=... MAIL_RELAY_SECRET=...

bin/kamal accessory boot db
```

## 8. Pasar los datos de Neon

Con la app en Render apagada, para que nadie escriba en Neon mientras se copia (mejor de noche):

1. Render → el servicio → **Settings → Suspend Web Service**.
2. En el droplet, con el `pg_dump` de la imagen `postgres:18` (así no importa qué versión tengas en tu máquina):

   ```bash
   ssh deploy@<IP>
   docker run --rm postgres:18 pg_dump --format=custom --no-owner --no-acl \
     'postgresql://...la de Neon...' > neon.dump
   docker exec -i fsy_management-db pg_restore -U fsy_management -d fsy_management_production \
     --no-owner --no-acl < neon.dump
   ```

   Si `pg_restore` se queja de alguna extensión propia de Neon, se puede ignorar. Lo que importa es que las
   cuentas coincidan:

   ```bash
   docker exec fsy_management-db psql -U fsy_management -d fsy_management_production \
     -c "select count(*) from participants" -c "select count(*) from users"
   ```

3. Prueba el respaldo: `ssh root@<IP> fsy-backup` debe terminar con «respaldo listo».

## 9. Primer deploy

1. En GitHub crea la variable `KAMAL_DEPLOY` = `true`.
2. **Actions → CI → Run workflow** sobre `main`. Corren las pruebas y, si pasan, el job `deploy`: construye la
   imagen, la sube a ghcr.io, arranca kamal-proxy (que saca el certificado) y la app, que corre
   `db:prepare` al arrancar (con los datos ya restaurados, no hace nada).
3. Entra a `https://<APP_HOST>`, inicia sesión y revisa fichas, fotos y un escaneo.

Desde aquí, cada merge a `main` se despliega solo cuando el CI pasa, igual que con Render.

**Si algo sale mal:** Render → **Resume Web Service**. Neon no se tocó, así que todo vuelve a como estaba.

Cuando el VPS lleve unos días bien: borra el servicio de Render y, después de otro respaldo, el proyecto de
Neon.

## Día a día

Con las variables del paso 7 exportadas:

```bash
bin/kamal logs                      # logs en vivo
bin/kamal console                   # consola de Rails en producción
bin/kamal app exec --interactive --reuse "bash -c 'CONFIRMAR=1 bin/rails datos:reiniciar'"
ssh deploy@<IP> 'free -m; docker stats --no-stream'   # memoria y CPU de cada contenedor
bin/kamal rollback <versión>        # volver a una imagen anterior (bin/kamal app containers las lista)
```

Las tareas que con Render corrían desde tu máquina contra Neon (crear un superadmin, `datos:reiniciar`) ahora
corren así, dentro del contenedor.

## Prueba de carga

`script/carga/` mide el droplet desde otra máquina: cada pantalla por separado y 650 usuarios a la vez. Cómo
correrla y los números de referencia están en `script/carga/README.md`. Conviene hacerla con el droplet ya
desplegado y antes del evento; y no desplegar el lunes en la mañana: un servidor recién arrancado responde
más lento sus primeros minutos.

## Restaurar un respaldo

```bash
ssh root@<IP>
source /etc/fsy-backup.env && rclone ls r2:$BACKUP_BUCKET   # elige uno
rclone copy r2:$BACKUP_BUCKET/fsy-AAAA-MM-DD-HHMM.dump .
```

Desde tu máquina, `bin/kamal app stop`. En el droplet:

```bash
docker exec fsy_management-db dropdb -U fsy_management fsy_management_production
docker exec fsy_management-db createdb -U fsy_management fsy_management_production
docker exec -i fsy_management-db pg_restore -U fsy_management -d fsy_management_production \
  --no-owner --no-acl < fsy-AAAA-MM-DD-HHMM.dump
```

Y `bin/kamal app boot`.

## Cambiar de tamaño

`config/deploy.yml` tiene una tabla de tamaños; `DROPLET_SIZE` dice cuál usar y de ahí salen los procesos de
Puma, las fotos que se procesan a la vez y la memoria de Postgres:

| `DROPLET_SIZE` | Droplet | Procesos de Puma | Fotos a la vez | `shared_buffers` / `effective_cache_size` | `max_connections` |
|----------------|---------|------------------|----------------|-------------------------------------------|-------------------|
| `s-1vcpu-1gb` (sin la variable) | 6 dólares, 1 vCPU, 1 GB | 1 (sin maestro) | 1 | 128MB / 512MB | 60 |
| `s-2vcpu-4gb` | 24 dólares, 2 vCPU, 4 GB | 2 | 2 | 1GB / 2560MB | 100 |
| `s-4vcpu-8gb` | 48 dólares, 4 vCPU, 8 GB | 4 | 3 | 2GB / 5GB | 150 |

Cada proceso de Puma usa un núcleo (Ruby ejecuta de a un hilo por proceso) y ~300-400 MB. Para el lunes del
evento, el de **4 vCPU / 8 GB**: con él la prueba de carga atendió a 650 personas con p95 de ~0,3 s
(`script/carga/README.md`). Más RAM no lo haría más rápido, lo que limita es la CPU.

**Para subir** (por ejemplo el viernes antes del evento):

1. DigitalOcean → el droplet → **Resize** → **CPU and RAM only** (no agrandes el disco: así se puede volver a
   bajar al de 6) → `s-4vcpu-8gb`. Apaga el droplet 1-2 minutos; Postgres y la app vuelven solos.
2. En GitHub, la variable `DROPLET_SIZE` = `s-4vcpu-8gb`.
3. Desde tu máquina, con las variables del paso 7 y `DROPLET_SIZE=s-4vcpu-8gb`:

   ```bash
   bin/kamal accessory reboot db   # Postgres toma la memoria nueva (se reinicia unos segundos)
   bin/kamal deploy                # la app arranca con 4 procesos
   ```

**Para bajar** (después del evento), al revés: primero la variable `DROPLET_SIZE` = `s-1vcpu-1gb`,
`bin/kamal accessory reboot db` y `bin/kamal deploy`, y **después** el Resize al de 6 dólares. Si se achica
primero, la app y Postgres arrancarían pidiendo más memoria de la que hay.

No cambies de tamaño el día del evento: un servidor recién arrancado responde más lento sus primeros minutos.

## Memoria

**1 GB:** sistema ~150 MB, Postgres ~250 MB, la app (un solo proceso con la cola de trabajos) ~400 MB y
~150 MB más mientras procesa una foto. Mientras Kamal cambia de contenedor hay dos apps unos segundos: el swap
de 2 GB lo absorbe. Alcanza para probar y para pocas personas a la vez, no para el lunes.

**8 GB:** sistema ~200 MB, Postgres ~2.5 GB, los cuatro procesos de Puma ~1.5 GB, el proceso principal (con
la cola de trabajos) ~400 MB y hasta ~300 MB más con tres fotos a la vez. Lo que sobra lo usa el sistema como
caché de disco para Postgres.

El panel de DigitalOcean (Monitoring) muestra memoria y CPU en vivo.
