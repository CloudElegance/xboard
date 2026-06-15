#!/usr/bin/env bash

set -e

cd /root/xboard-one-click

echo "开始安装 Xboard..."

if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

read -rp "请输入 Xboard 对外端口，例如 7001，直接回车默认 7001: " XBOARD_PORT
read -rp "请输入 NPM 管理后台端口，例如 81，直接回车默认 81: " NPM_ADMIN_PORT
read -rp "请输入 Xboard 管理员邮箱，例如 admin@demo.com，直接回车默认 admin@demo.com: " ADMIN_EMAIL

XBOARD_PORT=${XBOARD_PORT:-7001}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT:-81}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@demo.com}

echo "Xboard 端口: $XBOARD_PORT"
echo "NPM 管理端口: $NPM_ADMIN_PORT"
echo "Xboard 管理员邮箱: $ADMIN_EMAIL"

echo "正在安装 Docker..."

if ! command -v docker >/dev/null 2>&1; then
  apt update
  apt install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://get.docker.com | bash
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose 插件未检测到，请检查 Docker 安装"
  exit 1
fi

echo "正在准备 Xboard 数据目录..."

mkdir -p .docker/.data
mkdir -p storage/logs
mkdir -p storage/theme
mkdir -p plugins

if [ ! -f .env ]; then
  touch .env
fi

cat > docker-compose.yml <<EOF
services:
  xboard:
    image: ghcr.io/cedar2025/xboard:latest
    container_name: xboard
    restart: unless-stopped
    ports:
      - "${XBOARD_PORT}:7001"
    volumes:
      - ./.env:/www/.env
      - ./.docker/.data/:/www/.docker/.data
      - ./storage/logs:/www/storage/logs
      - ./storage/theme:/www/storage/theme
      - ./plugins:/www/plugins
      - redis-data:/data
    environment:
      - RESOURCE_PROFILE=minimal
      - ENABLE_HORIZON=true
      - docker=true

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

volumes:
  redis-data:
EOF

cat > config.txt <<EOF
XBOARD_PORT=${XBOARD_PORT}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT}
ADMIN_EMAIL=${ADMIN_EMAIL}
EOF

echo "正在停止旧容器..."
docker compose down || true

echo "正在初始化 Xboard..."

if grep -q "^APP_KEY=" .env && [ -s .env ]; then
  echo "检测到已有 .env，跳过 xboard:install 初始化。"
  echo "如果你想重新初始化，请先备份并删除 /root/xboard-one-click/.env"
else
  docker compose run -it --rm \
    -e ENABLE_SQLITE=true \
    -e ENABLE_REDIS=true \
    -e ADMIN_ACCOUNT="${ADMIN_EMAIL}" \
    xboard php artisan xboard:install
fi

echo "正在启动服务..."
docker compose up -d

echo "正在尝试放行防火墙端口..."
bash firewall.sh "$XBOARD_PORT" "$NPM_ADMIN_PORT" || true

echo "安装完成"
echo ""
echo "请访问："
echo "Xboard: http://服务器IP:${XBOARD_PORT}"
echo "NPM: http://服务器IP:${NPM_ADMIN_PORT}"
echo ""
echo "NPM 默认账号：admin@example.com"
echo "NPM 默认密码：changeme"
echo ""
echo "Xboard 后台地址和密码请看上面 xboard:install 输出。"
echo ""

bash info.sh
