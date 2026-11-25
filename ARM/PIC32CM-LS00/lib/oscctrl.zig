const OSCCTRL_BASE = 0x40001000;

pub const OscctrlEvctrl = bitpack struct(u8) {
    cfdeo: bool = false,
    tuneei: bool = false,
    tuneinv: bool = false,
    reserved0: u5 = 0,
};

pub const OscctrlInt = bitpack struct(u32) {
    xoscrdy: bool = false,
    xoscfail: bool = false,
    reserved0: u2 = 0,
    osc16mrdy: bool = false,
    reserved1: u3 = 0,
    dfllulprdy: bool = false,
    dfllulplock: bool = false,
    dfllulpnolock: bool = false,
    reserved2: u5 = 0,
    dplllckr: bool = false,
    dplllckf: bool = false,
    dplllto: bool = false,
    dpllldrto: bool = false,
    reserved3: u4 = 0,
    dfllrdy: bool = false,
    dflloob: bool = false,
    dflllckf: bool = false,
    dflllckc: bool = false,
    dfllrcs: bool = false,
    reserved4: u3 = 0,
};

pub const OscctrlStatus = bitpack struct(u32) {
    xoscrdy: bool,
    xoscfail: bool,
    xosccksw: bool,
    reserved0: u1,
    osc16mrdy: bool,
    reserved1: u3,
    dfllulprdy: bool,
    dfllulplock: bool,
    dfllulpnolock: bool,
    reserved2: u5,
    dplllckr: bool,
    dplllckf: bool,
    dplllto: bool,
    dpllldrto: bool,
    reserved3: u4,
    dfllrdy: bool,
    dflloob: bool,
    dflllckf: bool,
    dflllckc: bool,
    dfllrcs: bool,
    reserved4: u3,
};

pub const OscctrlGain = enum(u3) {
    _2 = 0,
    _4 = 1,
    _8 = 2,
    _16 = 3,
    _30 = 4,
};

pub const OscctrlStartup = enum(u4) {
    cycle1 = 0,
    cycle2 = 1,
    cycle4 = 2,
    cycle8 = 3,
    cycle16 = 4,
    cycle32 = 5,
    cycle64 = 6,
    cycle128 = 7,
    cycle256 = 8,
    cycle512 = 9,
    cycle1024 = 10,
    cycle2048 = 11,
    cycle4096 = 12,
    cycle8192 = 13,
    cycle16384 = 14,
    cycle32768 = 15,
};

pub const OscctrlXoscctrl = bitpack struct(u16) {
    reserved0: u1 = 0,
    enable: bool = false,
    xtalen: bool = false,
    cfden: bool = false,
    swben: bool = false,
    reserved1: u1 = 0,
    runstdby: bool = false,
    ondemand: bool = true,
    gain: OscctrlGain = ._2,
    ampgc: bool = false,
    startup: OscctrlStartup = .cycle1,
};

pub const OscctrlCfdpresc = enum(u8) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7,
};

pub const OscctrlFsel = enum(u2) {
    _4Mhz = 0,
    _8Mhz = 1,
    _12Mhz = 2,
    _16Mhz = 3,
};

pub const OscctrlOsc16mctrl = bitpack struct(u8) {
    reserved0: u1 = 1,
    enable: bool = true,
    fsel: OscctrlFsel = ._4Mhz,
    reserved1: u2 = 2,
    runstdby: bool = false,
    ondemand: bool = true,
};

pub const OscctrlDiv = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
};

pub const OscctrlDfllulpctrl = bitpack struct(u16) {
    reserved0: u1 = 0,
    enable: bool = false,
    reserved1: u1 = 0,
    binse: bool = false,
    safe: bool = false,
    dither: bool = false,
    runstdby: bool = false,
    ondemand: bool = false,
    div: OscctrlDiv = .div32,
    reserved2: u5 = 0,
};

pub const OscctrlStep = enum(u3) {
    _1 = 0,
    _2 = 1,
    _4 = 2,
    _8 = 3,
};

pub const OscctrlPer = enum(u3) {
    _1 = 0,
    _2 = 1,
    _4 = 2,
    _8 = 3,
    _16 = 4,
    _32 = 5,
};

pub const OscctrlDfllulpdither = bitpack struct(u8) {
    step: OscctrlStep = ._1,
    reserved0: u1 = 0,
    per: OscctrlPer = ._1,
    reserved1: u1 = 0,
};

pub const OscctrlDfllulprreq = bitpack struct(u8) {
    reserved0: u7 = 0,
    rreq: bool = false,
};

pub const OscctrlDfllulpsyncbusy = bitpack struct(u32) {
    reserved0: u1,
    enable: bool,
    reserved1: u1,
    delay: bool,
    reserved2: u28,
};

pub const OscctrlDfllctrl = bitpack struct(u16) {
    reserved0: u1 = 0,
    enable: bool = false,
    mode: bool = false,
    stable: bool = false,
    llaw: bool = false,
    usbcrm: bool = false,
    runstdby: bool = false,
    ondemand: bool = true,
    ccdis: bool = false,
    qldis: bool = false,
    bplckc: bool = false,
    waitlock: bool = false,
    reserved1: u4 = 0,
};

pub const OscctrlDfllval = bitpack struct(u32) {
    fine: u10 = 0,
    coarse: u6 = 0,
    diff: u16 = 0,
};

pub const OscctrlDfllmul = bitpack struct(u32) {
    mul: u16 = 0,
    fstep: u10 = 0,
    cstep: u6 = 0,
};

pub const OscctrlDfllsync = bitpack struct(u8) {
    reserved0: u7 = 0,
    readreq: bool = false,
};

pub const OscctrlDpllctrla = bitpack struct(u8) {
    reserved0: u1 = 0,
    enable: bool = false,
    reserved1: u4 = 2,
    runstdby: bool = false,
    ondemand: bool = true,
};

pub const OscctrlDpllratio = bitpack struct(u32) {
    ldr: u12 = 0,
    reserved0: u4 = 0,
    ldrfrac: u4 = 0,
    reserved1: u12 = 0,
};

pub const OscctrlFilter = enum(u2) {
    default = 0,
    lbfilt = 1,
    hbfilt = 2,
    hdfilt = 3,
};

pub const OscctrlRefclk = enum(u2) {
    xosc32k = 0,
    xosc = 1,
    gclk = 2,
};

pub const OscctrlLtime = enum(u3) {
    default = 0,
    _8ms = 4,
    _9ms = 5,
    _10ms = 6,
    _11ms = 7,
};

pub const OscctrlDpllctrlb = bitpack struct(u32) {
    filter: OscctrlFilter = .default,
    lpen: bool = false,
    wuf: bool = false,
    refclk: OscctrlRefclk = .xosc32k,
    reserved0: u2 = 0,
    ltime: OscctrlLtime = .default,
    reserved1: u1 = 0,
    lbypass: bool = false,
    reserved2: u3 = 0,
    div: u11 = 0,
    reserved3: u5 = 0,
};

pub const OscctrlDpllPresc = enum(u8) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
};

pub const OscctrlDpllsyncbusy = bitpack struct(u8) {
    reserved0: u1,
    enable: bool,
    dpllratio: bool,
    dpllpresc: bool,
    reserved1: u4,
};

pub const OscctrlDpllstatus = bitpack struct(u8) {
    lock: bool,
    clkrdy: bool,
    reserved0: u6,
};

pub const Oscctrl = extern struct {
    evctrl: OscctrlEvctrl,
    reserved0: [3]u8,
    intenclr: OscctrlInt,
    intenset: OscctrlInt,
    intflag: OscctrlInt,
    status: OscctrlStatus,
    xoscctrl: OscctrlXoscctrl,
    cfdpresc: OscctrlCfdpresc,
    reserved1: u8,
    osc16mctrl: OscctrlOsc16mctrl,
    reserved2: [3]u8,
    dfllulpctrl: OscctrlDfllulpctrl,
    dfllulpdither: OscctrlDfllulpdither,
    dfllulprreq: OscctrlDfllulprreq,
    dfllulpdly: u32,
    dfllulpratio: u32,
    dfllulpsyncbusy: OscctrlDfllulpsyncbusy,
    reserved3: u32,
    dfllctrl: OscctrlDfllctrl,
    reserved4: u16,
    dfllval: OscctrlDfllval,
    dfllmul: OscctrlDfllmul,
    dfllsync: OscctrlDfllsync,
    reserved5: [3]u8,
    dpllctrla: OscctrlDpllctrla,
    reserved6: [3]u8,
    dpllratio: OscctrlDpllratio,
    dpllctrlb: OscctrlDpllctrlb,
    dpllpresc: OscctrlDpllPresc,
    reserved7: [3]u8,
    dpllsyncbusy: OscctrlDpllsyncbusy,
    reserved8: [3]u8,
    dpllstatus: OscctrlDpllstatus,
    reserved9: [3]u8,
};

pub const oscctrl: *volatile Oscctrl = @ptrFromInt(OSCCTRL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x58, @sizeOf(Oscctrl));
}
