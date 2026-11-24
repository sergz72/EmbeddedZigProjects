const board = @import("board");
const system_timer = @import("system_timer");
const pfic = @import("pfic");
const cpu = @import("cpu");

var led_status: bool = undefined;

fn ledHandler() void {
    led_status = !led_status;
    if (led_status) {
        board.led1On();
    } else {
        board.led1Off();
    }
}

export fn SystemInit() callconv(.c) void {
    board.init0();
}

export fn main() callconv(.c) noreturn {
    pfic.wakeupCpu1(@intFromPtr(&cpu.CORE_V5F_START_ADDRESS));
    while (true) {
        system_timer.delayms(2000);
        ledHandler();
    }
}
