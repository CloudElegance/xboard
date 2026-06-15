#!/usr/bin/env bash

set -e

read -rp "确定要卸载吗？输入 yes/y 继续: " confirm

confirm="${confirm,,}"

case "$confirm" in
  yes|y)
    echo "开始卸载..."
    ;;
  *)
    echo "已取消"
    exit 0
    ;;
esac

docker compose down || docker-compose down

read -rp "是否删除数据？输入 yes/y 删除数据: " deldata

deldata="${deldata,,}"

case "$deldata" in
  yes|y)
    rm -rf xboard-data npm-data npm-letsencrypt config.txt docker-compose.yml
    echo "数据已删除"
    ;;
  *)
    echo "已保留数据"
    ;;
esac

echo "卸载完成"
read -rp "按回车返回菜单..."
