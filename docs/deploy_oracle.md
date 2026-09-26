# Despliegue en Oracle Cloud Free Tier

La app se despliega con **Kamal** (Docker) a una sola instancia "Always Free" de Oracle Cloud
(OCI). En esa misma máquina corren el contenedor de la app (Puma + Thruster + Solid Queue),
`kamal-proxy` (SSL con Let's Encrypt) y Postgres como accesorio.

## 1. Crear la instancia

En la consola de OCI → *Compute → Instances → Create instance*:

- **Image:** Canonical Ubuntu 24.04 (o 22.04).
- **Shape:** `VM.Standard.A1.Flex` (Ampere, ARM64). El free tier incluye hasta 4 OCPU y 24 GB
  en total; 2 OCPU / 12 GB es más que suficiente. Si sale "Out of capacity", reintentar más tarde
  o en otro *availability domain*.
  - La `VM.Standard.E2.1.Micro` (AMD, 1 GB) también es gratis, pero se queda corta para
    Rails + Postgres. Si igual se usa, cambiar `builder.arch` a `amd64` en `config/deploy.yml`.
- **Networking:** VCN con subred pública y *Assign a public IPv4 address*.
- **SSH keys:** subir tu llave pública.
- **Boot volume:** el free tier da hasta 200 GB en total; 50–100 GB alcanzan.

Recomendado: en *Networking → IP administration* convertir la IP en **Reserved public IP**
(gratis) para que no cambie si la instancia se recrea.

## 2. Abrir puertos en la VCN

*Networking → Virtual cloud networks → (tu VCN) → Security Lists → Default* → *Add Ingress Rules*:

| Source CIDR | Protocolo | Puerto destino |
|-------------|-----------|----------------|
| `0.0.0.0/0` | TCP       | 80             |
| `0.0.0.0/0` | TCP       | 443            |

(El 22 ya viene abierto.) **No** abrir el 5432: Postgres solo escucha en `127.0.0.1`.

## 3. Preparar el servidor

Las imágenes de Oracle traen además un firewall `iptables` propio que rechaza todo salvo SSH.
El script lo abre, instala Docker, agrega a `ubuntu` al grupo `docker`, crea swap y activa
actualizaciones de seguridad:

```bash
scp script/oracle/setup_server.sh ubuntu@<IP>:~
ssh ubuntu@<IP> 'sudo bash ~/setup_server.sh'
ssh ubuntu@<IP> docker ps   # debe responder sin sudo
```

## 4. Dominio

`kamal-proxy` necesita un nombre de host para pedir el certificado SSL:

- Con dominio propio: registro `A` → IP de la instancia.
- Sin dominio: usar `sslip.io`, p. ej. para `129.146.10.20` → `129-146-10-20.sslip.io`
  (no requiere configurar nada).

## 5. Variables en tu máquina

`config/deploy.yml` y `.kamal/secrets` leen estas variables (no se versionan):

```bash
export ORACLE_SERVER_IP=129.146.10.20
export APP_HOST=fsy.midominio.com            # o 129-146-10-20.sslip.io
export KAMAL_REGISTRY_PASSWORD=ghp_xxx       # token de GitHub con write:packages (ghcr.io)
export POSTGRES_PASSWORD='una-contraseña-larga'
# RAILS_MASTER_KEY se lee de config/master.key
```

Sugerencia: guardarlas en un `.env.oracle` (ya ignorado por git) y cargarlas con
`set -a; source .env.oracle; set +a`.

## 6. Primer despliegue

```bash
bin/kamal setup      # instala kamal-proxy, levanta Postgres, construye y despliega la app
```

La imagen es ARM64. Si tu máquina es x86, Kamal la construye en el propio servidor por SSH
(`builder.remote`), que es mucho más rápido que emular con QEMU. En un Mac con Apple Silicon
se construye localmente.

Al arrancar, `bin/docker-entrypoint` corre `db:prepare`, que crea las bases `primary`, `cache`,
`queue` y `cable` y carga sus esquemas.

Despliegues siguientes: `bin/kamal deploy`. Útiles: `bin/kamal logs`, `bin/kamal console`,
`bin/kamal dbc`.

## 7. Respaldos

Todo vive en el boot volume de la instancia (Postgres en `~/fsy_management-db/data`, archivos
subidos en el volumen Docker `fsy_management_storage`). Oracle no respalda nada por defecto:

- **Boot volume backups** desde la consola de OCI (el free tier incluye 5 respaldos), o
- un dump manual:

  ```bash
  ssh ubuntu@<IP> 'docker exec fsy_management-db pg_dump -U fsy_management fsy_management_production' \
    > backup-$(date +%F).sql
  ```

## Notas sobre el free tier

- Oracle puede **reclamar instancias "idle"** (CPU, red y memoria por debajo del 20 % durante
  7 días) en cuentas Always Free. Pasar la cuenta a *Pay As You Go* evita el reclamo y sigue sin
  costo mientras se usen solo recursos Always Free.
- El tráfico de salida gratuito es de 10 TB/mes.
