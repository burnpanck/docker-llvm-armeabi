#!/usr/bin/env bash
# Download libc++ and friends
# parameters:
#  - SRC_ROOT
# requirements:
#  - curl

set -e
set -o errexit

cd ${SRC_ROOT}

curl -LO https://releases.llvm.org/8.0.0/libcxx-8.0.0.src.tar.xz && \
    [ "c2902675e7c84324fb2c1e45489220f250ede016cc3117186785d9dc291f9de2" = \
      "$(sha256sum libcxx-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxx-8.0.0.src.tar.xz && \
    mv libcxx-8.0.0.src libcxx

curl -LO https://releases.llvm.org/8.0.0/libcxxabi-8.0.0.src.tar.xz && \
    [ "c2d6de9629f7c072ac20ada776374e9e3168142f20a46cdb9d6df973922b07cd" = \
      "$(sha256sum libcxxabi-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxxabi-8.0.0.src.tar.xz && \
    mv libcxxabi-8.0.0.src libcxxabi

curl -LO https://releases.llvm.org/8.0.0/libunwind-8.0.0.src.tar.xz && \
    [ "ff243a669c9cef2e2537e4f697d6fb47764ea91949016f2d643cb5d8286df660" = \
      "$(sha256sum libunwind-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libunwind-8.0.0.src.tar.xz && \
    mv libunwind-8.0.0.src libunwind


# TODO: patch all three CMakeLists with:
patch :p0, <<~EOS
  --- CMakeLists.txt  (revision 331442)
  +++ CMakeLists.txt  (working copy)
  @@ -12,6 +12,12 @@
     cmake_policy(SET CMP0022 NEW) # Required when interacting with LLVM and Clang
   endif()

  +FOREACH (arg ${EXTRA_CX_FLAGS})
  +  SET (COMPILE_FLAGS "${COMPILE_FLAGS} ${arg}")
  +ENDFOREACH ()
  +SET (CMAKE_C_FLAGS "${COMPILE_FLAGS}")
  +SET (CMAKE_CXX_FLAGS "${COMPILE_FLAGS}")
  +
   # Add path for custom modules
   set(CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
~EOS
