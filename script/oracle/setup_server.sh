#!/usr/bin/env bash
# Prepara una instancia nueva de Oracle Cloud (Ubuntu 22.04/24.04, Ampere A1)
# para recibir el despliegue de Kamal. Es idempotente: se puede correr de nuevo.
#
# Uso (desde tu máquina):
#   scp script/oracle/setup_server.sh ubuntu@<IP>:~
#   ssh ubuntu@<IP> 'sudo bash ~/setup_server.sh'
#
# Qué hace:
#   1. Abre 80/443 en el iptables de la instancia (las imágenes de Oracle traen un
#      REJECT para todo salvo SSH, aunque la Security List de la VCN esté abierta).
#   2. Instala Docker y agrega al usuario de SSH al grupo docker (Kamal no usa root).
#   3. Crea un swapfile de 2 GB (colchón para assets:precompile y picos de memoria).
#   4. Activa las actualizaciones de seguridad automáticas.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecutar con sudo" >&2
  exit 1
fi

DEPLOY_USER="${SUDO_USER:-ubuntu}"

echo "==> Paquetes base"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq ca-certificates curl iptables-persistent unattended-upgrades

echo "==> Firewall de la instancia: abrir 80 y 443"
# Se hace antes de instalar Docker para que netfilter-persistent no guarde sus reglas.
for port in 80 443; do
  if ! iptables -C INPUT -p tcp -m state --state NEW --dport "$port" -j ACCEPT 2>/dev/null; then
    reject_line=$(iptables -L INPUT --line-numbers -n | awk '/REJECT/ {print $1; exit}')
    if [[ -n "$reject_line" ]]; then
      iptables -I INPUT "$reject_line" -p tcp -m state --state NEW --dport "$port" -j ACCEPT
    else
      iptables -A INPUT -p tcp -m state --state NEW --dport "$port" -j ACCEPT
    fi
  fi
done
if ! command -v docker >/dev/null; then
  netfilter-persistent save
fi

echo "==> Docker"
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi
systemctl enable --now docker
usermod -aG docker "$DEPLOY_USER"

echo "==> Swap"
if ! swapon --show | grep -q /swapfile; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "==> Actualizaciones de seguridad automáticas"
dpkg-reconfigure -f noninteractive unattended-upgrades

echo
echo "Listo. Cierra la sesión SSH y vuelve a entrar para que '$DEPLOY_USER' tome el grupo docker."
echo "Comprueba con: ssh $DEPLOY_USER@<IP> docker ps"
