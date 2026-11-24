const board = @import("board");
const system_timer = @import("system_timer");

var led_status: bool = undefined;

fn ledHandler() void {
    led_status = !led_status;
    if (led_status) {
        board.led2On();
    } else {
        board.led2Off();
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
