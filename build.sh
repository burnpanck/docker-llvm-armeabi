#!/usr/bin/env bash

set -e
set -o errexit

TOOLCHAIN_ROOT=/mnt/LargeData/SDKs/llvm-arm-none-eabi-newlib
export DOWNLOAD_ROOT=${TOOLCHAIN_ROOT}/download
export BUILD_ROOT=${TOOLCHAIN_ROOT}/build
export INSTALL_PREFIX=${TOOLCHAIN_ROOT}/dist
mkdir -p ${DOWNLOAD_ROOT}
mkdir -p ${BUILD_ROOT}

export SCRIPT_ROOT=`pwd`
#./010-download-newlib.sh
#./020-download-llvm.sh
#./030-build-llvm.sh
#./040-build-newlib.sh
./045-build-compiler-rt.sh
