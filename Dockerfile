# run as "docker build -t burnpanck/llvm-armeabi-newlib ."
FROM alpine:latest as build

LABEL description=""
LABEL maintainer=""

RUN apk update
RUN apk add build-base ninja cmake git patch vim python2 curl bash

ENV TOOLCHAIN_ROOT /toolchain

WORKDIR ${TOOLCHAIN_ROOT}/scripts
#COPY *.sh ./
COPY config.sh ./
COPY patches/*.patch patches/

RUN mkdir ${TOOLCHAIN_ROOT}/src
RUN mkdir ${TOOLCHAIN_ROOT}/build
RUN mkdir ${TOOLCHAIN_ROOT}/dist

COPY 010-download-newlib.sh ./
RUN ./010-download-newlib.sh
COPY 020-download-llvm-8.sh ./
RUN ./020-download-llvm.sh
COPY "030-download-libc++.sh" ./
RUN ./030-download-libc++.sh
COPY 040-build-llvm9.sh ./
RUN ./040-build-llvm.sh
COPY 050-build-newlib.sh ./
RUN ./050-build-newlib.sh
COPY 060-build-compiler-rt-llvm8.sh ./
RUN ./060-build-compiler-rt.sh
COPY "070-build-libc++.sh" ./
RUN ./070-build-libc++.sh

RUN mkdir ${TOOLCHAIN_ROOT}/dist/cmake
COPY assets/armv7em-eabi-none-toolchain.cmake ${TOOLCHAIN_ROOT}/dist/cmake

FROM alpine:latest

RUN apk update && apk add ninja cmake git curl bash

COPY --from=build /toolchain/dist /toolchain