const NVIC_BASE: usize = 0xE000E000;

pub var priority_bits: u3 = 2;

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
};

pub fn enableInterrupt(interrupt: u8) void {
    const shift: u5 = @truncate(interrupt);
    nvic.iser[interrupt >> 5] = @as(u32, 1) << shift;
}

pub fn disableInterrupt(interrupt: u8) void {
    const shift: u5 = @truncate(interrupt);
    nvic.icer[interrupt >> 5] = @as(u32, 1) << shift;
}

pub fn setInterruptPriority(interrupt: u8, priority: u8) void {
    const idx = interrupt >> 2;
    var v = nvic.ipr[idx];
    const shift: u5 = @truncate((interrupt & 0x3) << 3);
    v &= ~(0xFF << shift);
    v |= priority << (shift + 8 - priority_bits);
    nvic.ipr[idx] = v;
}

pub inline fn getPrimask() u32 {
    return asm volatile ("mrs %[result], primask"
        : [result] "=r" (-> u32),
        :
        : .{ .memory = true });
}

pub inline fn setPrimask(primask: u32) void {
    asm volatile ("msr primask, %[val]"
        :
        : [val] "r" (primask),
        : .{ .memory = true });
}

pub inline fn disableIrq() void {
    asm volatile ("cpsid i"
        :
        :
        : .{ .memory = true });
}

pub inline fn enableIrq() void {
    asm volatile ("cpsie i"
        :
        :
        : .{ .memory = true });
}

pub const nvic: *volatile Nvic = @ptrFromInt(NVIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x4F0, @sizeOf(Nvic));
}
