#!/usr/bin/env bash

set -e
set -o errexit

export TOOLCHAIN_ROOT="${TOOLCHAIN_ROOT:-/toolchain}"

source ./config.sh

echo "Starting build."
echo "TOOLCHAIN_ROOT=${TOOLCHAIN_ROOT}"
echo "SRC_ROOT=${SRC_ROOT}"
echo "BUILD_ROOT=${BUILD_ROOT}"
echo "INSTALL_PREFIX=${INSTALL_PREFIX}"
echo ""

mkdir -p ${SRC_ROOT}
mkdir -p ${BUILD_ROOT}

./010-download-newlib.sh
./020-download-llvm.sh
#./030-download-libc++.sh
./031-download-libc++9.sh
./040-build-llvm.sh
./050-build-newlib.sh
./060-build-compiler-rt.sh
#./070-build-libc++.sh
./071-build-libc++9.sh

mkdir -p "${INSTALL_PREFIX}/cmake"
cp assets/*-toolchain.cmake "${INSTALL_PREFIX}/cmake/"

echo "Build complete."
