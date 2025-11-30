#!/bin/bash
# 1. Redirigir logs para depuración
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- 1. Iniciando actualización del sistema (CRÍTICO) ---"
sleep 20
apt-get update
apt-get upgrade -y
apt-get install -y git curl

echo "--- 2. Instalando Docker y Docker Compose ---"
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl start docker
systemctl enable docker

echo "--- 3. Configurando SWAP (2GB) ---"
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
echo "vm.swappiness=10" >> /etc/sysctl.conf
sysctl -p

echo "--- 4. Preparación de carpetas ---"
mkdir -p /home/ubuntu/odoo18-l10n-spain
chown -R ubuntu:ubuntu /home/ubuntu/odoo18-l10n-spain

echo "--- Configuración completada ---"