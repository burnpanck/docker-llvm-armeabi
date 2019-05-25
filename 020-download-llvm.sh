#!/usr/bin/env bash
# Download LLVM and Clang
# parameters:
#  - SRC_ROOT
# requirements:
#  - curl

set -e
set -o errexit

source ./config.sh

cd ${SRC_ROOT}

[ -d llvm ] && rm -rf llvm
curl -LO https://releases.llvm.org/8.0.0/llvm-8.0.0.src.tar.xz && \
    [ "8872be1b12c61450cacc82b3d153eab02be2546ef34fa3580ed14137bb26224c" = \
      "$(sha256sum llvm-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf llvm-8.0.0.src.tar.xz && \
    mv llvm-8.0.0.src llvm
[ -d clang ] && rm -rf clang
curl -LO https://releases.llvm.org/8.0.0/cfe-8.0.0.src.tar.xz && \
    [ "084c115aab0084e63b23eee8c233abb6739c399e29966eaeccfc6e088e0b736b" = \
      "$(sha256sum cfe-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf cfe-8.0.0.src.tar.xz && \
    mv cfe-8.0.0.src clang
[ -d clang-tools-extra ] && rm -rf clang-tools-extra
curl -LO https://releases.llvm.org/8.0.0/clang-tools-extra-8.0.0.src.tar.xz && \
    [ "4f00122be408a7482f2004bcf215720d2b88cf8dc78b824abb225da8ad359d4b" = \
      "$(sha256sum clang-tools-extra-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf clang-tools-extra-8.0.0.src.tar.xz && \
    mv clang-tools-extra-8.0.0.src clang-tools-extra
[ -d lld ] && rm -rf lld
curl -LO https://releases.llvm.org/8.0.0/lld-8.0.0.src.tar.xz && \
    [ "9caec8ec922e32ffa130f0fb08e4c5a242d7e68ce757631e425e9eba2e1a6e37" = \
      "$(sha256sum lld-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf lld-8.0.0.src.tar.xz && \
    mv lld-8.0.0.src lld
(cd llvm/tools && ln -s ../../clang && ln -s ../../lld) && \
    (cd llvm/tools/clang/tools && ln -s ../../clang-tools-extra extra)
