#! /bin/sh

/opt/openocd/openocd/bin/openocd -f board/ti_mspm0_launchpad.cfg \
  -c "init; reset halt;" \
  -c "program zig-out/bin/mspm0g3507_tests.elf verify;" \
  -c "reset run; shutdown"
