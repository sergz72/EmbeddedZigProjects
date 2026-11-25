const MCLK_BASE = 0x40000800;

pub const MclkCtrla = bitpack struct(u8) {
    reserved0: u2 = 0,
    cksel: bool = false,
    reserved1: u5 = 0,
};

pub const MclkCpudiv = enum(u8) {
    div1 = 1,
    div2 = 2,
    div4 = 4,
    div8 = 8,
    div16 = 16,
    div32 = 32,
    div64 = 64,
    div128 = 128,
};

pub const MclkAhbmask = bitpack struct(u32) {
    apba: bool = true,
    apbb: bool = true,
    apbc: bool = true,
    dmac: bool = true,
    dsu: bool = true,
    hmatrixhs: bool = true,
    pac: bool = true,
    nvmctrl: bool = true,
    reserved0: u4 = 3,
    tram: bool = true,
    usb: bool = true,
    reserved1: u18 = 0,
};

pub const MclkApbamask = bitpack struct(u32) {
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
    reserved0: u18 = 1,
};

pub const MclkApbbmask = bitpack struct(u32) {
    idau: bool = true,
    dsu: bool = true,
    nvmctrl: bool = true,
    reserved0: u1 = 1,
    hmatrixhs: bool = true,
    usb: bool = true,
    reserved1: u26 = 0,
};

pub const MclkApbcmask = bitpack struct(u32) {
    evsys: bool = true,
    sercom0: bool = true,
    sercom1: bool = true,
    sercom2: bool = true,
    sercom3: bool = true,
    sercom4: bool = true,
    sercom5: bool = true,
    tc0: bool = true,
    tc1: bool = true,
    tc2: bool = true,
    tcc0: bool = true,
    tcc1: bool = true,
    tcc2: bool = true,
    tcc3: bool = true,
    adc: bool = true,
    dac: bool = true,
    ptc: bool = true,
    trng: bool = true,
    ccl: bool = true,
    i2s: bool = true,
    opamp: bool = true,
    reserved0: u11 = 0,
};

pub const Mclk = extern struct {
    ctrla: MclkCtrla,
    intenclr: u8,
    intenset: u8,
    intflag: u8,
    cpudiv: MclkCpudiv,
    reserved0: [11]u8,
    ahbmask: MclkAhbmask,
    apbamask: MclkApbamask,
    apbbmask: MclkApbbmask,
    apbcmask: MclkApbcmask,
};

pub const mclk: *volatile Mclk = @ptrFromInt(MCLK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Mclk));
}
