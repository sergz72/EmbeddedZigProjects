const LTDC_BASE = 0x40016800;

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

pub const LtdcIr = bitpack struct(u32) {
    l: bool = false,
    fu: bool = false,
    terr: bool = false,
    rr: bool = false,
    reserved0: u28 = 0,
};

pub const LtdcCpsr = bitpack struct(u32) {
    cypos: u16,
    cxpos: u16,
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

pub const LtdcLpfcr = enum(u32) {
    argb8888 = 0,
    rgb888 = 1,
    rgb565 = 2,
    argb1555 = 3,
    argb4444 = 4,
    l8 = 5,
    al44 = 6,
    al88 = 7
};

pub const LtdcLdccr = bitpack struct(u32) {
    dcblue: u8 = 0,
    dcgreen: u8 = 0,
    dcred: u8 = 0,
    dcalpha: u8 = 0,
};

pub const LtdcBf1 = enum(u3) {
    constant_alpha = 4,
    pixel_alpha = 6,
};

pub const LtdcBf2 = enum(u3) {
    constant_alpha = 5,
    pixel_alpha = 7,
};

pub const LtdcLbfcr = bitpack struct(u32) {
    bf2: LtdcBf2 = .pixel_alpha,
    reserved0: u5 = 0,
    bf1: LtdcBf1 = .pixel_alpha,
    reserved1: u21 = 0,
};

pub const LtdcLcfblr = bitpack struct(u32) {
    cfbll: u13 = 0,
    reserved0: u3 = 0,
    cfbp: u13 = 0,
    reserved1: u3 = 0,
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
    cacr: u32,
    dccr: LtdcLdccr,
    bfcr: LtdcLbfcr,
    reserved5: [2]u32,
    cfbar: u32,
    cfblr: LtdcLcfblr,
    cfblnr: u32,
    reserved6: [3]u32,
    clutwr: LtdcLclutwr,
    reserved7: [15]u32,
};

pub const Ltdc = extern struct {
    reserved0: [2]u32,
    sscr: LtdcSscr,
    bpcr: LtdcBpcr,
    awcr: LtdcAwcr,
    twcr: LtdcTwcr,
    gcr: LtdcGcr,
    reserved1: [2]u32,
    srcr: LtdcSrcr,
    reserved2: u32,
    bccr: LtdcBccr,
    reserved3: u32,
    ier: LtdcIr,
    isr: LtdcIr,
    icr: LtdcIr,
    lipcr: u32,
    cpsr: LtdcCpsr,
    cdsr: LtdcCdsr,
    reserved4: [14]u32,
    l: [2]LtdcLayer,
};

pub const ltdc: *volatile Ltdc = @ptrFromInt(LTDC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x184, @sizeOf(Ltdc));
}
