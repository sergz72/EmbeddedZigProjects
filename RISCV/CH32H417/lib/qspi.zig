const QSPI1_BASE = 0x40024C00;
const QSPI2_BASE = 0x40025000;

pub const QspiCr = bitpack struct(u32) {
    en: bool = false,
    abort: bool = false,
    dmaen: bool = false,
    tcen: bool = false,
    reserved0: u1 = 0,
    start: bool = false,
    dfm: bool = false,
    fsel: bool = false,
    fthres: u5 = 0,
    sioxen: bool = false,
    reserved1: u2 = 0,
    teie: bool = false,
    tcie: bool = false,
    ftie: bool = false,
    smie: bool = false,
    toie: bool = false,
    reserved2: u1 = 0,
    apms: bool = false,
    pmm: bool = false,
    prescaler: u8 = 0,
};

pub const QspiDcr = bitpack struct(u32) {
    ckmode: bool = false,
    reserved0: u7 = 0,
    csht: u3 = 0,
    reserved1: u5 = 0,
    fsize: u5 = 0,
    reserved2: u11 = 0,
};

pub const QspiSr = bitpack struct(u32) {
    tef: bool,
    tcf: bool,
    ftf: bool,
    smf: bool,
    tof: bool,
    busy: bool,
    reserved0: u2,
    flevel: u6,
    reserved1: u2,
    idlef: bool,
    reserved2: u15,
};

pub const QspiFcr = bitpack struct(u32) {
    ctef: bool = false,
    ctcf: bool = false,
    reserved0: u1 = 0,
    csmf: bool = false,
    ctof: bool = false,
    reserved1: u27 = 0,
};

pub const QspiCcr = bitpack struct(u32) {
    instruction: u8 = 0,
    imode: u2 = 0,
    admode: u2 = 0,
    adsize: u2 = 0,
    abmode: u2 = 0,
    absize: u2 = 0,
    dcyc: u5 = 0,
    reserved0: u1 = 0,
    dmode: u2 = 0,
    fmode: u2 = 0,
    sioo: bool = false,
    reserved1: u3 = 0,
};

pub const Qspi = extern struct {
    cr: QspiCr,
    dcr: QspiDcr,
    sr: QspiSr,
    fcr: QspiFcr,
    dlr: u32,
    ccr: QspiCcr,
    ar: u32,
    abr: u32,
    dr: u32,
    psmkr: u32,
    psmar: u32,
    pir: u32,
    lptr: u32,
};

pub const qspi1: *volatile Qspi = @ptrFromInt(QSPI1_BASE);
pub const qspi2: *volatile Qspi = @ptrFromInt(QSPI2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x34, @sizeOf(Qspi));
}
