const TRNG_BASE = 0x42002800;

pub const TrngCtrlA = packed struct(u8) {
    reserved: u1 = 0,
    enable: bool = false,
    reserved2: u4 = 0,
    runstdby: bool = false,
    reserved3: u1 = 0
};

pub const Trng = extern struct {
    trng_ctrla: TrngCtrlA,
    reserved1: [3]u8,
    trng_evctrl: u8,
    reserved2: [3]u8,
    trng_intenclr: u8,
    trng_intenset: u8,
    trng_intflag: u8,
    reserved3: [0x15]u8,
    trng_data: u32
};

pub const trng: *volatile Trng = @ptrFromInt(TRNG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Trng));
}
