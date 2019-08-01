# Docker image with LLVM/Clang 8.0 for armv7em-none-eabi (Cortex M4), with newlib-nano and libc++

## Credits

Most of the code here is based on code from the
[Homebrew armeabi taps by Emmanuel Blot](https://github.com/eblot/homebrew-armeabi).

## Contents

This repositories contsains scripts to build the following projects
for ARMv7em targets:
 - **LLVM/Clang 9.0.0rc1** (including **LLD**)
 - **Newlib 3.1.0**:
   Configured in a *nano* configuration, to reduce size for bare-metal applications.
 - **libcompiler-rt**, version 9.0.0rc1 from the LLVM project.
   Includes a patch to prevent using double precision floating point instructions, 
   which are available on some ARMv7em targets (M7f), but not all (M4f).
 - **libc++** (plus *libc++abi* and *libunwind*), version 9.0.0rc1 from the LLVM project.
   Some features are disabled, namely threading.
   Includes [my patch D65348](https://reviews.llvm.org/D65348), enabling `<atomic>` header.
   
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
 - The header `<iostream>` seems to fail with a missing symbol `locale_t`.

## Details

### libcompiler-rt
The original sources fail to compile,
because implementations make use of double precision instructions,
which are unavailable on ARM M4f.
The patch excludes those builtins from the build,
which will then be replaced by generic implementations.
