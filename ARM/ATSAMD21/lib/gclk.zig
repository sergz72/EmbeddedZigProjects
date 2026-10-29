const GCLK_BASE = 0x40000c00;

pub const GclkSrc = enum(u5) {
    xosc = 0,
    gclk_in = 1,
    gclk_gen1 = 2,
    osculp32k = 3,
    osc32k = 4,
    xosc32k = 5,
    osc8m = 6,
    dfll48m = 7,
    fdpll96m = 8
};

pub const GclkGenCtrl = packed struct(u32) {
    id: u4 = 0,
    reserved: u4 = 0,
    src: GclkSrc = .xosc,
    reserved2: u3 = 0,
    genen: bool = false,
    idc: bool = false,
    oov: bool = false,
    oe: bool = false,
    divsel: bool = false,
    runstdby: bool = false,
    reserved3: u10 = 0
};

pub const GclkChannel = enum(u6) {
    dfll48ref = 0,
    dpll = 1,
    dpll_32k = 2,
    wdt = 3,
    rtc = 4,
    eic = 5,
    usb = 6,
    evsys_channel0 = 7,
    evsys_channel1 = 8,
    evsys_channel2 = 9,
    evsys_channel3 = 10,
    evsys_channel4 = 11,
    evsys_channel5 = 12,
    evsys_channel6 = 13,
    evsys_channel7 = 14,
    evsys_channel8 = 15,
    evsys_channel9 = 0x10,
    evsys_channel10 = 0x11,
    evsys_channel11 = 0x12,
    sercom_slow = 0x13,
    sercom0_core = 0x14,
    sercom1_core = 0x15,
    sercom2_core = 0x16,
    sercom3_core = 0x17,
    sercom4_core = 0x18,
    sercom5_core = 0x19,
    tcc0_tcc1 = 0x1A,
    tcc2_tc3 = 0x1B,
    tc4_tc5 = 0x1C,
    tc6_tc7 = 0x1D,
    adc = 0x1E,
    ac_dig = 0x1F,
    ac_ana = 0x20,
    dac = 0x21,
    ptc = 0x22,
    i2s0 = 0x23,
    i2s1 = 0x24
};

pub const GclkClkctrl = packed struct(u16) {
    id: GclkChannel,
    reserved: u2 = 0,
    gen: u4 = 0,
    reserved2: u2 = 0,
    clken: bool = false,
    wrtlock: bool = false
};

pub const GclkGendiv = packed struct(u32) {
    id: u4 = 0,
    reserved: u4 = 0,
    div: u16 = 0,
    reserved2: u8 = 0
};

pub const Gclk = extern struct {
    ctrl: u8,
    status: u8,
    clkctrl: GclkClkctrl,
    genctrl: GclkGenCtrl,
    gendiv: GclkGendiv,
};

pub const gclk: *volatile Gclk = @ptrFromInt(GCLK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(12, @sizeOf(Gclk));
}
