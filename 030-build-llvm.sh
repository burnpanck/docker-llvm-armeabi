#!/usr/bin/env bash
# Build LLVM
# parameters:
#  - SRC_ROOT
#  - BUILD_ROOT
#  - INSTALL_PREFIX
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


set -e
set -o errexit

source ./config.sh

LLVM_BUILD_PATH=${BUILD_ROOT}/llvm

mkdir -p ${LLVM_BUILD_PATH}
cd ${LLVM_BUILD_PATH}
cmake -G Ninja ${SRC_ROOT}/llvm \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DLLVM_ENABLE_SPHINX=False \
    -DLLVM_INCLUDE_TESTS=False \
    -DLLVM_TARGETS_TO_BUILD="ARM" \
    -DCLANG_ANALYZER_ENABLE_Z3_SOLVER=OFF # this last one is just needed on my ubuntu machine because of an incompatible version being present
cmake --build .
cmake --build . --target install

PATH=${PATH}:${INSTALL_PREFIX}/bin
file ${INSTALL_PREFIX}/bin/* | grep ELF | cut -d: -f1 | xargs strip
rm ${INSTALL_PREFIX}/lib/*.a
