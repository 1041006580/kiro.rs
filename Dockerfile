FROM node:22-alpine AS frontend-builder

WORKDIR /app/admin-ui
COPY admin-ui/package.json ./
RUN npm install -g pnpm && pnpm install
COPY admin-ui ./
RUN pnpm build

FROM rust:1.85-alpine AS builder

RUN apk add --no-cache musl-dev openssl-dev openssl-libs-static

WORKDIR /app
COPY Cargo.toml Cargo.lock* ./
COPY src ./src
COPY --from=frontend-builder /app/admin-ui/dist /app/admin-ui/dist

RUN cargo build --release

FROM alpine:3.21

RUN apk add --no-cache ca-certificates

# 创建非 root 用户 (HuggingFace Spaces 要求)
RUN adduser -D -u 1000 appuser

WORKDIR /app

COPY --from=builder /app/target/release/kiro-rs /app/kiro-rs
COPY entrypoint.sh /app/entrypoint.sh

# 创建配置目录并设置权限
RUN mkdir -p /app/config && \
    chown -R appuser:appuser /app && \
    chmod +x /app/entrypoint.sh

USER appuser

# HuggingFace Spaces 只支持端口 7860
EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
