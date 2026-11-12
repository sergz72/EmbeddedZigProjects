const SCB_BASE = 0xE000ED00;

pub const ScbCpuId = bitpack struct(u32) {
    revision: u4,
    partno: u12,
    reserved: u4,
    variant: u4,
    implementer: u8
};

pub const ScbIcsr = bitpack struct(u32) {
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

pub const ScbAircr = bitpack struct(u32) {
    vectreset: bool = false,
    vectclractive: bool = false,
    sysresetreq: bool = false,
    reserved: u5 = 0,
    prigroup: u3 = 0,
    reserved2: u4 = 0,
    endianess: bool = false,
    vectkey: u16 = 0x5FA
};

pub const ScbScr = bitpack struct(u32) {
    reserved: u1 = 0,
    sleeponexit: bool = false,
    sleepdeep: bool = false,
    reserved2: u1 = 0,
    sevonpend: bool = false,
    reserved3: u27 = 0
};

pub const ScbCfsrParts = bitpack struct(u32) {
    mmfsr: u8,
    bfsr: u8,
    ufsr: u16
};

pub const ScbCfsr = extern union {
    cfsr: u32,
    parts: ScbCfsrParts
};

pub const ScbAccess = enum(u2) {
    no_access = 0,
    privileged_only = 1,
    full_access = 3
};

pub const ScbCpacr = bitpack struct(u32) {
    cp0: ScbAccess = .no_access,
    cp1: ScbAccess = .no_access,
    cp2: ScbAccess = .no_access,
    cp3: ScbAccess = .no_access,
    cp4: ScbAccess = .no_access,
    cp5: ScbAccess = .no_access,
    cp6: ScbAccess = .no_access,
    cp7: ScbAccess = .no_access,
    reserved: u4 = 0,
    cp10: ScbAccess = .no_access,
    cp11: ScbAccess = .no_access,
    reserved2: u8 = 0
};

pub const ScbNsacr = bitpack struct(u32) {
    cp0: bool,
    cp1: bool,
    cp2: bool,
    cp3: bool,
    cp4: bool,
    cp5: bool,
    cp6: bool,
    cp7: bool,
    reserved: u2,
    cp10: bool,
    cp11: bool,
    reserved2: u20
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
    reserved2: [18]u32,
    cpacr: ScbCpacr,
    nsacr: ScbNsacr,

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
    try std.testing.expectEqual(0x90, @sizeOf(Scb));
}
