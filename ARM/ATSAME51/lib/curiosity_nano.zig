const std = @import("std");
const sercom = @import("sercom");
const port = @import("port");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const gclk = @import("gclk");
const pm = @import("pm");
const system_timer = @import("system_timer");
const mclk = @import("mclk");
const usart_writer = @import("usart_writer");

pub const panic = std.debug.no_panic;

const LED_PIN = 14;
const LED_PIN_MASK = 1 << LED_PIN;
const LED_PORT = 0;

const BUTTON_PIN = 15;
const BUTTON_PIN_MASK = 1 << BUTTON_PIN;
const BUTTON_PORT = 0;

const USART_PORT = 1;
pub const USART_INSTANCE = sercom.sercom5;
//--------------------------------
const USART_TX_PIN = 16;
const USART_TX_PIN_MASK = 1 << USART_TX_PIN;
//--------------------------------
const USART_RX_PIN = 17;
const USART_RX_PIN_MASK = 1 << USART_RX_PIN;

var usart_callback: *const fn(u8) void = undefined;

pub inline fn ledOn() void {
    port.ports[LED_PORT].outset = LED_PIN_MASK;
}

pub inline fn ledOff() void {
    port.ports[LED_PORT].outclr = LED_PIN_MASK;
}

pub inline fn ledToggle() void {
    port.ports[LED_PORT].outtgl = LED_PIN_MASK;
}

pub fn initXosc32k() void {
}

inline fn usartInit() void {
    const uinit = sercom.UsartInitParameters{
        .baud = 115200,
        .clock_frequency = cpu.cpu.current_frequency,
        .rxpo = 1,
        .txpo = 0,
        .tx_pin = USART_TX_PIN,
        .rx_pin = USART_RX_PIN,
        .port = USART_PORT,
        .pmux = .C
    };
    USART_INSTANCE.usart.init(uinit);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM5_2.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn clocksInit() void {
    //USART
    mclk.mclk.apbdmask.sercom5 = true;
    gclk.gclk.channelEnable(.sercom5_core, 0);
}

pub fn init(callback: *const fn(u8) void) void {
    usart_callback = callback;
    clocksInit();
    pm.pm.sleepcfg = .idle;
    system_timer.delay_init(system_timer.init_div1);
    port.ports[LED_PORT].dirset = LED_PIN_MASK;
    usartInit();
}

pub fn usartWrite(c: u8) void {
    USART_INSTANCE.usart.write(c);
}

export fn SERCOM5_2_Handler() callconv(.c) void {
    const flags = USART_INSTANCE.usart.intflag;
    if (flags.err) {
        USART_INSTANCE.usart.intflag = .{.err = true};
    }
    if (flags.rxc) {
        usart_callback(@truncate(USART_INSTANCE.usart.data));
    }
}
