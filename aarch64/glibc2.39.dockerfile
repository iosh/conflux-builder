FROM ubuntu:24.04

RUN tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null <<'EOF'
# AMD64 (x86_64) Sources
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Architectures: amd64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
 
# AMD64 Security Sources
Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Architectures: amd64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
 
# ARM64 (aarch64) Sources
Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Architectures: arm64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
 
# ARM64 Security Sources
Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports/
Suites: noble-security
Components: main restricted universe multiverse
Architectures: arm64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

RUN apt-get update && apt-get install curl lsb-release wget software-properties-common gnupg pkg-config cmake -y

RUN wget https://apt.llvm.org/llvm.sh && chmod u+x llvm.sh && ./llvm.sh 18

RUN dpkg --add-architecture arm64


RUN apt update && apt-get install -y libsqlite3-dev:arm64 libssl-dev:arm64 crossbuild-essential-arm64 libc++-18-dev:arm64


RUN  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain none -y

ENV PATH="/root/.cargo/bin:${PATH}"

ENV OPENSSL_DIR="/usr"
ENV OPENSSL_LIB_DIR="/usr/lib/aarch64-linux-gnu"
ENV OPENSSL_INCLUDE_DIR="/usr/include"

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


ENV PKG_CONFIG_PATH="/usr/lib/aarch64-linux-gnu/pkgconfig"
ENV PKG_CONFIG_ALLOW_CROSS=1

ENV CFLAGS_aarch64_unknown_linux_gnu="--target=aarch64-linux-gnu"
ENV CXXFLAGS_aarch64_unknown_linux_gnu="--target=aarch64-linux-gnu -stdlib=libc++"
