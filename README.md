# Xboard 一键安装和管理菜单

一个用于快速部署 **Xboard + Nginx Proxy Manager** 的一键脚本。

支持：

* 一键安装 / 重新配置 Xboard
* 自动安装 Docker
* 自动部署 Nginx Proxy Manager
* 自动生成 Xboard 管理员账号信息
* 自动生成重要资料卡片
* 查看服务状态
* 重启服务
* 查看访问地址
* 查看 NPM 反代填写教程
* 卸载并可选择是否删除数据

---

## 快速开始

> 支持系统：Debian / Ubuntu
> 建议使用 root 用户执行

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/CloudElegance/xboard/main/bootstrap.sh)
```

执行后会自动进入管理菜单。

---

## 管理菜单

安装完成后，可以随时输入：

```bash
xb
```

打开管理菜单：

```text
1. 安装 / 重新配置 Xboard
2. 查看服务状态
3. 重启服务
4. 查看访问地址
5. 更新脚本
6. 卸载
7. 查看 NPM 反代填写教程
8. 查看重要资料 / 账号密码
0. 退出
```

---

## 安装时需要输入

安装过程中会提示输入：

```text
Xboard 对外端口
NPM 管理后台端口
Xboard 管理员邮箱
```

如果直接回车，会使用默认值：

```text
Xboard 对外端口：7001
NPM 管理后台端口：81
Xboard 管理员邮箱：admin@demo.com
```

---

## 安装完成后

安装完成后会显示重要资料卡片，包括：

```text
Xboard 前台地址
Xboard 后台地址
Xboard 管理员邮箱
Xboard 管理员密码
Nginx Proxy Manager 后台地址
NPM 默认账号
NPM 默认密码
需要放行的端口
```

也可以在菜单中输入：

```text
8
```

查看重要资料。

重要资料文件保存在：

```bash
/root/xboard-one-click/important-info.txt
```

---

## 默认访问地址

假设服务器 IP 是：

```text
你的服务器IP
```

默认访问地址为：

```text
Xboard：
http://你的服务器IP:7001

Nginx Proxy Manager：
http://你的服务器IP:81
```

NPM 默认账号：

```text
邮箱：admin@example.com
密码：changeme
```

首次登录后请立即修改默认密码。

---

## 反向代理说明

菜单输入：

```text
7
```

可以查看 Nginx Proxy Manager 反代填写教程。

常用配置如下：

```text
Domain Names:
你的域名

Scheme:
http

Forward Hostname / IP:
xboard

Forward Port:
7001

Websockets Support:
开启

Block Common Exploits:
开启
```

SSL 页面建议：

```text
SSL Certificate:
Request a new SSL Certificate

Force SSL:
开启

HTTP/2 Support:
开启

HSTS:
首次配置建议关闭
```

---

## 需要放行的端口

服务器防火墙 / 云平台安全组需要放行：

```text
80/tcp
443/tcp
81/tcp
7001/tcp
```

说明：

```text
80：HTTP
443：HTTPS
81：NPM 管理后台
7001：Xboard 面板
```

反代成功后，如果只通过域名访问 Xboard，可以关闭 Xboard 直连端口，只保留：

```text
80/tcp
443/tcp
81/tcp
```

---

## 常见问题

### 1. NPM 后台打不开

先检查容器：

```bash
docker ps -a
```

再检查端口：

```bash
ss -ltnp | grep -E ':(80|81|443|7001)\b'
```

如果 80 端口被 OpenResty / Nginx / Apache 占用，需要先停止占用程序。

---

### 2. Xboard 打开 502

查看日志：

```bash
docker logs --tail=100 xboard
```

如果出现：

```text
No application encryption key has been specified
```

说明 Xboard 没有完成初始化，需要重新执行安装。

---

### 3. SSL 申请失败

请先确认：

```text
域名已经解析到服务器 IP
80 和 443 端口已经放行
Cloudflare 暂时关闭橙色云朵，使用 DNS only
NPM 里已经填写邮箱并同意协议
```

建议先确认 HTTP 可以访问，再申请 SSL。

---

## 更新脚本

菜单输入：

```text
5
```

即可从 GitHub 同步最新脚本。

也可以重新执行一键命令：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/CloudElegance/xboard/main/bootstrap.sh)
```

---

## 卸载

菜单输入：

```text
6
```

卸载时会提示是否删除数据。

输入：

```text
y
```

或：

```text
yes
```

表示确认。

---

## 安全提醒

* 不要公开 `important-info.txt`
* 不要把真实后台地址和密码写入 README
* 首次登录 Xboard 后请立即修改管理员密码
* 首次登录 NPM 后请立即修改默认密码
* 仓库公开时，不要提交 `.env`、数据库文件、日志文件和证书文件

---

## 相关项目

* Xboard
* Nginx Proxy Manager
* Docker
