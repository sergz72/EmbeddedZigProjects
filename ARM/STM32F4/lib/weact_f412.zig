const system_timer = @import("system_timer");
const gpio = @import("gpio");
const rcc = @import("rcc");
const cpu = @import("cpu");
const flash = @import("flash");
const nvic = @import("nvic");
const usart = @import("usart");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");

const LED_PIN = 2;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PIN_CLR_MASK: u32 = 0x10000 << LED_PIN;
const LED_PORT = gpio.gpiob;

const BUTTON_PIN = 13;
const BUTTON_PIN_MASK: u16 = 1 << BUTTON_PIN;
const BUTTON_PORT = gpio.gpioc;

const USART_PORT = gpio.gpioa;
pub const USART_INSTANCE = usart.usart1;
//--------------------------------
const USART_TX_PIN = 9;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
//--------------------------------
const USART_RX_PIN = 10;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;

var usart_callback: *const fn(u8) void = undefined;

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
        // 8 MHZ XTAL
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

pub fn initLeds() void {
    rcc.rcc.ahb1enr.gpioben = true;
    var init_data: gpio.GpioInit = .{
        .pins = LED_PIN_MASK,
        .mode = .output,
        .speed = .low
    };
    LED_PORT.init(&init_data);
}

pub fn initButton() void {
    rcc.rcc.ahb1enr.gpiocen = true;
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

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
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
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}
