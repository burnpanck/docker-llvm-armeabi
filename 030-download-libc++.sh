#!/usr/bin/env bash
# Download libc++ and friends
# parameters:
#  - SRC_ROOT
# requirements:
#  - curl

set -e
set -o errexit

source ./config.sh

cd ${SRC_ROOT}

[ -d libcxx ] && rm -rf libcxx
curl -LO https://releases.llvm.org/8.0.0/libcxx-8.0.0.src.tar.xz && \
    [ "c2902675e7c84324fb2c1e45489220f250ede016cc3117186785d9dc291f9de2" = \
      "$(sha256sum libcxx-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxx-8.0.0.src.tar.xz && \
    mv libcxx-8.0.0.src libcxx

[ -d libcxxabi ] && rm -rf libcxxabi
curl -LO https://releases.llvm.org/8.0.0/libcxxabi-8.0.0.src.tar.xz && \
    [ "c2d6de9629f7c072ac20ada776374e9e3168142f20a46cdb9d6df973922b07cd" = \
      "$(sha256sum libcxxabi-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxxabi-8.0.0.src.tar.xz && \
    mv libcxxabi-8.0.0.src libcxxabi

[ -d libunwind ] && rm -rf libunwind
curl -LO https://releases.llvm.org/8.0.0/libunwind-8.0.0.src.tar.xz && \
    [ "ff243a669c9cef2e2537e4f697d6fb47764ea91949016f2d643cb5d8286df660" = \
      "$(sha256sum libunwind-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libunwind-8.0.0.src.tar.xz && \
    mv libunwind-8.0.0.src libunwind
