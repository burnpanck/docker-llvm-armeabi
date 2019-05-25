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

source ./config.sh

mkdir -p ${SRC_ROOT}/compiler-rt/cortex-m/
cp ${SCRIPT_ROOT}/patches/compiler_rt-cortex-m-CMakeLists.txt ${SRC_ROOT}/compiler-rt/cortex-m/CMakeLists.txt

mkdir -p ${BUILD_ROOT}/compiler_rt
cd ${BUILD_ROOT}/compiler_rt
cmake -G Ninja ${SRC_ROOT}/compiler-rt/cortex-m \
    -DXTARGET=${XTARGET} -DXCPU=${XCPU} -DXCPUDIR=${XCPUDIR} \
    -DXCFLAGS="${XFPU}" -DXCLANG=${INSTALL_PREFIX}/bin/clang
cmake --build .
cp libcompiler_rt.a ${INSTALL_PREFIX}/${XTARGET}/${XCPUDIR}/lib/
