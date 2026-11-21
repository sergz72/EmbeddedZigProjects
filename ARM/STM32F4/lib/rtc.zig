const rcc = @import("rcc");
const pwr = @import("pwr");
const generic_rtc = @import("generic_rtc");

const RTC_BASE = 0x40002800;

pub const RtcTr = bitpack struct(u32) {
    su: u4 = 0,
    st: u3 = 0,
    reserved0: u1 = 0,
    mnu: u4 = 0,
    mnt: u3 = 0,
    reserved1: u1 = 0,
    hu: u4 = 0,
    ht: u2 = 0,
    pm: bool = false,
    reserved2: u9 = 0,
};

pub const RtcWeekday = enum(u3) {
    unknown = 0,
    monday = 1,
    tuesday = 2,
    wednesday = 3,
    thursday = 4,
    friday = 5,
    saturday = 6,
    sunday = 7
};

pub const RtcDr = bitpack struct(u32) {
    du: u4 = 1,
    dt: u2 = 0,
    reserved0: u2 = 0,
    mu: u4 = 1,
    mt: u1 = 0,
    wdu: RtcWeekday = .monday,
    yu: u4 = 0,
    yt: u4 = 0,
    reserved1: u8 = 0,
};

pub const RtcWcksel = enum(u3) {
    rtc_div16 = 0,
    rtc_div8 = 1,
    rtc_div4 = 2,
    rtc_div2 = 3,
    ck_spre = 4,
    ck_spre_add65536 = 6
};

pub const RtcOsel = enum(u2) {
    disabled = 0,
    alarm_a = 1,
    alarm_b = 2,
    wakeup = 3
};

pub const RtcCr = bitpack struct(u32) {
    wcksel: RtcWcksel = .rtc_div16,
    tsedge: bool = false,
    refckon: bool = false,
    reserved0: u1 = 0,
    fmt: bool = false,
    dce: bool = false,
    alrae: bool = false,
    alrbe: bool = false,
    wute: bool = false,
    tse: bool = false,
    alraie: bool = false,
    alrbie: bool = false,
    wutie: bool = false,
    tsie: bool = false,
    add1h: bool = false,
    sub1h: bool = false,
    bkp: bool = false,
    reserved1: u1 = 0,
    pol: bool = false,
    osel: RtcOsel = .disabled,
    coe: bool = false,
    reserved2: u8 = 0,
};

pub const RtcIsr = bitpack struct(u32) {
    alrawf: bool = true,
    alrbwf: bool = true,
    wutwf: bool = true,
    shpf: bool = false,
    inits: bool = false,
    rsf: bool = false,
    initf: bool = false,
    init: bool = false,
    alraf: bool = false,
    alrbf: bool = false,
    wutf: bool = false,
    tsf: bool = false,
    tsovf: bool = false,
    tamp1f: bool = false,
    tamp2f: bool = false,
    reserved0: u1 = 0,
    recalpf: bool = false,
    reserved1: u15 = 0,
};

pub const RtcPrer = bitpack struct(u32) {
    prediv_s: u15 = 255,
    reserved0: u1 = 1,
    prediv_a: u7 = 127,
    reserved1: u9 = 0,
};

pub const RtcCalibr = bitpack struct(u32) {
    dc: u5 = 0,
    reserved0: u2 = 0,
    dcs: bool = false,
    reserved1: u24 = 0,
};

pub const RtcAlrmr = bitpack struct(u32) {
    su: u4 = 0,
    st: u3 = 0,
    msk1: bool = false,
    mnu: u4 = 0,
    mnt: u3 = 0,
    msk2: bool = false,
    hu: u4 = 0,
    ht: u2 = 0,
    pm: bool = false,
    msk3: bool = false,
    du: u4 = 0,
    dt: u2 = 0,
    wdsel: bool = false,
    msk4: bool = false,
};

pub const RtcShiftr = bitpack struct(u32) {
    subfs: u15 = 0,
    reserved0: u16 = 0,
    add1s: bool = false,
};

pub const RtcTstr = bitpack struct(u32) {
    tamp1e: bool,
    tamp1trg: bool,
    tampie: bool,
    reserved0: u13,
    tamp1insel: bool,
    tsinsel: bool,
    alarmouttype: bool,
    reserved1: u13,
};

pub const RtcTsdr = bitpack struct(u32) {
    du: u4,
    dt: u2,
    reserved0: u2,
    mu: u4,
    mt: bool,
    wdu: RtcWeekday,
    reserved1: u16,
};

pub const RtcCalr = bitpack struct(u32) {
    calm: u9 = 0,
    reserved0: u4 = 0,
    calw16: bool = false,
    calw8: bool = false,
    calp: bool = false,
    reserved1: u16 = 0,
};

pub const RtcTampprch = enum(u2) {
    _1cycle = 0,
    _2cycles = 1,
    _4cycles = 2,
    _8cycles = 3,
};

pub const RtcTampFreq = enum(u3) {
    div32768 = 0,
    div16384 = 1,
    div8192 = 2,
    div4096 = 3,
    div2048 = 4,
    div1024 = 5,
    div512 = 6,
    div256 = 7
};

pub const RtcTampflt = enum(u2) {
    on_edge = 0,
    _2samples = 1,
    _4samples = 2,
    _8samples = 3,
};

pub const RtcTafcr = bitpack struct(u32) {
    tamp1e: bool = false,
    tamp1trg: bool = false,
    tampie: bool = false,
    tamp2e: bool = false,
    tamp2trg: bool = false,
    reserved0: u2 = 0,
    tampts: bool = false,
    tampfreq: RtcTampFreq = .div32768,
    tampflt: RtcTampflt = .on_edge,
    tampprch: RtcTampprch = ._1cycle,
    tamppudis: bool = false,
    tamp1insel: bool = false,
    tsinsel: bool = false,
    alarmouttype: bool = false,
    reserved1: u13 = 0,
};

pub const RtcAlrmssr = bitpack struct(u32) {
    ss: u15 = 0,
    reserved0: u9 = 0,
    maskss: u4 = 0,
    reserved1: u4 = 0,
};

pub const Rtc = extern struct {
    tr: RtcTr,
    dr: RtcDr,
    cr: RtcCr,
    isr: RtcIsr,
    prer: RtcPrer,
    wutr: u32,
    calibr: RtcCalibr,
    alrmar: RtcAlrmr,
    alrmbr: RtcAlrmr,
    wpr: u32,
    ssr: u32,
    shiftr: RtcShiftr,
    tstr: RtcTstr,
    tsdr: RtcTsdr,
    tsssr: u32,
    calr: RtcCalr,
    tafcr: RtcTafcr,
    alrmassr: RtcAlrmssr,
    alrmbssr: RtcAlrmssr,
    reserved0: u32,
    bkp: [20]u32,

    pub fn unlock(self: *volatile Rtc) void {
        // Write the key sequence to the write protection register to unlock
        self.wpr = 0xCA;
        self.wpr = 0x53;
    }

    pub fn lock(self: *volatile Rtc) void {
        // Write any value to the write protection register to lock
        self.wpr = 0xFF;
    }

    pub fn enterInit(self: *volatile Rtc, timeout: usize) RtcError!void {
        if (self.icsr.initf) return;
        self.icsr.init = true;
        for (0..timeout) |_| {
            if (self.icsr.initf) return;
        }
        return InternalRtcError.Timeout;
    }

    fn exitInit(self: *volatile Rtc) void {
        self.icsr.init = false;
    }

    fn waitSync(self: *volatile Rtc, timeout: usize) RtcError!void {
        for (0..timeout) |_| {
            if (self.icsr.rsf) return;
        }
        return InternalRtcError.Timeout;
    }

    pub fn init(self: *volatile Rtc, drv: rcc.RccLseDrv, timeout: usize) RtcError!void {
        rcc.rcc.hpenr.apb3.rtcapben = true;
        if (rcc.rcc.bdcr.rtcen and self.icsr.inits) {
            return;
        }
        pwr.pwr.unlockBackupDomain();
        defer pwr.pwr.lockBackupDomain();
        rcc.rcc.backupDomainReset();
        rcc.rcc.lseOn(drv);
        rcc.rcc.bdcr.rtcsel = .lse;
        rcc.rcc.bdcr.rtcen = true;

        self.unlock();
        defer self.lock();
        try self.enterInit(timeout);
        self.dr = RtcDr{.yu = 6, .yt = 2}; // year field should be not 0 to set inits flag. Setting year 2026
        self.exitInit();
        try self.waitSync(timeout);
    }

    pub fn setTime(self: *volatile Rtc, data: *generic_rtc.RtcData, timeout: usize) RtcError!void {
        try data.validate();
        var wd: u3 = @truncate(@backingInt(data.wday));
        if (wd == 0) {
            wd = 7;
        }
        const month = @backingInt(data.month);
        const mu = month % 10;
        const mt = month / 10;
        const year = data.year - 2000;
        pwr.pwr.unlockBackupDomain();
        defer pwr.pwr.lockBackupDomain();
        self.unlock();
        defer self.lock();
        try self.enterInit(timeout);
        self.tr = RtcTr{
            .hu = @truncate(data.hours % 10),
            .ht = @truncate(data.hours / 10),
            .mnu = @truncate(data.minutes % 10),
            .mnt = @truncate(data.minutes / 10),
            .su = @truncate(data.seconds % 10),
            .st = @truncate(data.seconds / 10),
        };
        self.dr = RtcDr{
            .yu = @truncate(year % 10),
            .yt = @truncate(year / 10),
            .mu = @truncate(mu),
            .mt = @truncate(mt),
            .du = @truncate(data.day % 10),
            .dt = @truncate(data.day / 10),
            .wdu = @bitCast(wd),
        };
        self.exitInit();
        try self.waitSync(timeout);
    }

    pub fn getTime(self: *volatile Rtc, rtc_data: *generic_rtc.RtcData) RtcError!void {
        while (true) {
            const tr = self.tr;
            const dr = self.dr;
            const tr2 = self.tr;
            const dr2 = self.dr;
            if (tr == tr2 and dr == dr2) {
                var weekday = @as(u8, @backingInt(dr.wdu));
                if (weekday == 7) {
                    weekday = 0;
                }
                rtc_data.seconds = @as(u8, tr.st) * 10 + tr.su;
                rtc_data.minutes = @as(u8, tr.mnt) * 10 + tr.mnu;
                rtc_data.hours = @as(u8, tr.ht) * 10 + tr.hu;
                rtc_data.day = @as(u8, dr.dt) * 10 + dr.du;
                rtc_data.month = @bitCast(@as(u8, dr.mt) * 10 + dr.mu);
                rtc_data.year = @as(u32, dr.yt) * 10 + dr.yu + 2000;
                rtc_data.wday = @bitCast(weekday);
                rtc_data.buildYDay();
                return;
            }
        }
    }
};

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xA0, @sizeOf(Rtc));
}
