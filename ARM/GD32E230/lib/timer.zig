const TIMER0_BASE: usize = 0x40012C00;
const TIMER2_BASE: usize = 0x40000400;
const TIMER13_BASE: usize = 0x40002000;
const TIMER14_BASE: usize = 0x40014000;
const TIMER15_BASE: usize = 0x40014400;
const TIMER16_BASE: usize = 0x40014800;
const TIMER5_BASE: usize = 0x40001000;

pub const TimerCtl0 = packed struct(u32) {
    cen: bool = false,
    udis: bool = false,
    ups: bool = false,
    spm: bool = false,
    dir: bool = false,
    cam: u2 = 0,
    arse: bool = false,
    ckdiv: u2 = 0,
    reserved: u22 = 0
};

pub const TimerCtl1 = packed struct(u32) {
    ccse: bool = false,
    reserved: u1 = 0,
    ccuc: bool = false,
    dmas: bool = false,
    mmc: u3 = 0,
    ti0s: bool = false,
    iso0: bool = false,
    iso0n: bool = false,
    iso1: bool = false,
    iso1n: bool = false,
    iso2: bool = false,
    iso2n: bool = false,
    iso3: bool = false,
    reserved2: u17 = 0
};

pub const TimerSmcfg = packed struct(u32) {
    smc: u3 = 0,
    ocrc: bool = false,
    trgs: u3 = 0,
    msm: bool = false,
    etfc: u4 = 0,
    etpsc: u2 = 0,
    smc1: bool = false,
    etp: bool = false,
    reserve: u16 = 0
};

pub const TimerDmaIntEn = packed struct(u32) {
    upie: bool = false,
    ch0ie: bool = false,
    ch1ie: bool = false,
    ch2ie: bool = false,
    ch3ie: bool = false,
    cmtie: bool = false,
    trgie: bool = false,
    brkie: bool = false,
    upden: bool = false,
    ch0den: bool = false,
    ch1den: bool = false,
    ch2den: bool = false,
    ch3den: bool = false,
    cmtden: bool = false,
    trgden: bool = false,
    reserved: u17 = 0
};

pub const TimerIntf = packed struct(u32) {
    upif: bool = false,
    ch0if: bool = false,
    ch1if: bool = false,
    ch2if: bool = false,
    ch3if: bool = false,
    cmtif: bool = false,
    trgif: bool = false,
    brkif: bool = false,
    reserved: u1 = 0,
    ch0of: bool = false,
    ch1of: bool = false,
    ch2of: bool = false,
    ch3of: bool = false,
    reserved2: u19 = 0
};

pub const TimerSwevg = packed struct(u32) {
    upg: bool = false,
    ch0g: bool = false,
    ch1g: bool = false,
    ch2g: bool = false,
    ch3g: bool = false,
    cmtg: bool = false,
    trgg: bool = false,
    brkg: bool = false,
    reserved: u24 = 0
};

pub const TimerChCtl0Capture = packed struct(u32) {
    ch0ms: u2 = 0,
    ch0cappsc: u2 = 0,
    ch0capflt: u4 = 0,
    ch1ms: u2 = 0,
    ch1cappsc: u2 = 0,
    ch1capflt: u4 = 0,
    reserved: u16 = 0
};

pub const TimerChCtl0Compare = packed struct(u32) {
    ch0ms: u2 = 0,
    ch0comfen: bool = false,
    ch0comsen: bool = false,
    ch0comctl: u3 = 0,
    ch0comcen: bool = false,
    ch1ms: u2 = 0,
    ch1comfen: bool = false,
    ch1comsen: bool = false,
    ch1comctl: u3 = 0,
    ch1comcen: bool = false,
    reserved: u16 = 0
};

pub const TimerChCtl0 = extern union {
    capture: TimerChCtl0Capture,
    compare: TimerChCtl0Compare
};

pub const TimerChCtl1Capture = packed struct(u32) {
    ch2ms: u2 = 0,
    ch2cappsc: u2 = 0,
    ch2capflt: u4 = 0,
    ch3ms: u2 = 0,
    ch3cappsc: u2 = 0,
    ch3capflt: u4 = 0,
    reserved: u16 = 0
};

pub const TimerChCtl1Compare = packed struct(u32) {
    ch2ms: u2 = 0,
    ch2comfen: bool = false,
    ch2comsen: bool = false,
    ch2comctl: u3 = 0,
    ch2comcen: bool = false,
    ch3ms: u2 = 0,
    ch3comfen: bool = false,
    ch3comsen: bool = false,
    ch3comctl: u3 = 0,
    ch3comcen: bool = false,
    reserved: u16 = 0
};

pub const TimerChCtl1 = extern union {
    capture: TimerChCtl1Capture,
    compare: TimerChCtl1Compare
};

pub const TimerChCtl2 = packed struct(u32) {
    ch0en: bool = false,
    ch0p: bool = false,
    ch0nen: bool = false,
    ch0np: bool = false,
    ch1en: bool = false,
    ch1p: bool = false,
    ch1nen: bool = false,
    ch1np: bool = false,
    ch2en: bool = false,
    ch2p: bool = false,
    ch2nen: bool = false,
    ch2np: bool = false,
    ch3en: bool = false,
    ch3p: bool = false,
    reserved: u18 = 0
};

pub const TimerCchp = packed struct(u32) {
    dtcfg: u8 = 0,
    prot: u2 = 0,
    ios: bool = false,
    ros: bool = false,
    brken: bool = false,
    brkp: bool = false,
    oaen: bool = false,
    poen: bool = false,
    reserved: u16 = 0
};

pub const TimerDmaCfg = packed struct(u32) {
    dmata: u5 = 0,
    reserved: u3 = 0,
    dmatc: u5 = 0,
    reserved2: u19 = 0
};

pub const TimerCfg = packed struct(u32) {
    outsel: bool = false,
    chvsel: bool = false,
    reserved: u30 = 0
};

pub const Timer = extern struct {
    ctl0: TimerCtl0,
    ctl1: TimerCtl1,
    smcfg: TimerSmcfg,
    dmainten: TimerDmaIntEn,
    intf: TimerIntf,
    swevg: TimerSwevg,
    chctl0: TimerChCtl0,
    chctl1: TimerChCtl1,
    chctl2: TimerChCtl2,
    cnt: u32,
    psc: u32,
    car: u32,
    crep: u32,
    cv: [4]u32,
    cchp: TimerCchp,
    dmacfg: TimerDmaCfg,
    dmatb: u32,
    reserved: [43]u32,
    cfg: TimerCfg
};

pub const adtm0: *volatile Timer = @ptrFromInt(TIMER0_BASE);

pub const gptm2: *volatile Timer = @ptrFromInt(TIMER2_BASE);
pub const gptm13: *volatile Timer = @ptrFromInt(TIMER13_BASE);
pub const gptm14: *volatile Timer = @ptrFromInt(TIMER14_BASE);
pub const gptm15: *volatile Timer = @ptrFromInt(TIMER15_BASE);
pub const gptm16: *volatile Timer = @ptrFromInt(TIMER16_BASE);

pub const bctm5: *volatile Timer = @ptrFromInt(TIMER5_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x100, @sizeOf(Timer));
}
