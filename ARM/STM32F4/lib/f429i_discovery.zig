const gpio = @import("gpio");
const rcc = @import("rcc");

const LED_GREEN_PIN = 13;
const LED_GREEN_PIN_MASK: u16 = 1 << LED_GREEN_PIN;
const LED_GREEN_PIN_CLR_MASK: u32 = 0x10000 << LED_GREEN_PIN;
const LED_GREEN_PORT = gpio.gpiog;

const LED_RED_PIN = 14;
const LED_RED_PIN_MASK: u16 = 1 << LED_RED_PIN;
const LED_RED_PIN_CLR_MASK: u32 = 0x10000 << LED_RED_PIN;
const LED_RED_PORT = gpio.gpiog;

const BUTTON_PIN = 0;
const BUTTON_PIN_MASK: u16 = 1 << BUTTON_PIN;
const BUTTON_PORT = gpio.gpioa;

pub inline fn led_green_on() void {
    LED_GREEN_PORT.bsrr = @as(u32, LED_GREEN_PIN_MASK);
}

pub inline fn led_green_off() void {
    LED_GREEN_PORT.bsrr = LED_GREEN_PIN_CLR_MASK;
}

pub inline fn led_red_on() void {
    LED_RED_PORT.bsrr = @as(u32, LED_RED_PIN_MASK);
}

pub inline fn led_red_off() void {
    LED_RED_PORT.bsrr = LED_RED_PIN_CLR_MASK;
}

pub fn init_leds() void {
    rcc.rcc.ahb1enr.gpiogen = true;
    var init: gpio.GpioInit = .{
        .pins = LED_GREEN_PIN_MASK,
        .mode = .output,
        .speed = .low
    };
    LED_GREEN_PORT.init(&init);
    init.pins = LED_RED_PIN_MASK;
    LED_RED_PORT.init(&init);
}

pub fn init_button() void {
    rcc.rcc.ahb1enr.gpioaen = true;
    var init: gpio.GpioInit = .{
        .pins = BUTTON_PIN_MASK,
        .mode = .input
    };
    BUTTON_PORT.init(&init);
}

pub fn init_lcd() void {
    //todo
}

pub fn init_sdram() void {
    //todo
}

pub fn init_usb() void {
    //todo
}
