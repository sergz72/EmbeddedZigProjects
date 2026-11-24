const GPHA_BASE = 0x40016800;

pub const GphaCtlr = bitpack struct(u32) {
    start: bool = false,
    susp: bool = false,
    abort: bool = false,
    reserved0: u6 = 0,
    tcie: bool = false,
    twie: bool = false,
    caeie: bool = false,
    ctcie: bool = false,
    ceie: bool = false,
    reserved1: u2 = 0,
    mode: u2 = 0,
    reserved2: u14 = 0,
};

pub const GphaIsr = bitpack struct(u32) {
    reserved0: u1,
    tcif: bool,
    twif: bool,
    caeif: bool,
    ctcif: bool,
    ceif: bool,
    reserved1: u26,
};

pub const GphaIfcr = bitpack struct(u32) {
    reserved0: u1 = 0,
    ctcif: bool = false,
    ctwif: bool = false,
    caecif: bool = false,
    cctcif: bool = false,
    cceif: bool = false,
    reserved1: u26 = 0,
};

pub const GphaFgpfccr = bitpack struct(u32) {
    cm: u4 = 0,
    ccm: bool = false,
    start: bool = false,
    reserved0: u2 = 0,
    cs: u8 = 0,
    am: u2 = 0,
    reserved1: u2 = 0,
    ai: bool = false,
    rbs: bool = false,
    reserved2: u2 = 0,
    alpha: u8 = 0,
};

pub const GphaColr = bitpack struct(u32) {
    blue: u8 = 0,
    green: u8 = 0,
    red: u8 = 0,
    reserved0: u8 = 0,
};

pub const GphaBgpfccr = bitpack struct(u32) {
    cm: u4 = 0,
    ccm: bool = false,
    start: bool = false,
    reserved0: u2 = 0,
    cs: u8 = 0,
    am: u2 = 0,
    reserved1: u2 = 0,
    ai: bool = false,
    rbs: bool = false,
    reserved2: u2 = 0,
    alpha: u8 = 0,
};

pub const GphaOpfccr = bitpack struct(u32) {
    cm: u3 = 0,
    reserved0: u17 = 0,
    ai: bool = false,
    rbs: bool = false,
    reserved1: u10 = 0,
};

pub const GphaOcolr = bitpack struct(u32) {
    blue: u8 = 0,
    green: u8 = 0,
    red: u8 = 0,
    alpha: u8 = 0,
};

pub const GphaNlr = bitpack struct(u32) {
    nl: u16 = 0,
    pl: u14 = 0,
    reserved0: u2 = 0,
};

pub const GphaAmtcr = bitpack struct(u32) {
    en: bool = false,
    reserved0: u7 = 0,
    dt: u8 = 0,
    reserved1: u16 = 0,
};

pub const GphaFgcwrs = bitpack struct(u32) {
    fg_clut_index: u8 = 0,
    fg_clut_en: bool = false,
    reserved0: u23 = 0,
};

pub const GphaBgcwrs = bitpack struct(u32) {
    bg_clut_index: u8 = 0,
    bg_clut_en: bool = false,
    reserved0: u23 = 0,
};

pub const Gpha = extern struct {
    ctlr: GphaCtlr,
    isr: GphaIsr,
    ifcr: GphaIfcr,
    fgmar: u32,
    fgor: u32,
    bgmar: u32,
    bgor: u32,
    fgpfccr: GphaFgpfccr,
    fgcolr: GphaColr,
    bgpfccr: GphaBgpfccr,
    bgcolr: GphaColr,
    fgcmar: u32,
    bgcmar: u32,
    opfccr: GphaOpfccr,
    ocolr: GphaOcolr,
    omar: u32,
    oor: u32,
    nlr: GphaNlr,
    lwr: u32,
    amtcr: GphaAmtcr,
    fgcwrs: GphaFgcwrs,
    fgcdat: u32,
    bgcwrs: GphaBgcwrs,
    bgcdat: u32,
};

pub const gpha: *volatile Gpha = @ptrFromInt(GPHA_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x60, @sizeOf(Gpha));
}
