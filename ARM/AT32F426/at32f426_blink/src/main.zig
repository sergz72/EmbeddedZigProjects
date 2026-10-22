const system_timer = @import("system_timer");
const crm = @import("crm");
const gpio = @import("gpio");

const LED_PIN = 2;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiob;
const LED_INIT: gpio.GpioInit = .{
    .mode = .output
};

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div1);
    crm.crm.ahben = .{.gpioben = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);
}

export fn main() callconv(.c) noreturn {
    while (true) {
        LED_PORT.setPins(LED_PIN_MASK);
        system_timer.delayms(1000);
        LED_PORT.clearPins(LED_PIN_MASK);
        system_timer.delayms(1000);
    }
}
