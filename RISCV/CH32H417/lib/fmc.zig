const FMC_BASE = 0x40025400;

pub const FmcBcr1 = bitpack struct(u32) {
    mbken: bool = false,
    muxen: bool = true,
    mtyp: u2 = 0,
    mwid: u2 = 1,
    faccen: bool = true,
    reserved0: u1 = 0,
    bursten: bool = false,
    waitpol: bool = false,
    reserved1: u1 = 0,
    waitcfg: bool = false,
    wren: bool = true,
    waiten: bool = true,
    extmod: bool = false,
    asyncwait: bool = false,
    cpsize: u3 = 0,
    cburstrw: bool = false,
    reserved2: u4 = 0,
    bmp: u2 = 0,
    reserved3: u5 = 0,
    fmc_en: bool = false,
};

pub const FmcBtr1 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    clkdiv: u4 = 15,
    datlat: u4 = 15,
    accmod: u2 = 0,
    reserved0: u2 = 0,
};

pub const FmcBcr2 = bitpack struct(u32) {
    mbken: bool = false,
    muxen: bool = true,
    mtyp: u2 = 0,
    mwid: u2 = 1,
    faccen: bool = true,
    reserved0: u1 = 0,
    bursten: bool = false,
    waitpol: bool = false,
    reserved1: u1 = 0,
    waitcfg: bool = false,
    wren: bool = true,
    waiten: bool = true,
    extmod: bool = false,
    asyncwait: bool = false,
    cpsize: u3 = 0,
    cburstrw: bool = false,
    reserved2: u4 = 0,
    bmp: u2 = 0,
    reserved3: u5 = 0,
    fmc_en: bool = false,
};

pub const FmcBtr2 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    clkdiv: u4 = 15,
    datlat: u4 = 15,
    accmod: u2 = 0,
    reserved0: u2 = 0,
};

pub const FmcBcr3 = bitpack struct(u32) {
    mbken: bool = false,
    muxen: bool = true,
    mtyp: u2 = 0,
    mwid: u2 = 1,
    faccen: bool = true,
    reserved0: u1 = 0,
    bursten: bool = false,
    waitpol: bool = false,
    reserved1: u1 = 0,
    waitcfg: bool = false,
    wren: bool = true,
    waiten: bool = true,
    extmod: bool = false,
    asyncwait: bool = false,
    cpsize: u3 = 0,
    cburstrw: bool = false,
    reserved2: u4 = 0,
    bmp: u2 = 0,
    reserved3: u5 = 0,
    fmc_en: bool = false,
};

pub const FmcBtr3 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    clkdiv: u4 = 15,
    datlat: u4 = 15,
    accmod: u2 = 0,
    reserved0: u2 = 0,
};

pub const FmcBcr4 = bitpack struct(u32) {
    mbken: bool = false,
    muxen: bool = true,
    mtyp: u2 = 0,
    mwid: u2 = 1,
    faccen: bool = true,
    reserved0: u1 = 0,
    bursten: bool = false,
    waitpol: bool = false,
    reserved1: u1 = 0,
    waitcfg: bool = false,
    wren: bool = true,
    waiten: bool = true,
    extmod: bool = false,
    asyncwait: bool = false,
    cpsize: u3 = 0,
    cburstrw: bool = false,
    reserved2: u4 = 0,
    bmp: u2 = 0,
    reserved3: u5 = 0,
    fmc_en: bool = false,
};

pub const FmcBtr4 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    clkdiv: u4 = 15,
    datlat: u4 = 15,
    accmod: u2 = 0,
    reserved0: u2 = 0,
};

pub const FmcPcr = bitpack struct(u32) {
    reserved0: u1 = 0,
    pwaiten: bool = false,
    pbken: bool = false,
    ptyp: bool = true,
    pwid: u2 = 1,
    eccen: bool = false,
    reserved1: u2 = 0,
    tclr: u4 = 0,
    tar: u4 = 0,
    eccps: u3 = 0,
    reserved2: u12 = 0,
};

pub const FmcSr = bitpack struct(u32) {
    irs: bool = false,
    ils: bool = false,
    ifs: bool = false,
    iren: bool = false,
    ilen: bool = false,
    ifen: bool = false,
    fempt: bool = true,
    reserved0: u25 = 0,
};

pub const FmcPmem = bitpack struct(u32) {
    memset: u8 = 252,
    memwait: u8 = 252,
    memhold: u8 = 252,
    memhiz: u8 = 252,
};

pub const FmcPatt = bitpack struct(u32) {
    attset: u8 = 252,
    attwait: u8 = 252,
    atthold: u8 = 252,
    atthiz: u8 = 252,
};

pub const FmcBwtr1 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    reserved0: u8 = 0,
    accmod: u2 = 0,
    reserved1: u2 = 0,
};

pub const FmcBwtr2 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    reserved0: u8 = 0,
    accmod: u2 = 0,
    reserved1: u2 = 0,
};

pub const FmcBwtr3 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    reserved0: u8 = 0,
    accmod: u2 = 0,
    reserved1: u2 = 0,
};

pub const FmcBwtr4 = bitpack struct(u32) {
    addset: u4 = 15,
    addhld: u4 = 15,
    datast: u8 = 255,
    busturn: u4 = 15,
    reserved0: u8 = 0,
    accmod: u2 = 0,
    reserved1: u2 = 0,
};

pub const FmcSdcr1 = bitpack struct(u32) {
    nc: u2 = 0,
    nr: u2 = 0,
    mwid: u2 = 1,
    nb: bool = true,
    cas: u2 = 1,
    wp: bool = true,
    sdclk: u2 = 0,
    rburst: bool = false,
    rpipe: u2 = 0,
    reserved0: u17 = 0,
};

pub const FmcSdcr2 = bitpack struct(u32) {
    nc: u2 = 0,
    nr: u2 = 0,
    mwid: u2 = 1,
    nb: bool = true,
    cas: u2 = 1,
    wp: bool = true,
    sdclk: u2 = 0,
    rburst: bool = false,
    rpipe: u2 = 0,
    reserved0: u17 = 0,
};

pub const FmcSdtr1 = bitpack struct(u32) {
    tmrd: u4 = 15,
    txsr: u4 = 15,
    tras: u4 = 15,
    trc: u4 = 15,
    twr: u4 = 15,
    trp: u4 = 15,
    trcd: u4 = 15,
    reserved0: u4 = 0,
};

pub const FmcSdtr2 = bitpack struct(u32) {
    tmrd: u4 = 15,
    txsr: u4 = 15,
    tras: u4 = 15,
    trc: u4 = 15,
    twr: u4 = 15,
    trp: u4 = 15,
    trcd: u4 = 15,
    reserved0: u4 = 0,
};

pub const FmcSdcmr = bitpack struct(u32) {
    mode: u3 = 0,
    ctb2: bool = false,
    ctb1: bool = false,
    nrfs: u4 = 0,
    mrd: u14 = 0,
    reserved0: u9 = 0,
};

pub const FmcSdrtr = bitpack struct(u32) {
    cre: bool = false,
    count: u13 = 0,
    reie: bool = false,
    reserved0: u17 = 0,
};

pub const FmcSdsr = bitpack struct(u32) {
    re: bool,
    modes1: u2,
    modes2: u2,
    busy: bool,
    reserved0: u26,
};

pub const FmcMisc = bitpack struct(u32) {
    nrfs_cnt: u4 = 0,
    phase_sel: u4 = 0,
    reserved0: u7 = 0,
    enhance_read_mode: bool = false,
    en_bank1: bool = false,
    en_bank2: bool = false,
    reserved1: u14 = 0,
};

pub const Fmc = extern struct {
    bcr1: FmcBcr1,
    btr1: FmcBtr1,
    bcr2: FmcBcr2,
    btr2: FmcBtr2,
    bcr3: FmcBcr3,
    btr3: FmcBtr3,
    bcr4: FmcBcr4,
    btr4: FmcBtr4,
    reserved0: [24]u32,
    pcr: FmcPcr,
    sr: FmcSr,
    pmem: FmcPmem,
    patt: FmcPatt,
    reserved1: u32,
    eccr: u32,
    reserved2: [27]u32,
    bwtr1: FmcBwtr1,
    reserved3: u32,
    bwtr2: FmcBwtr2,
    reserved4: u32,
    bwtr3: FmcBwtr3,
    reserved5: u32,
    bwtr4: FmcBwtr4,
    reserved6: [8]u32,
    sdcr1: FmcSdcr1,
    sdcr2: FmcSdcr2,
    sdtr1: FmcSdtr1,
    sdtr2: FmcSdtr2,
    sdcmr: FmcSdcmr,
    sdrtr: FmcSdrtr,
    sdsr: FmcSdsr,
    reserved7: [9]u32,
    sdram_misc: FmcMisc,
};

pub const fmc: *volatile Fmc = @ptrFromInt(FMC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x184, @sizeOf(Fmc));
}
