const nucleo = @import("nucleo");
const hal = @import("hal");
const system_timer = @import("system_timer");

export fn SystemInit() callconv(.c) void {
}

export fn main() callconv(.c) noreturn {
    hal.init_core1();
    while (true) {
        nucleo.led_red_on();
        system_timer.delayms(500);
        nucleo.led_red_off();
        system_timer.delayms(500);
    }
}

export fn __libc_init_array() callconv(.c) void {
}

export fn ExitRun0Mode() callconv(.c) void {
}