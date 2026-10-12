const EIC_BASE = 0x40002800;

pub const EicCtrlA = packed struct(u8) {
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

pub const EicNmiCtrl = packed struct(u8) {
    nmisense: EicSense = .no_detection,
    nmifilten: bool = false,
    nmiasynch: bool = false,
    reserved: u3 = 0
};

pub const EicSyncBusy = packed struct(u32) {
    swrst: bool,
    enable: bool,
    reserved: u30
};

pub const EicIntEn = packed struct(u32) {
    extint: u8 = 0,
    reserved: u23 = 0,
    nschk: bool = false 
};

pub const EicChConfig = packed struct(u4) {
    sense: EicSense = .no_detection,
    filten: bool = false
};

pub const EicConfig = packed struct(u32) {
    ch0: EicChConfig,
    ch1: EicChConfig,
    ch2: EicChConfig,
    ch3: EicChConfig,
    ch4: EicChConfig,
    ch5: EicChConfig,
    ch6: EicChConfig,
    ch7: EicChConfig,
};

pub const EicDpPrescaler = packed struct(u32) {
    prescaler: u3 = 0,
    states: bool = false,
    reserved: u12 = 0,
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
    intenclr: EicIntEn,
    intenset: EicIntEn,
    intflag: EicIntEn,
    asynch: u32,
    config: EicConfig,
    reserved2: [4]u32,
    debouncen: u32,
    dprescaler: EicDpPrescaler,
    pinstate: u32,
    nschk: EicIntEn,
    nonsec: EicIntEn
};

pub const eic: *volatile Eic = @ptrFromInt(EIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x44, @sizeOf(Eic));
}
