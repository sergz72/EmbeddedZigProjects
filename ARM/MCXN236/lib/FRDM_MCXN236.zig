const std = @import("std");
const gpio = @import("gpio");
const syscon = @import("syscon");

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

pub inline fn ledGreenOn() void {
    LED_GPIO.clearPins(LED_GREEN_GPIO_PIN_MASK);
}

pub inline fn ledGreenOff() void {
    LED_GPIO.setPins(LED_GREEN_GPIO_PIN_MASK);
}

pub inline fn ledBlueOn() void {
    LED_GPIO.clearPins(LED_BLUE_GPIO_PIN_MASK);
}

pub inline fn ledBlueOff() void {
    LED_GPIO.setPins(LED_BLUE_GPIO_PIN_MASK);
}

pub inline fn ledRedOn() void {
    LED_GPIO.clearPins(LED_RED_GPIO_PIN_MASK);
}

pub inline fn ledRedOff() void {
    LED_GPIO.setPins(LED_RED_GPIO_PIN_MASK);
}

pub fn initClock() void {
    syscon.syscon0.initSystemTimer();
}

pub fn getSW2() bool {
    return (SW_GPIO.in(1 << SW2_GPIO_PIN) != 0);
}

pub fn getSW3() bool {
    return (SW_GPIO.in(1 << SW3_GPIO_PIN) != 0);
}

pub fn initGpio() void {
    syscon.syscon0.ahbclkctrlset0 = syscon.Ahbclkctrl0{
        .gpio0 = true, .port0 = true,.gpio4 = true, .port4 = true
    };
    ledGreenOff();
    ledBlueOff();
    ledRedOff();
    LED_GPIO.setAsOutput(LED_RED_GPIO_PIN_MASK | LED_BLUE_GPIO_PIN_MASK | LED_GREEN_GPIO_PIN_MASK);
}

pub fn initUart(baud: usize) void {
    // Initialize UART with the given baud rate
}

export fn SystemInit() callconv(.c) void {
    SystemPreInit();
    initClock();
    initGpio();
}
