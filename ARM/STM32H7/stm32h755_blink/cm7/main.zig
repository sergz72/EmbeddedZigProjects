const nucleo = @import("nucleo");
const hal = @import("hal");
const system_timer = @import("system_timer");

export fn SystemInit() callconv(.c) void {
}

export fn main() callconv(.c) noreturn {
    hal.init_core0();
    while (true) {
        nucleo.led_green_on();
        system_timer.delayms(1000);
        nucleo.led_green_off();
        system_timer.delayms(1000);
    }
}

export fn __libc_init_array() callconv(.c) void {
}

export fn ExitRun0Mode() callconv(.c) void {
}