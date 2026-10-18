const system_timer = @import("system_timer");
const gpio = @import("gpio");
const rcc = @import("rcc");
const cpu = @import("cpu");
const flash = @import("flash");

const LED_PIN = 13;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PIN_CLR_MASK: u32 = 0x10000 << LED_PIN;
const LED_PORT = gpio.gpioc;

const BUTTON_PIN = 0;
const BUTTON_PIN_MASK: u16 = 1 << BUTTON_PIN;
const BUTTON_PORT = gpio.gpioa;

pub inline fn ledOn() void {
    LED_PORT.bsrr = @as(u32, LED_PIN_MASK);
}

pub inline fn ledOff() void {
    LED_PORT.bsrr = LED_PIN_CLR_MASK;
}

pub fn initClock() void {
    rcc.rcc.cr.hseon = true;
    while (!rcc.rcc.cr.hserdy) {
        asm volatile ("nop");
    }

    rcc.rcc.pllcfgr = .{
        // 25 MHZ XTAL
        .pllm = 25,
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

pub fn initLeds() void {
    rcc.rcc.ahb1enr.gpiocen = true;
    var init_data: gpio.GpioInit = .{
        .pins = LED_PIN_MASK,
        .mode = .output,
        .speed = .low
    };
    LED_PORT.init(&init_data);
}

pub fn initButton() void {
    rcc.rcc.ahb1enr.gpioaen = true;
    var init_data: gpio.GpioInit = .{
        .pins = BUTTON_PIN_MASK,
        .mode = .input
    };
    BUTTON_PORT.init(&init_data);
}

pub fn initUsb() void {
    //todo
}

pub fn init() void {
    initClock();
    system_timer.delay_init(system_timer.init_div8);
    initLeds();
    initButton();
}
