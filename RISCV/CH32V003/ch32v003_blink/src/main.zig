const rcc = @import("rcc");
const gpio = @import("gpio");
const system_timer = @import("system_timer");

const LED_PIN = 6;
const LED_PIN_MASK: u8 = 1 << LED_PIN;

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init();
    rcc.rcc.apb2pcenr.iopden = true;
    gpio.gpiod.init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
}

export fn main() callconv(.c) noreturn {
    while (true) {
        gpio.gpiod.bshr = LED_PIN_MASK;
        system_timer.delayms(1000);
        gpio.gpiod.bcr = LED_PIN_MASK;
        system_timer.delayms(1000);
    }
}
