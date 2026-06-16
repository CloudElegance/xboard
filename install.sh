#!/usr/bin/env bash

set -e

cd /root/xboard-one-click

clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 Xboard 一键安装程序                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

read -rp "请输入 Xboard 对外端口，直接回车默认 7001: " XBOARD_PORT
read -rp "请输入 NPM 管理后台端口，直接回车默认 81: " NPM_ADMIN_PORT
read -rp "请输入 Xboard 管理员邮箱，直接回车默认 admin@demo.com: " ADMIN_EMAIL

XBOARD_PORT=${XBOARD_PORT:-7001}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT:-81}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@demo.com}

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    安装参数确认                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "Xboard 端口：${XBOARD_PORT}"
echo "NPM 管理端口：${NPM_ADMIN_PORT}"
echo "管理员邮箱：${ADMIN_EMAIL}"
echo ""

echo "正在检查 Docker..."

if ! command -v docker >/dev/null 2>&1; then
  echo "未检测到 Docker，正在安装..."
  apt update
  apt install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://get.docker.com | bash
else
  echo "Docker 已安装，跳过安装。"
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose 插件未检测到，请检查 Docker 安装"
  exit 1
fi

echo ""
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

echo ""
echo "正在停止旧容器..."
docker compose down || true

INSTALL_LOG="/root/xboard-one-click/install-output.log"
IMPORTANT_FILE="/root/xboard-one-click/important-info.txt"

echo ""
echo "正在初始化 Xboard..."

if grep -q "^APP_KEY=" .env && [ -s .env ]; then
  echo "检测到已有 .env，跳过 xboard:install 初始化。"
  echo "如果你想重新初始化，请先备份并删除：/root/xboard-one-click/.env"
else
  docker compose run -it --rm \
    -e ENABLE_SQLITE=true \
    -e ENABLE_REDIS=true \
    -e ADMIN_ACCOUNT="${ADMIN_EMAIL}" \
    xboard php artisan xboard:install | tee "$INSTALL_LOG"
fi

echo ""
echo "正在启动服务..."
docker compose up -d

sleep 5

SERVER_IP=$(curl -s --max-time 5 ipv4.ip.sb || hostname -I | awk '{print $1}')

XBOARD_ADMIN_EMAIL=""
XBOARD_ADMIN_PASSWORD=""
XBOARD_ADMIN_PATH=""

if [ -f "$INSTALL_LOG" ]; then
  XBOARD_ADMIN_EMAIL=$(grep -oP '管理员邮箱：\K.*' "$INSTALL_LOG" | tail -n 1 || true)
  XBOARD_ADMIN_PASSWORD=$(grep -oP '管理员密码：\K.*' "$INSTALL_LOG" | tail -n 1 || true)
  XBOARD_ADMIN_PATH=$(grep -oP '访问 http\(s\)://你的站点/\K[^ ]+' "$INSTALL_LOG" | tail -n 1 || true)
fi

if [ -z "$XBOARD_ADMIN_EMAIL" ]; then
  XBOARD_ADMIN_EMAIL="${ADMIN_EMAIL}"
fi

if [ -z "$XBOARD_ADMIN_PASSWORD" ]; then
  XBOARD_ADMIN_PASSWORD="已有安装，无法重新显示初始密码，请在 Xboard 后台修改"
fi

if [ -z "$XBOARD_ADMIN_PATH" ]; then
  XBOARD_ADMIN_PATH="请查看安装时输出的后台安全路径"
fi

cat > "$IMPORTANT_FILE" <<EOF
╔════════════════════════════════════════════════════════════╗
║                    🎉 安装成功                            ║
║                 Xboard 重要资料卡片                       ║
╚════════════════════════════════════════════════════════════╝

【Xboard 前台】
http://${SERVER_IP}:${XBOARD_PORT}

【Xboard 后台】
http://${SERVER_IP}:${XBOARD_PORT}/${XBOARD_ADMIN_PATH}

【Xboard 管理员账号】
邮箱：${XBOARD_ADMIN_EMAIL}
密码：${XBOARD_ADMIN_PASSWORD}

────────────────────────────────────────────────────────────

【Nginx Proxy Manager 后台】
http://${SERVER_IP}:${NPM_ADMIN_PORT}

【NPM 默认账号】
邮箱：admin@example.com
密码：changeme

────────────────────────────────────────────────────────────

【端口信息】
Xboard 对外端口：${XBOARD_PORT}
NPM 管理端口：${NPM_ADMIN_PORT}
HTTP：80
HTTPS：443

【防火墙需要放行】
80/tcp
443/tcp
${XBOARD_PORT}/tcp
${NPM_ADMIN_PORT}/tcp

────────────────────────────────────────────────────────────

【安全提醒】
1. 首次登录 Xboard 后，立刻修改管理员密码
2. 首次登录 NPM 后，立刻修改默认密码
3. 反代成功后，可以关闭 Xboard 直连端口 ${XBOARD_PORT}
4. 不要把这个文件发给别人

【查看方式】
菜单输入：8
或者执行：
cat /root/xboard-one-click/important-info.txt
EOF

chmod 600 "$IMPORTANT_FILE"

echo ""
echo "正在尝试放行防火墙端口..."
bash firewall.sh "$XBOARD_PORT" "$NPM_ADMIN_PORT" || true

clear
cat "$IMPORTANT_FILE"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    服务状态                                ║"
echo "╚════════════════════════════════════════════════════════════╝"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "安装完成。"
echo ""
read -rp "按回车返回菜单..."
