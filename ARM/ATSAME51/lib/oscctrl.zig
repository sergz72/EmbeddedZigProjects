const OSCCTRL_BASE = 0x40001000;

pub const OscctrlDpllctrla = bitpack struct(u8) {
    reserved0: u1 = 0,
    enable: bool = false,
    reserved1: u4 = 2,
    runstdby: bool = false,
    ondemand: bool = true,
};

pub const OscctrlDpllratio = bitpack struct(u32) {
    ldr: u13 = 0,
    reserved0: u3 = 0,
    ldrfrac: u5 = 0,
    reserved1: u11 = 0,
};

pub const OscctrlRefclk = enum(u3) {
    gclk = 0,
    xosc32 = 1,
    xosc0 = 2,
    xosc1 = 3,
};

pub const OscctrlLtime = enum(u3) {
    default = 0,
    _800us = 4,
    _900us = 5,
    _1ms = 6,
    _1p1ms = 7,
};

pub const OscctrlDpllctrlb = bitpack struct(u32) {
    filter: u4 = 0,
    wuf: bool = false,
    refclk: OscctrlRefclk = .xosc32,
    ltime: OscctrlLtime = .default,
    lbypass: bool = false,
    dcofilter: u3 = 0,
    dcoen: bool = false,
    div: u11 = 0,
    reserved0: u5 = 0,
};

pub const OscctrlDpllsyncbusy = bitpack struct(u32) {
    reserved0: u1,
    enable: bool,
    dpllratio: bool,
    reserved1: u29,
};

pub const OscctrlDpllstatus = bitpack struct(u32) {
    lock: bool,
    clkrdy: bool,
    reserved0: u30,
};

pub const OscctrlDPLL = extern struct {
    dpllctrla: OscctrlDpllctrla,
    reserved0: [3]u8,
    dpllratio: OscctrlDpllratio,
    dpllctrlb: OscctrlDpllctrlb,
    dpllsyncbusy: OscctrlDpllsyncbusy,
    dpllstatus: OscctrlDpllstatus,
};

pub const OscctrlEvctrl = bitpack struct(u8) {
    cfdeo0: bool = false,
    cfdeo1: bool = false,
    reserved0: u6 = 0,
};

pub const OscctrlInt = bitpack struct(u32) {
    xoscrdy0: bool = false,
    xoscrdy1: bool = false,
    xoscfail0: bool = false,
    xoscfail1: bool = false,
    reserved0: u4 = 0,
    dfllrdy: bool = false,
    dflloob: bool = false,
    dflllckf: bool = false,
    dflllckc: bool = false,
    dfllrcs: bool = false,
    reserved1: u3 = 0,
    dpll0lckr: bool = false,
    dpll0lckf: bool = false,
    dpll0lto: bool = false,
    dpll0ldrto: bool = false,
    reserved2: u4 = 0,
    dpll1lckr: bool = false,
    dpll1lckf: bool = false,
    dpll1lto: bool = false,
    dpll1ldrto: bool = false,
    reserved3: u4 = 0,
};

pub const OscctrlStatus = bitpack struct(u32) {
    xoscrdy0: bool,
    xoscrdy1: bool,
    xoscfail0: bool,
    xoscfail1: bool,
    xosccksw0: bool,
    xosccksw1: bool,
    reserved0: u2,
    dfllrdy: bool,
    dflloob: bool,
    dflllckf: bool,
    dflllckc: bool,
    dfllrcs: bool,
    reserved1: u3,
    dpll0lckr: bool,
    dpll0lckf: bool,
    dpll0to: bool,
    dpll0ldrto: bool,
    reserved2: u4,
    dpll1lckr: bool,
    dpll1lckf: bool,
    dpll1to: bool,
    dpll1ldrto: bool,
    reserved3: u4,
};

pub const Startup = enum(u4) {
    _1cycles = 0,
    _2cycles = 1,
    _4cycles = 2,
    _8cycles = 3,
    _16cycles = 4,
    _32cycles = 5,
    _64cycles = 6,
    _128cycles = 7,
    _256cycles = 8,
    _512cycles = 9,
    _1024cycles = 10,
    _2048cycles = 11,
    _4096cycles = 12,
    _8192cycles = 13,
    _16384cycles = 14,
    _32768cycles = 15,
};

pub const Cfdpresc = enum(u4) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7,
};

pub const OscctrlXoscctrl = bitpack struct(u32) {
    reserved0: u1 = 0,
    enable: bool = false,
    xtalen: bool = false,
    reserved1: u3 = 0,
    runstdby: bool = false,
    ondemand: bool = true,
    lowbufgain: bool = false,
    iptat: u2 = 0,
    imult: u4 = 0,
    enalc: bool = false,
    cfden: bool = false,
    swben: bool = false,
    reserved2: u2 = 0,
    startup: Startup = ._1cycles,
    cfdpresc: Cfdpresc = .div1,
    reserved3: u4 = 0,
};

pub const OscctrlDfllctrla = bitpack struct(u8) {
    reserved0: u1 = 0,
    enable: bool = true,
    reserved1: u4 = 0,
    runstdby: bool = false,
    ondemand: bool = true,
};

pub const OscctrlDfllctrlb = bitpack struct(u8) {
    mode: bool = false,
    stable: bool = false,
    llaw: bool = false,
    usbcrm: bool = false,
    ccdis: bool = false,
    qldis: bool = false,
    bplckc: bool = false,
    waitlock: bool = false,
};

pub const OscctrlDfllval = bitpack struct(u32) {
    fine: u8,
    reserved0: u2 = 0,
    coarse: u6,
    diff: u16,
};

pub const OscctrlDfllmul = bitpack struct(u32) {
    mul: u16 = 0,
    fstep: u8 = 0,
    reserved0: u2 = 0,
    cstep: u6 = 0,
};

pub const OscctrlDfllsync = bitpack struct(u8) {
    reserved0: u1 = 0,
    enable: bool = false,
    dfllctrlb: bool = false,
    dfllval: bool = false,
    dfllmul: bool = false,
    reserved1: u3 = 0,
};

pub const Oscctrl = extern struct {
    evctrl: OscctrlEvctrl,
    reserved0: [3]u8,
    intenclr: OscctrlInt,
    intenset: OscctrlInt,
    intflag: OscctrlInt,
    status: OscctrlStatus,
    xoscctrl: [2]OscctrlXoscctrl,
    dfllctrla: OscctrlDfllctrla,
    reserved2: [3]u8,
    dfllctrlb: OscctrlDfllctrlb,
    reserved3: [3]u8,
    dfllval: OscctrlDfllval,
    dfllmul: OscctrlDfllmul,
    dfllsync: OscctrlDfllsync,
    reserved4: [3]u8,
    dpll: [2]OscctrlDPLL,
};

pub const oscctrl: *volatile Oscctrl = @ptrFromInt(OSCCTRL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x58, @sizeOf(Oscctrl));
}
