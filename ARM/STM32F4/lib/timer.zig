const TIM1_BASE: usize = 0x40010000;
const TIM2_BASE: usize = 0x40000000;
const TIM3_BASE: usize = 0x40000400;
const TIM4_BASE: usize = 0x40000800;
const TIM5_BASE: usize = 0x40000C00;
const TIM6_BASE: usize = 0x40001000;
const TIM7_BASE: usize = 0x40001400;
const TIM8_BASE: usize = 0x40010400;
const TIM9_BASE: usize = 0x40014000;
const TIM10_BASE: usize = 0x40014400;
const TIM11_BASE: usize = 0x40014800;
const TIM12_BASE: usize = 0x40001800;
const TIM13_BASE: usize = 0x40001C00;
const TIM14_BASE: usize = 0x40002000;

pub const TimerCr1 = packed struct(u16) {
    cen: bool = false,
    udis: bool = false,
    urs: bool = false,
    opm: bool = false,
    dir: bool = false,
    cms: u2 = 0,
    apre: bool = false,
    ckd: u2 = 0,
    reserved: u6 = 0
};

pub const TimerCr2 = packed struct(u16) {
    ccpc: bool = false,
    reserved: u1 = 0,
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
    reserved2: u1 = 0
};

pub const TimerSmcr = packed struct(u16) {
    sms: u3 = 0,
    reserved: u1 = 0,
    ts: u3 = 0,
    msm: bool = false,
    etf: u4 = 0,
    etps: u2 = 0,
    ece: bool = false,
    etp: bool = false
};

pub const TimerDier = packed struct(u16) {
    uie: bool = false,
    cc1ie: bool = false,
    cc2ie: bool = false,
    cc3ie: bool = false,
    cc4ie: bool = false,
    comie: bool = false,
    tie: bool = false,
    bie: bool = false,
    ude: bool = false,
    cc1de: bool = false,
    cc2de: bool = false,
    cc3de: bool = false,
    cc4de: bool = false,
    comde: bool = false,
    tde: bool = false,
    reserved: u1 = 0
};

pub const TimerSr = packed struct(u16) {
    uif: bool = false,
    cc1if: bool = false,
    cc2if: bool = false,
    cc3if: bool = false,
    cc4if: bool = false,
    comif: bool = false,
    tif: bool = false,
    bif: bool = false,
    reserved: u1 = 0,
    cc1of: bool = false,
    cc2of: bool = false,
    cc3of: bool = false,
    cc4of: bool = false,
    reserved2: u3 = 0
};

pub const TimerEgr = packed struct(u16) {
    ug: bool = false,
    cc1g: bool = false,
    cc2g: bool = false,
    cc3g: bool = false,
    cc4g: bool = false,
    comg: bool = false,
    tg: bool = false,
    bg: bool = false,
    reserved: u8 = 0
};

pub const TimerCcmr1Capture = packed struct(u16) {
    cc1s: u2 = 0,
    ic1psc: u2 = 0,
    ic1f: u4 = 0,
    cc2s: u2 = 0,
    ic2psc: u2 = 0,
    ic2f: u4 = 0
};

pub const TimerCcmr1Compare = packed struct(u16) {
    cc1s: u2 = 0,
    oc1fe: bool = false,
    oc1pe: bool = false,
    oc1m: u3 = 0,
    oc1ce: bool = false,
    cc2s: u2 = 0,
    oc2fe: bool = false,
    oc2pe: bool = false,
    oc2m: u3 = 0,
    oc2ce: bool = false
};

pub const TimerCcmr1 = extern union {
    capture: TimerCcmr1Capture,
    compare: TimerCcmr1Compare
};

pub const TimerCcmr2Capture = packed struct(u16) {
    cc3s: u2 = 0,
    ic3psc: u2 = 0,
    ic3f: u4 = 0,
    cc4s: u2 = 0,
    ic4psc: u2 = 0,
    ic4f: u4 = 0
};

pub const TimerCcmr2Compare = packed struct(u16) {
    cc3s: u2 = 0,
    oc3fe: bool = false,
    oc3pe: bool = false,
    oc3m: u3 = 0,
    oc3ce: bool = false,
    cc4s: u2 = 0,
    oc4fe: bool = false,
    oc4pe: bool = false,
    oc4m: u3 = 0,
    oc4ce: bool = false
};

pub const TimerCcmr2 = extern union {
    capture: TimerCcmr2Capture,
    compare: TimerCcmr2Compare
};

pub const TimerCcer = packed struct(u16) {
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
    reserved: u1 = 0,
    cc4np: bool = false
};

pub const TimerBdtr = packed struct(u16) {
    dtg: u8 = 0,
    lock: u2 = 0,
    ossi: bool = false,
    ossr: bool = false,
    bke: bool = false,
    bkp: bool = false,
    aoe: bool = false,
    moe: bool = false
};

pub const TimerDcr = packed struct(u16) {
    dba: u5 = 0,
    reserved: u3 = 0,
    dbl: u5 = 0,
    reserved2: u3 = 0
};

pub const TimerCnt = extern union {
    value16: u16,
    value32: u32
};

pub const Timer = extern struct {
    cr1: TimerCr1,
    reserved: u16,
    cr2: TimerCr2,
    reserved2: u16,
    smcr: TimerSmcr,
    reserved3: u16,
    dier: TimerDier,
    reserved4: u16,
    sr: TimerSr,
    reserved5: u16,
    egr: TimerEgr,
    reserved6: u16,
    ccmr1: TimerCcmr1,
    reserved7: u16,
    ccmr2: TimerCcmr2,
    reserved8: u16,
    ccer: TimerCcer,
    reserved9: u16,
    cnt: TimerCnt,
    psc: u16,
    reserved11: u16,
    arr: TimerCnt,
    rcr: u16,
    reserved13: u16,
    ccr: [4]TimerCnt,
    bdtr: TimerBdtr,
    reserved14: u16,
    dcr: TimerDcr,
    reserved15: u16,
    dmar: u32
};

pub const adtm1: *volatile Timer = @ptrFromInt(TIM1_BASE);
pub const adtm8: *volatile Timer = @ptrFromInt(TIM8_BASE);

pub const gptm2: *volatile Timer = @ptrFromInt(TIM2_BASE);
pub const gptm3: *volatile Timer = @ptrFromInt(TIM3_BASE);
pub const gptm4: *volatile Timer = @ptrFromInt(TIM4_BASE);
pub const gptm5: *volatile Timer = @ptrFromInt(TIM5_BASE);
pub const gptm9: *volatile Timer = @ptrFromInt(TIM9_BASE);
pub const gptm10: *volatile Timer = @ptrFromInt(TIM10_BASE);
pub const gptm11: *volatile Timer = @ptrFromInt(TIM11_BASE);
pub const gptm12: *volatile Timer = @ptrFromInt(TIM12_BASE);
pub const gptm13: *volatile Timer = @ptrFromInt(TIM13_BASE);
pub const gptm14: *volatile Timer = @ptrFromInt(TIM14_BASE);

pub const bctm6: *volatile Timer = @ptrFromInt(TIM6_BASE);
pub const bctm7: *volatile Timer = @ptrFromInt(TIM7_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x50, @sizeOf(Timer));
}
