const PFIC_BASE: usize = 0xE000E000;

const PFIC_KEY1 = 0xFA05;
const PFIC_KEY2 = 0xBCAF;
const PFIC_KEY3 = 0xBEEF;

pub const Interrupt = enum(u8) {
    NonMaskableInt         = 2,       // 2 Non Maskable Interrupt
    EXC                    = 3,       // 3 Exception Interrupt
    Ecall_M_Mode           = 5,       // 5 Ecall M Mode Interrupt
    Ecall_U_Mode           = 8,       // 8 Ecall U Mode Interrupt
    Break_Point            = 9,       // 9 Break Point Interrupt
    SysTick                = 12,      // 12 System timer Interrupt
    SysTick1               = 13,      // 13 System timer 2 Interrupt
    Software               = 14,      // 14 software Interrupt

    pub fn toU8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};

pub const PficCfgr = bitpack struct(u32) {
    reserved: u7 = 0,
    sysreset: bool = false,
    reserved2: u8 = 0,
    keycode: u16 = PFIC_KEY3
};

pub const PficSctlr = bitpack struct(u32) {
    reserved: u1 = 0,
    sleeponexit: bool = false,
    sleepdeep: bool = false,
    wfitowfe: bool = false,
    sevonpend: bool = false,
    setevent: bool = false,
    reserved2: u25 = 0,
    sysreset: bool = false
};

pub const Pfic = extern struct {
    isr: [8]u32,
    ipr: [8]u32,
    ithresdr: u32,
    reserved: u32,
    cfgr: PficCfgr,
    gisr: u32,
    vtfidr: [4]u8,
    reserved1: [3]u32,
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
    iprior: [256]u8,
    reserved8: [64]u32,
    iallocr: [256]u8,
    iautr: [8]u32,
    wakeip: [2]u32,
    reserved10: [22]u32,
    cstar: [2]u32,
    reserved11: [318]u32,
    eenr: u32,
    epr: u32,
    ewupr: u32,
    reserved12: [33]u32,
    sctlr: PficSctlr
};

pub fn setInterruptPriority(interrupt: u8, priority: u8) void {
    pfic.iprior[interrupt] = priority;
}

pub fn interruptEnable(interrupt: u8) void {
    const shift: u5 = @truncate(interrupt);
    pfic.ienr[interrupt >> 5] = @as(u32, 1) << shift;
}

pub fn interruptDisable(interrupt: u8) void {
    const shift: u5 = @truncate(interrupt);
    pfic.irer[interrupt >> 5] = @as(u32, 1) << shift;
}

pub fn systemReset() noreturn {
    pfic.cfgr = PficCfgr{.sysreset = true};
    while (true) {
        asm volatile ("wfi");
    }
}

pub fn wakeupCpu1(address: usize) void {
    pfic.wakeip[1] = address;
    pfic.sctlr.setevent = true;
}

pub const pfic: *volatile Pfic = @ptrFromInt(PFIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xD14, @sizeOf(Pfic));
}
