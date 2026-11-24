const LTDC_BASE = 0x40014800;

pub const LtdcSscr = bitpack struct(u32) {
    vsh: u11 = 0,
    reserved0: u5 = 0,
    hsw: u12 = 0,
    reserved1: u4 = 0,
};

pub const LtdcBpcr = bitpack struct(u32) {
    avbp: u11 = 0,
    reserved0: u5 = 0,
    ahbp: u12 = 0,
    reserved1: u4 = 0,
};

pub const LtdcAwcr = bitpack struct(u32) {
    aah: u11 = 0,
    reserved0: u5 = 0,
    aaw: u12 = 0,
    reserved1: u4 = 0,
};

pub const LtdcTwcr = bitpack struct(u32) {
    totalh: u11 = 0,
    reserved0: u5 = 0,
    totalw: u12 = 0,
    reserved1: u4 = 0,
};

pub const LtdcGcr = bitpack struct(u32) {
    ltdcen: bool = false,
    reserved0: u3 = 2,
    dbw: u3 = 2,
    reserved1: u1 = 0,
    dgw: u3 = 2,
    reserved2: u1 = 0,
    drw: u3 = 2,
    reserved3: u1 = 0,
    den: bool = false,
    reserved4: u11 = 0,
    pcpol: bool = false,
    depol: bool = false,
    vspol: bool = false,
    hspol: bool = false,
};

pub const LtdcSrcr = bitpack struct(u32) {
    imr: bool = false,
    vbr: bool = false,
    reserved0: u30 = 0,
};

pub const LtdcBccr = bitpack struct(u32) {
    bcblue: u8 = 0,
    bcgreen: u8 = 0,
    bcred: u8 = 0,
    reserved0: u8 = 0,
};

pub const LtdcIer = bitpack struct(u32) {
    lie: bool = false,
    fuie: bool = false,
    reserved0: u1 = 0,
    rrie: bool = false,
    reserved1: u28 = 0,
};

pub const LtdcIsr = bitpack struct(u32) {
    lif: bool,
    fuif: bool,
    reserved0: u1,
    rrif: bool,
    reserved1: u28,
};

pub const LtdcIcr = bitpack struct(u32) {
    clif: bool = false,
    cfuif: bool = false,
    reserved0: u1 = 0,
    crrif: bool = false,
    reserved1: u28 = 0,
};

pub const LtdcLipcr = bitpack struct(u32) {
    lipos: u11 = 0,
    reserved0: u21 = 0,
};

pub const LtdcCpsr = bitpack struct(u32) {
    cypos: u16 = 0,
    cxpos: u16 = 0,
};

pub const LtdcCdsr = bitpack struct(u32) {
    vdes: bool,
    hdes: bool,
    vsyncs: bool,
    hsyncs: bool,
    reserved0: u28,
};

pub const LtdcLcr = bitpack struct(u32) {
    len: bool = false,
    colken: bool = false,
    reserved0: u2 = 0,
    cluten: bool = false,
    reserved1: u27 = 0,
};

pub const LtdcLwhpcr = bitpack struct(u32) {
    whstpos: u12 = 0,
    reserved0: u4 = 0,
    whsppos: u12 = 0,
    reserved1: u4 = 0,
};

pub const LtdcLwvpcr = bitpack struct(u32) {
    wvstpos: u11 = 0,
    reserved0: u5 = 0,
    wvsppos: u11 = 0,
    reserved1: u5 = 0,
};

pub const LtdcLckcr = bitpack struct(u32) {
    ckblue: u8 = 0,
    ckgreen: u8 = 0,
    ckred: u8 = 0,
    reserved0: u8 = 0,
};

pub const LtdcLpfcr = bitpack struct(u32) {
    pf: u3 = 0,
    reserved0: u29 = 0,
};

pub const LtdcLcacr = bitpack struct(u32) {
    consta: u8 = 0,
    reserved0: u24 = 0,
};

pub const LtdcLdccr = bitpack struct(u32) {
    dcblue: u8 = 0,
    dcgreen: u8 = 0,
    dcred: u8 = 0,
    dcalpha: u8 = 0,
};

pub const LtdcLbfcr = bitpack struct(u32) {
    bf2: u3 = 0,
    reserved0: u5 = 6,
    bf1: u3 = 6,
    reserved1: u21 = 0,
};

pub const LtdcLcfbar = bitpack struct(u32) {
    cfbadd: u32 = 0,
};

pub const LtdcLcfblr = bitpack struct(u32) {
    cfbll: u13 = 0,
    reserved0: u3 = 0,
    cfbp: u13 = 0,
    reserved1: u3 = 0,
};

pub const LtdcLcfblnr = bitpack struct(u32) {
    cfblnbr: u11 = 0,
    reserved0: u21 = 0,
};

pub const LtdcLclutwr = bitpack struct(u32) {
    blue: u8 = 0,
    green: u8 = 0,
    red: u8 = 0,
    clutadd: u8 = 0,
};

pub const LtdcLayer = extern struct {
    cr: LtdcLcr,
    whpcr: LtdcLwhpcr,
    wvpcr: LtdcLwvpcr,
    ckcr: LtdcLckcr,
    pfcr: LtdcLpfcr,
    cacr: LtdcLcacr,
    dccr: LtdcLdccr,
    bfcr: LtdcLbfcr,
    cfbar: LtdcLcfbar,
    cfblr: LtdcLcfblr,
    cfblnr: LtdcLcfblnr,
    clutwr: LtdcLclutwr,
};

pub const Ltdc = extern struct {
    sscr: LtdcSscr,
    bpcr: LtdcBpcr,
    awcr: LtdcAwcr,
    twcr: LtdcTwcr,
    gcr: LtdcGcr,
    srcr: LtdcSrcr,
    bccr: LtdcBccr,
    ier: LtdcIer,
    isr: LtdcIsr,
    icr: LtdcIcr,
    lipcr: LtdcLipcr,
    cpsr: LtdcCpsr,
    cdsr: LtdcCdsr,
    layers: [2]LtdcLayer,
};

pub const ltdc: *volatile Ltdc = @ptrFromInt(LTDC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x94, @sizeOf(Ltdc));
}
