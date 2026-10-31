const bkp = @import("bkp");
const generic_rtc = @import("generic_rtc");
const rcc = @import("rcc");
const pwr = @import("pwr");

const RTC_BASE = 0x40002800;

const BPR_CODE = 0x5A5A;

pub const RtcCtrlh = packed struct(u16) {
    secie: bool = false,
    alrie: bool = false,
    owie: bool = false,
    reserved: u13 = 0
};

pub const RtcCtrll = packed struct(u16) {
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

    pub fn init(self: *volatile Rtc) void {
        pwr.Pwr.enable();
        bkp.Bkp.enable();
        if (bkp.bkp.data[0].data != BPR_CODE) {
            pwr.pwr.setBatteryPoweredDomainWriteAccess(true);
            bkp.Bkp.reset();
            rcc.rcc.rtcEnable();
            self.waitUpdateFinish();
            self.waitConfigFinish();
            self.setDivider(32768);
            bkp.bkp.data[0].data = BPR_CODE;
            pwr.pwr.setBatteryPoweredDomainWriteAccess(false);
        }
    }

    pub fn setTime(self: *volatile Rtc, data: *generic_rtc.RtcData) generic_rtc.RtcDataError!void {
        try data.validate();
        const time = data.toBinary();
        pwr.pwr.setBatteryPoweredDomainWriteAccess(true);
        self.waitUpdateFinish();
        self.waitConfigFinish();
        self.setCounter(@truncate(time));
        pwr.pwr.setBatteryPoweredDomainWriteAccess(false);
    }

    pub fn getCounter(self: *volatile Rtc) u32 {
        while (true) {
            const cnth = self.cnth;
            const cntl = self.cntl;
            const cnth2 = self.cnth;
            if (cnth == cnth2) {
                return (@as(u32, cnth) << 16) | @as(u32, cntl);
            }
        }
    }

    pub fn getTime(self: *volatile Rtc, rtc_data: *generic_rtc.RtcData) void {
        const time = self.getCounter();
        rtc_data.fromBinary(time);
    }

    fn setCounter(self: *volatile Rtc, cnt: u32) void {
        self.enterConfigMode();
        self.cnth = @truncate(cnt >> 16);
        self.cntl = @truncate(cnt);
        self.exitConfigMode();
    }

    fn enterConfigMode(self: *volatile Rtc) void {
        self.ctlrl = RtcCtrll{
            .cnf = true,
            .secf = true,
            .alrf = true,
            .owf = true,
            .rsf = true,
        };
    }

    fn exitConfigMode(self: *volatile Rtc) void {
        self.ctlrl = RtcCtrll{
            .secf = true,
            .alrf = true,
            .owf = true,
            .rsf = true,
        };
        self.waitConfigFinish();
    }

    pub fn setDivider(self: *volatile Rtc, div: u20) void {
        if (div == 0) {
            while (true) {
                asm volatile ("wfi");
            }
        }
        const divm1 = div - 1;
        self.enterConfigMode();
        self.divh = @truncate(divm1 >> 16);
        self.divl = @truncate(divm1);
        self.exitConfigMode();
    }

    pub fn waitUpdateFinish(self: *volatile Rtc)void {
        while (!self.ctlrl.rtoff) {
            asm volatile ("nop");
        }
    }

    pub fn waitConfigFinish(self: *volatile Rtc) void {
        while (!self.ctlrl.rsf) {
            asm volatile ("nop");
        }
    }
};

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x26, @sizeOf(Rtc));
}

