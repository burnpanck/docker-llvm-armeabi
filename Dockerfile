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
COPY 020-download-llvm.sh ./
RUN ./020-download-llvm.sh
COPY "025-download-libc++.sh" ./
RUN ./025-download-libc++.sh
COPY 030-build-llvm.sh ./
RUN ./030-build-llvm.sh
COPY 040-build-newlib.sh ./
RUN ./040-build-newlib.sh
COPY 044-build-compiler-rt.sh ./
RUN ./044-build-compiler-rt.sh
COPY "050-build-libc++.sh" ./
RUN ./050-build-libc++.sh