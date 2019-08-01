#!/usr/bin/env bash

SRC_ROOT=${TOOLCHAIN_ROOT}/src
BUILD_ROOT=${TOOLCHAIN_ROOT}/build
INSTALL_PREFIX=${TOOLCHAIN_ROOT}/dist
SCRIPT_ROOT=`pwd`

XTARGET=armv7em-none-eabi
XCPU=cortex-m4
XCPUDIR=cortex-m4f
XFPU="-mfloat-abi=hard -mfpu=fpv4-sp-d16"
XABI="-mthumb -mabi=aapcs"

XOPTFLAGS="-g -O2 -fomit-frame-pointer -fdata-sections -ffunction-sections"

SYSROOT=${INSTALL_PREFIX}/${XTARGET}/${XCPUDIR}

PATH=$PATH:${INSTALL_PREFIX}/bin

