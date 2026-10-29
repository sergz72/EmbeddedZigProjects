const std = @import("std");
const port = @import("port");
const system_timer = @import("system_timer");

const LED1_PIN = 27;
const LED1_PIN_MASK: u32 = 1 << LED1_PIN;
const LED1_PORT = 0;

const LED2_PIN = 3;
const LED2_PIN_MASK: u32 = 1 << LED2_PIN;
const LED2_PORT = 1;

pub const panic = std.debug.no_panic;

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div1);
    port.ports[LED1_PORT].outset = LED1_PIN_MASK;
    port.ports[LED1_PORT].dirset = LED1_PIN_MASK;
    port.ports[LED2_PORT].dirset = LED2_PIN_MASK;
}

export fn main() callconv(.c) noreturn {
    while (true) {
        system_timer.delayms(1000);
        port.ports[LED1_PORT].outtgl = LED1_PIN_MASK;
        port.ports[LED2_PORT].outtgl = LED2_PIN_MASK;
    }
}
