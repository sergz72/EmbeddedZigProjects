const EIC_BASE = 0x40002800;
const EIC_SEC_BASE = 0x40002A00;

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

pub const EicIntEn = bitpack struct(u32) {
    extint: u16 = 0,
    reserved: u15 = 0,
    nschk: bool = false 
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

pub const EicPrescaler = enum(u3) {
    div2 = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7,
};

pub const EicDpPrescaler = bitpack struct(u32) {
    prescaler0: EicPrescaler = .div2,
    states0: bool = false,
    prescaler1: EicPrescaler = .div2,
    states1: bool = false,
    reserved: u8 = 0,
    tickon: bool = false,
    reserved2: u15 = 0
};

pub const EicNschk = bitpack struct(u32) {
    extint: u16 = 0,
    reserved: u15 = 0,
    nmi: bool = false 
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
    config0: EicConfig0,
    config1: EicConfig1,
    reserved2: [3]u32,
    debouncen: u32,
    dprescaler: EicDpPrescaler,
    pinstate: u32,
    nschk: EicNschk,
    nonsec: EicNschk
};

pub const eic: *volatile Eic = @ptrFromInt(EIC_BASE);
pub const eic_sec: *volatile Eic = @ptrFromInt(EIC_SEC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x44, @sizeOf(Eic));
}
