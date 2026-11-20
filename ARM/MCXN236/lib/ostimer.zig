const OSTIMER0_BASE = 0x40049000;

pub const OseventCtrl = bitpack struct(u32) {
    ostimer_intrflag: bool = false,
    ostimer_intena: bool = false,
    match_wr_rdy: bool = false,
    reserved0: u29 = 0,
};

pub const Ostimer = extern struct {
    evtimerl: u32,
    evtimerh: u32,
    capture_l: u32,
    capture_h: u32,
    match_l: u32,
    match_h: u32,
    reserved0: u32,
    ctrl: OseventCtrl,
};

pub const ostimer0: *volatile Ostimer = @ptrFromInt(OSTIMER0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Ostimer));
}
