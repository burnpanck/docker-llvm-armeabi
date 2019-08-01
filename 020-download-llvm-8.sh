#!/usr/bin/env bash
# Download LLVM and Clang
# parameters:
#  - SRC_ROOT
# requirements:
#  - curl

set -e
set -o errexit

source ./config.sh

LLVM_URL="https://releases.llvm.org/8.0.0"
LLVM_VER="8.0.0"

cd ${SRC_ROOT}

[ -d llvm ] && rm -rf llvm
curl -LO ${LLVM_URL}/llvm-${LLVM_VER}.src.tar.xz && \
    [ "8872be1b12c61450cacc82b3d153eab02be2546ef34fa3580ed14137bb26224c" = \
      "$(sha256sum llvm-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf llvm-${LLVM_VER}.src.tar.xz && \
    mv llvm-${LLVM_VER}.src llvm
[ -d clang ] && rm -rf clang
curl -LO ${LLVM_URL}/cfe-${LLVM_VER}.src.tar.xz && \
    [ "084c115aab0084e63b23eee8c233abb6739c399e29966eaeccfc6e088e0b736b" = \
      "$(sha256sum cfe-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf cfe-${LLVM_VER}.src.tar.xz && \
    mv cfe-${LLVM_VER}.src clang
[ -d clang-tools-extra ] && rm -rf clang-tools-extra
curl -LO ${LLVM_URL}/clang-tools-extra-${LLVM_VER}.src.tar.xz && \
    [ "4f00122be408a7482f2004bcf215720d2b88cf8dc78b824abb225da8ad359d4b" = \
      "$(sha256sum clang-tools-extra-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf clang-tools-extra-${LLVM_VER}.src.tar.xz && \
    mv clang-tools-extra-${LLVM_VER}.src clang-tools-extra
[ -d lld ] && rm -rf lld
curl -LO ${LLVM_URL}/lld-${LLVM_VER}.src.tar.xz && \
    [ "9caec8ec922e32ffa130f0fb08e4c5a242d7e68ce757631e425e9eba2e1a6e37" = \
      "$(sha256sum lld-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf lld-${LLVM_VER}.src.tar.xz && \
    mv lld-${LLVM_VER}.src lld
[ -d lldb ] && rm -rf lldb
#curl -LO ${LLVM_URL}/lldb-${LLVM_VER}.src.tar.xz && \
#    [ "9caec8ec922e32ffa130f0fb08e4c5a242d7e68ce757631e425e9eba2e1a6e37" = \
#      "$(sha256sum lldb-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
#    tar xf lldb-${LLVM_VER}.src.tar.xz && \
#    mv lldb-${LLVM_VER}.src lldb

(cd llvm/tools && ln -s ../../clang && ln -s ../../lld && ln -s ../../lldb) && \
    (cd llvm/tools/clang/tools && ln -s ../../clang-tools-extra extra)

[ -d compiler-rt ] && rm -rf compiler-rt
curl -LO ${LLVM_URL}/compiler-rt-${LLVM_VER}.src.tar.xz && \
    [ "b435c7474f459e71b2831f1a4e3f1d21203cb9c0172e94e9d9b69f50354f21b1" = \
      "$(sha256sum compiler-rt-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf compiler-rt-${LLVM_VER}.src.tar.xz && \
    mv compiler-rt-${LLVM_VER}.src compiler-rt
(cd compiler-rt && patch -p2 < ${SCRIPT_ROOT}/patches/compiler_rt-CMakeLists.patch)
