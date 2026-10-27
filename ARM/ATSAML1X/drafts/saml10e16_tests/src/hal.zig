const std = @import("std");
const port = @import("port");
const gclk = @import("gclk");
const pm = @import("pm");
const supc = @import("supc");
const sercom = @import("sercom");
const tc = @import("tc");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");
const usart_writer = @import("usart_writer");
const shell = @import("shell");
const scb = @import("scb");
const wdt = @import("wdt");
const nvmctrl = @import("nvmctrl");
const trng = @import("trng");
const rstc = @import("rstc");

const LED_PIN = 27;
const LED_PIN_MASK: u32 = 1 << LED_PIN;

const USART_INSTANCE = sercom.sercom2;
const USART_RX_PIN = 25;
const USART_RX_PIN_MASK: u32 = 1 << USART_RX_PIN;
const USART_TX_PIN = 24;
const USART_TX_PIN_MASK: u32 = 1 << USART_TX_PIN;

pub const panic = std.debug.no_panic;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

export fn SERCOM2_2_Handler() callconv(.c) void {
    const flags = USART_INSTANCE.usart.intflag;
    if (flags.err) {
        USART_INSTANCE.usart.intflag = .{.err = true};
    }
    if (flags.rxc) {
        sh.processChar(@truncate(USART_INSTANCE.usart.data));
    }
}

export fn TC2_Handler() callconv(.c) void {
    tc.tc2_16.intflag = .{ .ovf = true };
    timer_interrupt = true;
}

inline fn clocksInit() void {
    //USART
    gclk.gclk.channelEnable(.sercom2_core, 0);
    //Timer
    gclk.gclk.channelEnable(.tc2, 0);
}

inline fn usartInit() void {
    const init: sercom.UsartInitParameters = .{
        .baud = 115200,
        .clock_frequency = cpu.cpu.current_frequency,
        .rxpo = 3,
        .txpo = 1,
        .tx_pin = USART_TX_PIN,
        .rx_pin = USART_RX_PIN,
        .pmux = .D
    };
    USART_INSTANCE.usart.init(init);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM2_2.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn timerInit() void {
    timer_interrupt = false;
    tc.tc2_16.setPer(@truncate(cpu.cpu.current_frequency / 1024));
    tc.tc2_16.intenset = tc.TcInt{.ovf = true};
    tc.tc2_16.ctrla = tc.TcCtrla{.runstdby = true, .presync = .presc, .prescaler = .div1024};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TC2.toU8());
}

export fn SystemInit() callconv(.c) void {
    pm.pm.sleepcfg = .idle;
    supc.supc.buckConverterEnable();
    system_timer.delay_init(system_timer.init_div1);
    port.ports[0].dirset = LED_PIN_MASK;
    clocksInit();
    usartInit();
    timerInit();
    trng.trng.init();
    wdt.wdt.init(10000);
}

pub inline fn startTimer() void {
    tc.tc2_16.ctrla.enable = true;
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.usart.write(byte);
}

pub inline fn ledToggle() void {
    port.ports[0].outtgl = LED_PIN_MASK;
}

pub fn flashWrite(address: usize, data: []const u8) nvmctrl.NvmctrlError!void {
    try nvmctrl.nvmctrl.writePage(address, data, true);
}

pub fn flashSectorErase(address: usize) nvmctrl.NvmctrlError!void {
    try nvmctrl.nvmctrl.rowErase(address, true);
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    wdt.wdt.reset();
}

pub fn getResetCause() []const u8 {
    return rstc.rstc.getResetCause();
}
