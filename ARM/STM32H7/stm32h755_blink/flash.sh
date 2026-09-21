#! /bin/sh

/opt/openocd/openocd_st/bin/openocd -f board/st_nucleo_h745zi.cfg \
  -c "init; reset halt;" \
  -c "program zig-out/bin/stm32h755_blink_cm7.elf verify;" \
  -c "program zig-out/bin/stm32h755_blink_cm4.elf verify;" \
  -c "reset run; shutdown"
