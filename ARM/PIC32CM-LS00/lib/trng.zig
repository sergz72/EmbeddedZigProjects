const TRNG_BASE = 0x42004400;

pub const TrngCtrlA = bitpack struct(u8) {
    reserved: u1 = 0,
    enable: bool = false,
    reserved2: u4 = 0,
    runstdby: bool = false,
    reserved3: u1 = 0
};

pub const Trng = extern struct {
    ctrla: TrngCtrlA,
    reserved1: [3]u8,
    evctrl: u8,
    reserved2: [3]u8,
    intenclr: u8,
    intenset: u8,
    intflag: u8,
    reserved3: [0x15]u8,
    data: u32,
};

pub fn init() void {
    trng.ctrla = TrngCtrlA{ .enable = true };
}

pub fn generate(data: []u32) void {
    for (data) |*d| {
        while (trng.intflag == 0) {
            asm volatile ("nop");
        }
        d.* = trng.data;
    }
}

pub const trng: *volatile Trng = @ptrFromInt(TRNG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Trng));
}
