#!/usr/bin/env bash
# shellcheck disable=SC2317
# document https://www.yuque.com/lwmacct/docker/buildx

__main() {
  {
    _sh_path=$(realpath "$(ps -p $$ -o args= 2>/dev/null | awk '{print $2}')") # 当前脚本路径
    _pro_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-2)}')               # 当前项目名
    _dir_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-1)}')               # 当前目录名
    _image="${_pro_name}:$_dir_name"
  }

  _dockerfile=$(
    # 双引号不转义
    cat <<"EOF"
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

LABEL org.opencontainers.image.source=$_ghcr_source
LABEL org.opencontainers.image.description="docker buildx 模板"
LABEL org.opencontainers.image.licenses=MIT
EOF
  )
  {
    cd "$(dirname "$_sh_path")" || exit 1
    echo "$_dockerfile" >Dockerfile

    _ghcr_source=$(sed 's|git@github.com:|https://github.com/|' ../.git/config | grep url | sed 's|.git$||' | awk '{print $NF}')
    _ghcr_source=${_ghcr_source:-"https://github.com/lwmacct/250210-cr-buildx"}
    sed -i "s|\$_ghcr_source|$_ghcr_source|g" Dockerfile
  }

  {
    if command -v sponge >/dev/null 2>&1; then
      jq 'del(.credsStore)' ~/.docker/config.json | sponge ~/.docker/config.json
    else
      jq 'del(.credsStore)' ~/.docker/config.json >~/.docker/config.json.tmp && mv ~/.docker/config.json.tmp ~/.docker/config.json
    fi
  }
  {
    _registry="ghcr.io/lwmacct" # 托管平台, 如果是 docker.io 则可以只填写用户名
    _repository="$_registry/$_image"
    echo "image: $_repository"
    docker buildx build --builder default --platform linux/amd64 -t "$_repository" --network host --progress plain --load . && {
      _image_id=$(docker images "$_repository" --format "{{.ID}}")
      if false; then
        docker rm -f sss 2>/dev/null
        docker run -itd --name=sss \
          --restart=always \
          --network=host \
          --privileged=false \
          "$_image_id"
        docker exec -it sss bash
      fi
    }
    docker push "$_repository"

  }
}

__main

__help() {
  cat >/dev/null <<"EOF"
这里可以写一些备注

ghcr.io/lwmacct/250210-cr-buildx:latest

EOF
}
