const generic_rtc = @import("generic_rtc");

const RTC_BASE = 0x40002400;

pub const RtcMode = enum(u2) {
    count32 = 0,
    count16 = 1,
    clock = 2,
};

pub const RtcPrescaler = enum(u4) {
    off = 0,
    div1 = 1,
    div2 = 2,
    div4 = 3,
    div8 = 4,
    div16 = 5,
    div32 = 6,
    div64 = 7,
    div128 = 8,
    div256 = 9,
    div512 = 10,
    div1024 = 11,
};

pub const RtcCtrla = bitpack struct(u16) {
    swrst: bool = false,
    enable: bool = false,
    mode: RtcMode = .count32,
    reserved0: u3 = 0,
    matchclr: bool = false,
    prescaler: RtcPrescaler = .off,
    reserved1: u1 = 0,
    bktrst: bool = false,
    gptrst: bool = false,
    countsync: bool = false,
};

pub const Rtcf = enum(u3) {
    div2 = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7,
};

pub const RtcCtrlb = bitpack struct(u16) {
    gp0en: bool = false,
    gp2en: bool = false,
    reserved0: u2 = 0,
    debmaj: bool = false,
    debasync: bool = false,
    rtcout: bool = false,
    dmaen: bool = false,
    debf: Rtcf = .div2,
    reserved1: u1 = 0,
    actf: Rtcf = .div2,
    reserved2: u1 = 0,
};

pub const RtcEvctrl = bitpack struct(u32) {
    pereo0: bool = false,
    pereo1: bool = false,
    pereo2: bool = false,
    pereo3: bool = false,
    pereo4: bool = false,
    pereo5: bool = false,
    pereo6: bool = false,
    pereo7: bool = false,
    cmp_alarm_eo0: bool = false,
    cmp_alarm_eo1: bool = false,
    cmpeo2: bool = false,
    cmpeo3: bool = false,
    reserved0: u2 = 0,
    tampereo: bool = false,
    ovfeo: bool = false,
    tampevei: bool = false,
    reserved1: u15 = 0,
};

pub const RtcInt = bitpack struct(u16) {
    per0: bool = false,
    per1: bool = false,
    per2: bool = false,
    per3: bool = false,
    per4: bool = false,
    per5: bool = false,
    per6: bool = false,
    per7: bool = false,
    cmp_alarm_0: bool = false,
    cmp_alarm_1: bool = false,
    cmp2: bool = false,
    cmp3: bool = false,
    reserved0: u2 = 0,
    tamper: bool = false,
    ovf: bool = false,
};

pub const RtcDbgctrl = bitpack struct(u8) {
    dbgrun: bool = false,
    reserved0: u7 = 0,
};

pub const RtcSyncbusy = bitpack struct(u32) {
    swrst: bool,
    enable: bool,
    freqcorr: bool,
    count: bool,
    reserved0: u1,
    comp_alarm_0: bool,
    comp_alarm_1: bool,
    comp2: bool,
    comp3: bool,
    reserved1: u6,
    countsync: bool,
    gp0: bool,
    gp1: bool,
    gp2: bool,
    gp3: bool,
    reserved2: u12,
};

pub const RtcFreqcorr = bitpack struct(u8) {
    value: u7 = 0,
    sign: bool = false,
};

pub const RtcInact = enum(u2) {
    off = 0,
    wake = 1,
    capture = 2,
    actl = 3,
};

pub const RtcTampctrl = bitpack struct(u32) {
    in0act: RtcInact = .off,
    in1act: RtcInact = .off,
    in2act: RtcInact = .off,
    in3act: RtcInact = .off,
    in4act: RtcInact = .off,
    reserved0: u6 = 0,
    tamlvl0: bool = false,
    tamlvl1: bool = false,
    tamlvl2: bool = false,
    tamlvl3: bool = false,
    tamlvl4: bool = false,
    reserved1: u3 = 0,
    debnc0: bool = false,
    debnc1: bool = false,
    debnc2: bool = false,
    debnc3: bool = false,
    debnc4: bool = false,
    reserved2: u3 = 0,
};

pub const RtcTampid = bitpack struct(u32) {
    tampid0: bool = false,
    tampid1: bool = false,
    tampid2: bool = false,
    tampid3: bool = false,
    tampid4: bool = false,
    reserved0: u26 = 0,
    tampevt: bool = false,
};

pub const RtcMode0 = extern struct {
    count: u32,
    reserved: u32,
    comp: [2]u32,
    reserved3: [6]u32,
    gp: [4]u32,
    reserved4: [4]u32,
    tampctrl: RtcTampctrl,
    timestamp: u32,
};

pub const RtcMode1 = extern struct {
    count: u16,
    reserved0: u16,
    per: u16,
    reserved1: u16,
    comp: [4]u16,
    reserved3: [6]u32,
    gp: [4]u32,
    reserved4: [4]u32,
    tampctrl: RtcTampctrl,
    timestamp: u16,
    reserved5: u16
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

pub const RtcMask = enum(u8) {
    off = 0,
    ss = 1,
    mmss = 2,
    hhmmss = 3,
    ddhhmmss = 4,
    mmddhhmmss = 5,
    yymmddhhmmss = 6,
};

pub const RtcTimestamp = bitpack struct(u32) {
    second: u6,
    minute: u6,
    hour: RtcHour = .am,
    day: u5,
    month: u4,
    year: u6,
};

pub const RtcClarm = extern struct {
    alarm: RtcAlarm,
    mask: RtcMask
};

pub const RtcMode2 = extern struct {
    clock: RtcClock,
    reserved: u32,
    alarm: [2]RtcClarm,
    gp: [4]u32,
    reserved4: [4]u32,
    tampctrl: RtcTampctrl,
    timestamp: RtcTimestamp
};

pub const RtcModes = extern union {
    mode0: RtcMode0,
    mode1: RtcMode1,
    mode2: RtcMode2
};

pub const InternalRtcError = error{
    Timeout
};

pub const RtcError = InternalRtcError || generic_rtc.RtcDataError;

pub const Rtc = extern struct {
    ctrla: RtcCtrla,
    ctrlb: RtcCtrlb,
    evctrl: RtcEvctrl,
    intenclr: RtcInt,
    intenset: RtcInt,
    intflag: RtcInt,
    dbgctrl: RtcDbgctrl,
    reserved0: u8,
    syncbusy: RtcSyncbusy,
    freqcorr: RtcFreqcorr,
    reserved1: [3]u8,
    mode: RtcModes,
    tampid: RtcTampid,
    reserved5: [5]u32,
    bkup: [8]u32,

    pub fn init(self: *volatile Rtc) void {
        _ = self;
        //todo
    }

    pub fn setTime(self: *volatile Rtc, data: *generic_rtc.RtcData, timeout: usize) RtcError!void {
        _ = self;
        _ = data;
        _ = timeout;
        return RtcError.Timeout;
    }

    pub fn getTime(self: *volatile Rtc, rtc_data: *generic_rtc.RtcData) RtcError!void {
        _ = self;
        _ = rtc_data;
        return RtcError.Timeout;
    }
};

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xA0, @sizeOf(Rtc));
}
