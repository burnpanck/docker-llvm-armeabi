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

LLVM_PROJECT_SRC_ROOT="${LLVM_PROJECT_SRC_ROOT:-${SRC_ROOT}}"

CXX_OPTIONS="-Os -g --target=${XTARGET} -mcpu=${XCPU} ${XFPU} ${XABI} ${XOPTFLAGS} -fno-stack-protector -fvisibility=hidden"

CXX_DEFINES="-D_LIBUNWIND_IS_BAREMETAL=1 -D_GNU_SOURCE=1 -D_POSIX_TIMERS=1 -D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION"
# "-D_LIBUNWIND_IS_BAREMETAL=1": Otherwise libunwind tries to utilise system facilities to deal with dynamically loaded libraries
# "-D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION": Our newlib seems to be missig the required functions
# "-D_GNU_SOURCE=1 -D_POSIX_TIMERS=1": Fixes "undeclared identifier locale_t" and "clock_gettime"

CXX_INCLUDE_PATH="-I${SYSROOT}/include"
CXX_LINK_PATH="-L${SYSROOT}/lib -L${INSTALL_PREFIX}/lib/baremetal"

CXX_FLAGS="${CXX_OPTIONS} ${CXX_DEFINES} ${CXX_INCLUDE_PATH}"
LIBUNWIND_FLAGS="${CXX_FLAGS} -D_LIBCPP_HAS_NO_THREADS"
LIBCXXABI_FLAGS="${CXX_FLAGS} -D_LIBCPP_HAS_NO_THREADS"
LIBCXX_FLAGS="${CXX_FLAGS}"

#-Wno-dev

cmake_args=$(cat <<EOM
-GNinja
-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
-DCMAKE_SYSTEM_PROCESSOR=arm
-DCMAKE_SYSTEM_NAME=Generic
-DCMAKE_CROSSCOMPILING=ON
-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
-DUNIX=1
-DCMAKE_CXX_COMPILER_FORCED=TRUE
-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang
-DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++
-DCMAKE_LINKER=${INSTALL_PREFIX}/bin/clang
-DCMAKE_AR=${INSTALL_PREFIX}/bin/llvm-ar
-DCMAKE_RANLIB=${INSTALL_PREFIX}/bin/llvm-ranlib
-DLLVM_CONFIG_PATH=${BUILD_ROOT}/llvm/bin/llvm-config
-DLLVM_ABI_BREAKING_CHECKS=WITH_ASSERTS
-DCMAKE_SYSROOT=${SYSROOT}
-DCMAKE_SYSROOT_LINK=${SYSROOT}
EOM
)

LLVM_CMAKE_CONFIG=()
while read -r line; do LLVM_CMAKE_CONFIG+=("$line"); done <<<"$cmake_args"

#echo cmake ${LLVM_CMAKE_CONFIG[@]} \
#   LAST_ARG

printf '%s\n' "${LLVM_CMAKE_CONFIG[@]}"

echo "**** configure libcxx and install headers..."
rm -r ${BUILD_ROOT}/libcxx || true
mkdir -p ${BUILD_ROOT}/libcxx
(
    set -e
    cd ${BUILD_ROOT}/libcxx
    # add LIBCXX_ABI_UNSTABLE?
    cmake ${LLVM_CMAKE_CONFIG[@]} \
       -DCMAKE_C_FLAGS="${LIBCXX_FLAGS}" \
       -DCMAKE_CXX_FLAGS="${LIBCXX_FLAGS}" \
       -DCMAKE_EXE_LINKER_FLAGS="${CXX_LINK_PATH}" \
       -DLIBCXX_ENABLE_SHARED=OFF \
       -DLIBCXX_ENABLE_FILESYSTEM=OFF \
       -DLIBCXX_ENABLE_THREADS=OFF \
       -DLIBCXX_ENABLE_MONOTONIC_CLOCK=OFF \
       -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF \
       -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=ON \
       -DLIBCXX_INCLUDE_TESTS=OFF \
       -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
       -DLIBCXX_USE_COMPILER_RT=ON \
       -DLIBCXX_CXX_ABI=libcxxabi \
       -DLIBCXX_CXX_ABI_INCLUDE_PATHS="${LLVM_PROJECT_SRC_ROOT}/libcxxabi/include" \
       -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
       -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
        ${LLVM_PROJECT_SRC_ROOT}/libcxx
    cmake --build . --target cxx_abi_headers
    cmake --build . --target install-cxx-headers
)


echo "**** configure libunwind and install headers..."
rm -r ${BUILD_ROOT}/libunwind || true
mkdir -p ${BUILD_ROOT}/libunwind
(
    set -e
    cd ${BUILD_ROOT}/libunwind
    cmake ${LLVM_CMAKE_CONFIG[@]} \
       -DCMAKE_C_FLAGS="${LIBUNWIND_FLAGS}" \
       -DCMAKE_CXX_FLAGS="${LIBUNWIND_FLAGS}" \
       -DCMAKE_EXE_LINKER_FLAGS="${CXX_LINK_PATH}" \
       -DLIBUNWIND_ENABLE_ASSERTIONS=1 \
       -DLIBUNWIND_ENABLE_PEDANTIC=1 \
       -DLIBUNWIND_ENABLE_SHARED=OFF \
       -DLIBUNWIND_ENABLE_THREADS=OFF \
       -DLLVM_ENABLE_LIBCXX=TRUE \
        ${LLVM_PROJECT_SRC_ROOT}/libunwind
#    cmake --build . --target install-cxx-headers
)

echo "**** configure libcxxabi and install headers..."
rm -r ${BUILD_ROOT}/libcxxabi || true
mkdir -p ${BUILD_ROOT}/libcxxabi
(
    set -e
    cd ${BUILD_ROOT}/libcxxabi
    cmake ${LLVM_CMAKE_CONFIG[@]} \
       -DCMAKE_C_FLAGS="${LIBCXXABI_FLAGS}" \
       -DCMAKE_CXX_FLAGS="${LIBCXXABI_FLAGS}" \
       -DCMAKE_EXE_LINKER_FLAGS="${CXX_LINK_PATH}" \
       -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
       -DLIBCXXABI_USE_COMPILER_RT=ON \
       -DLIBCXXABI_ENABLE_THREADS=OFF \
       -DLIBCXXABI_ENABLE_SHARED=OFF \
       -DLIBCXXABI_BAREMETAL=ON \
       -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
       -DLIBCXXABI_SILENT_TERMINATE=ON \
       -DLIBCXXABI_INCLUDE_TESTS=OFF \
       -DLIBCXXABI_LIBCXX_SRC_DIRS="${SRC_ROOT}/libcxx" \
       -DLIBCXXABI_LIBUNWIND_LINK_FLAGS="-L${BUILD_ROOT}/libunwind/lib" \
        ${LLVM_PROJECT_SRC_ROOT}/libcxxabi
)


echo "**** build libunwind"
(
    set -e
    cd ${BUILD_ROOT}/libunwind
    cmake --build .
    cmake --build . --target install
)

echo "**** build libcxxabi"
mkdir -p ${BUILD_ROOT}/libcxxabi
(
    set -e
    cd ${BUILD_ROOT}/libcxxabi
    cmake --build .
    cmake --build . --target install
)

echo "**** build libcxx"
(
    set -e
    cd ${BUILD_ROOT}/libcxx
    cmake --build .
    cmake --build . --target install
)

