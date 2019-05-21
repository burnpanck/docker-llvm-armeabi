#!/usr/bin/env bash

# TODO: signatures!
curl -LO https://releases.llvm.org/8.0.0/libcxx-8.0.0.src.tar.xz && \
    [ "8872be1b12c61450cacc82b3d153eab02be2546ef34fa3580ed14137bb26224c" = \
      "$(sha256sum libcxx-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxx-8.0.0.src.tar.xz && \
    mv libcxx-8.0.0.src libcxx

curl -LO https://releases.llvm.org/8.0.0/libcxxabi-8.0.0.src.tar.xz && \
    [ "8872be1b12c61450cacc82b3d153eab02be2546ef34fa3580ed14137bb26224c" = \
      "$(sha256sum libcxxabi-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf libcxxabi-8.0.0.src.tar.xz && \
    mv libcxxabi-8.0.0.src libcxxabi

curl -LO https://releases.llvm.org/8.0.0/libunwind-8.0.0.src.tar.xz && \
    [ "8872be1b12c61450cacc82b3d153eab02be2546ef34fa3580ed14137bb26224c" = \
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
EOS
