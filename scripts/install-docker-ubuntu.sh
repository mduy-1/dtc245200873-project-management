#!/usr/bin/env bash
set -euo pipefail
if [[ $(id -u) -ne 0 ]]; then
  echo 'Run with sudo bash scripts/install-docker-ubuntu.sh' >&2
  exit 1
fi
. /etc/os-release
[[ "$ID" == ubuntu ]] || { echo 'This installer is for Ubuntu only.' >&2; exit 1; }
if command -v docker >/dev/null && dpkg-query -W docker-ce >/dev/null 2>&1; then
  echo 'Docker CE is already installed; keeping the existing version.'
else
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
if [[ $(ps -p 1 -o comm=) == systemd ]]; then
  systemctl enable --now docker
else
  service docker start
fi
docker version
docker compose version
