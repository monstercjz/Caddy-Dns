
# Custom Caddy with DNS & Homelab Plugins

[![Build](https://github.com/monstercjz/Caddy-Dns/actions/workflows/build.yml/badge.svg)](https://github.com/monstercjz/Caddy-Dns/actions/workflows/build.yml)
[![GitHub Release](https://img.shields.io/github/v/release/monstercjz/Caddy-Dns?label=Latest%20Binary)](https://github.com/monstercjz/Caddy-Dns/releases)
[![GHCR Image](https://img.shields.io/badge/Container-GHCR-blue?logo=docker)](https://github.com/monstercjz/Caddy-Dns/pkgs/container/caddy)

基于官方最新版 Caddy，通过 **GitHub Actions** 全自动编译打包的定制化 Caddy。

- ⚡ **100% 开源纯粹**：纯云端透明构建，无后门、零第三方依赖篡改。
- 📦 **双模产物输出**：
  - **Linux 纯静态可执行文件**（发布在 Releases，极度轻量，适用于 Alpine / Debian LXC 容器）
  - **多架构 Docker 镜像**（发布在 GHCR，支持 `linux/amd64` 与 `linux/arm64`）

---

## 🧩 内置插件清单

| 插件名称 | 说明 | 适用场景 |
| :--- | :--- | :--- |
| **[caddy-dns/tencentcloud](https://github.com/caddy-dns/tencentcloud)** | 腾讯云 DNS-01 验证 | 自动签发内网 `*.xxxxx.xyz` 泛域名证书 |
| **[caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)** | Cloudflare DNS 验证 | 以后扩展 CF 托管的域名 |
| **[caddy-dns/alidns](https://github.com/caddy-dns/alidns)** | 阿里云 DNS 验证 | 阿里云域名证书申请 |
| **[caddy-webdav](https://github.com/mholt/caddy-webdav)** | 极简 WebDAV 服务端 | 手机/车机/Obsidian 笔记与文件同步 |
| **[cache-handler](https://github.com/caddyserver/cache-handler)** | HTTP 响应边缘缓存 | 自建前后端网站（如 sitebox）静态与 API 缓存加速 |
| **[replace-response](https://github.com/caddyserver/replace-response)** | 网页响应实时内容重写 | 修复内网反代网页中的写死绝对链接或被墙外链 |
| **[caddy-maxmind-geolocation](https://github.com/porech/caddy-maxmind-geolocation)** | 物理地域 IP 防火墙 | 公网 IP 开放时拦截境外恶意扫描器与机器爆破 |

---

## 🚀 使用方法

> **注意**：请先将下方命令中的 `<USERNAME>` 和 `<REPO>` 替换为你自己的 GitHub 用户名和仓库名（全小写）。

### 方式 A：在 PVE Alpine / Linux LXC 中直接运行（推荐，极致轻量）

编译出的单文件为 **纯静态二进制（`CGO_ENABLED=0`）**，在 Alpine (musl) 或 Debian (glibc) 上均可零依赖秒开。

```sh
# 1. 下载最新编译的 AMD64 静态二进制文件（ARM 架构请将 amd64 改为 arm64）
curl -L "https://github.com/<USERNAME>/<REPO>/releases/download/latest/caddy-linux-amd64" -o /usr/local/bin/caddy
chmod +x /usr/local/bin/caddy

# 2. 检查版本及插件内置情况
/usr/local/bin/caddy version
/usr/local/bin/caddy list-modules | grep dns.providers

# 3. 重启 Caddy 服务（Alpine OpenRC）
rc-service caddy restart
```

---

### 方式 B：通过 Docker / Docker Compose 部署

使用自动推送到 GitHub Container Registry (GHCR) 的镜像。

#### `docker-compose.yml` 示例

```yaml
services:
  caddy:
    image: ghcr.io/<USERNAME>/caddy:latest
    container_name: caddy
    restart: always
    network_mode: host      # 推荐使用 host 模式直接管理 80/443
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy_data:/data   # 存放自动申请的 HTTPS 证书与密钥
      - ./caddy_config:/config
```

---

## 📝 Caddyfile 配置参考

以下为常用的泛域名反代模板示例（`/etc/caddy/Caddyfile`）：

```caddyfile
{
	email your_email@example.com

	# 全局配置腾讯云 DNS-01 验证（申请泛域名证书用）
	acme_dns tencentcloud {
		secret_id "你的SecretId"
		secret_key "你的SecretKey"
	}
	tls_resolvers 119.29.29.29 223.5.5.5
}

*.052930.xyz {
	# 影视下载组件
	@qb host qb.xxxxx.xyz
	handle @qb {
		reverse_proxy 192.168.1.2:8000
	}

	# 前后端分离站点路由
	@sitebox host sitebox.xxxxx.xyz
	handle @sitebox {
		handle_path /api/* {
			reverse_proxy 192.168.1.3:8000
		}
		handle {
			reverse_proxy 192.168.1.4:3000
		}
	}

	# 局域网其他设备
	@app host app.xxxxx.xyz
	handle @app {
		reverse_proxy 192.168.1.5:8000
	}

	# 兜底拒绝未定义子域名
	handle {
		abort
	}
}
```

---

## 🔄 维护与升级

1. **手动一键重构**：进入本仓库的 **Actions** 标签页，在左侧选择 `Build Caddy (Docker & Executable)`，点击右侧的 **Run workflow** 即可在 3 分钟内自动打包全套最新版。
2. **增删插件**：直接修改仓库根目录的 `Dockerfile` 和 `.github/workflows/build.yml` 中的 `--with` 参数，提交代码即可自动触发构建。

---

## 📄 开源许可

本项目所编译的上游核心项目 [Caddy](https://github.com/caddyserver/caddy) 遵循 [Apache 2.0 License](https://github.com/caddyserver/caddy/blob/master/LICENSE)。
