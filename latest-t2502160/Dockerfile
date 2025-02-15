ARG DEBIAN_FRONTEND=noninteractive

FROM node:20.16.0 as web_compile
WORKDIR /home
RUN <<MEOF
git clone https://github.com/kvcache-ai/ktransformers.git &&
cd ktransformers/ktransformers/website/ &&
npm install @vue/cli &&
npm run build &&
rm -rf node_modules
MEOF

FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-devel as compile_server
WORKDIR /workspace
ENV CUDA_HOME /usr/local/cuda
COPY --from=web_compile /home/ktransformers /workspace/ktransformers
RUN <<MEOF
apt update -y &&  apt install -y  --no-install-recommends \
    git \
    wget \
    vim \
    gcc \
    g++ \
    cmake && 
rm -rf /var/lib/apt/lists/* &&
cd ktransformers &&
git submodule init &&
git submodule update &&
pip install ninja pyproject numpy cpufeature &&
pip install flash-attn &&
CPU_INSTRUCT=NATIVE  KTRANSFORMERS_FORCE_BUILD=TRUE TORCH_CUDA_ARCH_LIST="8.0;8.6;8.7;8.9;9.0+PTX" pip install . --no-build-isolation --verbose &&
pip cache purge
MEOF

ENTRYPOINT ["tail", "-f", "/dev/null"]


LABEL org.opencontainers.image.source=https://github.com/lwmacct/250216-cr-ktransformers
LABEL org.opencontainers.image.description="docker buildx 模板"
LABEL org.opencontainers.image.licenses=MIT
