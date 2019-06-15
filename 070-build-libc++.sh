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

CXX_OPTIONS="-Os -g --target=${XTARGET} -mcpu=${XCPU} ${XFPU} ${XABI} ${XOPTFLAGS} -fno-stack-protector -fvisibility=hidden"
CXX_DEFINES="-D_LIBUNWIND_IS_BAREMETAL=1 -D_GNU_SOURCE=1 -D_POSIX_TIMERS=1 -D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION"
CXX_INCLUDE_PATH="-I${SRC_ROOT}/libunwind/include -I${SRC_ROOT}/libcxxabi/include -I${SRC_ROOT}/libcxx/include -I${SYSROOT}/include"
CXX_LINK_PATH="-L${SYSROOT}/lib -L${INSTALL_PREFIX}/lib/baremetal"

CXX_FLAGS="${CXX_OPTIONS} ${CXX_DEFINES} ${CXX_INCLUDE_PATH}"
LIBCXX_FLAGS="${CXX_FLAGS}"
LIBUNWIND_FLAGS="${CXX_FLAGS} -D_LIBCPP_HAS_NO_THREADS"
LIBCXXABI_FLAGS="${CXX_FLAGS} -D_LIBCPP_HAS_NO_THREADS"

# build libunwind
mkdir -p ${BUILD_ROOT}/libunwind
(
    set -e
    cd ${BUILD_ROOT}/libunwind
    cmake -GNinja -Wno-dev \
       -DCMAKE_SYSTEM_PROCESSOR=arm \
       -DCMAKE_SYSTEM_NAME=Generic \
       -DCMAKE_CROSSCOMPILING=ON \
       -DUNIX=1 \
       -DCMAKE_CXX_COMPILER_FORCED=TRUE \
       -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang \
       -DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++ \
       -DCMAKE_LINKER=${INSTALL_PREFIX}/bin/clang \
       -DCMAKE_AR=${INSTALL_PREFIX}/bin/llvm-ar \
       -DCMAKE_RANLIB=${INSTALL_PREFIX}/bin/llvm-ranlib \
       -DLLVM_CONFIG_PATH=${BUILD_ROOT}/llvm/bin/llvm-config \
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
       -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang \
       -DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++ \
       -DCMAKE_LINKER=${INSTALL_PREFIX}/bin/clang \
       -DCMAKE_AR=${INSTALL_PREFIX}/bin/llvm-ar \
       -DCMAKE_RANLIB=${INSTALL_PREFIX}/bin/llvm-ranlib \
       -DLLVM_CONFIG_PATH=${BUILD_ROOT}/llvm/bin/llvm-config \
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
       -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang \
       -DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++ \
       -DCMAKE_LINKER=${INSTALL_PREFIX}/bin/clang \
       -DCMAKE_AR=${INSTALL_PREFIX}/bin/llvm-ar \
       -DCMAKE_RANLIB=${INSTALL_PREFIX}/bin/llvm-ranlib \
       -DLLVM_CONFIG_PATH=${BUILD_ROOT}/llvm/bin/llvm-config \
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

