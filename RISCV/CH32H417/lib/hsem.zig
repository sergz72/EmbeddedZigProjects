const HSEM_BASE = 0xE00C000;

pub const HsemRx = bitpack struct(u32) {
    pid: u8 = 0,
    cid: u4 = 0,
    reserved0: u19 = 0,
    lock: bool = false,
};

pub const HsemClr = bitpack struct(u32) {
    match_pid: u8 = 0,
    match_cid: u2 = 0,
    reserved0: u2 = 0,
    pid_mask: bool = false,
    cid_mask: bool = false,
    reserved1: u2 = 0,
    clr_key: u16 = 0,
};

pub const HsemKey = bitpack struct(u32) {
    auto_1step_clr: bool = false,
    auto_2step_clr: bool = false,
    reserved0: u14 = 0,
    key_value: u16 = 0,
};

pub const Hsem = extern struct {
    rx: [32]HsemRx,
    reserved0: [32]u32,
    rlrx: [32]HsemRx,
    reserved1: [32]u32,
    lse: u32,
    reserved2: u32,
    clr: HsemClr,
    key: HsemKey,
    reserved3: [60]u32,
    ier: u32,
    reserved4: u32,
    isr: u32,
    reserved5: u32,
    ism: u32,
    reserved6: u32,
    lsm: u32,
};

pub const hsem: *volatile Hsem = @ptrFromInt(HSEM_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x31C, @sizeOf(Hsem));
}
