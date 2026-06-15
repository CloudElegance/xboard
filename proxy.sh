#!/usr/bin/env bash

set -e

cd /root/xboard-one-click

SERVER_IP=$(curl -s --max-time 5 ipv4.ip.sb || hostname -I | awk '{print $1}')

if [ -f config.txt ]; then
  source config.txt
fi

if [ -z "$XBOARD_PORT" ]; then
  XBOARD_PORT=7001
fi

if [ -z "$NPM_ADMIN_PORT" ]; then
  NPM_ADMIN_PORT=81
fi

read -rp "请输入你的域名，例如 panel.example.com；没有域名可直接回车: " DOMAIN

if [ -z "$DOMAIN" ]; then
  DOMAIN="你的域名"
fi

cat > npm-proxy-template.txt <<EOF
====================================
Nginx Proxy Manager 反代配置
====================================

NPM 管理后台：
http://${SERVER_IP}:${NPM_ADMIN_PORT}

默认账号：
admin@example.com

默认密码：
changeme

登录后请立即修改默认密码。

------------------------------------
一、域名解析
------------------------------------

请先到你的域名 DNS 后台添加 A 记录：

主机记录：${DOMAIN}
记录类型：A
记录值：${SERVER_IP}

如果你的域名是 panel.example.com，
就让 panel.example.com 解析到 ${SERVER_IP}

------------------------------------
二、NPM 添加 Proxy Host
------------------------------------

进入 NPM 后台：

1. Proxy Hosts
2. Add Proxy Host

填写：

Domain Names:
${DOMAIN}

Scheme:
http

Forward Hostname / IP:
xboard

Forward Port:
7001

Cache Assets:
关闭

Block Common Exploits:
开启

Websockets Support:
开启

------------------------------------
三、SSL 证书
------------------------------------

切换到 SSL 页面：

SSL Certificate:
Request a new SSL Certificate

Force SSL:
开启

HTTP/2 Support:
开启

输入邮箱并同意协议，然后保存。

------------------------------------
四、访问地址
------------------------------------

Xboard 前台：
https://${DOMAIN}

Xboard 后台：
请以安装脚本输出的后台安全路径为准。

不要只访问根目录判断后台是否正常。

------------------------------------
五、备用反代参数
------------------------------------

如果 Forward Hostname / IP 填 xboard 无法访问，
可以改成：

Forward Hostname / IP:
${SERVER_IP}

Forward Port:
${XBOARD_PORT}

------------------------------------
六、必须放行的端口
------------------------------------

云服务器安全组 / 防火墙需要放行：

80/tcp
443/tcp
${NPM_ADMIN_PORT}/tcp

如果你还要直接用 IP:${XBOARD_PORT} 访问 Xboard，
也放行：

${XBOARD_PORT}/tcp

反代成功后，Xboard 端口可以不对公网开放，只保留 80/443。
====================================
EOF

cat npm-proxy-template.txt

read -rp "按回车返回菜单..."
