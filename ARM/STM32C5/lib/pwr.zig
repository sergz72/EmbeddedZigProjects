const PWR_BASE = 0x44020800;

pub const Lpms = enum(u2) {
    stop0 = 0,
    stop1 = 1,
    standby = 2
};

pub const PwrPmcr = bitpack struct(u32) {
    lpms: Lpms = .stop0,
    reserved0: u5 = 0,
    cssf: bool = false,
    reserved1: u1 = 0,
    flps: bool = false,
    reserved2: u13 = 0,
    sram2_3_so: bool = false,
    sram2_1_so: bool = false,
    sram2_2_so: bool = false,
    sram1so: bool = false,
    reserved3: u5 = 0,
};

pub const PwrPmsr = bitpack struct(u32) {
    reserved0: u5,
    stopf: bool,
    sbf: bool,
    reserved1: u25,
};

pub const PwrRtccr = bitpack struct(u32) {
    drtcp: bool = false,
    reserved0: u31 = 0,
};

pub const PwrVmcr = bitpack struct(u32) {
    pvde: bool = false,
    reserved0: u31 = 0,
};

pub const PwrVmsr = bitpack struct(u32) {
    reserved0: u22,
    pvdo: bool,
    reserved1: u9,
};

pub const PwrWuscr = bitpack struct(u32) {
    cwuf1: bool = false,
    cwuf2: bool = false,
    cwuf3: bool = false,
    cwuf4: bool = false,
    cwuf5: bool = false,
    cwuf6: bool = false,
    cwuf7: bool = false,
    reserved0: u25 = 0,
};

pub const PwrWusr = bitpack struct(u32) {
    wuf1: bool,
    wuf2: bool,
    wuf3: bool,
    wuf4: bool,
    wuf5: bool,
    wuf6: bool,
    wuf7: bool,
    reserved0: u25,
};

pub const Wuppupd = enum(u2) {
    floating = 0,
    pullup = 1,
    pulldown = 2,
};

pub const PwrWucr = bitpack struct(u32) {
    wupen1: bool = false,
    wupen2: bool = false,
    wupen3: bool = false,
    wupen4: bool = false,
    wupen5: bool = false,
    wupen6: bool = false,
    wupen7: bool = false,
    reserved0: u1 = 0,
    wupp1: bool = false,
    wupp2: bool = false,
    wupp3: bool = false,
    wupp4: bool = false,
    wupp5: bool = false,
    wupp6: bool = false,
    wupp7: bool = false,
    reserved1: u1 = 0,
    wuppupd1: Wuppupd = .floating,
    wuppupd2: Wuppupd = .floating,
    wuppupd3: Wuppupd = .floating,
    wuppupd4: Wuppupd = .floating,
    wuppupd5: Wuppupd = .floating,
    wuppupd6: Wuppupd = .floating,
    wuppupd7: Wuppupd = .floating,
    reserved2: u2 = 0
};

pub const PwrIoretr = bitpack struct(u32) {
    ioreten: bool = false,
    reserved0: u15 = 0,
    jtagioreten: bool = false,
    reserved1: u15 = 0,
};

pub const PwrPrivcfgr = bitpack struct(u32) {
    reserved0: u1 = 0,
    priv: bool = false,
    reserved1: u30 = 0,
};

pub const Pwr = extern struct {
    pmcr: PwrPmcr,
    pmsr: PwrPmsr,
    reserved0: [7]u32,
    rtccr: PwrRtccr,
    reserved1: [3]u32,
    vmcr: PwrVmcr,
    reserved2: u32,
    vmsr: PwrVmsr,
    wuscr: PwrWuscr,
    wusr: PwrWusr,
    wucr: PwrWucr,
    reserved3: u32,
    ioretr: PwrIoretr,
    reserved4: [44]u32,
    privcfgr: PwrPrivcfgr,
};

pub const pwr: *volatile Pwr = @ptrFromInt(PWR_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x108, @sizeOf(Pwr));
}
