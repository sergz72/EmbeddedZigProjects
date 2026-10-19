#! /bin/sh

/opt/openocd/openocd_st/bin/openocd -f board/f4.cfg \
  -c "init; reset halt;" \
  -c "program zig-out/bin/stm32f412_blink.elf verify;" \
  -c "reset run; shutdown"
