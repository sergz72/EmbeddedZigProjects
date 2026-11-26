const TC3_BASE = 0x42002C00;
const TC4_BASE = 0x42003000;
const TC5_BASE = 0x42003400;

pub const TcMode = enum(u2) {
    count16 = 0,
    count8 = 1,
    count32 = 2,
};

pub const TcWavegen = enum(u2) {
    nfrq = 0,
    mfrq = 1,
    npwm = 2,
    mpwm = 3,
};

pub const TcPrescaler = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div64 = 5,
    div256 = 6,
    div1024 = 7,
};

pub const TcPrescsync = enum(u2) {
    gclk = 0,
    presc = 1,
    resync = 2,
};

pub const TcCtrla = bitpack struct(u16) {
    swrst: bool = false,
    enable: bool = false,
    mode: TcMode = .count16,
    reserved0: u1 = 0,
    wavegen: TcWavegen = .nfrq,
    reserved1: u1 = 0,
    prescaler: TcPrescaler = .div1,
    runstdby: bool = false,
    prescsync: TcPrescsync = .gclk,
    reserved2: u2 = 0,
};

pub const TcReadreq = bitpack struct(u16) {
    addr: u5 = 0,
    reserved0: u9 = 0,
    rcont: bool = false,
    rreq: bool = false,
};

pub const TcCmd = enum(u2) {
    none = 0,
    retrigger = 1,
    stop = 2,
};

pub const TcCtrlb = bitpack struct(u8) {
    dir: bool = false,
    reserved0: u1 = 0,
    oneshot: bool = false,
    reserved1: u3 = 0,
    cmd: TcCmd = .none,
};

pub const TcCtrlc = bitpack struct(u8) {
    inven0: bool = false,
    inven1: bool = false,
    reserved0: u2 = 0,
    cpten0: bool = false,
    cpten1: bool = false,
    reserved1: u2 = 0,
};

pub const TcDbgctrl = bitpack struct(u8) {
    dbgrun: bool = false,
    reserved0: u7 = 0,
};

pub const TcEvact = enum(u3) {
    off = 0,
    retrigger = 1,
    count = 2,
    start = 3,
    ppw = 5,
    pwp = 6,
};

pub const TcEvctrl = bitpack struct(u16) {
    evact: TcEvact = .off,
    reserved0: u1 = 0,
    tcinv: bool = false,
    tcei: bool = false,
    reserved1: u2 = 0,
    ovfeo: bool = false,
    reserved2: u3 = 0,
    mceo0: bool = false,
    mceo1: bool = false,
    reserved3: u2 = 0,
};

pub const TcInt = bitpack struct(u8) {
    ovf: bool = false,
    err: bool = false,
    reserved0: u1 = 0,
    syncrdy: bool = false,
    mc0: bool = false,
    mc1: bool = false,
    reserved1: u2 = 0,
};

pub const TcStatus = bitpack struct(u8) {
    reserved0: u3,
    stop: bool,
    slave: bool,
    reserved1: u2,
    syncbusy: bool,
};

pub const Tc8 = extern struct {
    ctrla: TcCtrla,
    readreq: TcReadreq,
    ctrlbclr: TcCtrlb,
    ctrlbset: TcCtrlb,
    ctrlc: TcCtrlc,
    reserved0: u8,
    dbgctrl: TcDbgctrl,
    reserved1: u8,
    evctrl: TcEvctrl,
    intenclr: TcInt,
    intenset: TcInt,
    intflag: TcInt,
    status: TcStatus,
    count: u8,
    reserved2: [3]u8,
    per: u8,
    reserved3: [3]u8,
    cc: [2]u8,
    reserved: [3]u16,

    pub fn setPer(self: *volatile Tc8, value: u8) void {
        self.per = value;
        while (self.status.syncbusy) {
            asm volatile("nop");
        }
    }
};

pub const Tc16 = extern struct {
    ctrla: TcCtrla,
    readreq: TcReadreq,
    ctrlbclr: TcCtrlb,
    ctrlbset: TcCtrlb,
    ctrlc: TcCtrlc,
    reserved0: u8,
    dbgctrl: TcDbgctrl,
    reserved1: u8,
    evctrl: TcEvctrl,
    intenclr: TcInt,
    intenset: TcInt,
    intflag: TcInt,
    status: TcStatus,
    count: u16,
    reserved2: [3]u16,
    cc: [2]u16,
    reserved: u32
};

pub const Tc32 = extern struct {
    ctrla: TcCtrla,
    readreq: TcReadreq,
    ctrlbclr: TcCtrlb,
    ctrlbset: TcCtrlb,
    ctrlc: TcCtrlc,
    reserved0: u8,
    dbgctrl: TcDbgctrl,
    reserved1: u8,
    evctrl: TcEvctrl,
    intenclr: TcInt,
    intenset: TcInt,
    intflag: TcInt,
    status: TcStatus,
    count: u32,
    reserved2: u32,
    cc: [2]u32,
};

pub const tc3_8: *volatile Tc8 = @ptrFromInt(TC3_BASE);
pub const tc4_8: *volatile Tc8 = @ptrFromInt(TC4_BASE);
pub const tc5_8: *volatile Tc8 = @ptrFromInt(TC5_BASE);
pub const tc3_16: *volatile Tc16 = @ptrFromInt(TC3_BASE);
pub const tc4_16: *volatile Tc16 = @ptrFromInt(TC4_BASE);
pub const tc5_16: *volatile Tc16 = @ptrFromInt(TC5_BASE);
pub const tc3_32: *volatile Tc32 = @ptrFromInt(TC3_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Tc8));
    try std.testing.expectEqual(0x20, @sizeOf(Tc16));
    try std.testing.expectEqual(0x20, @sizeOf(Tc32));
}
