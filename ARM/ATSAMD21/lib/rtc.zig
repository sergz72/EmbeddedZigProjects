const RTC_BASE = 0x40001400;

pub const RtcMode = enum(u2) {
    count32 = 0,
    count16 = 1,
    clock = 2,
};

pub const RtcPrescaler = enum(u4) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7,
    div256 = 8,
    div512 = 9,
    div1024 = 10,
};

pub const RtcCtrl = bitpack struct(u16) {
    swrst: bool = false,
    enable: bool = false,
    mode: RtcMode = .count32,
    reserved0: u3 = 0,
    matchclr: bool = false,
    prescaler: RtcPrescaler = .div1,
    reserved1: u4 = 0,
};

pub const RtcReadreq = bitpack struct(u16) {
    addr: u6 = 16,
    reserved0: u8 = 0,
    rcont: bool = false,
    rreq: bool = false,
};

pub const RtcEvctrl = bitpack struct(u16) {
    pereo0: bool = false,
    pereo1: bool = false,
    pereo2: bool = false,
    pereo3: bool = false,
    pereo4: bool = false,
    pereo5: bool = false,
    pereo6: bool = false,
    pereo7: bool = false,
    cmp_alarm_eo0: bool = false,
    cmpeo1: bool = false,
    reserved0: u5 = 0,
    ovfeo: bool = false,
};

pub const RtcInt = bitpack struct(u8) {
    cmp_alarm_0: bool = false,
    cmp1: bool = false,
    reserved0: u4 = 0,
    syncrdy: bool = false,
    ovf: bool = false,
};

pub const RtcStatus = bitpack struct(u8) {
    reserved0: u7 = 0,
    syncbusy: bool = false,
};

pub const RtcDbgctrl = bitpack struct(u8) {
    dbgrun: bool = false,
    reserved0: u7 = 0,
};

pub const RtcFreqcorr = bitpack struct(u8) {
    value: u7 = 0,
    sign: bool = false,
};

pub const RtcMode0 = extern struct {
    count: u32,
    reserved2: [4]u8,
    comp: u32,
    reserved4: [2]u16,
};

pub const RtcMode1 = extern struct {
    count: u16,
    reserved2: [2]u8,
    per: u16,
    reserved3: [2]u8,
    comp: [2]u16,
    reserved4: [2]u16,
};

pub const RtcHour = enum(u5) {
    am = 0,
    pm = 16,
};

pub const RtcClock = bitpack struct(u32) {
    second: u6 = 0,
    minute: u6 = 0,
    hour: RtcHour = .am,
    day: u5 = 0,
    month: u4 = 0,
    year: u6 = 0,
};

pub const RtcAlarm = bitpack struct(u32) {
    second: u6 = 0,
    minute: u6 = 0,
    hour: RtcHour = .am,
    day: u5 = 0,
    month: u4 = 0,
    year: u6 = 0,
};

pub const RtcSel = enum(u3) {
    off = 0,
    ss = 1,
    mmss = 2,
    hhmmss = 3,
    ddhhmmss = 4,
    mmddhhmmss = 5,
    yymmddhhmmss = 6,
};

pub const RtcMask = bitpack struct(u8) {
    sel: RtcSel = .off,
    reserved0: u5 = 0,
};

pub const RtcMode2 = extern struct {
    clock: RtcClock,
    reserved2: [4]u8,
    alarm: RtcAlarm,
    mask: RtcMask,
    reserved3: [3]u8,
};

pub const RtcModes = extern union {
    mode0: RtcMode0,
    mode1: RtcMode1,
    mode2: RtcMode2,
};

pub const Rtc = extern struct {
    ctrl: RtcCtrl,
    readreq: RtcReadreq,
    evctrl: RtcEvctrl,
    intenclr: RtcInt,
    intenset: RtcInt,
    intflag: RtcInt,
    reserved0: [1]u8,
    status: RtcStatus,
    dbgctrl: RtcDbgctrl,
    freqcorr: RtcFreqcorr,
    reserved1: [3]u8,
    mode: RtcModes,
};

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Rtc));
}
