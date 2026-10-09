const system_timer = @import("system_timer");
const gpio = @import("gpio");
const rcc = @import("rcc");
const cpu = @import("cpu");
const nvic = @import("nvic");
const flash = @import("flash");
const usart = @import("usart");
const interrupts = @import("interrupts");

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

const USART_PORT = gpio.gpioa;
pub const USART_INSTANCE = usart.usart1;
//--------------------------------
const USART_TX_PIN = 9;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
//--------------------------------
const USART_RX_PIN = 10;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;

var usart_callback: *const fn(u8) void = undefined;

pub inline fn ledGreenOn() void {
    LED_GREEN_PORT.bsrr = @as(u32, LED_GREEN_PIN_MASK);
}

pub inline fn ledGreenOff() void {
    LED_GREEN_PORT.bsrr = LED_GREEN_PIN_CLR_MASK;
}

pub inline fn ledRedOn() void {
    LED_RED_PORT.bsrr = @as(u32, LED_RED_PIN_MASK);
}

pub inline fn ledRedOff() void {
    LED_RED_PORT.bsrr = LED_RED_PIN_CLR_MASK;
}

pub fn initClock() void {
    rcc.rcc.cr.hsebyp = true;
    rcc.rcc.cr.hseon = true;
    while (!rcc.rcc.cr.hserdy) {
        asm volatile ("nop");
    }

    rcc.rcc.pllcfgr = .{
        //The software has to set these bits correctly to ensure that the VCO input frequency ranges from 1 to 2 MHz.
        //It is recommended to select a frequency of 2 MHz to limit PLL jitter.
        .pllm = 4,
        // PLL frequency is 336 MHz
        .plln = 168,
        .pllq = 7, // 48 MHz for USB
        .pllp = .div2,
        .pllsrc = true
    };
    rcc.rcc.cr.pllon = true;
    while (!rcc.rcc.cr.pllrdy) {
        asm volatile ("nop");
    }

    flash.flash.acr = .{.dcrst = true, .icrst = true};
    flash.flash.acr = .{.dcen = true, .icen = true, .prften = true, .latency = 5};

    rcc.rcc.cfgr = .{.ppre1 = .div4, .ppre2 = .div2};
    rcc.rcc.cfgr.sw = .pll;
    while (rcc.rcc.cfgr.sws != .pll) {
        asm volatile ("nop");
    }

    cpu.cpu.current_frequency = 168000000;
    cpu.cpu.apb1_frequency = 42000000;
    cpu.cpu.apb2_frequency = 84000000;
}

pub fn initLeds() void {
    rcc.rcc.ahb1enr.gpiogen = true;
    var init_data: gpio.GpioInit = .{
        .pins = LED_GREEN_PIN_MASK,
        .mode = .output,
        .speed = .low
    };
    LED_GREEN_PORT.init(&init_data);
    init_data.pins = LED_RED_PIN_MASK;
    LED_RED_PORT.init(&init_data);
}

pub fn initButton() void {
    rcc.rcc.ahb1enr.gpioaen = true;
    var init_data: gpio.GpioInit = .{
        .pins = BUTTON_PIN_MASK,
        .mode = .input
    };
    BUTTON_PORT.init(&init_data);
}

pub fn initLcd() void {
    //todo
}

pub fn initSdram() void {
    //todo
}

pub fn initUsb() void {
    //todo
}

export fn USART1_IRQHandler() callconv(.c) void {
    const sr = USART_INSTANCE.sr;
    if (sr.ore) {
        _ = USART_INSTANCE.dr;
        return;
    }
    if (sr.rxne) {
        usart_callback(USART_INSTANCE.dr);
    }
}

pub fn initUsart(baud: u32, callback: *const fn(u8) void) void {
    usart_callback = callback;
    rcc.rcc.ahb1enr.gpioaen = true;
    rcc.rcc.apb2enr.usart1en = true;
    var init_data: gpio.GpioInit = .{
        .pins = USART_TX_PIN_MASK,
        .mode = .alternate,
        .speed = .high,
        .alternate_function = 7
    };
    USART_PORT.init(&init_data);
    init_data.pins = USART_RX_PIN_MASK;
    init_data.pupdr = .pullup;
    USART_PORT.init(&init_data);
    USART_INSTANCE.init(baud, cpu.cpu.apb2_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART1.toU8());
}

pub fn init() void {
    initClock();
    system_timer.delay_init(system_timer.init_div8);
    initLeds();
    initButton();
    initSdram();
    initLcd();
}