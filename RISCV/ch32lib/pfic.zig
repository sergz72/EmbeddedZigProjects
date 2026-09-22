const PFIC_BASE: usize = 0xE000E000;

pub const Interrupt = enum(u8) {
    NonMaskableInt         = 2,       // 2 Non Maskable Interrupt
    EXC                    = 3,       // 3 Exception Interrupt
    Ecall_M_Mode           = 5,       // 5 Ecall M Mode Interrupt
    Ecall_U_Mode           = 8,       // 8 Ecall U Mode Interrupt
    Break_Point            = 9,       // 9 Break Point Interrupt
    SysTick                = 12,      // 12 System timer Interrupt
    Software               = 14,      // 14 software Interrupt

    pub fn to_u8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};

pub const Pfic = extern struct {
    isr: [8]u32,
    ipr: [8]u32,
    ithresdr: u32,
    reserved: u32,
    cfgr: u32,
    gisr: u32,
    vtfidr: u32,
    reserved9: [3]u32,
    vtfaddrr: [4]u32,
    reserved2: [36]u32,
    ienr: [8]u32,
    reserved3: [24]u32,
    irer: [8]u32,
    reserved4: [24]u32,
    ipsr: [8]u32,
    reserved5: [24]u32,
    iprr: [8]u32,
    reserved6: [24]u32,
    iactr: [8]u32,
    reserved7: [56]u32,
    iprior: [16]u32,
    reserved8: [564]u32,
    sctlr: u32,

    pub fn interrupt_enable(self: *volatile Pfic, interrupt: u8) void {
        const shift: u5 = @truncate(interrupt);
        self.ienr[interrupt >> 5] = @as(u32, 1) << shift;
    }

    pub fn interrupt_disable(self: *volatile Pfic, interrupt: u8) void {
        const shift: u5 = @truncate(interrupt);
        self.irer[interrupt >> 5] = @as(u32, 1) << shift;
    }
};

pub const pfic: *volatile Pfic = @ptrFromInt(PFIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xD14, @sizeOf(Pfic));
}
