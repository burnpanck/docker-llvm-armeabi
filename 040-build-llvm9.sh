#!/usr/bin/env bash
# Build LLVM
# requirements:
#  - build-base
#  - ninja
#  - cmake
#  - git
#  - patch
#  - vim
#  - python2
#  - curl
#  - file
#  - swig


set -e
set -o errexit

source ./config.sh

LLVM_PROJECT_SRC_ROOT="${LLVM_PROJECT_SRC_ROOT:-${SRC_ROOT}}"

LLVM_BUILD_PATH=${BUILD_ROOT}/llvm

mkdir -p ${LLVM_BUILD_PATH}
cd ${LLVM_BUILD_PATH}
cmake -G Ninja ${LLVM_PROJECT_SRC_ROOT}/llvm \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DLLVM_ENABLE_SPHINX=False \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lldb;lld" \
    -DLLVM_INCLUDE_TESTS=False \
    -DLLVM_ABI_BREAKING_CHECKS=WITH_ASSERTS \
    -DLLVM_TARGETS_TO_BUILD="ARM" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="armv7em-none-eabi"
cmake --build .
cmake --build . --target install

PATH=${PATH}:${INSTALL_PREFIX}/bin
file ${INSTALL_PREFIX}/bin/* | grep ELF | cut -d: -f1 | xargs strip
rm ${INSTALL_PREFIX}/lib/*.a
