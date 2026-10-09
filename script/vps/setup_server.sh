#!/usr/bin/env bash
# Prepara un droplet nuevo de DigitalOcean (Ubuntu 24.04) para recibir el despliegue de Kamal.
# Es idempotente: se puede volver a correr. Guía completa en docs/deploy_vps.md.
#
# Uso, desde tu máquina:
#   scp script/vps/setup_server.sh script/vps/backup.sh root@<IP>:~
#   ssh root@<IP> 'bash ~/setup_server.sh'
#
# Qué hace:
#   1. Crea el usuario deploy (Kamal no entra como root) con las mismas llaves SSH que root.
#   2. Instala Docker y deja a deploy usarlo.
#   3. Firewall: solo SSH, 80 y 443.
#   4. Un swap de 2 GB: el colchón para los picos de memoria (fotos, migraciones).
#   5. Actualizaciones de seguridad automáticas.
#   6. El respaldo diario de la base a R2 (backup.sh), que queda listo en cuanto se llene /etc/fsy-backup.env.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Correr como root" >&2
  exit 1
fi

DEPLOY_USER=deploy
export DEBIAN_FRONTEND=noninteractive

echo "==> Paquetes base"
apt-get update -qq
apt-get install -y -qq ca-certificates curl ufw unattended-upgrades rclone

echo "==> Docker"
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi
systemctl enable --now docker

echo "==> Usuario $DEPLOY_USER"
if ! id "$DEPLOY_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$DEPLOY_USER"
fi
usermod -aG docker "$DEPLOY_USER"
install -d -m 700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh"
install -m 600 -o "$DEPLOY_USER" -g "$DEPLOY_USER" /root/.ssh/authorized_keys "/home/$DEPLOY_USER/.ssh/authorized_keys"

echo "==> Firewall"
ufw allow OpenSSH >/dev/null
ufw allow 80/tcp >/dev/null
ufw allow 443/tcp >/dev/null
ufw --force enable >/dev/null

echo "==> Swap"
if ! swapon --show | grep -q /swapfile; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile >/dev/null
  swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi
# Que use el swap solo cuando de verdad falte memoria.
echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf
sysctl -q -p /etc/sysctl.d/99-swappiness.conf

echo "==> Actualizaciones de seguridad automáticas"
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "==> Respaldo diario"
if [[ -f ~/backup.sh ]]; then
  install -m 755 ~/backup.sh /usr/local/bin/fsy-backup
fi
if [[ ! -f /etc/fsy-backup.env ]]; then
  cat > /etc/fsy-backup.env <<'ENV'
# Credenciales del bucket PRIVADO de respaldos (no el de fotos, que es público). Ver docs/deploy_vps.md.
export RCLONE_CONFIG_R2_TYPE=s3
export RCLONE_CONFIG_R2_PROVIDER=Cloudflare
export RCLONE_CONFIG_R2_NO_CHECK_BUCKET=true
export RCLONE_CONFIG_R2_ENDPOINT=https://CUENTA.r2.cloudflarestorage.com
export RCLONE_CONFIG_R2_ACCESS_KEY_ID=
export RCLONE_CONFIG_R2_SECRET_ACCESS_KEY=
export BACKUP_BUCKET=fsy-management-respaldos
ENV
  chmod 600 /etc/fsy-backup.env
fi
# A las 3:00 de Nicaragua (UTC-6).
echo '0 9 * * * root /usr/local/bin/fsy-backup >> /var/log/fsy-backup.log 2>&1' > /etc/cron.d/fsy-backup

echo
echo "Listo. Falta llenar /etc/fsy-backup.env con las llaves del bucket de respaldos."
echo "Comprueba el acceso de Kamal con: ssh $DEPLOY_USER@<IP> docker ps"
