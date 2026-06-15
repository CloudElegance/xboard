#!/usr/bin/env bash

set -e

cd /root/xboard-one-click

while true; do
  clear
  echo "===================================="
  echo "        Xboard 一键管理菜单"
  echo "===================================="
  echo "1. 安装 / 重新配置 Xboard"
  echo "2. 查看服务状态"
  echo "3. 重启服务"
  echo "4. 查看访问地址"
  echo "5. 更新脚本"
  echo "6. 卸载"
  echo "0. 退出"
  echo "===================================="
  read -rp "请输入选项: " choice

  case "$choice" in
    1)
      bash install.sh
      ;;
    2)
      docker ps
      read -rp "按回车返回菜单..."
      ;;
    3)
      docker compose restart || docker-compose restart
      read -rp "按回车返回菜单..."
      ;;
    4)
      bash info.sh
      ;;
    5)
      git pull
      chmod +x *.sh
      echo "更新完成"
      read -rp "按回车返回菜单..."
      ;;
    6)
      bash uninstall.sh
      ;;
    0)
      exit 0
      ;;
    *)
      echo "输入错误"
      sleep 1
      ;;
  esac
done
