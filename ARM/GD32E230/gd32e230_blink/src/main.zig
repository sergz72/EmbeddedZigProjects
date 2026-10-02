const rcu = @import("rcu");
const gpio = @import("gpio");
const cpu = @import("cpu");
const system_timer = @import("system_timer");

const LED_PIN = 13;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpioc;
const LED_INIT: gpio.GpioInit = .{
    .mode = .output,
    .output_speed = .low
};

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div1);
    rcu.rcu.ahben = rcu.RcuAhben{.pcen = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);
}

export fn main() callconv(.c) noreturn {
    while (true) {
        LED_PORT.bop = LED_PIN_MASK;
        system_timer.delayms(1000);
        LED_PORT.bc = LED_PIN_MASK;
        system_timer.delayms(1000);
    }
}
