const GCLK_BASE = 0x40001c00;

pub const GclkSyncBusy = packed struct(u32) {
    swrst: bool,
    reserved: u1,
    genctrl0: bool,
    genctrl1: bool,
    genctrl2: bool,
    genctrl3: bool,
    genctrl4: bool,
    reserved2: u25
};

pub const GclkSrc = enum(u5) {
    xosc = 0,
    gclk_in = 1,
    gclk_gen1 = 2,
    osculp32k = 3,
    xosc32k = 4,
    osc16m = 5,
    dfllulp = 6,
    fdpll96m = 7
};

pub const GclkGenCtrl = packed struct(u32) {
    src: GclkSrc,
    reserved: u3 = 0,
    genen: bool,
    idc: bool = false,
    oov: bool = false,
    oe: bool = false,
    divsel: bool = false,
    runstdby: bool = false,
    reserved2: u2 = 0,
    div: u16 = 0
};

pub const GclkPchCtrl = packed struct(u32) {
    gen: u3 = 0,
    reserved: u3 = 0,
    chen: bool = false,
    wrtlock: bool = false,
    reserved2: u24 = 0
};

pub const GclkChannel = enum(usize) {
    dpll = 0,
    dpll_32k = 1,
    dfllulp = 2,
    eic = 3,
    freqm_msr = 4,
    freqm_ref = 5,
    evsys_channel0 = 6,
    evsys_channel1 = 7,
    evsys_channel2 = 8,
    evsys_channel3 = 9,
    sercom_slow = 10,
    sercom0_core = 11,
    sercom1_core = 12,
    sercom2_core = 13,
    tc0_tc1 = 14,
    tc2 = 15,
    adc = 16,
    ac = 17,
    dac = 18,
    ptc = 19,
    ccl = 20
};

pub const Gclk = extern struct {
    ctrla: u8,
    reserved1: [3]u8,
    syncbusy: GclkSyncBusy,
    reserved2: [6]u32,
    genctrl: [5]GclkGenCtrl,
    reserved3: [19]u32,
    pchctrl: [21]GclkPchCtrl,

    pub fn channelEnable(self: *volatile Gclk, channel: GclkChannel, gen: u3) void {
        self.pchctrl[@backingInt(channel)] = GclkPchCtrl{
            .gen = gen,
            .chen = true,
        };
    }
};

pub const gclk: *volatile Gclk = @ptrFromInt(GCLK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xD4, @sizeOf(Gclk));
}
