const board = @import("board");
const cpu = @import("cpu");
const gpio = @import("gpio");
const iomuxc = @import("iomuxc");
const system_timer = @import("system_timer");
const rtwdog = @import("rtwdog");

const LED_GPIO = gpio.gpio1;
const LED_GPIO_PIN = 3;
const GPIO_PIN_MASK = 1 << LED_GPIO_PIN;

export fn SystemInit() callconv(.c) void {
    rtwdog.rtwdog.disable();
    system_timer.delay_init(system_timer.init_div1);
    iomuxc.iomuxc.mux_gpio[10].mux_mode = 5; // Set GPIO_03 to GPIO mode
    gpio.gpio1.gdir |= GPIO_PIN_MASK;
}

export fn main() callconv(.c) noreturn {
    while (true) {
        system_timer.delayms(1000);
        gpio.gpio1.toggle = GPIO_PIN_MASK;
    }
}
