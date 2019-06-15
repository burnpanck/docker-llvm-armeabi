# Docker image with LLVM/Clang 8.0 for armv7em-none-eabi (Cortex M4), with newlib-nano and libc++

## Credits

Most of the code here is based on code from the
[Homebrew armeabi taps by Emmanuel Blot](https://github.com/eblot/homebrew-armeabi).

## Contents

This repositories contsains scripts to build the following projects
for ARMv7em targets:
 - **LLVM/Clang 8.0** (including **LLD**)
 - **Newlib 3.1.0**:
   Configured in a *nano* configuration, to reduce size for bare-metal applications.
 - **libcompiler-rt**, version 8.0 from the LLVM project
 - **libc++** (plus *libc++abi* and *libunwind*), version 8.0 from the LLVM project.
   Some features are disabled. Namely threading,
   which unfortunately also disables the `<atomic>` header.

## How to use

### Building the toolchain

The toolchain can be built into a docker image
by running
`docker build -t burnpanck/llvm-armeabi-newlib .`
in the top-level directory.

Alternatively, the toolchain can be built outside of docker
on an UNIX-like system by executing
`TOOLCHAIN_ROOT=/path/to/toolchain/root ./build.sh`

### Building for ARMv7em in the docker image

The image is still rough around the edges;
environment variables are not set,
that needs to be done while using.
The following are generally needed:
 - `PATH=/toolchain/bin:$PATH`: The location of `clang`, `clang++`, `lld` etc.
 - *SYSROOT*: Is that needed at all?
 - Header include paths:
   - `/toolchain/`
 - Library search paths: 

## Limitations

This toolchain has successfully been applied to compile working bare-metal firmware for Cortex M4F.
However, the toolchain requires some manual work, i.e.

### libc++
 - The header `<atomic>` is disabled in libc++
   when the library is built without threadings support.
   However, atomics are useful on bare-metal even when
   there is no threading OS, e.g. in presence of interrupts.
   However, if our newlib build supports C11 atomics,
   there might be a way to enable `<atomic>`?
 - The header `<iostream>` seems to fail with a missing symbol `locale_t`.

## Details

### libcompiler-rt
The original sources fail to compile,
because implementations make use of double precision instructions,
which are unavailable on ARMv7em.
The patch excludes those builtins from the build,
which will then be replaced by generic implementations.
