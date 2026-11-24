const ESIG_BASE = 0x1FFFF7E0;

pub const Esig = extern struct {
    flacap: u16,
    reserved0: [3]u16,
    uniid1: u32,
    uniid2: u32,
    uniid3: u32,
};

pub const esig: *volatile Esig = @ptrFromInt(ESIG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(Esig));
}
