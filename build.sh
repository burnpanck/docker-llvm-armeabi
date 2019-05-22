#!/usr/bin/env bash

set -e
set -o errexit

TOOLCHAIN_ROOT=/mnt/LargeData/SDKs/llvm-arm-none-eabi-newlib
export SRC_ROOT=${TOOLCHAIN_ROOT}/src
export BUILD_ROOT=${TOOLCHAIN_ROOT}/build
export INSTALL_PREFIX=${TOOLCHAIN_ROOT}/dist
mkdir -p ${SRC_ROOT}
mkdir -p ${BUILD_ROOT}

export SCRIPT_ROOT=`pwd`
./010-download-newlib.sh
./020-download-llvm.sh
./025-download-libc++.sh
./030-build-llvm.sh
./040-build-newlib.sh
./044-build-compiler-rt.sh
#./045-build-compiler-rt-manual.sh
./050-build-libc++.sh