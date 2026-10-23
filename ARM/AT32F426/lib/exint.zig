pub const EXINT_BASE = 0x40010400;

pub const Exint = extern struct {
    inten: u32,
    evten: u32,
    polcfg1: u32,
    polcfg2: u32,
    swtrg: u32,
    intsts: u32,

    pub fn interruptEnable(self: *volatile Exint, line: u6, rising_edge: bool, falling_edge: bool) void {
        self.inten |= (1 << line);
        if (rising_edge) {
            self.polcfg1 |= (1 << line);
        }
        if (falling_edge) {
            self.polcfg2 |= (1 << line);
        }
    }
};

pub const exint: *volatile Exint = @ptrFromInt(EXINT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x18, @sizeOf(Exint));
}
