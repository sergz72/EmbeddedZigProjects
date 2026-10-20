pub const PWC_BASE = 0x40007000;

pub const PwcPvmsel = enum(u3) {
    unused = 0,
    _2p3v = 1,
    _2p4v = 2,
    _2p5v = 3,
    _2p6v = 4,
    _2p7v = 5,
    _2p8v = 6,
    _2p9v = 7
};

pub const PwcCtrl = packed struct(u32) {
    vrsel: bool = false,
    lpsel: bool = false,
    clswef: bool = false,
    clsef: bool = false,
    pvmen: bool = false,
    pvmsel: PwcPvmsel = .unused,
    bpwen: bool = false,
    reserved: u7 = 0,
    clsw1ef: bool = false,
    clsw2ef: bool = false,
    reserved2: u3 = 0,
    clsw6ef: bool = false,
    clsw7ef: bool = false,
    reserved3: u1 = 0,
    swp1pol: bool = false,
    swp2pol: bool = false,
    reserved4: u3 = 0,
    swp6pol: bool = false,
    swp7pol: bool = false,
    reserved5: u1 = 0
};

pub const PwcCtrlSts = packed struct(u32) {
    swef: bool = false,
    sef: bool = false,
    pvmof: bool = false,
    reserved: u5 = 0,
    swpen1: bool = false,
    swpen2: bool = false,
    reserved2: u3 = 0,
    swpen6: bool = false,
    swpen7: bool = false,
    reserved3: u1 = 0,
    sw1ef: bool = false,
    sw2ef: bool = false,
    reserved4: u3 = 0,
    sw6ef: bool = false,
    sw7ef: bool = false,
    reserved5: u9 = 0
};

pub const PwcLdoOvSel = enum(u2) {
    _1v2 = 2,
    _1v3 = 3,
};

pub const PwcLdoOv = packed struct(u32) {
    ldoovsel: PwcLdoOvSel = ._1v2,
    reserved: u2 = 0,
    vrexlpen: bool = true,
    reserved2: u27 = 0
};

pub const Pwc = extern struct {
    ctrl: PwcCtrl,
    ctrlsts: PwcCtrlSts,
    reserved: [2]u32,
    ldoov: PwcLdoOv
};

pub const pwc: *volatile Pwc = @ptrFromInt(PWC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(Pwc));
}
