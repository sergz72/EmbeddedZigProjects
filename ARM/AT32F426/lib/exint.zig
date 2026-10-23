pub const EXINT_BASE = 0x40010400;

pub const Exint = extern struct {
    inten: u32,
    evten: u32,
    polcfg1: u32,
    polcfg2: u32,
    swtrg: u32,
    intsts: u32
};

pub const exint: *volatile Exint = @ptrFromInt(EXINT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x18, @sizeOf(Exint));
}
