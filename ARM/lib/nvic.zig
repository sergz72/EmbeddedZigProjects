const NVIC_BASE: usize = 0xE000E000;

pub const Nvic = extern struct {
    reserved: u32,
    ictr: u32,
    reserved2: [62]u32,
    iser: [8]u32,
    reserved3: [24]u32,
    icer: [8]u32,
    reserved4: [24]u32,
    ispr: [8]u32,
    reserved5: [24]u32,
    icpr: [8]u32,
    reserved6: [24]u32,
    iabr: [8]u32,
    reserved7: [56]u32,
    ipr:  [60]u32,

    pub fn interrupt_enable(self: *volatile Nvic, interrupt: u32) void {
        const shift: u5 = @truncate(interrupt);
        self.iser[interrupt >> 5] = @as(u32, 1) << shift;
    }

    pub fn interrupt_disable(self: *volatile Nvic, interrupt: u32) void {
        const shift: u5 = @truncate(interrupt);
        self.icer[interrupt >> 5] = @as(u32, 1) << shift;
    }
};

pub const nvic: *volatile Nvic = @ptrFromInt(NVIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x4F0, @sizeOf(Nvic));
}
