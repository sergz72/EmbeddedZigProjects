#! /bin/sh

/opt/openocd/openocd_artery/bin/openocd -f board/at32f403a_dap.cfg \
  -c "init; reset halt;" \
  -c "program zig-out/bin/at32f403_blink.elf verify;" \
  -c "reset run; shutdown"
