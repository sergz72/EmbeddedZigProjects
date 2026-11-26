const EIC_BASE = 0x40001800;

pub const EicCtrl = bitpack struct(u8) {
    swrst: bool = false,
    enable: bool = false,
    reserved0: u6 = 0,
};

pub const EicStatus = bitpack struct(u8) {
    reserved0: u7,
    syncbusy: bool,
};

pub const EicSense = enum(u3) {
    no_detection = 0,
    rising_edge = 1,
    falling_edge = 2,
    both_edge = 3,
    high_level = 4,
    low_level = 5
};

pub const EicNmictrl = bitpack struct(u8) {
    nmisense: EicSense = .no_detection,
    nmifilten: bool = false,
    reserved0: u4 = 0,
};

pub const EicNmiflag = bitpack struct(u8) {
    nmi: bool = false,
    reserved0: u7 = 0,
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

pub const EicConfig2 = bitpack struct(u32) {
    ch24: EicChConfig,
    ch25: EicChConfig,
    ch26: EicChConfig,
    ch27: EicChConfig,
    ch28: EicChConfig,
    ch29: EicChConfig,
    ch30: EicChConfig,
    ch31: EicChConfig,
};

pub const Eic = extern struct {
    ctrl: EicCtrl,
    status: EicStatus,
    nmictrl: EicNmictrl,
    nmiflag: EicNmiflag,
    evctrl: u32,
    intenclr: u32,
    intenset: u32,
    intflag: u32,
    wakeup: u32,
    config0: EicConfig0,
    config1: EicConfig1,
    config2: EicConfig2,
};

pub const eic: *volatile Eic = @ptrFromInt(EIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Eic));
}
