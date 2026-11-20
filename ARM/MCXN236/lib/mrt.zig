const MRT0_BASE = 0x40013000;

pub const Intval = bitpack struct(u32) {
    ivalue: u24 = 0,
    reserved0: u7 = 0,
    load: bool = false,
};

pub const Timer = bitpack struct(u32) {
    value: u24,
    reserved0: u8,
};

pub const Mode = enum(u2) {
    repeat_interrupt = 0,
    one_shot_interrupt = 1,
    one_shot_stall = 2,
};

pub const Ctrl = bitpack struct(u32) {
    inten: bool = false,
    mode: Mode = .repeat_interrupt,
    reserved0: u29 = 0,
};

pub const Stat = bitpack struct(u32) {
    intflag: bool = false,
    run: bool = false,
    inuse: bool = false,
    reserved0: u29 = 0,
};

pub const Channel = extern struct {
    intval: Intval,
    timer: Timer,
    ctrl: Ctrl,
    stat: Stat,
};

pub const Modcfg = bitpack struct(u32) {
    noc: u4,
    nob: u5,
    reserved0: u22,
    multitask: bool = false,
};

pub const IdleCh = bitpack struct(u32) {
    reserved0: u4,
    chan: u4,
    reserved1: u24,
};

pub const IrqFlag = bitpack struct(u32) {
    gflag0: bool = false,
    gflag1: bool = false,
    gflag2: bool = false,
    gflag3: bool = false,
    reserved0: u28 = 0,
};

pub const Mrt = extern struct {
    ch: [4]Channel,
    reserved0: [44]u32,
    modcfg: Modcfg,
    idle_ch: IdleCh,
    irq_flag: IrqFlag,
};

pub const mrt0: *volatile Mrt = @ptrFromInt(MRT0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xFC, @sizeOf(Mrt));
}
