
ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl wget software-properties-common gnupg ca-certificates && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 18 && \
    apt-get install -y libsqlite3-dev pkg-config libssl-dev cmake libc++-18-dev git unzip && \
    rm -rf /var/lib/apt/lists/* && \
    rm llvm.sh


RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain none -y


ENV PATH="/root/.cargo/bin:${PATH}"
ENV CC=clang-18
ENV CXX=clang++-18
ENV CXXFLAGS="-std=c++11 -stdlib=libc++"
ENV LDFLAGS="-stdlib=libc++"

WORKDIR /workspace