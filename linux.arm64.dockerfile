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


RUN apt update && apt-get install -y libsqlite3-dev:arm64 libssl-dev:arm64 libc++-18-dev:arm64 gcc-aarch64-linux-gnu g++-aarch64-linux-gnu



RUN  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y 

ENV PATH="/root/.cargo/bin:${PATH}"

ENV CC_aarch64_unknown_linux_gnu="aarch64-linux-gnu-gcc"
ENV CXX_aarch64_unknown_linux_gnu="aarch64-linux-gnu-g++"
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="aarch64-linux-gnu-gcc"
ENV OPENSSL_LIB_DIR="/usr/lib/aarch64-linux-gnu"
ENV OPENSSL_INCLUDE_DIR="/usr/include/aarch64-linux-gnu"
