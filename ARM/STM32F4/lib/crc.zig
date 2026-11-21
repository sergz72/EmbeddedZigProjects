const CRC_BASE = 0x40023000;

pub const CrcCr = bitpack struct(u32) {
    reset: bool = false,
    reserved0: u31 = 0,
};

pub const Crc = extern struct {
    dr: u32,
    idr: u32,
    cr: CrcCr,
};

pub const crc: *volatile Crc = @ptrFromInt(CRC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x0C, @sizeOf(Crc));
}
