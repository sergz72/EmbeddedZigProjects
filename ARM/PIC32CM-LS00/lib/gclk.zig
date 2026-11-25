const GCLK_BASE = 0x40001C00;

pub const GclkCtrla = bitpack struct(u8) {
    swrst: bool = false,
    reserved0: u7 = 0,
};

pub const GclkSyncbusy = bitpack struct(u32) {
    swrst: bool,
    reserved0: u1,
    genctrl0: bool,
    genctrl1: bool,
    genctrl2: bool,
    genctrl3: bool,
    genctrl4: bool,
    genctrl5: bool,
    genctrl6: bool,
    genctrl7: bool,
    reserved1: u22,
};

pub const GclkSrc = enum(u4) {
    xosc = 0,
    gclkin = 1,
    gclkgen1 = 2,
    osculp32k = 3,
    xosc32k = 4,
    osc16m = 5,
    dfllulp = 6,
    dfll48m = 7,
    fdpll96m = 8,
};

pub const GclkGenctrl = bitpack struct(u32) {
    src: GclkSrc = .xosc,
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

pub const GclkPchctrl = bitpack struct(u32) {
    gen: u3 = 0,
    reserved0: u3 = 0,
    chen: bool = false,
    wrtlock: bool = false,
    reserved1: u24 = 0,
};

pub const GclkChannel = enum(usize) {
    fdpll96m = 0,
    fdpll96m_32k = 1,
    dfllulp = 2,
    dfll48m = 3,
    eic = 4,
    freqm_msr = 5,
    freqm_ref = 6,
    usb = 7,
    evsys_channel0 = 8,
    evsys_channel1 = 9,
    evsys_channel2 = 10,
    evsys_channel3 = 11,
    evsys_channel4 = 12,
    evsys_channel5 = 13,
    evsys_channel6 = 14,
    evsys_channel7 = 15,
    sercom_slow = 16,
    sercom0_core = 17,
    sercom1_core = 18,
    sercom2_core = 19,
    sercom3_core = 20,
    sercom4_core = 21,
    sercom5_core = 22,
    tc0_tc1 = 23,
    tc2 = 24,
    tcc0_tcc1 = 25,
    tcc2 = 26,
    tcc3 = 27,
    adc = 28,
    ac = 29,
    dac = 30,
    ptc = 31,
    ccl = 32,
    i2s_0 = 33,
    i2s_1 = 34
};

pub const Gclk = extern struct {
    ctrla: GclkCtrla,
    reserved0: [3]u8,
    syncbusy: GclkSyncbusy,
    reserved1: [6]u32,
    genctrl: [8]GclkGenctrl,
    reserved2: [16]u32,
    pchctrl: [35]GclkPchctrl,
};

pub fn channelEnable(channel: GclkChannel, gen: u3) void {
    gclk.pchctrl[@backingInt(channel)] = GclkPchctrl{
        .gen = gen,
        .chen = true,
    };
}

pub const gclk: *volatile Gclk = @ptrFromInt(GCLK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10C, @sizeOf(Gclk));

}
