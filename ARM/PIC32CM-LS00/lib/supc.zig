const SUPC_BASE = 0x40001800;

pub const SupcInt = bitpack struct(u32) {
    bod33rdy: bool = false,
    bod33det: bool = false,
    b33srdy: bool = false,
    reserved0: u5 = 0,
    vregrdy: bool = false,
    reserved1: u1 = 0,
    vcorerdy: bool = false,
    ulpvrefrdy: bool = false,
    reserved2: u6 = 0,
    vcorepllrdy: bool = false,
    reserved3: u13 = 0,
};

pub const SupcStatus = bitpack struct(u32) {
    bod33rdy: bool,
    bod33det: bool,
    b33srdy: bool,
    reserved0: u5,
    vregrdy: bool,
    reserved1: u1,
    vcorerdy: bool,
    reserved2: u1,
    ulpvrefrdy: bool,
    reserved3: u5,
    vcorepllrdy: bool,
    reserved4: u13,
};

pub const SupcAction = enum(u2) {
    none = 0,
    reset = 1,
    int = 2,
};

pub const SupcPsel = enum(u4) {
    div2 = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7,
    div512 = 8,
    div1024 = 9,
    div2048 = 10,
    div4096 = 11,
    div8192 = 12,
    div16384 = 13,
    div32768 = 14,
    div65536 = 15,
};

pub const SupcBod33 = bitpack struct(u32) {
    reserved0: u1 = 0,
    enable: bool = false,
    hyst: bool = false,
    action: SupcAction = .none,
    stdbycfg: bool = false,
    runstdby: bool = false,
    reserved1: u1 = 0,
    actcfg: bool = false,
    reserved2: u2 = 0,
    vrefsel: bool = false,
    psel: SupcPsel = .div2,
    level: u6 = 0,
    reserved3: u10 = 0,
};

pub const SupcVregSel = enum(u2) {
    ldo = 0,
    buck = 1,
};

pub const SupcVreg = bitpack struct(u32) {
    reserved0: u1 = 1,
    enable: bool = true,
    sel: SupcVregSel = .ldo,
    reserved1: u1 = 0,
    stdbypl0: bool = false,
    runstdby: bool = false,
    reserved2: u1 = 0,
    lpeff: bool = false,
    vrefsel: bool = false,
    reserved3: u6 = 0,
    vsvstep: u4 = 0,
    reserved4: u4 = 0,
    vsper: u8 = 0,
};

pub const SupcVrefSel = enum(u4) {
    _2v4 = 6,
    _2v5 = 7,
};

pub const SupcVref = bitpack struct(u32) {
    reserved0: u2 = 0,
    vrefoe: bool = false,
    reserved1: u3 = 0,
    runstdby: bool = false,
    ondemand: bool = false,
    reserved2: u8 = 0,
    sel: SupcVrefSel = ._2v4,
    reserved3: u12 = 0,
};

pub const SupcVregpll = bitpack struct(u32) {
    reserved0: u1 = 0,
    enable: bool = false,
    reserved1: u4 = 0,
    runstdby: bool = false,
    reserved2: u1 = 0,
    startup: u4 = 0,
    reserved3: u20 = 0,
};

pub const SupcEvctrl = bitpack struct(u32) {
    reserved0: u1 = 0,
    bod33deteo: bool = false,
    reserved1: u30 = 0,
};

pub const Supc = extern struct {
    intenclr: SupcInt,
    intenset: SupcInt,
    intflag: SupcInt,
    status: SupcStatus,
    bod33: SupcBod33,
    reserved0: u32,
    vreg: SupcVreg,
    vref: SupcVref,
    vregpll: SupcVregpll,
    reserved1: [2]u32,
    evctrl: SupcEvctrl,
};

pub fn buckConverterEnable() void {
    supc.vreg = .{.sel = .buck};
}

pub const supc: *volatile Supc = @ptrFromInt(SUPC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Supc));
}
