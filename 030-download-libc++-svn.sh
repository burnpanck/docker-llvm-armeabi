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
svn checkout https://github.com/llvm/llvm-project/trunk/libcxx
(cd libcxx && patch -p2 < ${SCRIPT_ROOT}/patches/0001-enable-atomic-header-on-thread-less-builds.patch)

[ -d libcxxabi ] && rm -rf libcxxabi
svn checkout https://github.com/llvm/llvm-project/trunk/libcxxabi
(cd libcxxabi && patch -p2 < ${SCRIPT_ROOT}/patches/0001-explicitly-specify-location-of-libunwind-in-static-b.patch)

[ -d libunwind ] && rm -rf libunwind
svn checkout https://github.com/llvm/llvm-project/trunk/libunwind
