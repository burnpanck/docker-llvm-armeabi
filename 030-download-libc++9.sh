#!/usr/bin/env bash
# Download libc++ and friends
# parameters:
#  - SRC_ROOT
# requirements:
#  - curl

set -e
set -o errexit

source ./config.sh

LLVM_URL="http://prereleases.llvm.org/9.0.0/rc1"
LLVM_VER="9.0.0rc1"

cd ${SRC_ROOT}

[ -d libcxx ] && rm -rf libcxx
curl -LO ${LLVM_URL}/libcxx-${LLVM_VER}.src.tar.xz && \
#    [ "c2902675e7c84324fb2c1e45489220f250ede016cc3117186785d9dc291f9de2" = \
#      "$(sha256sum libcxx-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxx-${LLVM_VER}.src.tar.xz && \
    mv libcxx-${LLVM_VER}.src libcxx
(cd libcxx && patch -p2 < ${SCRIPT_ROOT}/patches/0001-enable-atomic-header-on-thread-less-builds.patch)

[ -d libcxxabi ] && rm -rf libcxxabi
curl -LO ${LLVM_URL}/libcxxabi-${LLVM_VER}.src.tar.xz && \
#    [ "c2d6de9629f7c072ac20ada776374e9e3168142f20a46cdb9d6df973922b07cd" = \
#      "$(sha256sum libcxxabi-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxxabi-${LLVM_VER}.src.tar.xz && \
    mv libcxxabi-${LLVM_VER}.src libcxxabi
(cd libcxxabi && patch -p2 < ${SCRIPT_ROOT}/patches/0001-explicitly-specify-location-of-libunwind-in-static-b.patch)


[ -d libunwind ] && rm -rf libunwind
curl -LO ${LLVM_URL}/libunwind-${LLVM_VER}.src.tar.xz && \
#    [ "ff243a669c9cef2e2537e4f697d6fb47764ea91949016f2d643cb5d8286df660" = \
#      "$(sha256sum libunwind-${LLVM_VER}.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libunwind-${LLVM_VER}.src.tar.xz && \
    mv libunwind-${LLVM_VER}.src libunwind
