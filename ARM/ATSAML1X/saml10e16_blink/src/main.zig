const std = @import("std");
const port = @import("port");
const system_timer = @import("system_timer");

const LED_PIN = 0;
const LED_PIN_MASK: u32 = 1 << LED_PIN;
const LED_PORT = 0;

pub const panic = std.debug.no_panic;

fn systemInit() void {
    system_timer.delay_init(system_timer.init_div1);
    port.ports[0].dirset = LED_PIN_MASK;
}

export fn main() callconv(.c) noreturn {
    systemInit();
    while (true) {
        system_timer.delayms(1000);
        port.ports[0].outtgl = LED_PIN_MASK;
    }
}
