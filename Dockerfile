## Base Image
# https://github.com/wojiushixiaobai/docker-loongnix-artifacts/tree/master/debian/buster-slim

FROM debian:buster-slim AS builder

ARG TINI_VERSION=v0.19.0

ARG ARCH_SUFFIX=loong64 \
    CC=gcc \
    ARCH_NATIVE=1 \
    MINIMAL=1

ENV GOPROXY=https://goproxy.io,direct \
    GOSUMDB=off \
    GO111MODULE=auto \
    GOOS=linux

ARG DEPS="             \
    build-essential    \
    git                \
    gdb                \
    valgrind           \
    cmake              \
    rpm                \
    file               \
    libcap-dev         \
    python3-dev        \
    python3-pip        \
    python3-setuptools \
    gnupg              \
    git"

RUN set -ex; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    apt-get update; \
    apt-get install -y ${DEPS}; \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install virtualenv && \
    CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37" python3 -m pip install psutil python-prctl bitmap

# Persist ARGs into the image

ENV ARCH_SUFFIX="$ARCH_SUFFIX" \
    ARCH_NATIVE="$ARCH_NATIVE" \
    CC="$CC"

ENV SRC="/tini" \
    BUILD_DIR=/tmp/tini-build \
    SOURCE_DIR="${SRC}" \
    FORCE_SUBREAPER="${FORCE_SUBREAPER:-1}" \
    GPG_PASSPHRASE="${GPG_PASSPHRASE:-}" \
    CFLAGS="${CFLAGS:-}" \
    MINIMAL="${MINIMAL:-}"

RUN set -ex; \
    git clone -b ${TINI_VERSION} --depth=1 https://github.com/krallin/tini ${SRC}; \
    sed -i 's@hardening-check@# hardening-check@g' ${SRC}/ci/run_build.sh

WORKDIR /tini

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install virtualenv && \
    "${SRC}/ci/run_build.sh" && \
    ls -lah "${SRC}/dist"

VOLUME /dist

CMD cp -rf dist/* /dist/


