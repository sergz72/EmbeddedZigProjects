const SERCOM0_BASE = 0x42000400;
const SERCOM1_BASE = 0x42000800;
const SERCOM2_BASE = 0x42000C00;

pub const SercomI2cCtrlA = packed struct(u32) {
};

pub const SercomI2c = extern struct {
    ctrla: SercomI2cCtrlA,
    ctrlb: u32,
    reserved1: u32,
    baud: u32,
    reserved2: u32,
    intenclr: u8,
    reserved3: u8,
    intenset: u8,
    reserved4: u8,
    intflag: u8,
    reserved5: u8,
    status: u16,
    syncbusy: u32,
    reserved6: u32,
    addr: u32,
    data: u8,
    reserved7: [7]u8,
    dbgctrl: u8,
    reserved8: [3]u8
};

pub const SercomSpiCtrlA = packed struct(u32) {
};

pub const SercomSpi = extern struct {
    ctrla: SercomSpiCtrlA,
    ctrlb: u32,
    reserved1: u32,
    baud: u8,
    reserved2: [7]u8,
    intenclr: u8,
    reserved3: u8,
    intenset: u8,
    reserved4: u8,
    intflag: u8,
    reserved5: u8,
    status: u16,
    syncbusy: u32,
    reserved6: u32,
    addr: u32,
    data: u32,
    reserved7: u32,
    dbgctrl: u8,
    reserved8: [3]u8
};

pub const SercomUsartMode = enum(u3) {
    usart_ext_clk = 0,
    usart_int_clk = 1
};

pub const SercomUsartSampr = enum(u3) {
    over16_int = 0,
    over16_frac = 1,
    over8_int = 2,
    over8_frac = 3,
    over3_int = 4
};

pub const SercomUsartForm = enum(u4) {
    usart = 0,
    usart_with_parity = 1,
    lin_client_auto_baud = 4,
    auto_baud_with_parity = 5,
    iso7816 = 7
};

pub const SercomUsartCtrlA = packed struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    mode: SercomUsartMode = .usart_ext_clk,
    reserved: u2 = 0,
    runstdby: bool = false,
    ibon: bool = false,
    rxinv: bool = false,
    txinv: bool = false,
    reserved2: u2 = 0,
    sampr: SercomUsartSampr = .over16_int,
    txpo: u2 = 0,
    reserved3: u2 = 0,
    rxpo: u2 = 0,
    sampa: u2 = 0,
    form: SercomUsartForm = .usart,
    cmode: bool = false,
    cpol: bool = false,
    dord: bool = false,
    reserved4: u1 = 0
};

pub const SercomUsartCtrlB = packed struct(u32) {
    chsize: u3 = 0,
    reserved: u3 = 0,
    sbmode: bool = false,
    reserved2: u1 = 0,
    colden: bool = false,
    sfde: bool = false,
    enc: bool = false,
    reserved3: u2 = 0,
    pmode: bool = false,
    reserved4: u2 = 0,
    txen: bool = false,
    rxen: bool = false,
    reserved5: u14 = 0
};

pub const SercomUsartCtrlC = packed struct(u32) {
    gtime: u3 = 0,
    reserved: u13 = 0,
    inack: bool = false,
    dsnack: bool = false,
    reserved2: u2 = 0,
    maxiter: u3 = 0,
    reserved3: u9 = 0
};

pub const SercomUsartInt = packed struct(u8) {
    dre: bool = false,
    txc: bool = false,
    rxc: bool = false,
    rxs: bool = false,
    ctsic: bool = false,
    rxbrk: bool = false,
    reserved: u1 = 0,
    err: bool = false
};

pub const SercomUsartStatus = packed struct(u16) {
    perr: bool = false,
    ferr: bool = false,
    bufovf: bool = false,
    cts: bool = false,
    isf: bool = false,
    coll: bool = false,
    txe: bool = false,
    iter: bool = false,
    reserved: u8 = 0
};

pub const SercomUsartSyncBusy = packed struct(u32) {
    swrst: bool,
    enable: bool,
    ctrlb: bool,
    rxerrcnt: bool,
    reserved: u28
};

pub const SercomUsart = extern struct {
    ctrla: SercomUsartCtrlA,
    ctrlb: SercomUsartCtrlB,
    ctrlc: SercomUsartCtrlC,
    baud: u16,
    rxpl: u8,
    reserved1: [5]u8,
    intenclr: SercomUsartInt,
    reserved2: u8,
    intenset: SercomUsartInt,
    reserved3: u8,
    intflag: SercomUsartInt,
    reserved4: u8,
    status: SercomUsartStatus,
    syncbusy: SercomUsartSyncBusy,
    rxerrcnt: u8,
    reserved5: [7]u8,
    data: u16,
    reserved6: [3]u16,
    dbgctrl: u8,
    reserved8: [3]u8,

    pub fn init(self: *volatile SercomUsart, baud: usize, clock_frequency: usize) void {

    }
};

pub const Sercom = extern union {
    i2cs: SercomI2c,
    spis: SercomSpi,
    usart: SercomUsart
};

pub const sercom0: *volatile Sercom = @ptrFromInt(SERCOM0_BASE);
pub const sercom1: *volatile Sercom = @ptrFromInt(SERCOM1_BASE);
pub const sercom2: *volatile Sercom = @ptrFromInt(SERCOM2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x34, @sizeOf(SercomI2c));
    try std.testing.expectEqual(0x34, @sizeOf(SercomSpi));
    try std.testing.expectEqual(0x34, @sizeOf(SercomUsart));
}
