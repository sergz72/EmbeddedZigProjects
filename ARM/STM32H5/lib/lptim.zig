const LPTIM1_BASE = 0x44004400;
const LPTIM2_BASE = 0x40009400;
const LPTIM3_BASE = 0x44004800;
const LPTIM4_BASE = 0x44004C00;
const LPTIM5_BASE = 0x44005000;
const LPTIM6_BASE = 0x44005400;

pub const LptimIr = packed struct(u32) {
    cc1if: bool = false,
    arrm: bool = false,
    exttrig: bool = false,
    cmp1ok: bool = false,
    arrok: bool = false,
    up: bool = false,
    down: bool = false,
    ue: bool = false,
    repok: bool = false,
    cc2if: bool = false,
    reserved1: u2 = 0,
    cc1of: bool = false,
    cc2of: bool = false,
    reserved2: u5 = 0,
    cmp2ok: bool = false,
    reserved4: u4 = 0,
    dierok: bool = false,
    reserved3: u7 = 0,
};

pub const LptimDier = packed struct(u32) {
    cc1ie: bool = false,
    arrmie: bool = false,
    exttrigie: bool = false,
    cmp1okie: bool = false,
    arrokie: bool = false,
    upie: bool = false,
    downie: bool = false,
    ueie: bool = false,
    repokie: bool = false,
    cc2ie: bool = false,
    reserved1: u2 = 0,
    cc1oie: bool = false,
    cc2oie: bool = false,
    reserved2: u2 = 0,
    cc1de: bool = false,
    reserved6: u2 = 0,
    cmp2okie: bool = false,
    reserved3: u3 = 0,
    uede: bool = false,
    reserved4: u1 = 0,
    cc2de: bool = false,
    reserved5: u6 = 0,
};

pub const Ckpol = enum(u2) {
    rising_edge = 0,
    falling_edge = 1,
    both_edges = 2
};

pub const Ckflt = enum(u2) {
    any_level_change = 0,
    two_clock_periods_stable = 1,
    four_clock_periods_stable = 2,
    eight_clock_periods_stable = 3
};

pub const Presc = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7
};

pub const Trigen = enum(u2) {
    software = 0,
    rising_edge = 1,
    falling_edge = 2,
    both_edges = 3
};

pub const LptimCfgr = packed struct(u32) {
    cksel: bool = false,
    ckpol: Ckpol = .rising_edge,
    ckflt: Ckflt = .any_level_change,
    reserved0: u1 = 0,
    trgflt: Ckflt = .any_level_change,
    reserved1: u1 = 0,
    presc: Presc = .div1,
    reserved2: u1 = 0,
    trigsel: u3 = 0,
    reserved3: u1 = 0,
    trigen: Trigen = .software,
    timout: bool = false,
    wave: bool = false,
    wavpol: bool = false,
    preload: bool = false,
    countmode: bool = false,
    enc: bool = false,
    reserved4: u7 = 0,
};

pub const LptimCr = packed struct(u32) {
    enable: bool = false,
    sngstrt: bool = false,
    cntstrt: bool = false,
    countrst: bool = false,
    rstare: bool = false,
    reserved0: u27 = 0,
};

pub const LptimCfgr2 = packed struct(u32) {
    in1sel: u2 = 0,
    reserved0: u2 = 0,
    in2sel: u2 = 0,
    reserved1: u10 = 0,
    ic1sel: u2 = 0,
    reserved2: u2 = 0,
    ic2sel: u2 = 0,
    reserved3: u10 = 0,
};

pub const Icpsc = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3
};

pub const LptimCcmr1 = packed struct(u32) {
    cc1sel: bool = false,
    cc1e: bool = false,
    cc1p: u2 = 0,
    reserved0: u4 = 0,
    ic1psc: Icpsc = .div1,
    reserved1: u2 = 0,
    ic1f: Ckflt = .any_level_change,
    reserved2: u2 = 0,
    cc2sel: bool = false,
    cc2e: bool = false,
    cc2p: u2 = 0,
    reserved3: u4 = 0,
    ic2psc: Icpsc = .div1,
    reserved4: u2 = 0,
    ic2f: Ckflt = .any_level_change,
    reserved5: u2 = 0,
};

pub const Lptim = extern struct {
    isr: LptimIr,
    icr: LptimIr,
    dier: LptimDier,
    cfgr: LptimCfgr,
    cr: LptimCr,
    ccr1: u32,
    arr: u32,
    cnt: u32,
    reserved3: u32,
    cfgr2: LptimCfgr2,
    rcr: u32,
    ccmr1: LptimCcmr1,
    reserved4: u32,
    ccr2: u32,
};

pub const lptim1: *volatile Lptim = @ptrFromInt(LPTIM1_BASE);
pub const lptim2: *volatile Lptim = @ptrFromInt(LPTIM2_BASE);
pub const lptim3: *volatile Lptim = @ptrFromInt(LPTIM3_BASE);
pub const lptim4: *volatile Lptim = @ptrFromInt(LPTIM4_BASE);
pub const lptim5: *volatile Lptim = @ptrFromInt(LPTIM5_BASE);
pub const lptim6: *volatile Lptim = @ptrFromInt(LPTIM6_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x38, @sizeOf(Lptim));
}
