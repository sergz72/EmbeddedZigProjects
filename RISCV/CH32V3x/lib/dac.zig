const DAC_BASE: usize = 0x40007400;

pub const DacChannel = extern struct {
    r12bdhr: u32,
    l12bdhr: u32,
    r8bdhr: u32
};

pub const DacCtlrChannel = packed struct(u13) {
    en: bool = false,
    boff: bool = false,
    ten: bool = false,
    tsel: u3 = 0,
    wave: u2 = 0,
    mamp: u4 = 0,
    dmaen: bool = false
};

pub const DacCtlr = packed struct(u32) {
    ch1: DacCtlrChannel = DacCtlrChannel{},
    reserved: u3 = 0,
    ch2: DacCtlrChannel = DacCtlrChannel{},
    reserved2: u3 = 0
};

pub const Dac = extern struct {
    ctlr: DacCtlr,
    swtr: u32,
    ch1: DacChannel,
    ch2: DacChannel,
    ch12: DacChannel,
    dor: [2]u32
};

pub const dac: *volatile Dac = @ptrFromInt(DAC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x34, @sizeOf(Dac));
}
