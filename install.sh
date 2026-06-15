#!/usr/bin/env bash

set -e

echo "开始安装 Xboard..."

if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

read -rp "请输入 Xboard 对外端口，例如 7001: " XBOARD_PORT
read -rp "请输入 NPM 管理后台端口，例如 81: " NPM_ADMIN_PORT

if [ -z "$XBOARD_PORT" ]; then
  XBOARD_PORT=7001
fi

if [ -z "$NPM_ADMIN_PORT" ]; then
  NPM_ADMIN_PORT=81
fi

echo "Xboard 端口: $XBOARD_PORT"
echo "NPM 管理端口: $NPM_ADMIN_PORT"

echo "正在安装 Docker..."

if ! command -v docker >/dev/null 2>&1; then
  apt update
  apt install -y ca-certificates curl gnupg lsb-release

  curl -fsSL https://get.docker.com | bash
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose 插件未检测到，请检查 Docker 安装"
fi

cat > docker-compose.yml <<EOF
services:
  xboard:
    image: ghcr.io/cedar2025/xboard:latest
    container_name: xboard
    restart: always
    ports:
      - "${XBOARD_PORT}:7001"
    volumes:
      - ./xboard-data:/www

  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: always
    ports:
      - "80:80"
      - "443:443"
      - "${NPM_ADMIN_PORT}:81"
    volumes:
      - ./npm-data:/data
      - ./npm-letsencrypt:/etc/letsencrypt
EOF

echo "正在启动服务..."
docker compose up -d

cat > config.txt <<EOF
XBOARD_PORT=${XBOARD_PORT}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT}
EOF

bash firewall.sh "$XBOARD_PORT" "$NPM_ADMIN_PORT"

echo "安装完成"
bash info.sh
