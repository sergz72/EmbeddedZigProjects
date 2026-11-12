const TCC0_BASE = 0x42002000;
const TCC1_BASE = 0x42002400;
const TCC2_BASE = 0x42002800;
const TC3_BASE = 0x42002C00;
const TC4_BASE = 0x42003000;
const TC5_BASE = 0x42003400;
const TC6_BASE = 0x42003800;
const TC7_BASE = 0x42003C00;

pub const TcMode = enum(u2) {
    count16 = 0,
    count8 = 1,
    count32 = 2
};

pub const TcPresync = enum(u2) {
    gclk = 0,
    presc = 1,
    resync = 2
};

pub const TcPrescaler = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div64 = 5,
    div256 = 6,
    div1024 = 7
};

pub const TcCaptMode = enum(u2) {
    default = 0,
    capmin = 1,
    capmax = 2
};

pub const TcCtrla = bitpack struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    mode: TcMode = .count16,
    presync: TcPresync = .gclk,
    runstdby: bool = false,
    ondemand: bool = false,
    prescaler: TcPrescaler = .div1,
    alock: bool = false,
    reserved: u4 = 0,
    capten0: bool = false,
    capten1: bool = false,
    reserved2: u2 = 0,
    copen0: bool = false,
    copen1: bool = false,
    reserved3: u2 = 0,
    captmode0: TcCaptMode = .default,
    reserved4: u1 = 0,
    captmode1: TcCaptMode = .default,
    reserved5: u3 = 0
};

pub const TcCmd = enum(u3) {
    none = 0,
    retrigger = 1,
    stop = 2,
    update = 3,
    readsync = 4
};

pub const TcCtrlB = bitpack struct(u8) {
    dir: bool = false,
    lupd: bool = false,
    oneshot: bool = false,
    reserved: u2 = 0,
    cmd: TcCmd = .none
};

pub const TcEvAct = enum(u3) {
    off = 0,
    retrigger = 1,
    count = 2,
    start = 3,
    stamp = 4,
    ppw = 5,
    pwp = 6,
    pw = 7
};

pub const TcEvCtrl = bitpack struct(u16) {
    evact: TcEvAct = .off,
    reserved: u1 = 0,
    tcinv: bool = false,
    tcei: bool = false,
    reserved2: u2 = 0,
    ovfeo: bool = false,
    reserved3: u3 = 0,
    mce0: bool = false,
    mce1: bool = false,
    reserved4: u2 = 0
};

pub const TcInt = bitpack struct(u8) {
    ovf: bool = false,
    err: bool = false,
    reserved: u2 = 0,
    mc0: bool = false,
    mc1: bool = false,
    reserved2: u2 = 0
};

pub const TcStatus = bitpack struct(u8) {
    stop: bool,
    slave: bool,
    reserved: u1,
    perbufv: bool,
    ccbufv0: bool,
    ccbufv1: bool,
    reserved2: u2
};

pub const TcWave = enum(u8) {
    normal_frequency = 0,
    match_frequency = 1,
    normal_pwm = 2,
    match_pwm = 3
};

pub const TcDrvCtrl = bitpack struct(u8) {
    inven0: bool = false,
    inven1: bool = false,
    reserved: u6 = 0
};

pub const TcSyncBusy = bitpack struct(u32) {
    swrst: bool,
    enable: bool,
    ctrlb: bool,
    status: bool,
    count: bool,
    per: bool,
    cc0: bool,
    cc1: bool,
    reserved: u24
};

pub const Tc16 = extern struct {
    ctrla: TcCtrla,
    ctrlbclr: TcCtrlB,
    ctrlbset: TcCtrlB,
    evctrl: TcEvCtrl,
    intenclr: TcInt,
    intenset: TcInt,
    intflag: TcInt,
    status: TcStatus,
    wave: TcWave,
    drvctrl: TcDrvCtrl,
    reserved1: u8,
    dbgctrl: u8,
    syncbusy: TcSyncBusy,
    count: u16,
    reserved2: [2]u16,
    per: u16,
    cc: [2]u16,
    reserved3: [7]u16,
    perbuf: u16,
    ccbuf: [2]u16,

    pub fn setPer(self: *volatile Tc16, value: u16) void {
        self.per = value;
        while (self.syncbusy.per) {
            asm volatile("nop");
        }
    }
};

pub const Tc24 = extern struct {
    ctrla: TcCtrla,
    ctrlbclr: TcCtrlB,
    ctrlbset: TcCtrlB,
    evctrl: TcEvCtrl,
    intenclr: TcInt,
    intenset: TcInt,
    intflag: TcInt,
    status: TcStatus,
    wave: TcWave,
    drvctrl: TcDrvCtrl,
    reserved1: u8,
    dbgctrl: u8,
    syncbusy: TcSyncBusy,
    count: u16,
    reserved2: [2]u16,
    per: u16,
    cc: [2]u16,
    reserved3: [7]u16,
    perbuf: u16,
    ccbuf: [2]u16,

    pub fn setPer(self: *volatile Tc24, value: u16) void {
        self.per = value;
        while (self.syncbusy.per) {
            asm volatile("nop");
        }
    }
};

pub const tcc0: *volatile Tc24 = @ptrFromInt(TCC0_BASE);
pub const tcc1: *volatile Tc24 = @ptrFromInt(TCC1_BASE);
pub const tcc2: *volatile Tc24 = @ptrFromInt(TCC2_BASE);
pub const tc3: *volatile Tc16 = @ptrFromInt(TC3_BASE);
pub const tc4: *volatile Tc16 = @ptrFromInt(TC4_BASE);
pub const tc5: *volatile Tc16 = @ptrFromInt(TC5_BASE);
pub const tc6: *volatile Tc16 = @ptrFromInt(TC6_BASE);
pub const tc7: *volatile Tc16 = @ptrFromInt(TC7_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x34, @sizeOf(Tc16));
    try std.testing.expectEqual(0x34, @sizeOf(Tc24));
}
