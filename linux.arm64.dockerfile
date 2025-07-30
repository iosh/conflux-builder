FROM ubuntu:22.04

RUN tee /etc/apt/sources.list > /dev/null <<'EOF'
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
deb [arch=amd64] http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
 
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-backports main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse
EOF

RUN apt-get update && apt-get install curl lsb-release wget software-properties-common gnupg pkg-config cmake -y  

RUN wget https://apt.llvm.org/llvm.sh && chmod u+x llvm.sh && ./llvm.sh 18

RUN dpkg --add-architecture arm64


RUN apt update && apt-get install -y libsqlite3-dev:arm64 libssl-dev:arm64 crossbuild-essential-arm64


RUN  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain none -y

ENV PATH="/root/.cargo/bin:${PATH}"

ENV OPENSSL_DIR="/usr"
ENV OPENSSL_LIB_DIR="/usr/lib/aarch64-linux-gnu"
ENV OPENSSL_INCLUDE_DIR="/usr/include"

ENV CC_aarch64_unknown_linux_gnu="clang-18"
ENV CXX_aarch64_unknown_linux_gnu="clang++-18"
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="clang-18"
 
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C linker=clang-18 -C link-arg=--target=aarch64-linux-gnu -C link-arg=-fuse-ld=lld -C link-arg=-L/usr/lib/aarch64-linux-gnu"
 
ENV PKG_CONFIG_PATH="/usr/lib/aarch64-linux-gnu/pkgconfig"
ENV PKG_CONFIG_ALLOW_CROSS=1
 
ENV CFLAGS_aarch64_unknown_linux_gnu="--target=aarch64-linux-gnu"
ENV CXXFLAGS_aarch64_unknown_linux_gnu="--target=aarch64-linux-gnu -stdlib=libstdc++"
 