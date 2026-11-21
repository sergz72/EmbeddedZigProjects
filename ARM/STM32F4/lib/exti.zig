const EXTI_BASE: usize = 0x40013C00;

pub const Exti = extern struct {
    imr: u32,
    emr: u32,
    rtsr: u32,
    ftsr: u32,
    swier: u32,
    pr: u32,

    pub fn interruptEnable(self: *volatile Exti, line: u5, rising_edge: bool, falling_edge: bool) void {
        self.imr |= (1 << line);
        if (rising_edge) {
            self.rtsr |= (1 << line);
        }
        if (falling_edge) {
            self.ftsr |= (1 << line);
        }
    }
};

pub const exti: *volatile Exti = @ptrFromInt(EXTI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x18, @sizeOf(Exti));
}
