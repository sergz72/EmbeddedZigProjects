const GCLK_BASE = 0x40001C00;

pub const Ctrla = bitpack struct(u8) {
    swrst: bool = false,
    reserved0: u7 = 0,
};

pub const Syncbusy = bitpack struct(u32) {
    swrst: bool,
    reserved0: u1,
    genctrl: u12 = 0,
    reserved1: u18,
};

pub const Src = enum(u4) {
    xosc0 = 0,
    xosc1 = 1,
    gclkin = 2,
    gclkgen1 = 3,
    osculp32k = 4,
    xosc32k = 5,
    dfll = 6,
    dpll0 = 7,
    dpll1 = 8,
};

pub const Genctrl = bitpack struct(u32) {
    src: Src = .xosc0,
    reserved0: u4 = 0,
    genen: bool = false,
    idc: bool = false,
    oov: bool = false,
    oe: bool = false,
    divsel: bool = false,
    runstdby: bool = false,
    reserved1: u2 = 0,
    div: u16 = 0,
};

pub const GclkPchCtrl = bitpack struct(u32) {
    gen: u4 = 0,
    reserved0: u2 = 0,
    chen: bool = false,
    wrtlock: bool = false,
    reserved1: u24 = 0,
};

pub const GclkChannel = enum(usize) {
    dfll48 = 0,
    fdpll0 = 1,
    fdpll1 = 2,
    fdpll_32k_sdch_slow_sercom_slow = 3,
    eic = 4,
    freqm_msr = 5,
    freqm_ref = 6,
    sercom0_core = 7,
    sercom1_core = 8,
    tco_tc1 = 9,
    usb = 10,
    evsys_0 = 11,
    evsys_1 = 12,
    evsys_2 = 13,
    evsys_3 = 14,
    evsys_4 = 15,
    evsys_5 = 16,
    evsys_6 = 17,
    evsys_7 = 18,
    evsys_8 = 19,
    evsys_9 = 20,
    evsys_10 = 21,
    evsys_11 = 22,
    sercom2_core = 23,
    sercom3_core = 24,
    tcc0_tcc1 = 25,
    tc2_tc3 = 26,
    can0 = 27,
    can1 = 28,
    tcc2_tcc3 = 29,
    tc4_tc5 = 30,
    pdec = 31,
    ac = 32,
    ccl = 33,
    sercom4_core = 34,
    sercom5_core = 35,
    sercom6_core = 36,
    sercom7_core = 37,
    tcc4 = 38,
    tc6_tc7 = 39,
    adc0 = 40,
    adc1 = 41,
    dac = 42,
    i2s0 = 43,
    i2s1 = 44,
    sdch0 = 45,
    sdch1 = 46, 
    cm4_trace = 47
};

pub const Gclk = extern struct {
    ctrla: Ctrla,
    reserved0: [3]u8,
    syncbusy: Syncbusy,
    reserved1: [6]u32,
    genctrl: [12]Genctrl,
    reserved2: [12]u32,
    pchctrl: [48]GclkPchCtrl,

    pub fn channelEnable(self: *volatile Gclk, channel: GclkChannel, gen: u4) void {
        self.pchctrl[@backingInt(channel)] = GclkPchCtrl{
            .gen = gen,
            .chen = true,
        };
    }
};

pub const gclk: *volatile Gclk = @ptrFromInt(GCLK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x140, @sizeOf(Gclk));
}
