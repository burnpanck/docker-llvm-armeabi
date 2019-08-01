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

[ -d newlib ] && rm -rf newlib
curl -LO ftp://sourceware.org/pub/newlib/newlib-3.1.0.tar.gz && \
     [ "fb4fa1cc21e9060719208300a61420e4089d6de6ef59cf533b57fe74801d102a" = \
       "$(sha256sum newlib-3.1.0.tar.gz | cut -d' ' -f1)" ] && \
     tar xf newlib-3.1.0.tar.gz && \
     mv newlib-3.1.0 newlib
(cd newlib && patch -p1 < ${SCRIPT_ROOT}/patches/newlib-arm-eabi-3.1.0-linux.patch)
