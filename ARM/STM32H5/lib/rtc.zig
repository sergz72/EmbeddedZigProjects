const RTC_BASE = 0x44007800;

pub const RtcTr = packed struct(u32) {
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

pub const RtcDr = packed struct(u32) {
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

pub const RtcIcsr = packed struct(u32) {
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

pub const RtcPrer = packed struct(u32) {
    prediv_s: u15 = 255,
    reserved0: u1 = 1,
    prediv_a: u7 = 127,
    reserved1: u9 = 0,
};

pub const RtcWutr = packed struct(u32) {
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

pub const RtcCr = packed struct(u32) {
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

pub const RtcPrivcfgr = packed struct(u32) {
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

pub const RtcSeccfgr = packed struct(u32) {
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

pub const RtcCalr = packed struct(u32) {
    calm: u9 = 0,
    reserved0: u3 = 0,
    lpcal: bool = false,
    calw16: bool = false,
    calw8: bool = false,
    calp: bool = false,
    reserved1: u16 = 0,
};

pub const RtcShiftr = packed struct(u32) {
    subfs: u15 = 0,
    reserved0: u16 = 0,
    add1s: bool = false,
};

pub const RtcTsdr = packed struct(u32) {
    du: u4,
    dt: u2,
    reserved0: u2,
    mu: u4,
    mt: bool,
    wdu: RtcWeekday,
    reserved1: u16,
};

pub const RtcAlrmr = packed struct(u32) {
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

pub const RtcAlrmssr = packed struct(u32) {
    ss: u15 = 0,
    reserved0: u9 = 0,
    maskss: u6 = 0,
    reserved1: u1 = 0,
    ssclr: bool = false,
};

pub const RtcSr = packed struct(u32) {
    alraf: bool,
    alrbf: bool,
    wutf: bool,
    tsf: bool,
    tsovf: bool,
    itsf: bool,
    ssruf: bool,
    reserved0: u25
};

pub const RtcOr = packed struct(u32) {
    out2_rmp: bool = false,
    reserved0: u31 = 0,
};

pub const RTC = extern struct {
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
    reserved1: [12]u8,
    alrabinr: u32,
    alrbbinr: u32,
};

pub const rtc: *volatile RTC = @ptrFromInt(RTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x78, @sizeOf(RTC));

}
