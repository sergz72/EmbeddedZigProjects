const sysctl = @import("sysctl");
const gpio = @import("gpio");
const iomux = @import("iomux");
const cpu = @import("cpu");
const system_timer = @import("system_timer");

const LED_PIN = 0;
const LED_PIN_MASK = 1 << LED_PIN;
const LED_PIN_IOMUX = 1;
const LED_PORT = gpio.gpioa;

inline fn initGpio() void {
    LED_PORT.enablePower();
    iomux.iomux.initDigitalOutput(LED_PIN_IOMUX);
    LED_PORT.clearPins(LED_PIN_MASK);
    LED_PORT.enableOutput(LED_PIN_MASK);
}

export fn SystemInit() callconv(.c) void {
    sysctl.sysctl.mclkcfg.flashwait = .upto48Mhz;
    system_timer.delay_init(system_timer.init_div1);
    initGpio();
}

export fn main() callconv(.c) noreturn {
    while (true) {
        system_timer.delayms(1000);
        LED_PORT.togglePins(LED_PIN_MASK);
    }
}
