#!/usr/bin/env bash

read -rp "确定要卸载吗？输入 yes 继续: " confirm

if [ "$confirm" != "yes" ]; then
  echo "已取消"
  exit 0
fi

docker compose down || docker-compose down

read -rp "是否删除数据？输入 yes 删除数据: " deldata

if [ "$deldata" = "yes" ]; then
  rm -rf xboard-data npm-data npm-letsencrypt config.txt docker-compose.yml
  echo "数据已删除"
else
  echo "已保留数据"
fi

echo "卸载完成"
read -rp "按回车返回菜单..."
