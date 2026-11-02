const TIM1_BASE = 0x40012C00;
const TIM12_BASE = 0x40001800;
const TIM13_BASE = 0x40001C00;
const TIM14_BASE = 0x40002000;
const TIM15_BASE = 0x40014000;
const TIM16_BASE = 0x40014400;
const TIM17_BASE = 0x40014800;
const TIM2_BASE = 0x40000000;
const TIM3_BASE = 0x40000400;
const TIM4_BASE = 0x40000800;
const TIM5_BASE = 0x40000C00;
const TIM6_BASE = 0x40001000;
const TIM7_BASE = 0x40001400;
const TIM8_BASE = 0x40013400;

pub const TimCms = enum(u2) {
    edge_aligned = 0,
    center_aligned1 = 1,
    center_aligned2 = 2,
    center_aligned3 = 3,
};

pub const TimCkd = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2
};

pub const TimCr1 = packed struct(u16) {
    cen: bool = false,
    udis: bool = false,
    urs: bool = false,
    opm: bool = false,
    dir: bool = false,
    cms: TimCms = .edge_aligned,
    arpe: bool = false,
    ckd: TimCkd = .div1,
    reserved0: u1 = 0,
    uifremap: bool = false,
    dithen: bool = false,
    reserved1: u3 = 0,
};

pub const TimCr2 = packed struct(u32) {
    ccpc: bool = false,
    reserved0: u1 = 0,
    ccus: bool = false,
    ccds: bool = false,
    mms: u3 = 0,
    ti1s: bool = false,
    ois1: bool = false,
    ois1n: bool = false,
    ois2: bool = false,
    ois2n: bool = false,
    ois3: bool = false,
    ois3n: bool = false,
    ois4: bool = false,
    ois4n: bool = false,
    ois5: bool = false,
    reserved1: u1 = 0,
    ois6: bool = false,
    reserved2: u1 = 0,
    mms2: u4 = 0,
    reserved3: u1 = 0,
    mms_3: bool = false,
    reserved4: u6 = 0,
};

pub const Etps = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3
};

pub const TimSmcr = packed struct(u32) {
    sms: u3 = 0,
    occs: bool = false,
    ts: u3 = 0,
    msm: bool = false,
    etf: u4 = 0,
    etps: Etps = .div1,
    ece: bool = false,
    etp: bool = false,
    sms_3: u1 = 0,
    reserved0: u3 = 0,
    ts_4: u2 = 0,
    reserved1: u2 = 0,
    smspe: bool = false,
    smsps: bool = false,
    reserved2: u6 = 0,
};

pub const Timr = packed struct(u32) {
    u: bool = false,
    cc1: bool = false,
    cc2: bool = false,
    cc3: bool = false,
    cc4: bool = false,
    com: bool = false,
    t: bool = false,
    b: bool = false,
    ud: bool = false,
    cc1d: bool = false,
    cc2d: bool = false,
    cc3d: bool = false,
    cc4d: bool = false,
    comd: bool = false,
    td: bool = false,
    reserved0: u5 = 0,
    idx: bool = false,
    dir: bool = false,
    ierr: bool = false,
    terr: bool = false,
    reserved1: u8 = 0,
};

pub const TimEgr = packed struct(u16) {
    ug: bool = false,
    cc1g: bool = false,
    cc2g: bool = false,
    cc3g: bool = false,
    cc4g: bool = false,
    comg: bool = false,
    tg: bool = false,
    bg: bool = false,
    b2g: bool = false,
    reserved0: u7 = 0,
};

pub const TimIcpsc = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3
};

pub const TimCcmr1Input = packed struct(u32) {
    cc1s: u2 = 0,
    ic1psc: TimIcpsc = .div1,
    ic1f: u4 = 0,
    cc2s: u2 = 0,
    ic2psc: TimIcpsc = .div1,
    ic2f: u4 = 0,
    reserved0: u16 = 0,
};

pub const TimCcmr1Output = packed struct(u32) {
    cc1s: u2 = 0,
    oc1fe: bool = false,
    oc1pe: bool = false,
    oc1m: u3 = 0,
    oc1ce: bool = false,
    cc2s: u2 = 0,
    oc2fe: bool = false,
    oc2pe: bool = false,
    oc2m: u3 = 0,
    oc2ce: bool = false,
    oc1m_3: u1 = 0,
    reserved0: u7 = 0,
    oc2m_3: u1 = 0,
    reserved1: u7 = 0,
};

pub const TimCcmr2Input = packed struct(u32) {
    cc3s: u2 = 0,
    ic3psc: TimIcpsc = .div1,
    ic3f: u4 = 0,
    cc4s: u2 = 0,
    ic4psc: TimIcpsc = .div1,
    ic4f: u4 = 0,
    reserved0: u16 = 0,
};

pub const TimCcmr2Output = packed struct(u32) {
    cc3s: u2 = 0,
    oc3fe: bool = false,
    oc3pe: bool = false,
    oc3m: u3 = 0,
    oc3ce: bool = false,
    cc4s: u2 = 0,
    oc4fe: bool = false,
    oc4pe: bool = false,
    oc4m: u3 = 0,
    oc4ce: bool = false,
    oc3m_3: u1 = 0,
    reserved0: u7 = 0,
    oc4m_3: u1 = 0,
    reserved1: u7 = 0,
};

pub const TimCcer = packed struct(u32) {
    cc1e: bool = false,
    cc1p: bool = false,
    cc1ne: bool = false,
    cc1np: bool = false,
    cc2e: bool = false,
    cc2p: bool = false,
    cc2ne: bool = false,
    cc2np: bool = false,
    cc3e: bool = false,
    cc3p: bool = false,
    cc3ne: bool = false,
    cc3np: bool = false,
    cc4e: bool = false,
    cc4p: bool = false,
    cc4ne: bool = false,
    cc4np: bool = false,
    cc5e: bool = false,
    cc5p: bool = false,
    reserved0: u2 = 0,
    cc6e: bool = false,
    cc6p: bool = false,
    reserved1: u10 = 0,
};

pub const TimCnt = packed struct(u32) {
    cnt: u16 = 0,
    reserved0: u15 = 0,
    uifcpy: bool = false,
};

pub const Lock = enum(u2) {
    off = 0,
    level1 = 1,
    level2 = 2,
    level3 = 3
};

pub const TimBdtr = packed struct(u32) {
    dtg: u8 = 0,
    lock: Lock = .off,
    ossi: bool = false,
    ossr: bool = false,
    bke: bool = false,
    bkp: bool = false,
    aoe: bool = false,
    moe: bool = false,
    bkf: u4 = 0,
    bk2f: u4 = 0,
    bk2e: bool = false,
    bk2p: bool = false,
    bkdsrm: bool = false,
    bk2dsrm: bool = false,
    bkbid: bool = false,
    bk2bid: bool = false,
    reserved0: u2 = 0,
};

pub const TimCcr5 = packed struct(u32) {
    ccr5: u20 = 0,
    reserved0: u9 = 0,
    gc5c1: bool = false,
    gc5c2: bool = false,
    gc5c3: bool = false,
};

pub const TimCcmr3 = packed struct(u32) {
    reserved0: u2 = 0,
    oc5fe: bool = false,
    oc5pe: bool = false,
    oc5m: u3 = 0,
    oc5ce: bool = false,
    reserved1: u2 = 0,
    oc6fe: bool = false,
    oc6pe: bool = false,
    oc6m: u3 = 0,
    oc6ce: bool = false,
    oc5m_1: bool = false,
    reserved2: u7 = 0,
    oc6m_1: bool = false,
    reserved3: u7 = 0,
};

pub const TimDtr2 = packed struct(u32) {
    dtgf: u8 = 0,
    reserved0: u8 = 0,
    dtae: bool = false,
    dtpe: bool = false,
    reserved1: u14 = 0,
};

pub const Idir = enum(u2) {
    any = 0,
    up = 1,
    down = 2,
};

pub const TimEcr = packed struct(u32) {
    ie: bool = false,
    idir: Idir = .any,
    iblk: u2 = 0,
    fidx: bool = false,
    ipos: u2 = 0,
    reserved0: u8 = 0,
    pw: u8 = 0,
    pwprsc: u3 = 0,
    reserved1: u5 = 0,
};

pub const TimTisel = packed struct(u32) {
    ti1sel: u4 = 0,
    reserved0: u4 = 0,
    ti2sel: u4 = 0,
    reserved1: u4 = 0,
    ti3sel: u4 = 0,
    reserved2: u4 = 0,
    ti4sel: u4 = 0,
    reserved3: u4 = 0,
};

pub const TimAf1 = packed struct(u32) {
    bkine: bool = true,
    bkcmp1e: bool = false,
    bkcmp2e: bool = false,
    bkcmp3e: bool = false,
    bkcmp4e: bool = false,
    bkcmp5e: bool = false,
    bkcmp6e: bool = false,
    bkcmp7e: bool = false,
    bkcmp8e: bool = false,
    bkinp: bool = false,
    bkcmp1p: bool = false,
    bkcmp2p: bool = false,
    bkcmp3p: bool = false,
    bkcmp4p: bool = false,
    etrsel: u4 = 0,
    reserved0: u14 = 0,
};

pub const TimAf2 = packed struct(u32) {
    bk2ine: bool = true,
    bk2cmp1e: bool = false,
    bk2cmp2e: bool = false,
    bk2cmp3e: bool = false,
    bk2cmp4e: bool = false,
    bk2cmp5e: bool = false,
    bk2cmp6e: bool = false,
    bk2cmp7e: bool = false,
    bk2cmp8e: bool = false,
    bk2inp: bool = false,
    bk2cmp1p: bool = false,
    bk2cmp2p: bool = false,
    bk2cmp3p: bool = false,
    bk2cmp4p: bool = false,
    reserved0: u2 = 0,
    ocrsel: u3 = 0,
    reserved1: u13 = 0,
};

pub const Dbss = enum(u4) {
    reserved = 0,
    update = 1,
    cc1 = 2,
    cc2 = 3,
    cc3 = 4,
    cc4 = 5,
    com = 6,
    trigger = 7
};

pub const TimDcr = packed struct(u32) {
    dba: u5 = 0,
    reserved0: u3 = 0,
    dbl: u5 = 0,
    reserved1: u3 = 0,
    dbss: Dbss = .reserved,
    reserved2: u12 = 0,
};

pub const TimCcmr1 = extern union {
    input: TimCcmr1Input,
    output: TimCcmr1Output
};

pub const TimCcmr2 = extern union {
    input: TimCcmr2Input,
    output: TimCcmr2Output
};

pub const Tim = extern struct {
    cr1: TimCr1,
    reserved0: u16,
    cr2: TimCr2,
    smcr: TimSmcr,
    dier: Timr,
    sr: Timr,
    egr: TimEgr,
    reserved1: u16,
    ccmr1: TimCcmr1,
    ccmr2: TimCcmr2,
    ccer: TimCcer,
    cnt: TimCnt,
    psc: u16,
    reserved4: u16,
    arr: u32,
    rcr: u16,
    reserved5: u16,
    ccr: [4]u32,
    bdtr: TimBdtr,
    ccr5: TimCcr5,
    ccr6: u32,
    ccmr3: TimCcmr3,
    dtr2: TimDtr2,
    ecr: TimEcr,
    tisel: TimTisel,
    af1: TimAf1,
    af2: TimAf2,
    reserved6: [221]u32,
    dcr: TimDcr,
    dmar: u32,
};

pub const tim1: *volatile Tim = @ptrFromInt(TIM1_BASE);
pub const tim2: *volatile Tim = @ptrFromInt(TIM2_BASE);
pub const tim3: *volatile Tim = @ptrFromInt(TIM3_BASE);
pub const tim4: *volatile Tim = @ptrFromInt(TIM4_BASE);
pub const tim5: *volatile Tim = @ptrFromInt(TIM5_BASE);
pub const tim6: *volatile Tim = @ptrFromInt(TIM6_BASE);
pub const tim7: *volatile Tim = @ptrFromInt(TIM7_BASE);
pub const tim8: *volatile Tim = @ptrFromInt(TIM8_BASE);
pub const tim12: *volatile Tim = @ptrFromInt(TIM12_BASE);
pub const tim13: *volatile Tim = @ptrFromInt(TIM13_BASE);
pub const tim14: *volatile Tim = @ptrFromInt(TIM14_BASE);
pub const tim15: *volatile Tim = @ptrFromInt(TIM15_BASE);
pub const tim16: *volatile Tim = @ptrFromInt(TIM16_BASE);
pub const tim17: *volatile Tim = @ptrFromInt(TIM17_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x3E4, @sizeOf(Tim));
}
