const CMCC_BASE = 0x41006000;

pub const CmccWaynum = enum(u2) {
    _4way = 2,
};

pub const CmccCsize = enum(u3) {
    _1kb = 0,
    _2kb = 1,
    _4kb = 2,
};

pub const CmccClsize = enum(u3) {
    _16b = 2,
};

pub const CmccType = bitpack struct(u32) {
    reserved0: u1,
    gclk: bool,
    reserved1: u2,
    rrp: bool,
    waynum: CmccWaynum,
    lckdown: bool,
    csize: CmccCsize,
    clsize: CmccClsize,
    reserved2: u18,
};

pub const CmccCfg = bitpack struct(u32) {
    reserved0: u1 = 0,
    icdis: bool = false,
    dcdis: bool = false,
    reserved1: u1 = 0,
    csizesw: CmccCsize = ._4kb,
    reserved2: u25 = 0,
};

pub const CmccCtrl = bitpack struct(u32) {
    cen: bool = false,
    reserved0: u31 = 0,
};

pub const CmccSr = bitpack struct(u32) {
    csts: bool,
    reserved0: u31,
};

pub const CmccLckway = bitpack struct(u32) {
    lckway: u4 = 0,
    reserved0: u28 = 0,
};

pub const CmccMaint0 = bitpack struct(u32) {
    invall: bool = false,
    reserved0: u31 = 0,
};

pub const CmccMaint1 = bitpack struct(u32) {
    reserved0: u4 = 0,
    index: u8 = 0,
    reserved1: u16 = 0,
    way: u4 = 0,
};

pub const CmccMode = enum(u2) {
    cycle_count = 0,
    ihit_count = 1,
    dhit_count = 2,
};

pub const CmccMcfg = bitpack struct(u32) {
    mode: CmccMode = .cycle_count,
    reserved0: u30 = 0,
};

pub const CmccMen = bitpack struct(u32) {
    menable: bool = false,
    reserved0: u31 = 0,
};

pub const CmccMctrl = bitpack struct(u32) {
    swrst: bool = false,
    reserved0: u31 = 0,
};

pub const Cmcc = extern struct {
    type: CmccType,
    cfg: CmccCfg,
    ctrl: CmccCtrl,
    sr: CmccSr,
    lckway: CmccLckway,
    reserved0: [3]u32,
    maint0: CmccMaint0,
    maint1: CmccMaint1,
    mcfg: CmccMcfg,
    men: CmccMen,
    mctrl: CmccMctrl,
    msr: u32,
};

pub const cmcc: *volatile Cmcc = @ptrFromInt(CMCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x38, @sizeOf(Cmcc));
}
