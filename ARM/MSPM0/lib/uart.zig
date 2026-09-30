const builtin = @import("builtin");
const common = @import("common");//if (builtin.is_test) @import("common.zig") else @import("common");

const UART0_BASE: usize = 0x40108000 + 0x800;
const UART1_BASE: usize = 0x40100000 + 0x800;
const UART2_BASE: usize = 0x40102000 + 0x800;
const UART3_BASE: usize = 0x40500000 + 0x800;

pub const UartIntIMask = packed struct(u32) {
    rtout: bool = false,
    frmerr: bool = false,
    parerr: bool = false,
    brkerr: bool = false,
    ovrerr: bool = false,
    rxne: bool = false,
    rxpe: bool = false,
    linc0: bool = false,
    linc1: bool = false,
    linovf: bool = false,
    rxint: bool = false,
    txint: bool = false,
    eot: bool = false,
    addr_match: bool = false,
    cts: bool = false,
    dma_done_rx: bool = false,
    dma_done_tx: bool = false,
    nerr: bool = false,
    reserved: u14 = 0
};

pub const UartIntIIdx = enum(u32) {
    no_interrupt = 0,
    receive_timeout = 1,
    framing_error = 2,
    parity_error = 3,
    break_error = 4,
    receive_overrun = 5,
    rxne = 6,
    rxpe = 7,
    linc0 = 8,
    linc1 = 9,
    linovf = 10,
    receive_interrupt = 11,
    transmit_interrupt = 12,
    eot = 13,
    address_match = 14,
    cts = 15,
    dma_done_rx = 16,
    dma_done_tx = 17,
    noise = 18
};

pub const UartInt = extern struct {
    iidx: UartIntIIdx,
    reserved0: u32,
    imask: UartIntIMask,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const UartGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    clkcfg: u32,
    reserved0: [2]u32,
    stat: u32,
};

pub const UartMode = enum(u3) {
    normal = 0,
    rs485 = 1,
    idle_line = 2,
    address9 = 3,
    iso7816 = 4,
    dali = 5
};

pub const UartOversampling = enum(u2) {
    _16x = 0,
    _8x = 1,
    _3x = 2
};

pub const UartWordLength = enum(u2) {
    _5 = 0,
    _6 = 1,
    _7 = 2,
    _8 = 3
};

pub const UartCtl0 = packed struct(u32) {
    enable: bool = false,
    rserved: u1 = 0,
    lbe: bool = false,
    rxe: bool = true,
    txe: bool = true,
    txd_out_en: bool = true,
    txd_out: bool = false,
    menc: bool = false,
    mode: UartMode = .normal,
    rserved2: u1 = 0,
    rts: bool = false,
    rtsen: bool = false,
    ctsen: bool = false,
    hse: UartOversampling = ._16x,
    fen: bool = false,
    majvote: bool = false,
    msbfirst: bool = false,
    reserved: u12 = 0
};

pub const UartLcrh = packed struct(u32) {
    brk: bool = false,
    pen: bool = false,
    eps: bool = false,
    stp2: bool = false,
    wlen: UartWordLength,
    sps: bool = false,
    sendidle: bool = false,
    reserved: u8 = 0,
    extdir_setup: u5 = 0,
    extdir_hold: u5 = 0,
    reserved2: u6 = 0
};

pub const UartStat = packed struct(u32) {
    busy: bool,
    reserved: u1,
    rxfe: bool,
    rxff: bool,
    reserved2: u2,
    txfe: bool,
    txff: bool,
    cts: bool,
    idle: bool,
    reserved3: u22
};

pub const Uart = extern struct {
    gprcm: UartGprcm,
    reserved1: [506]u32,
    clkdiv: common.ClkDiv,
    reserved2: u32,
    clksel: common.Clksel3,
    reserved3: [3]u32,
    pdbgctl: u32,
    reserved4: u32,
    cpu_int: UartInt,
    reserved5: u32,
    dma_trig_rx: UartInt,
    reserved6: u32,
    dma_trig_tx: UartInt,
    reserved7: [13]u32,
    evt_mode: u32,
    intctl: u32,
    reserved8: [6]u32,
    ctl0: UartCtl0,
    lcrh: UartLcrh,
    stat: UartStat,
    ifls: u32,
    ibrd: u32,
    fbrd: u32,
    gfctl: u32,
    reserved9: u32,
    txdata: u32,
    rxdata: u32,
    reserved10: [2]u32,
    lincnt: u32,
    linctl: u32,
    linc0: u32,
    linc1: u32,
    irctl: u32,
    reserved11: u32,
    amask: u32,
    addr: u32,
    reserved12: [4]u32,
    clkdiv2: u32,

    pub inline fn enablePower(self: *volatile Uart) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub fn setBaudRateDivisor(self: *volatile Uart, divint: u16, divfrac: u6) void {
        self.ibrd = divint;
        self.fbrd = divfrac;
    }

    pub inline fn reset(self: *volatile Uart) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }

    pub fn write(self: *volatile Uart, byte: u8) void {
        while (self.stat.txff) {
            asm volatile ("nop");
        }
        self.txdata = byte;
    }
};

pub fn calculateIbrd(baudrate: comptime_int, cpu_frequency: comptime_int, oversampling: comptime_int) u16 {
    comptime {
        return @truncate(cpu_frequency / oversampling / baudrate);
    }
}

pub fn calculateFbrd(baudrate: comptime_int, cpu_frequency: comptime_int, oversampling: comptime_int) u6 {
    comptime {
        return @truncate(cpu_frequency * 64 / oversampling / baudrate);
    }
}

pub const uart0: *volatile Uart = @ptrFromInt(UART0_BASE);
pub const uart1: *volatile Uart = @ptrFromInt(UART1_BASE);
pub const uart2: *volatile Uart = @ptrFromInt(UART2_BASE);
pub const uart3: *volatile Uart = @ptrFromInt(UART3_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1164-0x800, @sizeOf(Uart));
}
