const EXTI_BASE: usize = 0x40010400;

pub const Exti = extern struct {
    intenr: u32,
    evenr: u32,
    rtenr: u32,
    ftenr: u32,
    swiewr: u32,
    intfr: u32
};

pub const exti: *volatile Exti = @ptrFromInt(EXTI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x18, @sizeOf(Exti));
}
