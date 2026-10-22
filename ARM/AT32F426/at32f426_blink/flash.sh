#! /bin/sh

/opt/openocd/openocd_artery/bin/openocd -f board/at32f426_dap.cfg \
  -c "init; reset halt;" \
  -c "program zig-out/bin/at32f426_blink.elf verify;" \
  -c "reset run; shutdown"
