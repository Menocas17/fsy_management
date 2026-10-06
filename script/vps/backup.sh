#!/usr/bin/env bash
# Respaldo de la base del VPS: pg_dump dentro del propio contenedor de Postgres (así la versión siempre
# coincide) y copia al bucket privado de respaldos en R2. Guarda 7 días en el disco y 30 en R2.
# setup_server.sh lo instala como /usr/local/bin/fsy-backup y lo corre cada noche; se puede correr a mano.
set -euo pipefail

source /etc/fsy-backup.env
if [[ -z "${RCLONE_CONFIG_R2_ACCESS_KEY_ID:-}" ]]; then
  echo "Falta llenar /etc/fsy-backup.env" >&2
  exit 1
fi

dir=/var/backups/fsy
mkdir -p "$dir"
file="$dir/fsy-$(date -u +%Y-%m-%d-%H%M).dump"
# Si pg_dump falla a medias no queda un archivo cortado que parezca un respaldo.
trap 'rm -f "$file.tmp"' EXIT

docker exec fsy_management-db pg_dump -U fsy_management --format=custom fsy_management_production > "$file.tmp"
mv "$file.tmp" "$file"

rclone copy "$file" "r2:$BACKUP_BUCKET/"
find "$dir" -name '*.dump' -mtime +7 -delete
rclone delete "r2:$BACKUP_BUCKET/" --min-age 30d

echo "$(date -u +%FT%TZ) respaldo listo: $(basename "$file") ($(du -h "$file" | cut -f1))"
