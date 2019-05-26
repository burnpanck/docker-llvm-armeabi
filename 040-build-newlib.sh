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

mkdir -p ${BUILD_ROOT}/newlib
cd ${BUILD_ROOT}/newlib

export CC_FOR_TARGET=${INSTALL_PREFIX}/bin/clang
export CXX_FOR_TARGET=${INSTALL_PREFIX}/bin/clang++
export AR_FOR_TARGET=${INSTALL_PREFIX}/bin/llvm-ar
export NM_FOR_TARGET=${INSTALL_PREFIX}/bin/llvm-nm
export RANLIB_FOR_TARGET=${INSTALL_PREFIX}/bin/llvm-ranlib
export READELF_FOR_TARGET=${INSTALL_PREFIX}/bin/llvm-readelf
export CFLAGS_FOR_TARGET="-target ${XTARGET} -mcpu=${XCPU} ${XFPU} ${XABI} -g -O3 -ffunction-sections -fdata-sections -Wno-unused-command-line-argument"
export AS_FOR_TARGET=${INSTALL_PREFIX}/bin/clang
export LD_FOR_TARGET=${INSTALL_PREFIX}/bin/clang

${SRC_ROOT}/newlib/configure \
    --host=`cc -dumpmachine`\
    --build=`cc -dumpmachine`\
    --target=${XTARGET}\
    --prefix=${INSTALL_PREFIX}/${XTARGET}/${XCPUDIR}\
    --disable-newlib-supplied-syscalls\
    --enable-newlib-reent-small\
    --disable-newlib-fvwrite-in-streamio\
    --disable-newlib-fseek-optimization\
    --disable-newlib-wide-orient\
    --enable-newlib-nano-malloc\
    --disable-newlib-unbuf-stream-opt\
    --enable-lite-exit\
    --enable-newlib-global-atexit\
    --enable-newlib-nano-formatted-io \
    --disable-newlib-fvwrite-in-streamio \
    --disable-nls

#    --disable-newlib-nano-formatted-io \
#    --enable-newlib-io-c99-formats \
#    --enable-newlib-io-float \
#    --disable-newlib-io-long-double \

make
make install
cp -rf ${INSTALL_PREFIX}/${XTARGET}/${XCPUDIR}/${XTARGET}/* \
    ${INSTALL_PREFIX}/${XTARGET}/${XCPUDIR}/
rm -r ${INSTALL_PREFIX}/${XTARGET}/${XCPUDIR}/${XTARGET}
