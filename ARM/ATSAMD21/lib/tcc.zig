const TCC0_BASE = 0x42002000;
const TCC1_BASE = 0x42002400;
const TCC2_BASE = 0x42002800;

pub const TccResolution = enum(u2) {
    none = 0,
    dith4 = 1,
    dith5 = 2,
    dith6 = 3,
};

pub const TccPrescaler = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div64 = 5,
    div256 = 6,
    div1024 = 7,
};

pub const TccPrescsync = enum(u2) {
    gclk = 0,
    presc = 1,
    resync = 2,
};

pub const TccCtrla = bitpack struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    reserved0: u3 = 0,
    resolution: TccResolution = .none,
    reserved1: u1 = 0,
    prescaler: TccPrescaler = .div1,
    runstdby: bool = false,
    prescsync: TccPrescsync = .gclk,
    alock: bool = false,
    reserved2: u9 = 0,
    cpten0: bool = false,
    cpten1: bool = false,
    cpten2: bool = false,
    cpten3: bool = false,
    reserved3: u4 = 0,
};

pub const TccIdxcmd = enum(u2) {
    disable = 0,
    set = 1,
    clear = 2,
    hold = 3,
};

pub const TccCmd = enum(u3) {
    none = 0,
    retrigger = 1,
    stop = 2,
    update = 3,
    readsync = 4,
};

pub const TccCtrlb = bitpack struct(u8) {
    dir: bool = false,
    lupd: bool = false,
    oneshot: bool = false,
    idxcmd: TccIdxcmd = .disable,
    cmd: TccCmd = .none,
};

pub const TccSyncbusy = bitpack struct(u32) {
    swrst: bool,
    enable: bool,
    ctrlb: bool,
    status: bool,
    count: bool,
    patt: bool,
    wave: bool,
    per: bool,
    cc0: bool,
    cc1: bool,
    cc2: bool,
    cc3: bool,
    reserved0: u4,
    pattb: bool,
    waveb: bool,
    perb: bool,
    ccb0: bool,
    ccb1: bool,
    ccb2: bool,
    ccb3: bool,
    reserved1: u9,
};

pub const TccSrc = enum(u2) {
    disable = 0,
    enable = 1,
    invert = 2,
    altfault = 3,
};

pub const TccBlank = enum(u2) {
    none = 0,
    rise = 1,
    fall = 2,
    both = 3,
};

pub const TccHalt = enum(u2) {
    disable = 0,
    hw = 1,
    sw = 2,
    nr = 3,
};

pub const TccCapture = enum(u3) {
    disable = 0,
    capt = 1,
    captmin = 2,
    captmax = 3,
    locmin = 4,
    locmax = 5,
    deriv0 = 6,
};

pub const TccFctrl = bitpack struct(u32) {
    src: TccSrc = .disable,
    reserved0: u1 = 0,
    keep: bool = false,
    qual: bool = false,
    blank: TccBlank = .none,
    restart: bool = false,
    halt: TccHalt = .disable,
    chsel: u2 = 0,
    capture: TccCapture = .disable,
    reserved1: u1 = 0,
    blankval: u8 = 0,
    filterval: u4 = 0,
    reserved2: u4 = 0,
};

pub const TccWexctrl = bitpack struct(u32) {
    otmx: u2 = 0,
    reserved0: u6 = 0,
    dtien0: bool = false,
    dtien1: bool = false,
    dtien2: bool = false,
    dtien3: bool = false,
    reserved1: u4 = 0,
    dtls: u8 = 0,
    dths: u8 = 0,
};

pub const TccDrvctrl = bitpack struct(u32) {
    nre0: bool = false,
    nre1: bool = false,
    nre2: bool = false,
    nre3: bool = false,
    nre4: bool = false,
    nre5: bool = false,
    nre6: bool = false,
    nre7: bool = false,
    nrv0: bool = false,
    nrv1: bool = false,
    nrv2: bool = false,
    nrv3: bool = false,
    nrv4: bool = false,
    nrv5: bool = false,
    nrv6: bool = false,
    nrv7: bool = false,
    inven0: bool = false,
    inven1: bool = false,
    inven2: bool = false,
    inven3: bool = false,
    inven4: bool = false,
    inven5: bool = false,
    inven6: bool = false,
    inven7: bool = false,
    filterval0: u4 = 0,
    filterval1: u4 = 0,
};

pub const TccDbgctrl = bitpack struct(u8) {
    dbgrun: bool = false,
    reserved0: u1 = 0,
    fddbd: bool = false,
    reserved1: u5 = 0,
};

pub const TccEvact = enum(u3) {
    off = 0,
    retrigger = 1,
    countev = 2,
    start = 3,
    inc = 4,
    count = 5,
    fault = 7,
};

pub const TccCntsel = enum(u2) {
    start = 0,
    end = 1,
    between = 2,
    boundary = 3,
};

pub const TccEvctrl = bitpack struct(u32) {
    evact0: TccEvact = .off,
    evact1: TccEvact = .off,
    cntsel: TccCntsel = .start,
    ovfeo: bool = false,
    trgeo: bool = false,
    cnteo: bool = false,
    reserved0: u1 = 0,
    tcinv0: bool = false,
    tcinv1: bool = false,
    tcei0: bool = false,
    tcei1: bool = false,
    mcei0: bool = false,
    mcei1: bool = false,
    mcei2: bool = false,
    mcei3: bool = false,
    reserved1: u4 = 0,
    mceo0: bool = false,
    mceo1: bool = false,
    mceo2: bool = false,
    mceo3: bool = false,
    reserved2: u4 = 0,
};

pub const TccInt = bitpack struct(u32) {
    ovf: bool = false,
    trg: bool = false,
    cnt: bool = false,
    err: bool = false,
    reserved0: u7 = 0,
    dfs: bool = false,
    faulta: bool = false,
    faultb: bool = false,
    fault0: bool = false,
    fault1: bool = false,
    mc0: bool = false,
    mc1: bool = false,
    mc2: bool = false,
    mc3: bool = false,
    reserved1: u12 = 0,
};

pub const TccStatus = bitpack struct(u32) {
    stop: bool = true,
    idx: bool = false,
    reserved0: u1 = 0,
    dfs: bool = false,
    slave: bool = false,
    pattbv: bool = false,
    wavebv: bool = false,
    perbv: bool = false,
    faultain: bool = false,
    faultbin: bool = false,
    fault0in: bool = false,
    fault1in: bool = false,
    faulta: bool = false,
    faultb: bool = false,
    fault0: bool = false,
    fault1: bool = false,
    ccbv0: bool = false,
    ccbv1: bool = false,
    ccbv2: bool = false,
    ccbv3: bool = false,
    reserved1: u4 = 0,
    cmp0: bool = false,
    cmp1: bool = false,
    cmp2: bool = false,
    cmp3: bool = false,
    reserved2: u4 = 0,
};

pub const TccPatt = bitpack struct(u16) {
    pge0: bool = false,
    pge1: bool = false,
    pge2: bool = false,
    pge3: bool = false,
    pge4: bool = false,
    pge5: bool = false,
    pge6: bool = false,
    pge7: bool = false,
    pgv0: bool = false,
    pgv1: bool = false,
    pgv2: bool = false,
    pgv3: bool = false,
    pgv4: bool = false,
    pgv5: bool = false,
    pgv6: bool = false,
    pgv7: bool = false,
};

pub const TccWavegen = enum(u3) {
    nfrq = 0,
    mfrq = 1,
    npwm = 2,
    dscritical = 4,
    dsbottom = 5,
    dsboth = 6,
    dstop = 7,
};

pub const TccRamp = enum(u2) {
    ramp1 = 0,
    ramp2a = 1,
    ramp2 = 2,
};

pub const TccWave = bitpack struct(u32) {
    wavegen: TccWavegen = .nfrq,
    reserved0: u1 = 0,
    ramp: TccRamp = .ramp1,
    reserved1: u1 = 0,
    ciperen: bool = false,
    ciccen0: bool = false,
    ciccen1: bool = false,
    ciccen2: bool = false,
    ciccen3: bool = false,
    reserved2: u4 = 0,
    pol0: bool = false,
    pol1: bool = false,
    pol2: bool = false,
    pol3: bool = false,
    reserved3: u4 = 0,
    swap0: bool = false,
    swap1: bool = false,
    swap2: bool = false,
    swap3: bool = false,
    reserved4: u4 = 0,
};

pub const TccChannel = extern struct {
    patt: TccPatt,
    reserved6: u16,
    wave: TccWave,
    per: u32,
    cc: [4]u32,
    reserved: [4]u32
};

pub const Tcc = extern struct {
    ctrla: TccCtrla,
    ctrlbclr: TccCtrlb,
    ctrlbset: TccCtrlb,
    reserved0: u16,
    syncbusy: TccSyncbusy,
    fctrla: TccFctrl,
    fctrlb: TccFctrl,
    wexctrl: TccWexctrl,
    drvctrl: TccDrvctrl,
    reserved1: u16,
    dbgctrl: TccDbgctrl,
    reserved2: u8,
    evctrl: TccEvctrl,
    intenclr: TccInt,
    intenset: TccInt,
    intflag: TccInt,
    status: TccStatus,
    count: u32,
    ch: [2]TccChannel
};

pub const tcc0: *volatile Tcc = @ptrFromInt(TCC0_BASE);
pub const tcc1: *volatile Tcc = @ptrFromInt(TCC1_BASE);
pub const tcc2: *volatile Tcc = @ptrFromInt(TCC2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x90, @sizeOf(Tcc));
}
