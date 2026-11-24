const std = @import("std");
const board = @import("board");
const system_timer = @import("system_timer");

var led_status: bool = undefined;

pub const panic = std.debug.no_panic;

fn ledHandler() void {
    led_status = !led_status;
    if (led_status) {
        board.ledBlueOn();
    } else {
        board.ledBlueOff();
    }
}

export fn SystemInit() callconv(.c) void {
    board.init1();
}

export fn main() callconv(.c) noreturn {
    while (true) {
        system_timer.delayms(500);
        ledHandler();
    }
}
