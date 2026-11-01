const PWR_BASE = 0x44020800;

pub const Svos = enum(u2) {
    scale5 = 1,
    scale4 = 2,
    scale3 = 3,
};

pub const PwrPmcr = packed struct(u32) {
    lpms: bool = false,
    reserved0: u1 = 1,
    svos: Svos = .scale3,
    reserved1: u3 = 0,
    cssf: bool = false,
    reserved2: u1 = 0,
    flps: bool = false,
    reserved3: u2 = 0,
    booste: bool = false,
    avd_ready: bool = false,
    reserved4: u2 = 0,
    ethernetso: bool = false,
    reserved5: u6 = 0,
    sram3so: bool = false,
    sram2_16so: bool = false,
    sram2_48so: bool = false,
    sram1so: bool = false,
    reserved6: u5 = 0,
};

pub const PwrPmsr = packed struct(u32) {
    reserved0: u5,
    stopf: bool,
    sbf: bool,
    reserved1: u25
};

pub const Vos = enum(u2) {
    scale3 = 0,
    scale2 = 1,
    scale1 = 2,
    scale0 = 3
};

pub const PwrVoscr = packed struct(u32) {
    reserved0: u4 = 0,
    vos: Vos = .scale3,
    reserved1: u26 = 0,
};

pub const PwrVossr = packed struct(u32) {
    reserved0: u3,
    vosrdy: bool,
    reserved1: u9,
    actvosrdy: bool,
    actvos: Vos,
    reserved2: u16
};

pub const PwrBdcr = packed struct(u32) {
    bren: bool = false,
    monen: bool = false,
    reserved0: u6 = 0,
    vbe: bool = false,
    vbrs: bool = false,
    reserved1: u22 = 0
};

pub const PwrDbpcr = packed struct(u32) {
    dbp: bool = false,
    reserved0: u31 = 0
};

pub const PwrBdsr = packed struct(u32) {
    reserved0: u16,
    brrdy: bool,
    reserved1: u3,
    vbatl: bool,
    vbath: bool,
    templ: bool,
    temph: bool,
    reserved2: u8
};

pub const PwrUcpdr = packed struct(u32) {
    ucpd_dbdis: bool = false,
    ucpd_stby: bool = false,
    reserved0: u30 = 0,
};

pub const PwrSccr = packed struct(u32) {
    bypass: bool = false,
    reserved0: u7 = 0,
    ldoen: bool = false,
    smpsen: bool = false,
    reserved1: u22 = 0
};

pub const Pls = enum(u3) {
    _1v95 = 0,
    _2v1 = 1,
    _2v25 = 2,
    _2v4 = 3,
    _2v55 = 4,
    _2v7 = 5,
    _2v85 = 6,
    pvd_in = 7
};

pub const Als = enum(u2) {
    _1v7 = 0,
    _2v1 = 1,
    _2v5 = 2,
    _2v8 = 3
};

pub const PwrVmcr = packed struct(u32) {
    pvde: bool = false,
    pls: Pls = ._1v95,
    reserved0: u4 = 0,
    avden: bool = false,
    als: Als = ._1v7,
    reserved1: u21 = 0,
};

pub const PwrUsbscr = packed struct(u32) {
    reserved0: u24 = 0,
    usb33den: bool = false,
    usb33sv: bool = false,
    reserved1: u6 = 0,
};

pub const PwrVmsr = packed struct(u32) {
    reserved0: u19,
    avdo: bool,
    vddio2rdy: bool,
    reserved1: u1,
    pvdo: bool,
    reserved2: u1,
    usb33rdy: bool,
    reserved3: u7
};

pub const PwrWuscr = packed struct(u32) {
    cwuf1: bool = false,
    cwuf2: bool = false,
    cwuf3: bool = false,
    cwuf4: bool = false,
    cwuf5: bool = false,
    cwuf6: bool = false,
    cwuf7: bool = false,
    cwuf8: bool = false,
    reserved0: u24 = 0
};

pub const PwrWusr = packed struct(u32) {
    wuf1: bool,
    wuf2: bool,
    wuf3: bool,
    wuf4: bool,
    wuf5: bool,
    wuf6: bool,
    wuf7: bool,
    wuf8: bool,
    reserved0: u24
};

pub const Wuppupd = enum(u2) {
    no_pullup = 0,
    pullup = 1,
    pulldown = 2
};

pub const PwrWucr = packed struct(u32) {
    wupen1: bool = false,
    wupen2: bool = false,
    wupen3: bool = false,
    wupen4: bool = false,
    wupen5: bool = false,
    wupen6: bool = false,
    wupen7: bool = false,
    wupen8: bool = false,
    wupp1: bool = false,
    wupp2: bool = false,
    wupp3: bool = false,
    wupp4: bool = false,
    wupp5: bool = false,
    wupp6: bool = false,
    wupp7: bool = false,
    wupp8: bool = false,
    wuppupd1: Wuppupd = .no_pullup,
    wuppupd2: Wuppupd = .no_pullup,
    wuppupd3: Wuppupd = .no_pullup,
    wuppupd4: Wuppupd = .no_pullup,
    wuppupd5: Wuppupd = .no_pullup,
    wuppupd6: Wuppupd = .no_pullup,
    wuppupd7: Wuppupd = .no_pullup,
    wuppupd8: Wuppupd = .no_pullup
};

pub const PwrIoretr = packed struct(u32) {
    ioreten: bool = false,
    reserved0: u15 = 0,
    jtagioreten: bool = false,
    reserved1: u15 = 0,
};

pub const PwrSeccfgr = packed struct(u32) {
    wup1sec: bool = false,
    wup2sec: bool = false,
    wup3sec: bool = false,
    wup4sec: bool = false,
    wup5sec: bool = false,
    wup6sec: bool = false,
    wup7sec: bool = false,
    wup8sec: bool = false,
    reserved0: u3 = 0,
    retsec: bool = false,
    lpmsec: bool = false,
    scmsec: bool = false,
    vbsec: bool = false,
    vusbsec: bool = false,
    reserved1: u16 = 0,
};

pub const PwrPrivcfgr = packed struct(u32) {
    spriv: bool = false,
    nspriv: bool = false,
    reserved0: u30 = 0,
};

pub const Pwr = extern struct {
    pmcr: PwrPmcr,
    pmsr: PwrPmsr,
    reserved0: [2]u32,
    voscr: PwrVoscr,
    vossr: PwrVossr,
    reserved1: [2]u32,
    bdcr: PwrBdcr,
    dbpcr: PwrDbpcr,
    bdsr: PwrBdsr,
    ucpdr: PwrUcpdr,
    sccr: PwrSccr,
    vmcr: PwrVmcr,
    usbscr: PwrUsbscr,
    vmsr: PwrVmsr,
    wuscr: PwrWuscr,
    wusr: PwrWusr,
    wucr: PwrWucr,
    reserved2: u32,
    ioretr: PwrIoretr,
    reserved3: [43]u32,
    seccfgr: PwrSeccfgr,
    privcfgr: PwrPrivcfgr,

    pub fn setVos(self: *volatile Pwr, value: PwrVoscr) void {
        self.voscr = value;
    }
};

pub const pwr: *volatile Pwr = @ptrFromInt(PWR_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x108, @sizeOf(Pwr));
}
