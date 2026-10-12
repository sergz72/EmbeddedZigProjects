const OSC32KCTRL_BASE = 0x40001400;

pub const Osc32kInt = packed struct(u32) {
    xosc32krdy: bool = false,
    reserved: u1 = 0,
    clkfail: bool = false,
    reserved2: u29 = 0
};

pub const Osc32kStatus = packed struct(u32) {
    xosc32krdy: bool,
    reserved: u1,
    clkfail: bool,
    clksw: bool,
    ulp32ksw: bool,
    reserved2: u27
};

pub const Osc32kRtcCtrl = enum(u8) {
    ulp1k = 0,
    ulp32k = 1,
    xosc1k = 4,
    xosc32k = 5
};

pub const Xosc32kStartup = enum(u3) {
    _2048 = 0,
    _4096 = 1,
    _16384 = 2,
    _32768 = 3,
    _65536 = 4,
    _131072 = 5,
    _262144 = 6
};

pub const Xosc32k = packed struct(u16) {
    reserved: u1 = 0,
    enable: bool = false,
    xtalen: bool = false,
    en32k: bool = false,
    en1k: bool = false,
    reserved2: u1 = 0,
    runstdby: bool = false,
    ondemand: bool = true,
    startup: Xosc32kStartup = ._2048,
    reserved3: u1 = 0,
    wrtlock: bool = false,
    reserved4: u3 = 0
};

pub const Osc32kCfdCtrl = packed struct(u8) {
    cfden: bool = false,
    swback: bool = false,
    cfdpresc: bool = false,
    reserved: u5 = 0
};

pub const OscUlp32k = packed struct(u32) {
    reserved: u5 = 0,
    ulp32ksw: bool = false,
    reserved2: u2 = 0,
    do_not_change: u5,
    reserved3: u2 = 0,
    wrtlock: bool = false,
    reserved4: u16 = 0
};

pub const Osc32kctrl = extern struct {
    intenclr: Osc32kInt,
    intenset: Osc32kInt,
    intflag: Osc32kInt,
    status: Osc32kStatus,
    rtcctrl: Osc32kRtcCtrl,
    reserved1: [3]u8,
    xosc32k: Xosc32k,
    cfdctrl: Osc32kCfdCtrl,
    evctrl: u8,
    reserved2: u32,
    osculp32k: OscUlp32k
};

pub const osc32kctrl: *volatile Osc32kctrl = @ptrFromInt(OSC32KCTRL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Osc32kctrl));
}
