#!/usr/bin/env bash

set -e

cd /root/xboard-one-click

while true; do
  clear
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║                  🚀 Xboard 一键管理菜单                   ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  1. 🛠  安装 / 重新配置 Xboard"
  echo "  2. 📊 查看服务状态"
  echo "  3. 🔄 重启服务"
  echo "  4. 🌐 查看访问地址"
  echo "  5. ⬆️  更新脚本"
  echo "  6. 🗑  卸载"
  echo "  7. 📘 查看 NPM 反代填写教程"
  echo "  8. 🔐 查看重要资料 / 账号密码"
  echo "  0. 🚪 退出"
  echo ""
  echo "══════════════════════════════════════════════════════════════"
  read -rp "请输入选项: " choice

  case "$choice" in
    1)
      bash install.sh
      ;;
    2)
      clear
      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║                     📊 服务状态                           ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
      echo ""
      read -rp "按回车返回菜单..."
      ;;
    3)
      docker compose restart || docker-compose restart
      echo ""
      echo "✅ 服务已重启"
      read -rp "按回车返回菜单..."
      ;;
    4)
      bash info.sh
      ;;
    5)
      clear
      echo "正在从 GitHub 强制同步最新脚本..."
      git fetch origin main
      git reset --hard origin/main
      chmod +x *.sh
      ln -sf /root/xboard-one-click/menu.sh /usr/local/bin/xb
      chmod +x /usr/local/bin/xb
      echo ""
      echo "✅ 脚本已更新，请重新输入 xb 打开新菜单"
      echo ""
      read -rp "按回车返回菜单..."
      ;;
    6)
      bash uninstall.sh
      ;;
    7)
      bash proxy.sh
      ;;
    8)
      bash important.sh
      ;;
    0)
      exit 0
      ;;
    *)
      echo "输入错误，请重新输入"
      sleep 1
      ;;
  esac
done
