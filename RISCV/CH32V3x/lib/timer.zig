const TIMER1_BASE: usize = 0x40012C00;
const TIMER2_BASE: usize = 0x40000000;
const TIMER3_BASE: usize = 0x40000400;
const TIMER4_BASE: usize = 0x40000800;
const TIMER5_BASE: usize = 0x40000C00;
const TIMER6_BASE: usize = 0x40001000;
const TIMER7_BASE: usize = 0x40001400;
const TIMER8_BASE: usize = 0x40013400;
const TIMER9_BASE: usize = 0x40014C00;
const TIMER10_BASE: usize = 0x40015000;

pub const TimerCtlr1 = packed struct(u16) {
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

pub const TimerCtlr2 = packed struct(u16) {
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

pub const TimerSmcfgr = packed struct(u16) {
    sms: u3 = 0,
    reserved: u1 = 0,
    ts: u3 = 0,
    msm: bool = false,
    etf: u4 = 0,
    etps: u2 = 0,
    ece: bool = false,
    etp: bool = false
};

pub const TimerDmaIntEnr = packed struct(u16) {
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

pub const TimerIntfr = packed struct(u16) {
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

pub const TimerSwevgr = packed struct(u16) {
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

pub const TimerChCtlr1Capture = packed struct(u16) {
    cc1s: u2 = 0,
    ic1psc: u2 = 0,
    ic1f: u4 = 0,
    cc2s: u2 = 0,
    ic2psc: u2 = 0,
    ic2f: u4 = 0
};

pub const TimerChCtlr1Compare = packed struct(u16) {
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

pub const TimerChCtlr1 = extern union {
    capture: TimerChCtlr1Capture,
    compare: TimerChCtlr1Compare
};

pub const TimerChCtlr2Capture = packed struct(u16) {
    cc3s: u2 = 0,
    ic3psc: u2 = 0,
    ic3f: u4 = 0,
    cc4s: u2 = 0,
    ic4psc: u2 = 0,
    ic4f: u4 = 0
};

pub const TimerChCtlr2Compare = packed struct(u16) {
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

pub const TimerChCtlr2 = extern union {
    capture: TimerChCtlr2Capture,
    compare: TimerChCtlr2Compare
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
    reserved: u2 = 0
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

pub const TimerDmaCfgr = packed struct(u16) {
    dba: u5 = 0,
    reserved: u3 = 0,
    dbl: u5 = 0,
    reserved2: u3 = 0
};

pub const TimerAux = packed struct(u16) {
    cap_ed_ch2: bool = false,
    cap_ed_ch3: bool = false,
    cap_ed_ch4: bool = false,
    reserved: u13 = 0
};

pub const TimerCnt = extern union {
    value16: u16,
    value32: u32
};

pub const Timer = extern struct {
    ctlr1: TimerCtlr1,
    reserved: u16,
    ctlr2: TimerCtlr2,
    reserved2: u16,
    smcfgr: TimerSmcfgr,
    reserved3: u16,
    dmaintenr: TimerDmaIntEnr,
    reserved4: u16,
    intfr: TimerIntfr,
    reserved5: u16,
    swevgr: TimerSwevgr,
    reserved6: u16,
    chctlr1: TimerChCtlr1,
    reserved7: u16,
    chctlr2: TimerChCtlr2,
    reserved8: u16,
    ccer: TimerCcer,
    reserved9: u16,
    cnt: TimerCnt,
    psc: u16,
    reserved11: u16,
    atrlr: TimerCnt,
    rptcr: u16,
    reserved13: u16,
    cvr: [4]TimerCnt,
    bdtr: TimerBdtr,
    reserved14: u16,
    dmacfgr: TimerDmaCfgr,
    reserved15: u16,
    dmaadr: u16,
    reserved16: u16,
    aux: TimerAux,
    reserved17: u16
};

pub const adtm1: *volatile Timer = @ptrFromInt(TIMER1_BASE);
pub const adtm8: *volatile Timer = @ptrFromInt(TIMER8_BASE);
pub const adtm9: *volatile Timer = @ptrFromInt(TIMER9_BASE);
pub const adtm10: *volatile Timer = @ptrFromInt(TIMER10_BASE);

pub const gptm2: *volatile Timer = @ptrFromInt(TIMER2_BASE);
pub const gptm3: *volatile Timer = @ptrFromInt(TIMER3_BASE);
pub const gptm4: *volatile Timer = @ptrFromInt(TIMER4_BASE);
pub const gptm5: *volatile Timer = @ptrFromInt(TIMER5_BASE);

pub const bctm6: *volatile Timer = @ptrFromInt(TIMER6_BASE);
pub const bctm7: *volatile Timer = @ptrFromInt(TIMER7_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x54, @sizeOf(Timer));
}
