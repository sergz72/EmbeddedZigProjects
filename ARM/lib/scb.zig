const SCB_BASE = 0xE000ED00;

pub const ScbCpuId = packed struct(u32) {
    revision: u4,
    partno: u12,
    reserved: u4,
    variant: u4,
    implementer: u8
};

pub const ScbIcsr = packed struct(u32) {
    vectactive: u9 = 0,
    reserved0: u2 = 0,
    rettobase: bool = false,
    vectpending: u6 = 0,
    reserved1: u4 = 0,
    isrpending: bool = false,
    reserved2: u2 = 0,
    pendstclr: bool = false,
    pendstset: bool = false,
    pendsvclr: bool = false,
    pendsvset: bool = false,
    reserved3: u2 = 0,
    nmipendset: bool = false
};

pub const ScbAircr = packed struct(u32) {
    vectreset: bool = false,
    vectclractive: bool = false,
    sysresetreq: bool = false,
    reserved: u5 = 0,
    prigroup: u3 = 0,
    reserved2: u4 = 0,
    endianess: bool = false,
    vectkey: u16 = 0x5FA
};

pub const ScbScr = packed struct(u32) {
    reserved: u1 = 0,
    sleeponexit: bool = false,
    sleepdeep: bool = false,
    reserved2: u1 = 0,
    sevonpend: bool = false,
    reserved3: u27 = 0
};

pub const ScbCfsrParts = packed struct(u32) {
    mmfsr: u8,
    bfsr: u8,
    ufsr: u16
};

pub const ScbCfsr = extern union {
    cfsr: u32,
    parts: ScbCfsrParts
};

pub const Scb = extern struct {
    cpuid: ScbCpuId,
    icsr: ScbIcsr,
    vtor: u32,
    aircr: ScbAircr,
    scr: ScbScr,
    ccr: u32,
    shpr: [3]u32,
    shcrs: u32,
    cfsr: ScbCfsr,
    hfsr: u32,
    reserved: u32,
    mmar: u32,
    bfar: u32,
    afsr: u32,

    pub fn reboot(self: *volatile Scb) void {
        asm volatile("dsb");
        self.aircr = ScbAircr{.sysresetreq = true};
        asm volatile("dsb");
        while (true) {
            asm volatile("wfi");
        }
    }
};

pub const scb: *volatile Scb = @ptrFromInt(SCB_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x40, @sizeOf(Scb));
}
