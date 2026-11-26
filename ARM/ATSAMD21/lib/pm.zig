const PM_BASE = 0x40000400;

pub const PmIdle = enum(u2) {
    cpu = 0,
    ahb = 1,
    apb = 2,
};

pub const PmSleep = bitpack struct(u8) {
    idle: PmIdle = .cpu,
    reserved0: u6 = 0,
};

pub const PmDiv = enum(u8) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7,
};

pub const PmAhbmask = bitpack struct(u32) {
    hpb0: bool = true,
    hpb1: bool = true,
    hpb2: bool = true,
    dsu: bool = true,
    nvmctrl: bool = true,
    dmac: bool = true,
    usb: bool = true,
    reserved0: u25 = 0,
};

pub const PmApbamask = bitpack struct(u32) {
    pac0: bool = true,
    pm: bool = true,
    sysctrl: bool = true,
    gclk: bool = true,
    wdt: bool = true,
    rtc: bool = true,
    eic: bool = true,
    reserved0: u25 = 0,
};

pub const PmApbbmask = bitpack struct(u32) {
    pac1: bool = true,
    dsu: bool = true,
    nvmctrl: bool = true,
    port: bool = true,
    dmac: bool = true,
    usb: bool = true,
    hmatrix: bool = true,
    reserved0: u25 = 0,
};

pub const PmApbcmask = bitpack struct(u32) {
    pac2: bool = false,
    evsys: bool = false,
    sercom0: bool = false,
    sercom1: bool = false,
    sercom2: bool = false,
    sercom3: bool = false,
    sercom4: bool = false,
    sercom5: bool = false,
    tcc0: bool = false,
    tcc1: bool = false,
    tcc2: bool = false,
    tc3: bool = false,
    tc4: bool = false,
    tc5: bool = false,
    reserved0: u2 = 1,
    adc: bool = true,
    ac: bool = false,
    dac: bool = false,
    ptc: bool = false,
    i2s: bool = false,
    reserved1: u11 = 0,
};

pub const PmRcause = bitpack struct(u8) {
    por: bool,
    bod12: bool,
    bod33: bool,
    reserved0: u1,
    ext: bool,
    wdt: bool,
    syst: bool,
    reserved1: u1,
};

pub const Pm = extern struct {
    ctrl: u8,
    sleep: PmSleep,
    reserved0: [3]u16,
    cpusel: PmDiv,
    apbasel: PmDiv,
    apbbsel: PmDiv,
    apbcsel: PmDiv,
    reserved1: [2]u32,
    ahbmask: PmAhbmask,
    apbamask: PmApbamask,
    apbbmask: PmApbbmask,
    apbcmask: PmApbcmask,
    reserved2: [4]u32,
    intenclr: u8,
    intenset: u8,
    intflag: u8,
    reserved3: u8,
    rcause: PmRcause,
    reserved4: [3]u8,
};

pub const pm: *volatile Pm = @ptrFromInt(PM_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x3C, @sizeOf(Pm));
}
