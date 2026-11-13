const rcc = @import("rcc");
const pwr = @import("pwr");
const generic_rtc = @import("generic_rtc");

const RTC_BASE = 0x44007800;

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
    mt: bool = false,
    wdu: RtcWeekday = .monday,
    yu: u4 = 0,
    yt: u4 = 0,
    reserved1: u8 = 0,
};

pub const RtcBinaryMode = enum(u2) {
    bcd_calendar = 0,
    binary_mode = 1,
    bcd_calendar_and_binary = 2
};

pub const RtcBcdu = enum(u3) {
    ss70 = 0,
    ss80 = 1,
    ss90 = 2,
    ss100 = 3,
    ss110 = 4,
    ss120 = 5,
    ss130 = 6,
    ss140 = 7,
};

pub const RtcIcsr = bitpack struct(u32) {
    reserved0: u2 = 3,
    wutwf: bool = true,
    shpf: bool = false,
    inits: bool = false,
    rsf: bool = false,
    initf: bool = false,
    init: bool = false,
    bin: RtcBinaryMode = .bcd_calendar,
    bcdu: RtcBcdu = .ss70,
    reserved1: u3 = 0,
    recalpf: bool = false,
    reserved2: u15 = 0,
};

pub const RtcPrer = bitpack struct(u32) {
    prediv_s: u15 = 255,
    reserved0: u1 = 1,
    prediv_a: u7 = 127,
    reserved1: u9 = 0,
};

pub const RtcWutr = bitpack struct(u32) {
    wut: u16 = 65535,
    wutoclr: u16 = 0,
};

pub const RtcWucksel = enum(u3) {
    rtc_clock_div16 = 0,
    rtc_clock_div8 = 1,
    rtc_clock_div4 = 2,
    rtc_clock_div2 = 3,
    ck_spre1 = 4,
    ck_spre2 = 6
};

pub const RtcOsel = enum(u2) {
    disabled = 0,
    alarm_a = 1,
    alarm_b = 2,
    wakeup = 3
};

pub const RtcCr = bitpack struct(u32) {
    wucksel: RtcWucksel = .rtc_clock_div16,
    tsedge: bool = false,
    refckon: bool = false,
    bypshad: bool = false,
    fmt: bool = false,
    ssruie: bool = false,
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
    cosel: bool = false,
    pol: bool = false,
    osel: RtcOsel = .disabled,
    coe: bool = false,
    itse: bool = false,
    tampts: bool = false,
    tampoe: bool = false,
    alrafclr: bool = false,
    alrbfclr: bool = false,
    tampalrm_pu: bool = false,
    tampalrm_type: bool = false,
    out2en: bool = false,
};

pub const RtcPrivcfgr = bitpack struct(u32) {
    alrapriv: bool = false,
    alrbpriv: bool = false,
    wutpriv: bool = false,
    tspriv: bool = false,
    reserved0: u9 = 0,
    calpriv: bool = false,
    initpriv: bool = false,
    priv: bool = false,
    reserved1: u16 = 0,
};

pub const RtcSeccfgr = bitpack struct(u32) {
    alrasec: bool = false,
    alrbsec: bool = false,
    wutsec: bool = false,
    tssec: bool = false,
    reserved0: u9 = 0,
    calsec: bool = false,
    initsec: bool = false,
    sec: bool = false,
    reserved1: u16 = 0,
};

pub const RtcCalr = bitpack struct(u32) {
    calm: u9 = 0,
    reserved0: u3 = 0,
    lpcal: bool = false,
    calw16: bool = false,
    calw8: bool = false,
    calp: bool = false,
    reserved1: u16 = 0,
};

pub const RtcShiftr = bitpack struct(u32) {
    subfs: u15 = 0,
    reserved0: u16 = 0,
    add1s: bool = false,
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

pub const RtcAlrmssr = bitpack struct(u32) {
    ss: u15 = 0,
    reserved0: u9 = 0,
    maskss: u6 = 0,
    reserved1: u1 = 0,
    ssclr: bool = false,
};

pub const RtcSr = bitpack struct(u32) {
    alraf: bool,
    alrbf: bool,
    wutf: bool,
    tsf: bool,
    tsovf: bool,
    itsf: bool,
    ssruf: bool,
    reserved0: u25
};

pub const RtcOr = bitpack struct(u32) {
    out2_rmp: bool = false,
    reserved0: u31 = 0,
};

pub const InternalRtcError = error{
    Timeout
};

pub const RtcError = InternalRtcError || generic_rtc.RtcDataError;

pub const Rtc = extern struct {
    tr: RtcTr,
    dr: RtcDr,
    ssr: u32,
    icsr: RtcIcsr,
    prer: RtcPrer,
    wutr: RtcWutr,
    cr: RtcCr,
    privcfgr: RtcPrivcfgr,
    seccfgr: RtcSeccfgr,
    wpr: u32,
    calr: RtcCalr,
    shiftr: RtcShiftr,
    tstr: RtcTr,
    tsdr: RtcTsdr,
    tsssr: u32,
    reserved0: u32,
    alrmar: RtcAlrmr,
    alrmassr: RtcAlrmssr,
    alrmbr: RtcAlrmr,
    alrmbssr: RtcAlrmssr,
    sr: RtcSr,
    misr: RtcSr,
    smisr: RtcSr,
    scr: RtcSr,
    rtc_or: RtcOr,
    reserved1: [3]u32,
    alrabinr: u32,
    alrbbinr: u32,

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
        for (0..timeout) |counter| {
            if (self.icsr.initf) return;
        }
        return InternalRtcError.Timeout;
    }

    fn exitInit(self: *volatile Rtc) void {
        self.icsr.init = false;
    }

    fn waitSync(self: *volatile Rtc, timeout: usize) RtcError!void {
        for (0..timeout) |counter| {
            if (self.icsr.rsf) return;
        }
        return InternalRtcError.Timeout;
    }

    pub fn init(self: *volatile Rtc, drv: rcc.LseDrv, timeout: usize) RtcError!void {
        rcc.rcc.apb3enr.rtcen = true;
        if (rcc.bdcr.rtcen and rtc.icsr.inits) {
            return;
        }
        pwr.pwr.unlockBackupDomain();
        defer pwr.pwr.lockBackupDomain();
        rcc.rcc.backupDomainReset();
        rcc.rcc.lseOn(drv);
        rcc.rcc.bdcr.rtcsel = .lse;
        rcc.rcc.bdcr.rtcen = true;

        self.unlock();
        defer self.lock()
        try self.enterInit(timeout);
        self.dr = RtcDr{.yu = 6, .yt = 2}; // year field should be not 0 to set inits flag. Setting year 2026
        self.exitInit();
        try self.waitSync(timeout);
    }

    pub fn setTime(self: *volatile Rtc, data: *generic_rtc.RtcData, timeout: usize) RtcError!void {
        try data.validate();
        const wd = @backingInt(data.weekday);
        if (wd == 0) {
            wd = 7;
        }
        const month = @backingInt(data.month);
        const mu = month / 10;
        const mt = month % 10;
        const year = data.year - 2000;
        pwr.pwr.unlockBackupDomain();
        defer pwr.pwr.lockBackupDomain();
        self.unlock();
        defer self.lock()
        try self.enterInit(timeout);
        self.tr = RtcTr{
            .hu = data.hour / 10,
            .ht = data.hour % 10,
            .mu = data.minute / 10,
            .mt = data.minute % 10,
            .su = data.second / 10,
            .st = data.second % 10,
        };
        self.dr = RtcDr{
            .yu = year / 10,
            .yt = year % 10,
            .mu = mu,
            .mt = mt,
            .du = data.day / 10,
            .dt = data.day % 10,
            .wdu = @bitCast(wd),
        }
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
                var weekday = @backingInt(dr.wdu);
                if (weekday == 7) {
                    weekday = 0;
                }
                rtc_data.second = tr.su * 10 + tr.st;
                rtc_data.minute = tr.mu * 10 + tr.mt;
                rtc_data.hour = tr.hu * 10 + tr.ht;
                rtc_data.day = dr.du * 10 + dr.dt;
                rtc_data.month = @bitcast(dr.mu * 10 + dr.mt);
                rtc_data.year = dr.yu * 10 + dr.yt + 2000;
                rtc_data.weekday = @bitcast(weekday);
                rtc_data.buildYday();
                return;
            };
        }
    }
};

pub const rtc: *volatile Rtc = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x78, @sizeOf(Rtc));
}
