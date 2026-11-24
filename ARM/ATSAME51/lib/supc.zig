const SUPC_BASE = 0x40001800;

pub const SupcInt = bitpack struct(u32) {
    bod33rdy: bool = false,
    bod33det: bool = false,
    b33srdy: bool = false,
    reserved0: u5 = 0,
    vregrdy: bool = false,
    reserved1: u1 = 0,
    vcorerdy: bool = false,
    reserved2: u21 = 0,
};

pub const SupcAction = enum(u2) {
    none = 0,
    reset = 1,
    int = 2,
    bkup = 3,
};

pub const SupcPsel = enum(u3) {
    nodiv = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7,
};

pub const SupcBod33 = bitpack struct(u32) {
    reserved0: u1 = 0,
    enable: bool = false,
    action: SupcAction = .none,
    stdbycfg: bool = false,
    runstdby: bool = false,
    runhib: bool = false,
    runbkup: bool = false,
    hyst: u4 = 0,
    psel: SupcPsel = .nodiv,
    reserved1: u1 = 0,
    level: u8 = 0,
    vbatlevel: u8 = 0,
};

pub const SupcVreg = bitpack struct(u32) {
    reserved0: u1 = 1,
    enable: bool = true,
    sel: bool = false,
    reserved1: u4 = 0,
    runbkup: bool = false,
    reserved2: u8 = 0,
    vsen: bool = false,
    reserved3: u7 = 0,
    vsper: u3 = 0,
    reserved4: u5 = 0,
};

pub const SupcSel = enum(u4) {
    _1v0 = 0,
    _1v1 = 1,
    _1v2 = 2,
    _1v25 = 3,
    _2v0 = 4,
    _2v2 = 5,
    _2v4 = 6,
    _2v5 = 7,
};

pub const SupcVref = bitpack struct(u32) {
    reserved0: u1 = 0,
    tsen: bool = false,
    vrefoe: bool = false,
    tssel: bool = false,
    reserved1: u2 = 0,
    runstdby: bool = false,
    ondemand: bool = false,
    reserved2: u8 = 0,
    sel: SupcSel = ._1v0,
    reserved3: u12 = 0,
};

pub const SupcBbps = bitpack struct(u32) {
    conf: bool = false,
    reserved0: u1 = 0,
    wakeen: bool = false,
    reserved1: u29 = 0,
};

pub const SupcBkout = bitpack struct(u32) {
    enout0: bool = false,
    enout1: bool = false,
    reserved0: u6 = 0,
    clrout0: bool = false,
    clrout1: bool = false,
    reserved1: u6 = 0,
    setout0: bool = false,
    setout1: bool = false,
    reserved2: u6 = 0,
    rtctglout0: bool = false,
    rtctglout1: bool = false,
    reserved3: u6 = 0,
};

pub const SupcBkin = bitpack struct(u32) {
    bkin0: bool,
    bkin1: bool,
    reserved0: u30,
};

pub const Supc = extern struct {
    intenclr: SupcInt,
    intenset: SupcInt,
    intflag: SupcInt,
    status: SupcInt,
    bod33: SupcBod33,
    reserved0: u32,
    vreg: SupcVreg,
    vref: SupcVref,
    bbps: SupcBbps,
    bkout: SupcBkout,
    bkin: SupcBkin,
};

pub fn buckConverterEnable() void {
    supc.vreg = .{.sel = true};
}

pub const supc: *volatile Supc = @ptrFromInt(SUPC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2C, @sizeOf(Supc));
}
