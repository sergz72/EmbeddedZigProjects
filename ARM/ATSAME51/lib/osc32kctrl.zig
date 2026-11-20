const OSC32KCTRL_BASE = 0x40001400;

pub const Osc32kInt = bitpack struct(u32) {
    xosc32krdy: bool = false,
    reserved0: u1 = 0,
    xosc32kfail: bool = false,
    reserved1: u29 = 0,
};

pub const Osc32kStatus = bitpack struct(u32) {
    xosc32krdy: bool,
    reserved0: u1,
    xosc32kfail: bool,
    xosc32ksw: bool,
    reserved1: u28,
};

pub const Osc32kRtcsel = enum(u3) {
    ulp1k = 0,
    ulp32k = 1,
    xosc1k = 4,
    xosc32k = 5,
};
    
pub const Osc32kRtcctrl = bitpack struct(u8) {
    rtcsel: Osc32kRtcsel = .ulp1k,
    reserved0: u5 = 0,
};

pub const Osc32kStartup = enum(u3) {
    _2048cycles = 0,
    _4096cycles = 1,
    _16384cycles = 2,
    _32768cycles = 3,
    _65536cycles = 4,
    _131072cycles = 5,
    _262144cycles = 6,
};

pub const Osc32kCgm = enum(u2) {
    standard = 1,
    high_speed = 2,
};

pub const Osc32kXosc32k = bitpack struct(u16) {
    reserved0: u1 = 0,
    enable: bool = false,
    xtalen: bool = false,
    en32k: bool = false,
    en1k: bool = false,
    reserved1: u1 = 0,
    runstdby: bool = false,
    ondemand: bool = true,
    startup: Osc32kStartup = ._2048cycles,
    reserved2: u1 = 0,
    wrtlock: bool = false,
    cgm: Osc32kCgm = .standard,
    reserved3: u1 = 0,
};

pub const Osc32kCfdctrl = bitpack struct(u8) {
    cfden: bool = false,
    swback: bool = false,
    cfdpresc: bool = false,
    reserved0: u5 = 0,
};

pub const Osc32kEvctrl = bitpack struct(u8) {
    cfdeo: bool = false,
    reserved0: u7 = 0,
};

pub const Osc32kOsculp32k = bitpack struct(u32) {
    reserved0: u1 = 0,
    en32k: bool = true,
    en1k: bool = true,
    reserved1: u12,
    wrtlock: bool = false,
    reserved2: u16 = 0,
};

pub const Osc32kctrl = extern struct {
    intenclr: Osc32kInt,
    intenset: Osc32kInt,
    intflag: Osc32kInt,
    status: Osc32kStatus,
    rtcctrl: Osc32kRtcctrl,
    reserved0: [3]u8,
    xosc32k: Osc32kXosc32k,
    cfdctrl: Osc32kCfdctrl,
    evctrl: Osc32kEvctrl,
    reserved1: u32,
    osculp32k: Osc32kOsculp32k,

    pub fn enableXosc32k(self: *volatile Osc32kctrl) void {
        self.xosc32k = Osc32kXosc32k{
            .enable = true,
            .xtalen = true,
            .en32k = true,
            .en1k = true,
            .runstdby = true,
            .ondemand = false,
            .cgm = .high_speed
        };
        while (!self.status.xosc32krdy) {
            asm volatile ("nop");
        }
    }
};

pub const osc32kctrl: *volatile Osc32kctrl = @ptrFromInt(OSC32KCTRL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Osc32kctrl));
}
