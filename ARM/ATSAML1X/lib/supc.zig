const SUPC_BASE = 0x40001800;

pub const SupcVregSel = enum(u2) {
    ldo = 0,
    buck = 1
};

pub const SupcVreg = packed struct(u32) {
    reserved: u1 = 0,
    enable: bool = true,
    sel: SupcVregSel = .ldo,
    reserved2: u1 = 0,
    stdbypl0: bool = true,
    runstdby: bool = false,
    reserved3: u1 = 0,
    pleff: bool = false,
    vrefsel: bool = false,
    reserved4: u6 = 0,
    vsvstep: u4 = 0,
    reserved5: u4 = 0,
    vsper: u8 = 0
};

pub const Supc = extern struct {
    intenclr: u32,
    intenset: u32,
    intflag: u32,
    status: u32,
    bod33: u32,
    reserved1: u32,
    vreg: SupcVreg,
    vref: u32,
    reserved2: [3]u32,
    evctrl: u32,

    pub fn buckConverterEnable(self: *volatile Supc) void {
        self.vreg = .{.sel = .buck};
    }
};

pub const supc: *volatile Supc = @ptrFromInt(SUPC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Supc));
}
