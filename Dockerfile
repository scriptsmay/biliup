# 1. Build biliup's web-ui
FROM node:lts-slim AS webui-builder
WORKDIR /biliup

# GitHub Actions 环境下直接使用官方 npm 源
COPY frontend/package*.json ./frontend/
WORKDIR /biliup/frontend
RUN npm install

COPY frontend/ .
RUN npm run build

# 2. Build biliup's core (Python Wheel via Maturin)
FROM rust:latest AS wheel-builder
WORKDIR /biliup

# 安装 maturin 和 python 编译环境
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip python3-dev \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --break-system-packages maturin

# 拷贝本地代码（Actions 已经检出的代码）
COPY . .
# 拷贝前端产物
COPY --from=webui-builder /biliup/frontend/out ./frontend/out

# 构建 Wheel 文件
RUN maturin build --release

# 3. Final Image
FROM python:3.13-slim AS biliup

ENV TZ="Asia/Shanghai"
ENV LANG="C.UTF-8"
EXPOSE 19159/tcp

WORKDIR /opt

# 安装运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# 从构建阶段安装 Wheel
COPY --from=wheel-builder /biliup/target/wheels/*.whl /tmp/
RUN pip3 install --no-cache-dir /tmp/*.whl quickjs && \
    rm -rf /tmp/*

ENTRYPOINT ["biliup"]