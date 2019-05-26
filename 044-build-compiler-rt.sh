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

CXX_FLAGS="-O3 -g --target=${XTARGET} -mcpu=${XCPU} ${XFPU} ${XABI} -fomit-frame-pointer"
CXX_DEFINES=""
CXX_INCLUDE_PATH=""

COMPILER_FLAGS="${CXX_FLAGS} ${CXX_DEFINES} ${CXX_INCLUDE_PATH}"

mkdir -p ${BUILD_ROOT}/compiler-rt
cd ${BUILD_ROOT}/compiler-rt
cmake -GNinja -Wno-dev \
   -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
   -DCMAKE_SYSTEM_PROCESSOR=arm \
   -DCMAKE_SYSTEM_NAME=Generic \
   -DCMAKE_CROSSCOMPILING=ON \
   -DUNIX=1 \
   -DCMAKE_CXX_COMPILER_FORCED=TRUE \
   -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_C_COMPILER_TARGET=${XTARGET} \
   -DCMAKE_ASM_COMPILER_TARGET=${XTARGET} \
   -DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang \
   -DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++ \
   -DCMAKE_LINKER=${INSTALL_PREFIX}/bin/clang \
   -DCMAKE_AR=${INSTALL_PREFIX}/bin/llvm-ar \
   -DCMAKE_RANLIB=${INSTALL_PREFIX}/bin/llvm-ranlib \
   -DLLVM_CONFIG_PATH=${BUILD_ROOT}/llvm/bin/llvm-config \
   -DLLVM_ABI_BREAKING_CHECKS=WITH_ASSERTS \
   -DLLVM_TARGETS_TO_BUILD="ARM" \
   -DCMAKE_SYSROOT=${SYSROOT} \
   -DCMAKE_SYSROOT_LINK=${SYSROOT} \
   -DCMAKE_C_FLAGS="${COMPILER_FLAGS}" \
   -DCMAKE_ASM_FLAGS="${COMPILER_FLAGS}" \
   -DCMAKE_CXX_FLAGS="${COMPILER_FLAGS}" \
   -DCMAKE_EXE_LINKER_FLAGS=-L${SYSROOT}/lib \
   -DCOMPILER_RT_OS_DIR="baremetal" \
   -DCOMPILER_RT_BUILD_BUILTINS=ON \
   -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
   -DCOMPILER_RT_BUILD_XRAY=OFF \
   -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
   -DCOMPILER_RT_BUILD_PROFILE=OFF \
   -DCOMPILER_RT_BAREMETAL_BUILD=ON \
   -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
   -DCOMPILER_RT_INCLUDE_TESTS=OFF \
   -DCOMPILER_RT_USE_LIBCXX=ON \
    ${SRC_ROOT}/compiler-rt
cmake --build .
cmake --build . --target install


# due to a bug in clang (https://bugs.llvm.org/show_bug.cgi?id=34578),
# the builtins are found with the wrong name - just create a link here to fix it
ln -fs libclang_rt.builtins-armv7em.a ${INSTALL_PREFIX}/lib/baremetal/libclang_rt.builtins-armv7em.a.a
