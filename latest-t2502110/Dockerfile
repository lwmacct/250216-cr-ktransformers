FROM ubuntu:noble-20241015
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    echo "配置源,容器内源文件为 /etc/apt/sources.list.d/ubuntu.sources"; \
    sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources; \
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get update; apt-get install -y --no-install-recommends ca-certificates curl wget sudo pcp gnupg; \
    sed -i 's/http:/https:/g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo "设置 PS1"; \
    cat >> /root/.bashrc <<"MEOF"
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[00m\]@\[\033[01;35m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
MEOF

LABEL org.opencontainers.image.source=https://github.com/lwmacct/250210-cr-buildx
LABEL org.opencontainers.image.description="docker buildx 模板"
LABEL org.opencontainers.image.licenses=MIT
