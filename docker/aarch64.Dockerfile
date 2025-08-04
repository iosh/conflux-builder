
ARG UBUNTU_VERSION=20.04
ARG UBUNTU_CODENAME=focal
ARG OPENSSL_CHOICE=openssl-3

FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture arm64 && \
    tee /etc/apt/sources.list > /dev/null <<EOF
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb [arch=amd64] http://security.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
EOF


RUN apt-get update && \
    apt-get install -y curl wget software-properties-common gnupg ca-certificates pkg-config cmake perl  && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 18 && \
    apt-get install -y \
    libsqlite3-dev:arm64 \
    crossbuild-essential-arm64 \
    libc++-18-dev:arm64 && \
    rm -rf /var/lib/apt/lists/* && \
    rm llvm.sh


ENV CROSS_COMPILE=aarch64-linux-gnu-
RUN set -ex;\
    OPENSSL_VERSION=""; \
    OPENSSL_SHA256=""; \
    case "${OPENSSL_CHOICE}" in \
    "openssl-3") \
    OPENSSL_VERSION="3.5.1"; \
    OPENSSL_SHA256="529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f"; \
    ;; \
    "openssl-1") \
    OPENSSL_VERSION="1.1.1w"; \
    OPENSSL_SHA256="cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d93925208b76ac8"; \
    ;; \
    *) \
    echo "Error: Unsupported OpenSSL choice: ${OPENSSL_CHOICE}"; \
    exit 1; \
    ;; \
    esac; \
    wget -O openssl.tar.gz "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"; \
    echo "${OPENSSL_SHA256} openssl.tar.gz" | sha256sum -c -; \
    tar -xzf openssl.tar.gz; \
    cd "openssl-${OPENSSL_VERSION}"; \
    perl ./Configure linux-aarch64 \
    --prefix=/opt/openssl-aarch64 \
    --openssldir=/opt/openssl-aarch64 \
    no-tests; \
    make -j$(nproc); \
    make install_sw; \
    cd ..; \
    rm -rf "openssl-${OPENSSL_VERSION}" openssl.tar.gz




RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain none -y && rustup default stable-x86_64-unknown-linux-gnu && rustup target add aarch64-unknown-linux-gnu


ENV PATH="/root/.cargo/bin:${PATH}"

ENV CC_aarch64_unknown_linux_gnu="clang-18"
ENV CXX_aarch64_unknown_linux_gnu="clang++-18"
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="clang-18"
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS="\
    -C linker=clang-18 \
    -C link-arg=--target=aarch64-linux-gnu \
    -C link-arg=-fuse-ld=lld \
    -C link-arg=-L/usr/lib/aarch64-linux-gnu \
    -C link-arg=-lc++ \
    -C link-arg=-lc++abi"
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV CFLAGS_aarch64_unknown_linux_gnu="--target=aarch64-linux-gnu"
ENV CXXFLAGS_aarch64_unknown_linux_gnu="--target=aarch64-linux-gnu -stdlib=libc++"

ENV OPENSSL_DIR_aarch64_unknown_linux_gnu=/opt/openssl-aarch64
ENV OPENSSL_LIB_DIR_aarch64_unknown_linux_gnu=/opt/openssl-aarch64/lib
ENV OPENSSL_INCLUDE_DIR_aarch64_unknown_linux_gnu=/opt/openssl-aarch64/include
ENV PKG_CONFIG_PATH_aarch64_unknown_linux_gnu=/opt/openssl-aarch64/lib/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig
ENV OPENSSL_STATIC_aarch64_unknown_linux_gnu=yes



WORKDIR /workspace