#! /bin/sh

clang-23 -S -O3 -o startup_samd21.ss --target=arm-none-eabi -mcpu=cortex-m0plus -Iinclude startup_samd21.c
