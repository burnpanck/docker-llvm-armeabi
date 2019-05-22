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
XABI="-mthumb -mabi=aapcs"

SYSROOT=${CLANG_PATH}/${XTARGET}/${XCPUDIR}

PATH=$PATH:${CLANG_PATH}/bin


CXX_FLAGS="-O3 -g --target=${XTARGET} -mcpu=${XCPU} ${XFPU} ${XABI} ${CXX_DEFINES}"
CXX_DEFINES="-D_LIBUNWIND_IS_BAREMETAL=1 -D_GNU_SOURCE=1 -D_POSIX_TIMERS=1"
CXX_INCLUDE_PATH="-I${SRC_ROOT}/libunwind/include -I${SRC_ROOT}/libcxxabi/include -I${SRC_ROOT}/libcxx/include -I${SYSROOT}/include"
CXX_LINK_PATH="-L${SYSROOT}/lib -L${CLANG_PATH}/lib/baremetal"

LIBCXX_FLAGS="${CXX_FLAGS} ${CXX_DEFINES} ${CXX_INCLUDE_PATH}"
LIBUNWIND_FLAGS="${LIBCXX_FLAGS} -D_LIBCPP_HAS_NO_THREADS"
LIBCXXABI_FLAGS="${LIBUNWIND_FLAGS}"

# build libunwind
mkdir -p ${BUILD_ROOT}/libunwind
(
    set -e
    cd ${BUILD_ROOT}/libunwind
    cmake -GNinja -Wno-dev \
       -DCMAKE_SYSTEM_PROCESSOR=arm \
       -G Ninja -Wno-dev \
       -DCMAKE_SYSTEM_PROCESSOR=arm \
       -DCMAKE_SYSTEM_NAME=Generic \
       -DCMAKE_CROSSCOMPILING=ON \
       -DUNIX=1 \
       -DCMAKE_CXX_COMPILER_FORCED=TRUE \
       -DCMAKE_INSTALL_PREFIX=${CLANG_PATH} \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=${CLANG_PATH}/bin/clang \
       -DCMAKE_CXX_COMPILER=${CLANG_PATH}/bin/clang++ \
       -DCMAKE_LINKER=${CLANG_PATH}/bin/clang \
       -DCMAKE_AR=${CLANG_PATH}/bin/llvm-ar \
       -DCMAKE_RANLIB=${CLANG_PATH}/bin/llvm-ranlib \
       -DLLVM_ABI_BREAKING_CHECKS=WITH_ASSERTS \
       -DCMAKE_SYSROOT=${SYSROOT} \
       -DCMAKE_SYSROOT_LINK=${SYSROOT} \
       -DCMAKE_C_FLAGS="${LIBUNWIND_FLAGS}" \
       -DCMAKE_CXX_FLAGS="${LIBUNWIND_FLAGS}" \
       -DCMAKE_EXE_LINKER_FLAGS="${CXX_LINK_PATH}" \
       -DCXX_SUPPORTS_CXX11=TRUE \
       -DLIBUNWIND_ENABLE_ASSERTIONS=1 \
       -DLIBUNWIND_ENABLE_PEDANTIC=1 \
       -DLIBUNWIND_ENABLE_SHARED=OFF \
       -DLIBUNWIND_ENABLE_THREADS=OFF \
       -DLLVM_ENABLE_LIBCXX=TRUE \
        ${SRC_ROOT}/libunwind
    cmake --build .
    cmake --build . --target install
)

# build libcxxabi
mkdir -p ${BUILD_ROOT}/libcxxabi
(
    set -e
    cd ${BUILD_ROOT}/libcxxabi
    cmake -GNinja -Wno-dev \
       -DCMAKE_SYSTEM_PROCESSOR=arm \
       -DCMAKE_SYSTEM_NAME=Generic \
       -DCMAKE_CROSSCOMPILING=ON \
       -DUNIX=1 \
       -DCMAKE_CXX_COMPILER_FORCED=TRUE \
       -DCMAKE_INSTALL_PREFIX=${CLANG_PATH} \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=${CLANG_PATH}/bin/clang \
       -DCMAKE_CXX_COMPILER=${CLANG_PATH}/bin/clang++ \
       -DCMAKE_LINKER=${CLANG_PATH}/bin/clang \
       -DCMAKE_AR=${CLANG_PATH}/bin/llvm-ar \
       -DCMAKE_RANLIB=${CLANG_PATH}/bin/llvm-ranlib \
       -DLLVM_ABI_BREAKING_CHECKS=WITH_ASSERTS \
       -DCMAKE_SYSROOT=${SYSROOT} \
       -DCMAKE_SYSROOT_LINK=${SYSROOT} \
       -DCMAKE_C_FLAGS="${LIBCXXABI_FLAGS}" \
       -DCMAKE_CXX_FLAGS="${LIBCXXABI_FLAGS}" \
       -DCMAKE_EXE_LINKER_FLAGS="${CXX_LINK_PATH}" \
       -DCXX_SUPPORTS_CXX11=TRUE \
       -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
       -DLIBCXXABI_USE_COMPILER_RT=ON \
       -DLIBCXXABI_ENABLE_THREADS=OFF \
       -DLIBCXXABI_ENABLE_SHARED=OFF \
       -DLIBCXXABI_BAREMETAL=ON \
       -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
       -DLIBCXXABI_INCLUDE_TESTS=OFF \
       -DLIBCXXABI_LIBUNWIND_INCLUDES=${SRC_ROOT}/libunwind/include \
       -DLIBCXXABI_LIBCXX_INCLUDES=${SRC_ROOT}/libcxx/include \
       -DCXX_SUPPORTS_CXX11=TRUE \
       -DLIBUNWIND_ENABLE_ASSERTIONS=1 \
       -DLIBUNWIND_ENABLE_PEDANTIC=1 \
       -DLIBUNWIND_ENABLE_SHARED=OFF \
       -DLIBUNWIND_ENABLE_THREADS=OFF \
       -DLLVM_ENABLE_LIBCXX=TRUE \
        ${SRC_ROOT}/libcxxabi
    cmake --build .
    cmake --build . --target install
)

# build libcxx
mkdir -p ${BUILD_ROOT}/libcxx
(
    set -e
    cd ${BUILD_ROOT}/libcxx
    cmake -GNinja -Wno-dev \
       -DCMAKE_SYSTEM_PROCESSOR=arm \
       -DCMAKE_SYSTEM_NAME=Generic \
       -DCMAKE_CROSSCOMPILING=ON \
       -DUNIX=1 \
       -DCMAKE_CXX_COMPILER_FORCED=TRUE \
       -DCMAKE_INSTALL_PREFIX=${CLANG_PATH} \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=${CLANG_PATH}/bin/clang \
       -DCMAKE_CXX_COMPILER=${CLANG_PATH}/bin/clang++ \
       -DCMAKE_LINKER=${CLANG_PATH}/bin/clang \
       -DCMAKE_AR=${CLANG_PATH}/bin/llvm-ar \
       -DCMAKE_RANLIB=${CLANG_PATH}/bin/llvm-ranlib \
       -DLLVM_ABI_BREAKING_CHECKS=WITH_ASSERTS \
       -DCMAKE_SYSROOT=${SYSROOT} \
       -DCMAKE_SYSROOT_LINK=${SYSROOT} \
       -DCMAKE_C_FLAGS="${LIBCXX_FLAGS}" \
       -DCMAKE_CXX_FLAGS="${LIBCXX_FLAGS}" \
       -DCMAKE_EXE_LINKER_FLAGS="${CXX_LINK_PATH}" \
       -DCXX_SUPPORTS_CXX11=TRUE \
       -DLIBCXX_ENABLE_SHARED=OFF \
       -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=ON \
       -DLIBCXX_ENABLE_FILESYSTEM=OFF \
       -DLIBCXX_INCLUDE_TESTS=OFF \
       -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
       -DLIBCXX_ENABLE_MONOTONIC_CLOCK=OFF \
       -DLIBCXX_USE_COMPILER_RT=ON \
       -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF \
       -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
       -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
       -DLIBCXX_ENABLE_THREADS=OFF \
       -DLIBCXX_CXX_ABI=libcxxabi \
        ${SRC_ROOT}/libcxx
    cmake --build .
    cmake --build . --target install
)

