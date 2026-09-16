const rcu = @import("rcu");
const gpio = @import("gpio");
const cpu = @import("cpu");
const system_timer = @import("system_timer");

const LED_PIN = 2;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiob;

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(false);
    rcu.rcu.apb2en = rcu.RcuApb2en{.pben = true};
    LED_PORT.Init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
}

export fn main() callconv(.c) noreturn {
    while (true) {
        LED_PORT.bop = LED_PIN_MASK;
        system_timer.delayms(1000);
        LED_PORT.bc = LED_PIN_MASK;
        system_timer.delayms(1000);
    }
}
