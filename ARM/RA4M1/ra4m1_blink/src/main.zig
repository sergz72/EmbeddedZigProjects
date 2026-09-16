const gpio = @import("gpio");
const system_timer = @import("system_timer");

const LED_PIN = 12;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = 0;

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(true);
    gpio.port[LED_PORT].pdr = LED_PIN_MASK;
}

export fn main() callconv(.c) noreturn {
    while (true) {
        gpio.port[LED_PORT].posr = LED_PIN_MASK;
        system_timer.delayms(1000);
        gpio.port[LED_PORT].porr = LED_PIN_MASK;
        system_timer.delayms(1000);
    }
}
