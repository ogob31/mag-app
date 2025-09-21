#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y docker.io git curl
systemctl enable --now docker

# Let 'ubuntu' use docker without sudo
usermod -aG docker ubuntu

# Optional: small swap helps on tiny VMs
if ! grep -q '/swapfile' /etc/fstab; then
  fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi
