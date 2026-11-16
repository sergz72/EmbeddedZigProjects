const CMC0_BASE = 0x40048000;

pub const Verid = bitpack struct(u32) {
    feature: u16,
    minor: u8,
    major: u8,
};

pub const Ckmode = enum(u4) {
    core_clock_on = 0,
    core_clock_off = 1,
    clocks_gated = 15
};

pub const Ckctrl = bitpack struct(u32) {
    ckmode: Ckmode = .core_clock_on,
    reserved0: u27 = 0,
    lock: bool = false,
};

pub const Ckstat = bitpack struct(u32) {
    ckmode: Ckmode = .core_clock_on,
    reserved0: u4 = 0,
    wakeup: u8 = 0,
    reserved1: u15 = 0,
    valid: bool = false,
};

pub const Pmprot = bitpack struct(u32) {
    lpmode: u4 = 0,
    reserved0: u27 = 0,
    lock: bool = false,
};

pub const Gpmctrl = bitpack struct(u32) {
    lpmode: u4 = 0,
    reserved0: u28 = 0,
};

pub const Lpmode = enum(u4) {
    active_sleep = 0,
    deep_sleep = 1,
    power_down = 3,
    deep_power_down = 15,
};

pub const Pmctrlmain = bitpack struct(u32) {
    lpmode: Lpmode = .active_sleep,
    reserved0: u28 = 0,
};

pub const Pmctrlwake = bitpack struct(u32) {
    lpmode: Lpmode = .active_sleep,
    reserved0: u28 = 0,
};

pub const Srs = bitpack struct(u32) {
    wakeup: bool,
    por: bool,
    vd: bool,
    reserved0: u1,
    warm: bool,
    fatal: bool,
    reserved1: u2,
    pin: bool,
    dap: bool,
    rstack: bool,
    lpack: bool,
    scg: bool,
    wwdt0: bool,
    sw: bool,
    lockup: bool,
    reserved2: u8,
    vbat: bool,
    wwdt1: bool,
    cdog0: bool,
    cdog1: bool,
    jtag: bool,
    reserved3: u1,
    secvio: bool,
    tamper: bool,
};

pub const Rpc = bitpack struct(u32) {
    filtcfg: u5 = 0,
    reserved0: u3 = 0,
    filten: bool = false,
    lpfen: bool = false,
    reserved1: u22 = 0,
};

pub const Ssrs = bitpack struct(u32) {
    wakeup: bool = false,
    por: bool = true,
    vd: bool = true,
    reserved0: u1 = 0,
    warm: bool = false,
    fatal: bool = false,
    reserved1: u2 = 0,
    pin: bool = false,
    dap: bool = false,
    rstack: bool = false,
    lpack: bool = false,
    scg: bool = false,
    wwdt0: bool = false,
    sw: bool = false,
    lockup: bool = false,
    cpu1: bool = false,
    reserved2: u7 = 0,
    vbat: bool = false,
    wwdt1: bool = false,
    cdog0: bool = false,
    cdog1: bool = false,
    jtag: bool = false,
    reserved3: u1 = 0,
    secvio: bool = false,
    tamper: bool = false,
};

pub const Srie = bitpack struct(u32) {
    reserved0: u8 = 136,
    pin: bool = false,
    dap: bool = false,
    reserved1: u1 = 1,
    lpack: bool = true,
    scg: bool = false,
    wwdt0: bool = false,
    sw: bool = false,
    lockup: bool = true,
    cpu1: bool = false,
    reserved2: u7 = 0,
    vbat: bool = false,
    wwdt1: bool = false,
    cdog0: bool = false,
    cdog1: bool = false,
    reserved3: u4 = 0,
};

pub const Srif = bitpack struct(u32) {
    reserved0: u8 = 0,
    pin: bool = false,
    dap: bool = false,
    reserved1: u1 = 0,
    lpack: bool = false,
    reserved2: u1 = 0,
    wwdt0: bool = false,
    sw: bool = false,
    lockup: bool = false,
    cpu1: bool = false,
    reserved3: u7 = 0,
    vbat: bool = false,
    wwdt1: bool = false,
    cdog0: bool = false,
    cdog1: bool = false,
    reserved4: u4 = 0,
};

pub const Mr0 = bitpack struct(u32) {
    ispmode_n: bool = false,
    reserved0: u31 = 0,
};

pub const Fm0 = bitpack struct(u32) {
    forcecfg: bool = false,
    reserved0: u31 = 0,
};

pub const Flashcr = bitpack struct(u32) {
    flashdis: bool = false,
    flashdoze: bool = false,
    reserved0: u30 = 0,
};

pub const Lock = enum(u3) {
    unlocked = 2,
    locked = 5,
};

pub const Blr = bitpack struct(u32) {
    lock: Lock = .unlocked,
    reserved0: u29 = 0,
};

pub const Corectl = bitpack struct(u32) {
    npie: bool = false,
    reserved0: u31 = 0,
};

pub const Dbgctl = bitpack struct(u32) {
    sod: bool = false,
    reserved0: u31 = 0,
};

pub const Cmc = extern struct {
    verid: Verid,
    reserved0: [3]u32,
    ckctrl: Ckctrl,
    ckstat: Ckstat,
    pmprot: Pmprot,
    gpmctrl: Gpmctrl,
    pmctrlmain: Pmctrlmain,
    pmctrlwake: Pmctrlwake,
    reserved1: [22]u32,
    srs: Srs,
    rpc: Rpc,
    ssrs: Ssrs,
    srie: Srie,
    srif: Srif,
    reserved2: [2]u32,
    rstcnt: u32,
    mr0: Mr0,
    reserved3: [3]u32,
    fm0: Fm0,
    reserved4: [3]u32,
    sramdis0: u32,
    reserved5: [3]u32,
    sramret0: u32,
    reserved6: [3]u32,
    flashcr: Flashcr,
    reserved7: [7]u32,
    bsr: u32,
    reserved8: [2]u32,
    blr: Blr,
    corectl: Corectl,
    reserved9: [3]u32,
    dbgctl: Dbgctl,

    pub fn getResetCause(self: *volatile Cmc) []const u8 {
        const srs = self.srs;
        const ssrs = self.ssrs;
        self.ssrs = ssrs;
        if (srs.wakeup) return "Wakeup reset";
        if (srs.por) return "Power on reset";
        if (srs.vd) return "Voltage detect reset";
        if (srs.pin) return "Pin reset";
        if (srs.dap) return "Dap reset";
        if (srs.rstack) return "Rstack reset";
        if (srs.lpack) return "Lpack reset";
        if (srs.scg) return "Scg reset";
        if (srs.wwdt0) return "Wwdt0 reset";
        if (srs.sw) return "Software reset";
        if (srs.lockup) return "Lockup reset";
        if (srs.vbat) return "Vbat reset";
        if (srs.wwdt1) return "Wwdt1 reset";
        if (srs.cdog0) return "Cdog0 reset";
        if (srs.cdog1) return "Cdog1 reset";
        if (srs.jtag) return "Jtag reset";
        if (srs.secvio) return "Security violation reset";
        if (srs.tamper) return "Tamper reset";
        return "Unknown";
    }
};

pub const cmc0: *volatile Cmc = @ptrFromInt(CMC0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x124, @sizeOf(Cmc));
}
