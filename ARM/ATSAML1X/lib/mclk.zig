const MCLK_BASE = 0x40000800;

pub const MclkCtrlA = packed struct(u8) {
    reserved: u2 = 0,
    clsel: bool = false,
    reserved2: u5 = 0
};

pub const MclkCpiDiv = enum(u8) {
    div1 = 1,
    div2 = 2,
    div4 = 4,
    div8 = 8,
    div16 = 16,
    div32 = 32,
    div64 = 64,
    div128 = 128
};

pub const MclkAhbMask = packed struct(u32) {
    apba: bool = true,
    apbb: bool = true,
    apbc: bool = true,
    dmac: bool = true,
    dsu: bool = true,
    reserved: u1 = 1,
    pac: bool = true,
    nvmctrl: bool = true,
    reserved2: u4 = 0x0F,
    tram: bool = true,
    reserved3: u19 = 0x7FFFF
};

pub const MclkApbaMask = packed struct(u32) {
    pac: bool = true,
    pm: bool = true,
    mclk: bool = true,
    rstc: bool = true,
    oscctrl: bool = true,
    osc32kctrl: bool = true,
    supc: bool = true,
    gclk: bool = true,
    wdt: bool = true,
    rtc: bool = true,
    eic: bool = true,
    freqm: bool = true,
    port: bool = true,
    ac: bool = true,
    reserved: u18 = 0x3FFFF
};

pub const MclkApbbMask = packed struct(u32) {
    idau: bool = true,
    dsu: bool = true,
    nvmctrl: bool = true,
    reserved: u1 = 1,
    hmatrixhs: bool = true,
    reserved2: u27 = 0x7FFFFFF
};

pub const MclkApbcMask = packed struct(u32) {
    evsys: bool = true,
    sercom0: bool = true,
    sercom1: bool = true,
    sercom2: bool = true,
    tc0: bool = true,
    tc1: bool = true,
    tc2: bool = true,
    adc: bool = true,
    dac: bool = true,
    ptc: bool = true,
    trng: bool = true,
    ccl: bool = true,
    opamp: bool = true,
    reserved: u19 = 0x7FFFF
};

pub const Mclk = extern struct {
    ctrla: MclkCtrlA,
    intenclr: u8,
    intenset: u8,
    intflag: u8,
    cpudiv: MclkCpiDiv,
    reserved1: [0x0b]u8,
    ahbmask: MclkAhbMask,
    apbamask: MclkApbaMask,
    apbbmask: MclkApbbMask,
    apbcmask: MclkApbcMask
};

pub const mclk: *volatile Mclk = @ptrFromInt(MCLK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Mclk));
}
