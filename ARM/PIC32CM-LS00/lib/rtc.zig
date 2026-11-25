const generic_rtc = @import("generic_rtc");
const osc32kctrl = @import("osc32kctrl");

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
    reserved1: u2 = 0,
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
    reserved0: u3 = 0,
    debmaj: bool = false,
    debasync: bool = false,
    rtcout: bool = false,
    dmaen: bool = false,
    debf: Rtcf = .div2,
    reserved1: u1 = 0,
    actf: Rtcf = .div2,
    septo: bool = false,
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
    reserved0: u4 = 0,
    tampereo: bool = false,
    ovfeo: bool = false,
    tampevei: bool = false,
    reserved1: u7 = 0,
    perdeo: bool = false,
    reserved2: u7 = 0,
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
    reserved0: u4 = 0,
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
    reserved1: u8,
    countsync: bool,
    gp0: bool,
    gp1: bool,
    reserved2: u14,
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
    in5act: RtcInact = .off,
    in6act: RtcInact = .off,
    in7act: RtcInact = .off,
    tamlvl0: bool = false,
    tamlvl1: bool = false,
    tamlvl2: bool = false,
    tamlvl3: bool = false,
    tamlvl4: bool = false,
    tamlvl5: bool = false,
    tamlvl6: bool = false,
    tamlvl7: bool = false,
    debnc0: bool = false,
    debnc1: bool = false,
    debnc2: bool = false,
    debnc3: bool = false,
    debnc4: bool = false,
    debnc5: bool = false,
    debnc6: bool = false,
    debnc7: bool = false,
};

pub const RtcTampid = bitpack struct(u32) {
    tampid0: bool = false,
    tampid1: bool = false,
    tampid2: bool = false,
    tampid3: bool = false,
    tampid4: bool = false,
    tampid5: bool = false,
    tampid6: bool = false,
    tampid7: bool = false,
    reserved0: u23 = 0,
    tampevt: bool = false,
};

pub const RtcTampctrlb = bitpack struct(u32) {
    alsi0: bool = false,
    alsi1: bool = false,
    alsi2: bool = false,
    alsi3: bool = false,
    alsi4: bool = false,
    alsi5: bool = false,
    alsi6: bool = false,
    alsi7: bool = false,
    reserved0: u24 = 0,
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

    pub fn setTime(self: *volatile RtcMode0, data: *generic_rtc.RtcData) RtcError!void {
        try data.validate();
        self.count = @truncate(data.toBinary());
    }

    pub fn getTime(self: *volatile RtcMode0, rtc_data: *generic_rtc.RtcData) RtcError!void {
        rtc_data.fromBinary(self.count);
    }

    pub fn getUnixTime(self: *volatile RtcMode0) RtcError!u32 {
        return self.count;
    }
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
    reserved5: u16,

    pub fn setTime(self: *volatile RtcMode1, data: *generic_rtc.RtcData) RtcError!void {
        _ = self;
        _ = data;
        return RtcError.NotImplemented;
    }

    pub fn getTime(self: *volatile RtcMode1, rtc_data: *generic_rtc.RtcData) RtcError!void {
        _ = self;
        _ = rtc_data;
        return RtcError.NotImplemented;
    }

    pub fn getUnixTime(self: *volatile RtcMode1) RtcError!u32 {
        _ = self;
        return RtcError.NotImplemented;
    }
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
    timestamp: RtcTimestamp,

    pub fn setTime(self: *volatile RtcMode2, data: *generic_rtc.RtcData) RtcError!void {
        _ = self;
        _ = data;
        return RtcError.NotImplemented;
    }

    pub fn getTime(self: *volatile RtcMode2, rtc_data: *generic_rtc.RtcData) RtcError!void {
        _ = self;
        _ = rtc_data;
        return RtcError.NotImplemented;
    }

    pub fn getUnixTime(self: *volatile RtcMode2) RtcError!u32 {
        _ = self;
        return RtcError.NotImplemented;
    }
};

pub const RtcModes = extern union {
    mode0: RtcMode0,
    mode1: RtcMode1,
    mode2: RtcMode2
};

pub const InternalRtcError = error{
    NotImplemented
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
    tampctrlb: RtcTampctrlb,
};

pub fn init(mode: RtcMode) void {
    osc32kctrl.osc32kctrl.rtcctrl = osc32kctrl.Osc32kRtcctrl{.rtcsel = .xosc1k};
    rtc.ctrla = RtcCtrla{
        .mode = mode,
        .prescaler = .div1024,
        .countsync = true
    };
    rtc.ctrla.enable = true;
    while (rtc.syncbusy.enable) {
        asm volatile("nop");
    }
}

pub fn setTime(data: *generic_rtc.RtcData, timeout: usize) RtcError!void {
    _ = timeout;
    return switch (rtc.ctrla.mode) {
        .count32 => rtc.mode.mode0.setTime(data),
        .count16 => rtc.mode.mode1.setTime(data),
        .clock => rtc.mode.mode2.setTime(data),
    };
}

pub fn getTime(rtc_data: *generic_rtc.RtcData) RtcError!void {
    return switch (rtc.ctrla.mode) {
        .count32 => rtc.mode.mode0.getTime(rtc_data),
        .count16 => rtc.mode.mode1.getTime(rtc_data),
        .clock => rtc.mode.mode2.getTime(rtc_data),
    };
}

pub fn getUnixTime() RtcError!u32 {
    return switch (rtc.ctrla.mode) {
        .count32 => rtc.mode.mode0.getUnixTime(),
        .count16 => rtc.mode.mode1.getUnixTime(),
        .clock => rtc.mode.mode2.getUnixTime(),
    };
}

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x70, @sizeOf(Rtc));
}
