#!/usr/bin/env bash

INFO_FILE="/root/xboard-one-click/important-info.txt"

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 Xboard 重要资料中心                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -f "$INFO_FILE" ]; then
  echo "暂未找到重要资料文件。"
  echo ""
  echo "请先执行："
  echo "1. 安装 / 重新配置 Xboard"
  echo ""
  read -rp "按回车返回菜单..."
  exit 0
fi

cat "$INFO_FILE"

echo ""
echo "⚠️  安全提醒："
echo "1. 首次登录后请立刻修改 Xboard 管理员密码"
echo "2. 首次登录 NPM 后请立刻修改默认密码"
echo "3. 不要把 important-info.txt 发给别人"
echo ""

read -rp "按回车返回菜单..."
