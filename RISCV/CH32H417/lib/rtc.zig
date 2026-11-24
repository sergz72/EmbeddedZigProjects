const bkp = @import("bkp");
const generic_rtc = @import("generic_rtc");
const rcc = @import("rcc");
const pwr = @import("pwr");

const RTC_BASE = 0x40002800;

const BPR_CODE = 0x5A5A;

pub const RtcCtrlh = bitpack struct(u16) {
    secie: bool = false,
    alrie: bool = false,
    owie: bool = false,
    reserved: u13 = 0
};

pub const RtcCtrll = bitpack struct(u16) {
    secf: bool = false,
    alrf: bool = false,
    owf: bool = false,
    rsf: bool = false,
    cnf: bool = false,
    rtoff: bool = false,
    reserved: u10 = 0
};

pub const Rtc = extern struct {
    ctlrh: RtcCtrlh,
    reserved0: u16,
    ctlrl: RtcCtrll,
    reserved1: u16,
    pscrh: u16,
    reserved2: u16,
    pscrl: u16,
    reserved3: u16,
    divh: u16,
    reserved4: u16,
    divl: u16,
    reserved5: u16,
    cnth: u16,
    reserved6: u16,
    cntl: u16,
    reserved7: u16,
    alrmh: u16,
    reserved8: u16,
    alrml: u16,
};

pub fn init() void {
    pwr.enable();
    bkp.enable();
    if (bkp.bkp.data[0].data != BPR_CODE) {
        pwr.setBatteryPoweredDomainWriteAccess(true);
        bkp.reset();
        rcc.rtcEnable();
        waitUpdateFinish();
        waitConfigFinish();
        setDivider(32768);
        bkp.bkp.data[0].data = BPR_CODE;
        pwr.setBatteryPoweredDomainWriteAccess(false);
    }
}

pub fn setTime(data: *generic_rtc.RtcData) generic_rtc.RtcDataError!void {
    try data.validate();
    const time = data.toBinary();
    pwr.setBatteryPoweredDomainWriteAccess(true);
    waitUpdateFinish();
    waitConfigFinish();
    setCounter(@truncate(time));
    pwr.setBatteryPoweredDomainWriteAccess(false);
}

pub fn getCounter() u32 {
    while (true) {
        const cnth = rtc.cnth;
        const cntl = rtc.cntl;
        const cnth2 = rtc.cnth;
        if (cnth == cnth2) {
            return (@as(u32, cnth) << 16) | @as(u32, cntl);
        }
    }
}

pub fn getTime(rtc_data: *generic_rtc.RtcData) void {
    const time = getCounter();
    rtc_data.fromBinary(time);
}

fn setCounter(cnt: u32) void {
    enterConfigMode();
    rtc.cnth = @truncate(cnt >> 16);
    rtc.cntl = @truncate(cnt);
    exitConfigMode();
}

fn enterConfigMode() void {
    rtc.ctlrl = RtcCtrll{
        .cnf = true,
        .secf = true,
        .alrf = true,
        .owf = true,
        .rsf = true,
    };
}

fn exitConfigMode() void {
    rtc.ctlrl = RtcCtrll{
        .secf = true,
        .alrf = true,
        .owf = true,
        .rsf = true,
    };
    waitConfigFinish();
}

pub fn setDivider(div: u20) void {
    if (div == 0) {
        while (true) {
            asm volatile ("wfi");
        }
    }
    const divm1 = div - 1;
    enterConfigMode();
    rtc.divh = @truncate(divm1 >> 16);
    rtc.divl = @truncate(divm1);
    exitConfigMode();
}

pub fn waitUpdateFinish() void {
    while (!rtc.ctlrl.rtoff) {
        asm volatile ("nop");
    }
}

pub fn waitConfigFinish() void {
    while (!rtc.ctlrl.rsf) {
        asm volatile ("nop");
    }
}

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x26, @sizeOf(Rtc));
}

