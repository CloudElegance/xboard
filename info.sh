#!/usr/bin/env bash

SERVER_IP=$(curl -s --max-time 5 ipv4.ip.sb || hostname -I | awk '{print $1}')

if [ -f /root/xboard-one-click/config.txt ]; then
  source /root/xboard-one-click/config.txt
fi

XBOARD_PORT=${XBOARD_PORT:-7001}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT:-81}

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    🌐 访问地址总览                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "【Xboard 前台】"
echo "http://${SERVER_IP}:${XBOARD_PORT}"
echo ""
echo "【Nginx Proxy Manager 后台】"
echo "http://${SERVER_IP}:${NPM_ADMIN_PORT}"
echo ""
echo "【NPM 默认账号】"
echo "邮箱：admin@example.com"
echo "密码：changeme"
echo ""
echo "────────────────────────────────────────────────────────────"
echo ""
echo "【重要资料】"
echo "菜单输入：8"
echo "可查看 Xboard 后台地址、管理员账号、管理员密码、NPM 账号密码"
echo ""
echo "⚠️  首次登录后请及时修改默认密码"
echo ""

read -rp "按回车返回菜单..."
