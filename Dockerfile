# 1. Build biliup's web-ui
FROM node:lts AS webui-builder

# 直接将本地代码拷贝到 /biliup
COPY . /biliup
WORKDIR /biliup

# 移除 git clone 逻辑，直接安装并构建本地代码
RUN set -eux; \
    npm install; \
    npm run build

# 2. Build biliup's python wheel
FROM rust:latest AS wheel-builder

# 安装构建依赖
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends python3-pip g++; \
    pip3 install maturin --break-system-packages

# 直接拷贝本地代码
COPY . /biliup
# 覆盖前端构建产物（确保使用的是 webui-builder 阶段生成的 out 目录）
COPY --from=webui-builder /biliup/out /biliup/out

WORKDIR /biliup

# 构建 Python Wheel
RUN set -eux; \
    maturin build --release

# 3. Deploy Biliup
FROM python:3.13-slim AS biliup

ENV TZ="Asia/Shanghai"
ENV LANG="C.UTF-8"
ENV LANGUAGE="C.UTF-8"
ENV LC_ALL="C.UTF-8"
EXPOSE 19159/tcp
VOLUME /opt

# 拷贝构建好的 wheel
COPY --from=wheel-builder /biliup/target/wheels/* /tmp/

RUN set -eux; \
    whl=$(ls /tmp/biliup*.whl); \
    pip3 install --no-cache-dir "$whl"; \
    pip3 cache purge; \
    rm -rf /tmp/*

# 原版 FFmpeg 安装逻辑 (保留)
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    useApt=false; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      wget \
      curl \
      xz-utils \
      g++ \
    ; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual curl wget; \
    \
    arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
    url='https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n8.0-latest-'; \
    case "$arch" in \
      'amd64') url="${url}linux64-gpl-8.0.tar.xz"; ;; \
      'arm64') url="${url}linuxarm64-gpl-8.0.tar.xz"; ;; \
      *) useApt=true; ;; \
    esac; \
    \
    if [ "$useApt" = true ] ; then \
      apt-get install -y --no-install-recommends ffmpeg; \
    else \
      wget -O ffmpeg.tar.xz "$url" --progress=dot:giga; \
      tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1; \
      rm -rf /usr/local/doc /usr/local/man /usr/local/bin/ffprobe /usr/local/bin/ffplay ffmpeg*; \
      chmod a+x /usr/local/*; \
    fi; \
    \
    pip3 install --no-cache-dir quickjs; \
    \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /tmp/* /usr/share/doc/* /var/cache/* /var/lib/apt/lists/* /var/tmp/* /var/log/*

WORKDIR /opt
ENTRYPOINT ["biliup"]