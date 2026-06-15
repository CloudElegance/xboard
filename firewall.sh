#!/usr/bin/env bash

XBOARD_PORT="$1"
NPM_ADMIN_PORT="$2"

echo "正在尝试放行本机防火墙端口..."

PORTS="80 443 $XBOARD_PORT $NPM_ADMIN_PORT"

if command -v ufw >/dev/null 2>&1; then
  for p in $PORTS; do
    ufw allow "$p/tcp" || true
  done
fi

if command -v firewall-cmd >/dev/null 2>&1; then
  for p in $PORTS; do
    firewall-cmd --permanent --add-port="$p/tcp" || true
  done
  firewall-cmd --reload || true
fi

echo "本机防火墙处理完成"
echo "重要：云服务器后台安全组也要手动放行这些端口：$PORTS"
