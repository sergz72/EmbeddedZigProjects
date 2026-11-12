const LPSPI0_BASE = 0x40092000;
const LPSPI1_BASE = 0x40093000;
const LPSPI2_BASE = 0x40094000;
const LPSPI3_BASE = 0x40095000;
const LPSPI4_BASE = 0x400B4000;
const LPSPI5_BASE = 0x400B5000;
const LPSPI6_BASE = 0x400B6000;
const LPSPI7_BASE = 0x400B7000;

pub const Feature = enum(u16) {
    STANDARD = 4,
};

pub const Verid = bitpack struct(u32) {
    feature: Feature = .STANDARD,
    minor: u8,
    major: u8,
};

pub const Param = bitpack struct(u32) {
    txfifo: u8,
    rxfifo: u8,
    pcsnum: u8,
    reserved0: u8,
};

pub const Cr = bitpack struct(u32) {
    men: bool = false,
    rst: bool = false,
    reserved0: u1 = 0,
    dbgen: bool = false,
    reserved1: u4 = 0,
    rtf: bool = false,
    rrf: bool = false,
    reserved2: u22 = 0,
};

pub const Sr = bitpack struct(u32) {
    tdf: bool = true,
    rdf: bool = false,
    reserved0: u6 = 0,
    wcf: bool = false,
    fcf: bool = false,
    tcf: bool = false,
    tef: bool = false,
    ref: bool = false,
    dmf: bool = false,
    reserved1: u10 = 0,
    mbf: bool = false,
    reserved2: u7 = 0,
};

pub const Ier = bitpack struct(u32) {
    tdie: bool = false,
    rdie: bool = false,
    reserved0: u6 = 0,
    wcie: bool = false,
    fcie: bool = false,
    tcie: bool = false,
    teie: bool = false,
    reie: bool = false,
    dmie: bool = false,
    reserved1: u18 = 0,
};

pub const Der = bitpack struct(u32) {
    tdde: bool = false,
    rdde: bool = false,
    reserved0: u7 = 0,
    fcde: bool = false,
    reserved1: u22 = 0,
};

pub const Cfgr0 = bitpack struct(u32) {
    hren: bool = false,
    hrpol: bool = false,
    hrsel: bool = false,
    hrdir: bool = false,
    reserved0: u4 = 0,
    cirfifo: bool = false,
    rdmo: bool = false,
    reserved1: u22 = 0,
};

pub const Pcspol = enum(u4) {
    DISCARDED = 0,
    STORED = 1,
};

pub const Matcfg = enum(u3) {
    DISABLED = 0,
    ENABLED_FIRSTDATAMATCH = 2,
    ENABLED_ANYDATAMATCH = 3,
    ENABLED_DATAMATCH_100 = 4,
    ENABLED_DATAMATCH_101 = 5,
    ENABLED_DATAMATCH_110 = 6,
    ENABLED_DATAMATCH_111 = 7,
};

pub const Pincfg = enum(u2) {
    SIN_IN_SOUT_OUT = 0,
    SIN_BOTH_IN_OUT = 1,
    SOUT_BOTH_IN_OUT = 2,
    SOUT_IN_SIN_OUT = 3,
};

pub const Cfgr1 = bitpack struct(u32) {
    master: bool = false,
    sample: bool = false,
    autopcs: bool = false,
    nostall: bool = false,
    partial: bool = false,
    reserved0: u3 = 0,
    pcspol: Pcspol = .DISCARDED,
    reserved1: u4 = 0,
    matcfg: Matcfg = .DISABLED,
    reserved2: u5 = 0,
    pincfg: Pincfg = .SIN_IN_SOUT_OUT,
    outcfg: bool = false,
    pcscfg: bool = false,
    reserved3: u4 = 0,
};

pub const Dmr0 = bitpack struct(u32) {
    match0: u32 = 0,
};

pub const Dmr1 = bitpack struct(u32) {
    match1: u32 = 0,
};

pub const Ccr = bitpack struct(u32) {
    sckdiv: u8 = 0,
    dbt: u8 = 0,
    pcssck: u8 = 0,
    sckpcs: u8 = 0,
};

pub const Ccr1 = bitpack struct(u32) {
    sckset: u8 = 0,
    sckhld: u8 = 0,
    pcspcs: u8 = 0,
    scksck: u8 = 0,
};

pub const Fcr = bitpack struct(u32) {
    txwater: u3 = 0,
    reserved0: u13 = 0,
    rxwater: u3 = 0,
    reserved1: u13 = 0,
};

pub const Fsr = bitpack struct(u32) {
    txcount: u4,
    reserved0: u12,
    rxcount: u4,
    reserved1: u12,
};

pub const Width = enum(u2) {
    ONEBIT = 0,
    TWOBIT = 1,
    FOURBIT = 2,
};

pub const Pcs = enum(u2) {
    TX_PCS0 = 0,
    TX_PCS1 = 1,
    TX_PCS2 = 2,
    TX_PCS3 = 3,
};

pub const Prescale = enum(u3) {
    DIVIDEBY1 = 0,
    DIVIDEBY2 = 1,
    DIVIDEBY4 = 2,
    DIVIDEBY8 = 3,
    DIVIDEBY16 = 4,
    DIVIDEBY32 = 5,
    DIVIDEBY64 = 6,
    DIVIDEBY128 = 7,
};

pub const Tcr = bitpack struct(u32) {
    framesz: u12 = 31,
    reserved0: u4 = 0,
    width: Width = .ONEBIT,
    txmsk: bool = false,
    rxmsk: bool = false,
    contc: bool = false,
    cont: bool = false,
    bysw: bool = false,
    lsbf: bool = false,
    pcs: Pcs = .TX_PCS0,
    reserved1: u1 = 0,
    prescale: Prescale = .DIVIDEBY1,
    cpha: bool = false,
    cpol: bool = false,
};

pub const Tdr = bitpack struct(u32) {
    data: u32 = 0,
};

pub const Rsr = bitpack struct(u32) {
    sof: bool,
    rxempty: bool,
    reserved0: u30,
};

pub const Rdr = bitpack struct(u32) {
    data: u32,
};

pub const Rdror = bitpack struct(u32) {
    data: u32,
};

pub const Tcbr = bitpack struct(u32) {
    data: u32 = 0,
};

pub const Tdbr[%s] = bitpack struct(u32) {
    data: u32 = 0,
};

pub const Rdbr[%s] = bitpack struct(u32) {
    data: u32,
};

pub const LPSPI0 = extern struct {
    verid: Verid,
    param: Param,
    reserved0: [8]u8,
    cr: Cr,
    sr: Sr,
    ier: Ier,
    der: Der,
    cfgr0: Cfgr0,
    cfgr1: Cfgr1,
    reserved1: [8]u8,
    dmr0: Dmr0,
    dmr1: Dmr1,
    reserved2: [8]u8,
    ccr: Ccr,
    ccr1: Ccr1,
    reserved3: [16]u8,
    fcr: Fcr,
    fsr: Fsr,
    tcr: Tcr,
    tdr: Tdr,
    reserved4: [8]u8,
    rsr: Rsr,
    rdr: Rdr,
    rdror: Rdror,
    reserved5: [896]u8,
    tcbr: Tcbr,
    tdbr[%s]: Tdbr[%s],
    reserved6: [508]u8,
    rdbr[%s]: Rdbr[%s],
};

pub const lpspi0: *volatile LPSPI0 = @ptrFromInt(LPSPI0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x800, @sizeOf(LPSPI0));

}
