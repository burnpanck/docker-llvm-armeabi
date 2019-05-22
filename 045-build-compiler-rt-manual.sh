#!/usr/bin/env bash
# Build runtime
# parameters:
#  - SCRIPT_ROOT
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
CLANG_PATH=${INSTALL_PREFIX}/clang-8.0

XTARGET=armv7em-none-eabi
XCPU=cortex-m4
XCPUDIR=cortex-m4f
XFPU="-mfloat-abi=hard -mfpu=fpv4-sp-d16"
PATH=$PATH:${CLANG_PATH}/bin

mkdir -p ${SRC_ROOT}/compiler-rt/cortex-m/
cp ${SCRIPT_ROOT}/patches/compiler_rt-cortex-m-CMakeLists.txt ${SRC_ROOT}/compiler-rt/cortex-m/CMakeLists.txt

mkdir -p ${BUILD_ROOT}/compiler_rt
cd ${BUILD_ROOT}/compiler_rt
cmake -G Ninja ${SRC_ROOT}/compiler-rt/cortex-m \
    -DXTARGET=${XTARGET} -DXCPU=${XCPU} -DXCPUDIR=${XCPUDIR} \
    -DXCFLAGS="${XFPU}" -DXCLANG=${CLANG_PATH}/bin/clang
cmake --build .
cp libcompiler_rt.a ${CLANG_PATH}/${XTARGET}/${XCPUDIR}/lib/
