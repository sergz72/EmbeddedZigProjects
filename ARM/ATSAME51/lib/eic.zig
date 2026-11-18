const EIC_BASE = 0x40002800;

pub const EicCtrlA = bitpack struct(u8) {
    swrst: bool = false,
    enable: bool = false,
    reserved: u2 = 0,
    cksel: bool = false,
    reserved2: u3 = 0
};

pub const EicSense = enum(u3) {
    no_detection = 0,
    rising_edge = 1,
    falling_edge = 2,
    both_edge = 3,
    high_level = 4,
    low_level = 5
};

pub const EicNmiCtrl = bitpack struct(u8) {
    nmisense: EicSense = .no_detection,
    nmifilten: bool = false,
    nmiasynch: bool = false,
    reserved: u3 = 0
};

pub const EicSyncBusy = bitpack struct(u32) {
    swrst: bool,
    enable: bool,
    reserved: u30
};

pub const EicChConfig = bitpack struct(u4) {
    sense: EicSense = .no_detection,
    filten: bool = false
};

pub const EicConfig0 = bitpack struct(u32) {
    ch0: EicChConfig,
    ch1: EicChConfig,
    ch2: EicChConfig,
    ch3: EicChConfig,
    ch4: EicChConfig,
    ch5: EicChConfig,
    ch6: EicChConfig,
    ch7: EicChConfig,
};

pub const EicConfig1 = bitpack struct(u32) {
    ch8: EicChConfig,
    ch9: EicChConfig,
    ch10: EicChConfig,
    ch11: EicChConfig,
    ch12: EicChConfig,
    ch13: EicChConfig,
    ch14: EicChConfig,
    ch15: EicChConfig,
};

pub const EicDprescaler = bitpack struct(u32) {
    prescaler0: u3 = 0,
    states0: bool = false,
    prescaler1: u3 = 0,
    states1: bool = false,
    reserved: u8 = 0,
    tickon: bool = false,
    reserved2: u15 = 0
};

pub const Eic = extern struct {
    ctrla: EicCtrlA,
    nmictrl: EicNmiCtrl,
    nmiflag: u8,
    reserved1: u8,
    syncbusy: EicSyncBusy,
    evctrl: u32,
    intenclr: u32,
    intenset: u32,
    intflag: u32,
    asynch: u32,
    config0: EicConfig0,
    config1: EicConfig1,
    reserved2: [3]u32,
    debouncen: u32,
    dprescaler: EicDprescaler,
    pinstate: u32,
};

pub const eic: *volatile Eic = @ptrFromInt(EIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x3C, @sizeOf(Eic));
}
