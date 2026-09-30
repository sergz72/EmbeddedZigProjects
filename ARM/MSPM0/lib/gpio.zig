const common = @import("common");

const GPIOA_BASE: usize = 0x400A0000 + 0x400;
const GPIOB_BASE: usize = 0x400A2000 + 0x400;

pub const GpioGenEvent = extern struct {
    iidx: u32,
    reserved0: u32,
    imask: u32,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const GpioGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const Gpio = extern struct {
    fsub_0: u32,
    fsub_1: u32,
    reserved1: [15]u32,
    fpub_0: u32,
    fpub_1: u32,
    reserved2: [237]u32,
    gprcm: GpioGprcm,
    reserved3: [510]u32,
    clkovr: u32,
    reserved4: u32,
    pdbgctl: u32,
    reserved5: u32,
    cpu_int: GpioGenEvent,
    reserved6: u32,
    gen_event0: GpioGenEvent,
    reserved7: u32,
    gen_event1: GpioGenEvent,
    reserved8: [13]u32,
    evt_mode: u32,
    reserved9: [6]u32,
    desc: u32,
    reserved10: [64]u32,
    dout3_0: u32,
    dout7_4: u32,
    dout11_8: u32,
    dout15_12: u32,
    dout19_16: u32,
    dout23_20: u32,
    dout27_24: u32,
    dout31_28: u32,
    reserved11: [24]u32,
    dout31_0: u32,
    reserved12: [3]u32,
    doutset31_0: u32,
    reserved13: [3]u32,
    doutclr31_0: u32,
    reserved14: [3]u32,
    douttgl31_0: u32,
    reserved15: [3]u32,
    doe31_0: u32,
    reserved16: [3]u32,
    doeset31_0: u32,
    reserved17: [3]u32,
    doeclr31_0: u32,
    reserved18: [7]u32,
    din3_0: u32,
    din7_4: u32,
    din11_8: u32,
    din15_12: u32,
    din19_16: u32,
    din23_20: u32,
    din27_24: u32,
    din31_28: u32,
    reserved19: [24]u32,
    din31_0: u32,
    reserved20: [3]u32,
    polarity15_0: u32,
    reserved21: [3]u32,
    polarity31_16: u32,
    reserved22: [23]u32,
    ctl: u32,
    fastwake: u32,
    reserved23: [62]u32,
    sub0cfg: u32,
    reserved24: u32,
    filteren15_0: u32,
    filteren31_16: u32,
    dmamask: u32,
    reserved25: [3]u32,
    sub1cfg: u32,

    pub inline fn enablePower(self: *volatile Gpio) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub inline fn clearPins(self: *volatile Gpio, mask: u32) void {
        self.doutclr31_0 = mask;
    }

    pub inline fn setPins(self: *volatile Gpio, mask: u32) void {
        self.doutset31_0 = mask;
    }

    pub inline fn togglePins(self: *volatile Gpio, mask: u32) void {
        self.douttgl31_0 = mask;
    }

    pub inline fn enableOutput(self: *volatile Gpio, mask: u32) void {
        self.doeset31_0 = mask;
    }

    pub inline fn reset(self: *volatile Gpio) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpiob: *volatile Gpio = @ptrFromInt(GPIOB_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1524-0x400, @sizeOf(Gpio));
}
