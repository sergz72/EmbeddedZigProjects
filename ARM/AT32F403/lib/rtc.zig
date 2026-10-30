const bpr = @import("bpr");
const generic_rtc = @import("generic_rtc");
const crm = @import("crm");
const pwc = @import("pwc");

const RTC_BASE = 0x40002800;

const BPR_CODE = 0x5A5A;

pub const RtcCtrlh = packed struct(u16) {
    tsien: bool = false,
    taien: bool = false,
    ovfien: bool = false,
    reserved: u13 = 0
};

pub const RtcCtrll = packed struct(u16) {
    tsf: bool = false,
    taf: bool = false,
    ovff: bool = false,
    updf: bool = false,
    cfgen: bool = false,
    cfgf: bool = false,
    reserved: u10 = 0
};

pub const Rtc = extern struct {
    ctrlh: RtcCtrlh,
    reserved: u16,
    ctrll: RtcCtrll,
    reserved2: u16,
    divh: u16,
    reserved3: u16,
    divl: u16,
    reserved4: u16,
    divcnth: u16,
    reserved5: u16,
    divcntl: u16,
    reserved6: u16,
    cnth: u16,
    reserved7: u16,
    cntl: u16,
    reserved8: u16,
    tah: u16,
    reserved9: u16,
    tal: u16,

    pub fn init(self: *volatile Rtc) void {
        pwc.Pwc.enable();
        bpr.Bpr.enable();
        crm.crm.bpdc.rtcen = true;
        if (bpr.bpr.data[0].data != BPR_CODE) {
            pwc.pwc.setBatteryPoweredDomainWriteAccess(true);
            bpr.Bpr.reset();
            crm.crm.rtcEnable();
            self.waitUpdateFinish();
            self.waitConfigFinish();
            self.setDivider(32768);
            bpr.bpr.data[0].data = BPR_CODE;
            pwc.pwc.setBatteryPoweredDomainWriteAccess(false);
        }
    }

    pub fn setTime(self: *volatile Rtc, data: *generic_rtc.RtcData) generic_rtc.RtcDataError!void {
        try data.validate();
        const time = data.toBinary();
        pwc.pwc.setBatteryPoweredDomainWriteAccess(true);
        self.waitUpdateFinish();
        self.waitConfigFinish();
        self.setCounter(@truncate(time));
        pwc.pwc.setBatteryPoweredDomainWriteAccess(false);
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
        self.ctrll = RtcCtrll{
            .cfgen = true,
            .updf = true,
            .ovff = true,
            .taf = true,
            .tsf = true,
        };
    }

    fn exitConfigMode(self: *volatile Rtc) void {
        self.ctrll = RtcCtrll{
            .updf = true,
            .ovff = true,
            .taf = true,
            .tsf = true,
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
        while (!self.ctrll.updf) {
            asm volatile ("nop");
        }
    }

    pub fn waitConfigFinish(self: *volatile Rtc) void {
        while (!self.ctrll.cfgf) {
            asm volatile ("nop");
        }
    }
};

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x26, @sizeOf(Rtc));
}
