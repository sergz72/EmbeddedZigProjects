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
const osc32kctrl = @import("osc32kctrl");
const oscctrl = @import("oscctrl");
const dma_sender = @import("dma_sender");
const dmac = @import("dmac");

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
var dma_sender_instance = dma_sender.DmaSender {
    .dma_start = &usartDmaStart,
    .delayms = system_timer.delayms,
};

pub inline fn ledOn() void {
    port.ports[LED_PORT].outset = LED_PIN_MASK;
}

pub inline fn ledOff() void {
    port.ports[LED_PORT].outclr = LED_PIN_MASK;
}

pub inline fn ledToggle() void {
    port.ports[LED_PORT].outtgl = LED_PIN_MASK;
}

inline fn usartInit(use_dma: bool) void {
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
    if (use_dma) {
        usart_writer.usart_writer.writeCharFunc = usartWriteDma;
        usart_writer.usart_writer.writeFlushFunc = usartFlushDma;
    } else {
        usart_writer.usart_writer.writeCharFunc = usartWrite;
    }
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM5_2.toU8());
}

inline fn clocksInit() void {
    osc32kctrl.osc32kctrl.enableXosc32k();
    gclk.gclk.setXosc32kForDfll48(1);
    oscctrl.oscctrl.setXosc32kForDfll48();
    //USART
    mclk.mclk.apbdmask.sercom5 = true;
    gclk.gclk.channelEnable(.sercom5_core, 0);
}

pub fn init(callback: *const fn(u8) void, use_dma: bool) void {
    usart_callback = callback;
    clocksInit();
    pm.pm.sleepcfg = .idle;
    system_timer.delay_init(system_timer.init_div1);
    port.ports[LED_PORT].dirset = LED_PIN_MASK;
    usartInit(use_dma);
}

pub fn usartDmaInit(buffer_size: usize, allocator: std.mem.Allocator) error{OutOfMemory}!void {
    try dma_sender_instance.init(buffer_size, allocator);
    dmac.dmac.initMemoryToPeripheral8(0, @intFromPtr(&USART_INSTANCE.usart.data), .sercom5_tx);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.DMAC_0.toU8());
}

pub fn usartWrite(c: u8) void {
    USART_INSTANCE.usart.write(c);
}

pub fn shellWriteCharDma(byte: u8) void {
    usartWriteDma(byte);
    usartFlushDma();
}

pub fn usartWriteDma(byte: u8) void {
    dma_sender_instance.sendChar(byte);
}

pub fn usartFlushDma() void {
    dma_sender_instance.start();
}

fn usartDmaStart(data: []const u8) usize {
    dmac.dmac.startTransferMemoryToPeripheral8(0, data);
    return data.len;
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

export fn DMAC_0_Handler() callconv(.c) void {
    dmac.dmac.clearInterruptFlags(0);
    dma_sender_instance.dmaDone();
}
