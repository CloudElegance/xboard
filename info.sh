#!/usr/bin/env bash

SERVER_IP=$(curl -s ipv4.ip.sb || hostname -I | awk '{print $1}')

if [ -f config.txt ]; then
  source config.txt
fi

echo "===================================="
echo "访问地址"
echo "===================================="
echo "Xboard 面板："
echo "http://${SERVER_IP}:${XBOARD_PORT}"
echo ""
echo "Nginx Proxy Manager 后台："
echo "http://${SERVER_IP}:${NPM_ADMIN_PORT}"
echo ""
echo "NPM 默认账号："
echo "Email: admin@example.com"
echo "Password: changeme"
echo ""
echo "请及时修改默认密码"
echo "===================================="

read -rp "按回车返回菜单..."
