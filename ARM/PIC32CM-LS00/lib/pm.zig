const PM_BASE = 0x40000400;

pub const PmSleepCfg = enum(u8) {
    idle = 2,
    standby = 4,
    off = 6
};

pub const PmPlsel = enum(u2) {
    pl0 = 0,
    pl2 = 2
};

pub const PmPlCfg = bitpack struct(u8) {
    plsel: PmPlsel = .pl0,
    reserved: u5 = 0,
    pldis: bool = false
};

pub const PmPwCfg = enum(u8) {
    _64k = 0,
    _48k = 1,
    _32k = 2,
    _16k = 3
};

pub const PmVregsMod = enum(u2) {
    auto = 0,
    performance = 1,
    lp = 2
};

pub const PmStdbyCfg = bitpack struct(u16) {
    pdcfg: bool = false,
    reserved: u3 = 0,
    dpgpdsw: bool = false,
    reserved2: u1 = 0,
    vregsmod: PmVregsMod = .auto,
    reserved3: u2 = 0,
    bbiashs: bool = false,
    reserved4: u1 = 0,
    bbiastr: bool = false,
    reserved5: u3 = 0
};

pub const Pm = extern struct {
    reserved1: u8,
    sleepcfg: PmSleepCfg,
    plcfg: PmPlCfg,
    pwcfg: PmPwCfg,
    intenclr: u8,
    intenset: u8,
    intflag: u8,
    reserved2: u8,
    stdbycfg: PmStdbyCfg,
};

pub fn enterStandby() void {
    pm.sleepcfg = .standby;
    while (pm.sleepcfg != .standby) {
        asm volatile("nop");
    }
    asm volatile("dsb");
    asm volatile("wfi");
    pm.sleepcfg = .idle;
    while (pm.sleepcfg != .idle) {
        asm volatile("nop");
    }
}

pub const pm: *volatile Pm = @ptrFromInt(PM_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x0A, @sizeOf(Pm));
}
