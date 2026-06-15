#!/usr/bin/env bash

set -e

REPO_URL="https://github.com/CloudElegance/xboard.git"
INSTALL_DIR="/root/xboard-one-click"

echo "正在准备 Xboard 一键安装脚本..."

if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "正在安装 git..."
  apt update
  apt install -y git
fi

if [ -d "$INSTALL_DIR/.git" ]; then
  echo "检测到已有目录，正在更新..."
  cd "$INSTALL_DIR"
  git pull
else
  echo "正在拉取项目..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

chmod +x *.sh

echo "正在安装快捷命令 xb..."
ln -sf "$INSTALL_DIR/menu.sh" /usr/local/bin/xb
chmod +x /usr/local/bin/xb

echo "准备完成，正在启动菜单..."
bash "$INSTALL_DIR/menu.sh"
