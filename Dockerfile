# 第一阶段：编译带插件的 Caddy
FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/tencentcloud \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/alidns \
    --with github.com/mholt/caddy-webdav \
    --with github.com/caddyserver/cache-handler \
    --with github.com/caddyserver/replace-response \
    --with github.com/porech/caddy-maxmind-geolocation

# 第二阶段：装载进最小化官方镜像
FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
