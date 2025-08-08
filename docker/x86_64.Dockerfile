
ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}


ARG COMPATIBILITY_MODE=false
ARG OPENSSL_CHOICE=openssl-3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl wget software-properties-common gnupg ca-certificates git && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 18 && \
    apt-get install -y libsqlite3-dev pkg-config  cmake libc++-18-dev git unzip && \
    rm -rf /var/lib/apt/lists/* && \
    rm llvm.sh


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
    CONFIG_FLAGS="--prefix=/opt/openssl --openssldir=/opt/openssl no-tests"; \
    if [ "${COMPATIBILITY_MODE}" = "true" ]; then \
        echo "OpenSSL: Compiling in compatibility mode (-march=x86-64-v3 -mtune=generic)"; \
        CONFIG_FLAGS="${CONFIG_FLAGS} -march=x86-64-v3 -mtune=generic"; \
    else \
        echo "OpenSSL: Compiling in normal mode"; \
    fi; \
    ./config ${CONFIG_FLAGS}; \
    make -j$(nproc); \
    make install_sw; \
    cd ..; \
    rm -rf "openssl-${OPENSSL_VERSION}" openssl.tar.gz



RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain none -y


ENV PATH="/root/.cargo/bin:${PATH}"
ENV CC=clang-18
ENV CXX=clang++-18
ENV CXXFLAGS="-std=c++11 -stdlib=libc++"
ENV LDFLAGS="-stdlib=libc++"
ENV RUSTFLAGS="-C target-cpu=x86-64-v3"
ENV OPENSSL_DIR=/opt/openssl
ENV OPENSSL_LIB_DIR=/opt/openssl/lib64
ENV OPENSSL_INCLUDE_DIR=/opt/openssl/include
ENV PKG_CONFIG_PATH=/opt/openssl/lib64/pkgconfig

WORKDIR /workspace

RUN git config --global --add safe.directory /workspace