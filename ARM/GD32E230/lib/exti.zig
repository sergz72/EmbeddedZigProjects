const EXTI_BASE: usize = 0x40010400;

pub const Exti = extern struct {
    inten: u32,
    even: u32,
    rten: u32,
    ften: u32,
    swiev: u32,
    pd: u32,

    pub fn interruptEnable(self: *volatile Exti, line: u5, rising_edge: bool, falling_edge: bool) void {
        self.inten |= (1 << line);
        if (rising_edge) {
            self.rten |= (1 << line);
        }
        if (falling_edge) {
            self.ften |= (1 << line);
        }
    }
};

pub const exti: *volatile Exti = @ptrFromInt(EXTI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x18, @sizeOf(Exti));
} 
