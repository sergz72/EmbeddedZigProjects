const SYSCTRL_BASE = 0x40000800;

pub const SysctrlInt = bitpack struct(u32) {
    xoscrdy: bool = false,
    xosc32krdy: bool = false,
    osc32krdy: bool = false,
    osc8mrdy: bool = false,
    dfllrdy: bool = false,
    dflloob: bool = false,
    dflllckf: bool = false,
    dflllckc: bool = false,
    dfllrcs: bool = false,
    bod33rdy: bool = false,
    bod33det: bool = false,
    b33srdy: bool = false,
    reserved0: u3 = 0,
    dplllckr: bool = false,
    dplllckf: bool = false,
    dplllto: bool = false,
    reserved1: u14 = 0,
};

pub const SysctrlGain = enum(u3) {
    _2Mhz = 0,
    _4Mhz = 1,
    _8Mhz = 2,
    _16Mhz = 3,
    _30Mhz = 4,
};

pub const SysctrlStartupXosc = enum(u4) {
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

pub const SysctrlXosc = bitpack struct(u16) {
    reserved0: u1 = 0,
    enable: bool = false,
    xtalen: bool = false,
    reserved1: u3 = 0,
    runstdby: bool = false,
    ondemand: bool = true,
    gain: SysctrlGain = ._2Mhz,
    ampgc: bool = false,
    startup: SysctrlStartupXosc = .cycle1,
};

pub const SysctrlStartupXosc32k = enum(u3) {
    cycle1 = 0,
    cycle32 = 1,
    cycle2048 = 2,
    cycle4096 = 3,
    cycle16384 = 4,
    cycle32768 = 5,
    cycle65536 = 6,
    cycle131072 = 7,
};

pub const SysctrlXosc32k = bitpack struct(u16) {
    reserved0: u1 = 0,
    enable: bool = false,
    xtalen: bool = false,
    en32k: bool = false,
    en1k: bool = false,
    aampen: bool = false,
    runstdby: bool = false,
    ondemand: bool = true,
    startup: SysctrlStartupXosc32k = .cycle1,
    reserved1: u1 = 0,
    wrtlock: bool = false,
    reserved2: u3 = 0,
};

pub const SysctrlStartupOsc32k = enum(u3) {
    cycle3 = 0,
    cycle4 = 1,
    cycle6 = 2,
    cycle10 = 3,
    cycle18 = 4,
    cycle34 = 5,
    cycle66 = 6,
    cycle130 = 7,
};

pub const SysctrlOsc32k = bitpack struct(u32) {
    reserved0: u1 = 0,
    enable: bool = false,
    en32k: bool = false,
    en1k: bool = false,
    reserved1: u2 = 0,
    runstdby: bool = false,
    ondemand: bool = true,
    startup: SysctrlStartupOsc32k = .cycle3,
    reserved2: u1 = 0,
    wrtlock: bool = false,
    reserved3: u3 = 0,
    calib: u7 = 63,
    reserved4: u9 = 0,
};

pub const SysctrlOsculp32k = bitpack struct(u8) {
    calib: u5 = 31,
    reserved0: u2 = 0,
    wrtlock: bool = false,
};

pub const SysctrlPresc = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
};

pub const SysctrlFrange = enum(u2) {
    _4to6Mhz = 0,
    _6to8Mhz = 1,
    _8to11Mhz = 2,
    _11to15Mhz = 3,
};

pub const SysctrlOsc8m = bitpack struct(u32) {
    reserved0: u1 = 1,
    enable: bool = true,
    reserved1: u4 = 14,
    runstdby: bool = false,
    ondemand: bool = true,
    presc: SysctrlPresc = .div8,
    reserved2: u6 = 7,
    calib: u12 = 1799,
    reserved3: u2 = 2,
    frange: SysctrlFrange = ._8to11Mhz,
};

pub const SysctrlDfllctrl = bitpack struct(u16) {
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

pub const SysctrlDfllval = bitpack struct(u32) {
    fine: u10 = 0,
    coarse: u6 = 0,
    diff: u16 = 0,
};

pub const SysctrlDfllmul = bitpack struct(u32) {
    mul: u16 = 0,
    fstep: u10 = 0,
    cstep: u6 = 0,
};

pub const SysctrlDfllsync = bitpack struct(u8) {
    reserved0: u7 = 0,
    readreq: bool = false,
};

pub const SysctrlAction = enum(u2) {
    none = 0,
    reset = 1,
    interrupt = 2,
};

pub const SysctrlPsel = enum(u4) {
    div2 = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7,
    div512 = 8,
    div1k = 9,
    div2k = 10,
    div4k = 11,
    div8k = 12,
    div16k = 13,
    div32k = 14,
    div64k = 15,
};

pub const SysctrlBod33 = bitpack struct(u32) {
    reserved0: u1 = 0,
    enable: bool = false,
    hyst: bool = false,
    action: SysctrlAction = .none,
    reserved1: u1 = 0,
    runstdby: bool = false,
    reserved2: u1 = 0,
    mode: bool = false,
    cen: bool = false,
    reserved3: u2 = 0,
    psel: SysctrlPsel = .div2,
    level: u6 = 0,
    reserved4: u10 = 0,
};

pub const SysctrlVreg = bitpack struct(u16) {
    reserved0: u6 = 0,
    runstdby: bool = false,
    reserved1: u6 = 0,
    forceldo: bool = false,
    reserved2: u2 = 0,
};

pub const SysctrlVref = bitpack struct(u32) {
    reserved0: u1 = 0,
    tsen: bool = false,
    bgouten: bool = false,
    reserved1: u13 = 0,
    calib: u11 = 0,
    reserved2: u5 = 0,
};

pub const SysctrlDpllctrla = bitpack struct(u8) {
    reserved0: u1 = 0,
    enable: bool = false,
    reserved1: u4 = 2,
    runstdby: bool = false,
    ondemand: bool = true,
};

pub const SysctrlDpllratio = bitpack struct(u32) {
    ldr: u12 = 0,
    reserved0: u4 = 0,
    ldrfrac: u4 = 0,
    reserved1: u12 = 0,
};

pub const SysctrlFilter = enum(u2) {
    default = 0,
    lbfilt = 1,
    hbfilt = 2,
    hdfilt = 3,
};

pub const SysctrlRefclk = enum(u2) {
    ref0 = 0,
    ref1 = 1,
    gclk = 2,
};

pub const SysctrlLtime = enum(u3) {
    default = 0,
    _8ms = 4,
    _9ms = 5,
    _10ms = 6,
    _11ms = 7,
};

pub const SysctrlDpllctrlb = bitpack struct(u32) {
    filter: SysctrlFilter = .default,
    lpen: bool = false,
    wuf: bool = false,
    refclk: SysctrlRefclk = .ref0,
    reserved0: u2 = 0,
    ltime: SysctrlLtime = .default,
    reserved1: u1 = 0,
    lbypass: bool = false,
    reserved2: u3 = 0,
    div: u11 = 0,
    reserved3: u5 = 0,
};

pub const SysctrlDpllstatus = bitpack struct(u8) {
    lock: bool,
    clkrdy: bool,
    enable: bool,
    div: bool,
    reserved0: u4,
};

pub const Sysctrl = extern struct {
    intenclr: SysctrlInt,
    intenset: SysctrlInt,
    intflag: SysctrlInt,
    pclksr: SysctrlInt,
    xosc: SysctrlXosc,
    reserved0: u16,
    xosc32k: SysctrlXosc32k,
    reserved1: u16,
    osc32k: SysctrlOsc32k,
    osculp32k: SysctrlOsculp32k,
    reserved2: [3]u8,
    osc8m: SysctrlOsc8m,
    dfllctrl: SysctrlDfllctrl,
    reserved3: u16,
    dfllval: SysctrlDfllval,
    dfllmul: SysctrlDfllmul,
    dfllsync: SysctrlDfllsync,
    reserved4: [3]u8,
    bod33: SysctrlBod33,
    reserved5: u32,
    vreg: SysctrlVreg,
    reserved6: u16,
    vref: SysctrlVref,
    dpllctrla: SysctrlDpllctrla,
    reserved7: [3]u8,
    dpllratio: SysctrlDpllratio,
    dpllctrlb: SysctrlDpllctrlb,
    dpllstatus: SysctrlDpllstatus,
    reserved8: [3]u8,
};

pub const sysctrl: *volatile Sysctrl = @ptrFromInt(SYSCTRL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x54, @sizeOf(Sysctrl));
}
