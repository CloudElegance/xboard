#!/usr/bin/env bash

set -e

cd /root/xboard-one-click

SERVER_IP=$(curl -s --max-time 5 ipv4.ip.sb || hostname -I | awk '{print $1}')

if [ -f config.txt ]; then
  source config.txt
fi

XBOARD_PORT=${XBOARD_PORT:-7001}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT:-81}

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              📘 NPM 反代填写教程                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "说明："
echo "这里不是自动配置反代，只是生成一份填写教程。"
echo "真正添加反代，需要进入 Nginx Proxy Manager 后台手动填写。"
echo ""

read -rp "请输入你的域名，例如 new.xzys.me；没有域名可直接回车: " DOMAIN

if [ -z "$DOMAIN" ]; then
  DOMAIN="你的域名"
fi

cat > npm-proxy-template.txt <<EOF
╔════════════════════════════════════════════════════════════╗
║              📘 Nginx Proxy Manager 反代填写教程           ║
╚════════════════════════════════════════════════════════════╝

【一、NPM 后台地址】

Nginx Proxy Manager 后台：
http://${SERVER_IP}:${NPM_ADMIN_PORT}

首次登录默认账号：

邮箱：admin@example.com
密码：changeme

⚠️  注意：
NPM 第一次登录后，可能会让你填写姓名、邮箱、新密码。
这不是公开注册，而是初始化管理员账号。
修改完成后，以后就用你新设置的邮箱和密码登录。

────────────────────────────────────────────────────────────

【二、域名 DNS 解析】

你准备绑定的域名：

${DOMAIN}

请到域名 DNS 后台添加 A 记录。

如果你的域名是 new.xzys.me，
通常这样填：

类型：A
主机记录：new
记录值：${SERVER_IP}

如果 DNS 面板要求填写完整域名，则填：

主机记录：${DOMAIN}
记录值：${SERVER_IP}

⚠️  如果使用 Cloudflare：
请先设置为 DNS only，也就是灰色云朵。
不要一开始就开橙色云朵。

────────────────────────────────────────────────────────────

【三、NPM 添加代理服务】

进入 NPM 后台：

1. 点击：主机列表
2. 点击：代理服务
3. 点击：添加代理服务

在【详情】页面这样填写：

域名：
${DOMAIN}

协议：
http

转发主机名 / IP：
xboard

转发端口：
7001

通信规则：
公开可访问

下面选项建议：

缓存资源：关闭
阻止常见攻击：开启
Websockets 支持：开启

然后先不要申请 SSL。

────────────────────────────────────────────────────────────

【四、第一次保存时 SSL 怎么选】

第一次添加代理服务，建议 SSL 页面先这样：

SSL 证书：
无

强制 SSL：
关闭

HTTP/2 支持：
关闭

HSTS：
关闭

HSTS 子域名：
关闭

使用 DNS 验证：
关闭

然后点保存。

保存成功后，先测试：

http://${DOMAIN}

如果这个地址能打开 Xboard，再回来申请 SSL。

────────────────────────────────────────────────────────────

【五、HTTP 能打开后，再申请 SSL】

确认下面这个地址能正常打开后：

http://${DOMAIN}

再回到 NPM 编辑这个代理服务，进入 SSL 页面：

SSL 证书：
申请新证书

强制 SSL：
开启

HTTP/2 支持：
开启

HSTS：
首次配置建议关闭

HSTS 子域名：
关闭

使用 DNS 验证：
关闭

然后填写邮箱，勾选同意协议，保存。

成功后访问：

https://${DOMAIN}

────────────────────────────────────────────────────────────

【六、Xboard 后台地址说明】

Xboard 前台一般是：

https://${DOMAIN}

但是 Xboard 后台不是根目录。

后台地址类似：

https://${DOMAIN}/安全路径

安全路径请在菜单输入：

8

查看“重要资料 / 账号密码”。

或者查看：

cat /root/xboard-one-click/important-info.txt

────────────────────────────────────────────────────────────

【七、如果保存代理服务报错】

如果 NPM 保存代理服务报错，先检查：

1. Xboard 是否正常：
   http://${SERVER_IP}:${XBOARD_PORT}

2. Xboard 容器是否运行：
   docker ps -a

3. 反代主机名是否填对：
   xboard

4. 反代端口是否填对：
   7001

如果填 xboard 不通，可以改成备用方案：

转发主机名 / IP：
${SERVER_IP}

转发端口：
${XBOARD_PORT}

────────────────────────────────────────────────────────────

【八、如果 SSL 申请失败】

SSL 申请失败通常不是 Xboard 问题，而是以下原因：

1. 域名没有解析到服务器 IP
2. 80/tcp 没放行
3. 443/tcp 没放行
4. Cloudflare 开了橙色云朵
5. NPM 里没有填写邮箱或没有同意协议
6. HTTP 都还打不开，就直接申请 SSL

排查命令：

ping ${DOMAIN}

curl -I http://${DOMAIN}

ss -ltnp | grep -E ':(80|443|${NPM_ADMIN_PORT}|${XBOARD_PORT})\\b'

docker logs --tail=100 nginx-proxy-manager

────────────────────────────────────────────────────────────

【九、服务器需要放行的端口】

云服务器安全组 / 防火墙需要放行：

80/tcp
443/tcp
${NPM_ADMIN_PORT}/tcp
${XBOARD_PORT}/tcp

说明：

80：HTTP 证书验证和网页访问
443：HTTPS 访问
${NPM_ADMIN_PORT}：NPM 管理后台
${XBOARD_PORT}：Xboard 直连访问

反代成功后，如果只通过域名访问 Xboard，
可以关闭 Xboard 直连端口 ${XBOARD_PORT}，
只保留 80、443、${NPM_ADMIN_PORT}。

────────────────────────────────────────────────────────────

【十、推荐配置总结】

详情页面：

域名：${DOMAIN}
协议：http
转发主机名 / IP：xboard
转发端口：7001
缓存资源：关闭
阻止常见攻击：开启
Websockets 支持：开启

SSL 页面第一次：

SSL 证书：无
强制 SSL：关闭
HTTP/2：关闭

HTTP 测试成功后：

SSL 证书：申请新证书
强制 SSL：开启
HTTP/2：开启
HSTS：关闭

╔════════════════════════════════════════════════════════════╗
║                  ✅ 教程生成完成                          ║
╚════════════════════════════════════════════════════════════╝
EOF

cat npm-proxy-template.txt

echo ""
echo "教程已保存到："
echo "/root/xboard-one-click/npm-proxy-template.txt"
echo ""

read -rp "按回车返回菜单..."
