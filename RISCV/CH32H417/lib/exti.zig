const EXTI_BASE: usize = 0x40010400;

pub const Exti = extern struct {
    intenr: u32,
    evenr: u32,
    rtenr: u32,
    ftenr: u32,
    swievr: u32,
    intfr: u32,

    pub fn interruptEnable(self: *volatile Exti, line: u5, rising_edge: bool, falling_edge: bool) void {
        self.intenr |= (1 << line);
        if (rising_edge) {
            self.rtenr |= (1 << line);
        }
        if (falling_edge) {
            self.ftenr |= (1 << line);
        }
    }
};

pub const exti: *volatile Exti = @ptrFromInt(EXTI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x18, @sizeOf(Exti));
}
