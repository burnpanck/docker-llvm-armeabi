#!/usr/bin/env bash

set -e
set -o errexit

LLVM_VERSION="${LLVM_VERSION:-9}"
LIBCXX_VERSION="${LIBCXX_VERSION:-9}"

export TOOLCHAIN_ROOT="${TOOLCHAIN_ROOT:-/toolchain-llvm${LLVM_VERSION}-libc++${LIBCXX_VERSION}}"

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
./020-download-llvm-${LLVM_VERSION}.sh
./030-download-libc++${LIBCXX_VERSION}.sh
./040-build-llvm${LLVM_VERSION}.sh
./050-build-newlib.sh
./060-build-compiler-rt-llvm${LLVM_VERSION}.sh
./070-build-libc++${LIBCXX_VERSION}.sh

mkdir -p "${INSTALL_PREFIX}/cmake"
cp assets/*-toolchain.cmake "${INSTALL_PREFIX}/cmake/"

echo "Build complete."
