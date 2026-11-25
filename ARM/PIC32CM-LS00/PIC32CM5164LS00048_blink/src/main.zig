const std = @import("std");
const port = @import("port");
const system_timer = @import("system_timer");

const LED_PIN = 15;
const LED_PIN_MASK = 1 << LED_PIN;

pub const panic = std.debug.no_panic;

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div1);
    port.ports_sec[0].dirset = LED_PIN_MASK;
}

export fn main() callconv(.c) noreturn {
    while (true) {
        system_timer.delayms(1000);
        port.ports_sec[0].outtgl = LED_PIN_MASK;
    }
}
