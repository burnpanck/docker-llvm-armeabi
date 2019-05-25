#!/usr/bin/env bash
# Download newlib and C runtime libraries
# requirements:
#  - curl
#  - patch

set -e
set -o errexit

source ./config.sh

echo "Downloading newlib to SRC_ROOT=${SRC_ROOT}"


cd ${SRC_ROOT}

[ -d compiler-rt ] && rm -rf compiler-rt
curl -LO https://releases.llvm.org/8.0.0/compiler-rt-8.0.0.src.tar.xz && \
    [ "b435c7474f459e71b2831f1a4e3f1d21203cb9c0172e94e9d9b69f50354f21b1" = \
      "$(sha256sum compiler-rt-8.0.0.src.tar.xz | cut -d' ' -f1)" ] && \
    tar xf compiler-rt-8.0.0.src.tar.xz && \
    mv compiler-rt-8.0.0.src compiler-rt
(cd compiler-rt && patch -p2 < ${SCRIPT_ROOT}/patches/compiler_rt-CMakeLists.patch)

[ -d newlib ] && rm -rf newlib
curl -LO ftp://sourceware.org/pub/newlib/newlib-3.1.0.tar.gz && \
     [ "fb4fa1cc21e9060719208300a61420e4089d6de6ef59cf533b57fe74801d102a" = \
       "$(sha256sum newlib-3.1.0.tar.gz | cut -d' ' -f1)" ] && \
     tar xf newlib-3.1.0.tar.gz && \
     mv newlib-3.1.0 newlib
(cd newlib && patch -p1 < ${SCRIPT_ROOT}/patches/newlib-arm-eabi-3.1.0-linux.patch)
