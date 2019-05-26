#!/usr/bin/env bash

set -e
set -o errexit

export TOOLCHAIN_ROOT=/mnt/LargeData/SDKs/test
export TOOLCHAIN_ROOT=/mnt/LargeData/SDKs/llvm-armeabi-newlib

source ./config.sh

echo "Starting build."
echo "TOOLCHAIN_ROOT=${TOOLCHAIN_ROOT}"
echo "SRC_ROOT=${SRC_ROOT}"
echo "BUILD_ROOT=${BUILD_ROOT}"
echo "INSTALL_PREFIX=${INSTALL_PREFIX}"
echo ""

mkdir -p ${SRC_ROOT}
mkdir -p ${BUILD_ROOT}

#./010-download-newlib.sh
#./020-download-llvm.sh
#./025-download-libc++.sh
#./030-build-llvm.sh
#./040-build-newlib.sh
#./044-build-compiler-rt.sh
#./045-build-compiler-rt-manual.sh
./050-build-libc++.sh

echo "Build complete."