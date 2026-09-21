const gpio = @import("gpio");
const rcc = @import("rcc");

const LED_GREEN_PB0_PIN = 0;
const LED_GREEN_PB0_PIN_MASK: u16 = 1 << LED_GREEN_PB0_PIN;
const LED_GREEN_PB0_PIN_CLR_MASK: u32 = 0x10000 << LED_GREEN_PB0_PIN;
const LED_GREEN_PB0_PORT = gpio.gpiob;

const LED_GREEN_PA5_PIN = 5;
const LED_GREEN_PA5_PIN_MASK: u16 = 1 << LED_GREEN_PA5_PIN;
const LED_GREEN_PA5_PIN_CLR_MASK: u32 = 0x10000 << LED_GREEN_PA5_PIN;
const LED_GREEN_PA5_PORT = gpio.gpioa;

const LED_YELLOW_PIN = 1;
const LED_YELLOW_PIN_MASK: u16 = 1 << LED_YELLOW_PIN;
const LED_YELLOW_PIN_CLR_MASK: u32 = 0x10000 << LED_YELLOW_PIN;
const LED_YELLOW_PORT = gpio.gpioe;

const LED_RED_PIN = 14;
const LED_RED_PIN_MASK: u16 = 1 << LED_RED_PIN;
const LED_RED_PIN_CLR_MASK: u32 = 0x10000 << LED_RED_PIN;
const LED_RED_PORT = gpio.gpiob;

var led_green_alternate: bool = undefined;

pub inline fn led_green_on() void {
    if (led_green_alternate) {
        LED_GREEN_PA5_PORT.bsrr = @as(u32, LED_GREEN_PA5_PIN_MASK);
    } else {
        LED_GREEN_PB0_PORT.bsrr = @as(u32, LED_GREEN_PB0_PIN_MASK);
    }
}

pub inline fn led_green_off() void {
    if (led_green_alternate) {
        LED_GREEN_PA5_PORT.bsrr = LED_GREEN_PA5_PIN_CLR_MASK;
    } else {
        LED_GREEN_PB0_PORT.bsrr = LED_GREEN_PB0_PIN_CLR_MASK;
    }
}

pub inline fn led_yellow_on() void {
    LED_YELLOW_PORT.bsrr = @as(u32, LED_YELLOW_PIN_MASK);
}

pub inline fn led_yellow_off() void {
    LED_YELLOW_PORT.bsrr = LED_YELLOW_PIN_CLR_MASK;
}

pub inline fn led_red_on() void {
    LED_RED_PORT.bsrr = @as(u32, LED_RED_PIN_MASK);
}

pub inline fn led_red_off() void {
    LED_RED_PORT.bsrr = LED_RED_PIN_CLR_MASK;
}

pub fn init_leds(led_green_pa5: bool) void {
    if (led_green_pa5)
        rcc.rcc.enr[0].hp.ahb4.gpioa = true;
    rcc.rcc.enr[0].hp.ahb4.gpiob = true;
    rcc.rcc.enr[0].hp.ahb4.gpioe = true;
    led_green_alternate = led_green_pa5;
    var init: gpio.GpioInit = .{
        .pins = if (led_green_pa5) LED_GREEN_PA5_PIN_MASK else LED_GREEN_PB0_PIN_MASK,
        .mode = .output,
        .speed = .low
    };
    if (led_green_pa5) LED_GREEN_PA5_PORT.init(&init) else LED_GREEN_PB0_PORT.init(&init);
    init.pins = LED_YELLOW_PIN_MASK;
    LED_YELLOW_PORT.init(&init);
    init.pins = LED_RED_PIN_MASK;
    LED_RED_PORT.init(&init);
}

pub fn init_ethernet_gpio() void {
    //todo
}

pub fn init_usb_gpio() void {
    //todo
}
