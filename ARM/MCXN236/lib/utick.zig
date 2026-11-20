const UTICK0_BASE = 0x40012000;

pub const Ctrl = bitpack struct(u32) {
    delayval: u31 = 0,
    repeat: bool = false,
};

pub const Stat = bitpack struct(u32) {
    intr: bool = false,
    active: bool = false,
    reserved0: u30 = 0,
};

pub const Cfg = bitpack struct(u32) {
    capen0: bool = false,
    capen1: bool = false,
    capen2: bool = false,
    capen3: bool = false,
    reserved0: u4 = 0,
    cappol0: bool = false,
    cappol1: bool = false,
    cappol2: bool = false,
    cappol3: bool = false,
    reserved1: u20 = 0,
};

pub const Capclr = bitpack struct(u32) {
    capclr0: bool = false,
    capclr1: bool = false,
    capclr2: bool = false,
    capclr3: bool = false,
    reserved0: u28 = 0,
};

pub const Cap = bitpack struct(u32) {
    cap_value: u31,
    valid: bool,
};

pub const Utick = extern struct {
    ctrl: Ctrl,
    stat: Stat,
    cfg: Cfg,
    capclr: Capclr,
    cap: [4]Cap,
};

pub const utick0: *volatile Utick = @ptrFromInt(UTICK0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Utick));
}
