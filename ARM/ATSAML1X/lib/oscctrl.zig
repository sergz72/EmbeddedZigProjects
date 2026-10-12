const OSCCTRL_BASE = 0x40001000;

pub const Oscctrl = extern struct {
    evctrl: u8,
    reserved1: [3]u8,
    intenclr: u32,
    intenset: u32,
    intflag: u32,
    status: u32,
    xoscctrl: u16,
    cfdpresc: u8,
    reserved2: u8,
    osc16mctrl: u8,
    reserved3: [3]u8,
    dfllulpctrl: u16,
    dfllulpdither: u8,
    dfllulprreq: u8,
    dfllulpdly: u32,
    dfllulpratio: u32,
    dfllulpsyncbusy: u32,
    dpllctrla: u8,
    reserved4: [3]u8,
    dpllratio: u32,
    dpllctrlb: u32,
    dpllpresc: u8,
    reserved5: [3]u8,
    dpllsyncbusy: u8,
    reserved6: [3]u8,
    dpllstatus: u8,
    reserved7: [3]u8
};

pub const oscctrl: *volatile Oscctrl = @ptrFromInt(OSCCTRL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x44, @sizeOf(Oscctrl));
}
