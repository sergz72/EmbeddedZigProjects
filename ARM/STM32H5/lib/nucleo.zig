const gpio = @import("gpio");
const rcc = @import("rcc");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const flash = @import("flash");

const LED_GREEN_PB0_PIN = 0;
const LED_GREEN_PB0_PIN_MASK: u16 = 1 << LED_GREEN_PB0_PIN;
const LED_GREEN_PB0_PORT = gpio.gpiob;

const LED_GREEN_PA5_PIN = 5;
const LED_GREEN_PA5_PIN_MASK: u16 = 1 << LED_GREEN_PA5_PIN;
const LED_GREEN_PA5_PORT = gpio.gpioa;

const LED_YELLOW_PIN = 4;
const LED_YELLOW_PIN_MASK: u16 = 1 << LED_YELLOW_PIN;
const LED_YELLOW_PORT = gpio.gpiof;

const LED_RED_PIN = 4;
const LED_RED_PIN_MASK: u16 = 1 << LED_RED_PIN;
const LED_RED_PORT = gpio.gpiog;

const BUTTON_PIN = 13;
const BUTTON_PIN_MASK: u16 = 1 << BUTTON_PIN;
const BUTTON_PORT = gpio.gpioc;

var led_green_alternate: bool = undefined;

pub inline fn ledGreenOn() void {
    if (led_green_alternate) {
        LED_GREEN_PA5_PORT.setPins(LED_GREEN_PA5_PIN_MASK);
    } else {
        LED_GREEN_PB0_PORT.setPins(LED_GREEN_PB0_PIN_MASK);
    }
}

pub inline fn ledGreenOff() void {
    if (led_green_alternate) {
        LED_GREEN_PA5_PORT.clearPins(LED_GREEN_PA5_PIN_MASK);
    } else {
        LED_GREEN_PB0_PORT.clearPins(LED_GREEN_PB0_PIN_MASK);
    }
}

pub inline fn ledYellowOn() void {
    LED_YELLOW_PORT.setPins(LED_YELLOW_PIN_MASK);
}

pub inline fn ledYellowOff() void {
    LED_YELLOW_PORT.clearPins(LED_YELLOW_PIN_MASK);
}

pub inline fn ledRedOn() void {
    LED_RED_PORT.setPins(LED_RED_PIN_MASK);
}

pub inline fn ledRedOff() void {
    LED_RED_PORT.clearPins(LED_RED_PIN_MASK);
}

pub fn initClock() void {
    rcc.rcc.cr.hsebyp = true;
    rcc.rcc.cr.hseon = true;
    while (!rcc.rcc.cr.hserdy) {
        asm volatile ("nop");
    } 

    rcc.rcc.pllcfgr = .{
        // 8 mhz input clock
        .pllm = 8,
        // PLL frequency is 192 MHz
        .plln = 192,
        .pllq = 4, // 48 MHz for USB
        .pllp = .div4,
        .pllsrc = true
    };
    rcc.rcc.cr.pllon = true;
    while (!rcc.rcc.cr.pllrdy) {
        asm volatile ("nop");
    }

    flash.flash.acr = .{.dcrst = true, .icrst = true, .prften = true, .latency = 1};
    flash.flash.acr = .{.prften = true, .latency = 1};
    flash.flash.acr = .{.dcen = true, .icen = true, .prften = true, .latency = 1};

    rcc.rcc.cfgr = .{.ppre1 = .div2, .ppre2 = .off};
    rcc.rcc.cfgr.sw = .pll;
    while (rcc.rcc.cfgr.sws != .pll) {
        asm volatile ("nop");
    }

    cpu.cpu.current_frequency = 48000000;
    cpu.cpu.apb1_frequency = 24000000;
    cpu.cpu.apb2_frequency = 48000000;
}

pub fn init_leds(led_green_pa5: bool) void {
    if (led_green_pa5) {
        rcc.rcc.hpenr.ahb2.gpioaen = true;
    } else {
        rcc.rcc.hpenr.ahb2.gpioben = true;
    }
    rcc.rcc.hpenr.ahb2.gpiofen = true;
    rcc.rcc.hpenr.ahb2.gpiogen = true;
    led_green_alternate = led_green_pa5;
    const ginit: gpio.GpioInit = .{
        .mode = .output,
        .speed = .low
    };
    if (led_green_pa5) LED_GREEN_PA5_PORT.init(LED_GREEN_PA5_PIN_MASK, ginit) else LED_GREEN_PB0_PORT.init(LED_GREEN_PB0_PIN_MASK, ginit);
    LED_YELLOW_PORT.init(LED_YELLOW_PIN_MASK, ginit);
    LED_RED_PORT.init(LED_RED_PIN_MASK, ginit);
}

pub fn initButton() void {
    rcc.rcc.hpenr.ahb2.gpiocen = true;
    const init_data: gpio.GpioInit = .{
        .mode = .input
    };
    BUTTON_PORT.init(BUTTON_PIN_MASK, init_data);
}

pub fn init(led_green_pa5: bool) void {
    //initClock();
    system_timer.delay_init(system_timer.init_div8);
    init_leds(led_green_pa5);
    initButton();
}

pub fn init_ethernet_gpio() void {
    //todo
}

pub fn init_usb_gpio() void {
    //todo
}
