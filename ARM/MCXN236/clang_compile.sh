#! /bin/sh

clang-23 -S -O3 -o system_MCXN236.ss --target=arm-none-eabi -mcpu=cortex-m33 -Iinclude -DCPU_MCXN236VDF system_MCXN236.c

