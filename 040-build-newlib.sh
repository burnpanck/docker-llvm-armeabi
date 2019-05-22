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

mkdir -p ${BUILD_ROOT}/newlib
cd ${BUILD_ROOT}/newlib
export CC_FOR_TARGET=${CLANG_PATH}/bin/clang
export AR_FOR_TARGET=${CLANG_PATH}/bin/llvm-ar
export NM_FOR_TARGET=${CLANG_PATH}/bin/llvm-nm
export RANLIB_FOR_TARGET=${CLANG_PATH}/bin/llvm-ranlib
export READELF_FOR_TARGET=${CLANG_PATH}/bin/llvm-readelf
export CFLAGS_FOR_TARGET="-target ${XTARGET} -mcpu=${XCPU} ${XFPU} -mthumb -mabi=aapcs -g -O3 -ffunction-sections -fdata-sections -Wno-unused-command-line-argument"
export AS_FOR_TARGET="${CLANG_PATH}/bin/clang"
${SRC_ROOT}/newlib/configure \
    --host=`cc -dumpmachine`\
    --build=`cc -dumpmachine`\
    --target=${XTARGET}\
    --prefix=${CLANG_PATH}/${XTARGET}/${XCPUDIR}\
    --disable-newlib-supplied-syscalls\
    --enable-newlib-reent-small\
    --disable-newlib-fvwrite-in-streamio\
    --disable-newlib-fseek-optimization\
    --disable-newlib-wide-orient\
    --enable-newlib-nano-malloc\
    --disable-newlib-unbuf-stream-opt\
    --enable-lite-exit\
    --enable-newlib-global-atexit\
    --disable-newlib-nano-formatted-io \
    --disable-newlib-fvwrite-in-streamio \
    --enable-newlib-io-c99-formats \
    --enable-newlib-io-float \
    --disable-newlib-io-long-double \
    --disable-nls
make
make install
mv ${CLANG_PATH}/${XTARGET}/${XCPUDIR}/${XTARGET}/* \
    ${CLANG_PATH}/${XTARGET}/${XCPUDIR}/
rmdir ${CLANG_PATH}/${XTARGET}/${XCPUDIR}/${XTARGET}
