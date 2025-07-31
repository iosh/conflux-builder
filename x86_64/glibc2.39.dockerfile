FROM ubuntu:24.04


RUN apt-get update && apt-get install curl lsb-release wget software-properties-common gnupg -y  

RUN wget https://apt.llvm.org/llvm.sh && chmod u+x llvm.sh && ./llvm.sh 18

RUN apt-get install -y libsqlite3-dev pkg-config libssl-dev cmake libc++-18-dev git curl unzip

RUN  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain none -y


ENV CC=clang-18
ENV CXX=clang++-18
ENV CXXFLAGS="-std=c++11 -stdlib=libc++"
ENV LDFLAGS="-stdlib=libc++"
