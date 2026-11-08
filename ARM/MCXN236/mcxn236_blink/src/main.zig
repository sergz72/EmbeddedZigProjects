const std = @import("std");
const syscon = @import("syscon");
const gpio = @import("gpio");
const system_timer = @import("system_timer");

const LED_GPIO = gpio.gpio4;
const LED_RED_GPIO_PIN = 18;
const LED_RED_GPIO_PIN_MASK = 1 << LED_RED_GPIO_PIN;
const LED_BLUE_GPIO_PIN = 17;
const LED_BLUE_GPIO_PIN_MASK = 1 << LED_BLUE_GPIO_PIN;
const LED_GREEN_GPIO_PIN = 19;
const LED_GREEN_GPIO_PIN_MASK = 1 << LED_GREEN_GPIO_PIN;

const SW_GPIO = gpio.gpio0;
const SW2_GPIO_PIN = 20;
const SW3_GPIO_PIN = 6;

pub const panic = std.debug.no_panic;

extern fn SystemPreInit() callconv(.c) void;

fn ledGreenOn() void {
    LED_GPIO.pcor = LED_GREEN_GPIO_PIN_MASK;
}

fn ledGreenOff() void {
    LED_GPIO.psor = LED_GREEN_GPIO_PIN_MASK;
}

fn ledBlueOn() void {
    LED_GPIO.pcor = LED_BLUE_GPIO_PIN_MASK;
}

fn ledBlueOff() void {
    LED_GPIO.psor = LED_BLUE_GPIO_PIN_MASK;
}

fn ledRedOn() void {
    LED_GPIO.pcor = LED_RED_GPIO_PIN_MASK;
}

fn ledRedOff() void {
    LED_GPIO.psor = LED_RED_GPIO_PIN_MASK;
}

fn clockInit() void {
    syscon.syscon0.systickclkdiv0 = syscon.Clkdiv{.halt = false, .div = 7};
    syscon.syscon0.systickclksel0 = .ckclkdiv0;
    system_timer.delay_init(system_timer.init_div8);
}

fn gpioInit() void {
    syscon.syscon0.ahbclkctrlset0 = syscon.Ahbclkctrl0{ .gpio4 = true, .port4 = true };
    ledGreenOff();
    ledBlueOff();
    ledRedOff();
    LED_GPIO.pddr = LED_RED_GPIO_PIN_MASK | LED_BLUE_GPIO_PIN_MASK | LED_GREEN_GPIO_PIN_MASK;
}

export fn SystemInit() callconv(.c) void {
    SystemPreInit();
    clockInit();
    gpioInit();
}

export fn main() callconv(.c) noreturn {
    while (true) {
        system_timer.delayms(1000);
        ledRedOff();
        ledGreenOn();
        system_timer.delayms(1000);
        ledGreenOff();
        ledBlueOn();
        system_timer.delayms(1000);
        ledBlueOff();
        ledRedOn();
    }
}
