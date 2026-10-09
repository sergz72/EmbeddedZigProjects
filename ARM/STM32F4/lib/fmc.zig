const FMC_BASE: usize = 0xA0000000;

pub const FmcBcr = packed struct(u32) {
    mbken: bool = false,
    muxen: bool = true,
    mtyp: u2 = 0,
    mwid: u2 = 0,
    faccen: bool = false,
    reserved: u1 = 0,
    bursten: bool = false,
    waitpol: bool = false,
    wrapmod: bool = false,
    waitcfg: bool = false,
    wren: bool = false,
    waiten: bool = false,
    extmod: bool = false,
    asyncwait: bool = false,
    cpsize: u3 = 0,
    cburstrw: bool = false,
    reserved2: u12 = 0
};

pub const FmcBtr = packed struct(u32) {
    addset: u4 = 0x0F,
    addhld: u4 = 0x0F,
    datast: u8 = 0xFF,
    burstrun: u4 = 0x0F,
    ckdiv: u4 = 0x0F,
    datlat: u4 = 0x0F,
    accmod: u2 = 0,
    reserved: u2 = 0
};

pub const FmcBwtrr = packed struct(u32) {
    addset: u4 = 0x0F,
    addhld: u4 = 0x0F,
    datast: u8 = 0xFF,
    burstrun: u4 = 0x0F,
    reserved: u8 = 0xFF,
    accmod: u2 = 0,
    reserved2: u2 = 0
};

pub const FmcBtcr = extern struct {
    bcr: FmcBcr,
    btr: FmcBtr
};

pub const FmcPcrPcr = packed struct(u32) {
    reserved: u1 = 0,
    pwaiten: bool = false,
    pbken: bool = false,
    ptyp: bool = true,
    pwid: u2 = 1,
    eccen: bool = false,
    reserved2: u2 = 0,
    tclr: u4 = 0,
    tar: u4 = 0,
    eccps: u3 = 0,
    reserved3: u12 = 0
};

pub const FmcPcrSr = packed struct(u32) {
    irs: bool = false,
    ils: bool = false,
    ifs: bool = false,
    iren: bool = false,
    ilen: bool = false,
    ifen: bool = false,
    fempt: bool = true,
    reserved: u25 = 0
};

pub const FmcPcrP = packed struct(u32) {
    set: u8 = 0xFC,
    wait: u8 = 0xFC,
    hold: u8 = 0xFC,
    hiz: u8 = 0xFC
};

pub const FmcPcr2 = extern struct {
    pcr: FmcPcrPcr,
    sr: FmcPcrSr,
    pmem: FmcPcrP,
    reserved: u32,
    pio: u32,
    eccr: u32,
    reserved2: [2]u32
};

pub const FmcPcr3 = extern struct {
    pcr: FmcPcrPcr,
    sr: FmcPcrSr,
    pmem: FmcPcrP,
    patt: FmcPcrP,
    reserved: u32,
    eccr: u32,
    reserved2: [2]u32
};

pub const FmcPcr4 = extern struct {
    pcr: FmcPcrPcr,
    sr: FmcPcrSr,
    pmem: FmcPcrP,
    patt: FmcPcrP,
    pio: FmcPcrP,
    reserved2: [3]u32
};

pub const FmcBwtr = extern struct {
    bwtr: FmcBwtrr,
    reserved: u32
};

pub const FmcSdcr = packed struct(u32) {
    nc: u2 = 0,
    nr: u2 = 0,
    mwid: u2 = 3,
    nb: bool = false,
    cas: u2 = 1,
    wp: bool = false,
    sdclk: u2 = 1,
    rburst: bool = false,
    rpipe: u2 = 0,
    reserved: u17 = 0
};

pub const FmcSdtr = packed struct(u32) {
    tmrd: u4 = 0x0F,
    txsr: u4 = 0x0F,
    tras: u4 = 0x0F,
    trc: u4 = 0x0F,
    twr: u4 = 0x0F,
    trp: u4 = 0x0F,
    trcd: u4 = 0x0F,
    reserved: u4 = 0
};

pub const FmcSdcmr = packed struct(u32) {
    mode: u3 = 0,
    ctb2: bool = false,
    ctb1: bool = false,
    nrfs: u4 = 0,
    mrd: u13 = 0,
    reserved: u10 = 0
};

pub const FmcSdrtr = packed struct(u32) {
    cre: bool = false,
    count: u13 = 0,
    reie: bool = false,
    reserved: u17 = 0
};

pub const FmcSdsr = packed struct(u32) {
    re: bool,
    modes1: u2,
    modes2: u2,
    busy: bool,
    reserved: u26
};

pub const Fmc = extern struct {
    btcr: [4]FmcBtcr,
    reserved: [16]u32,
    //0x60
    pcr2: FmcPcr2,
    pcr3: FmcPcr3,
    pcr4: FmcPcr4,
    reserved2: [17]u32,
    //0x104
    bwtr: [4]FmcBwtr,
    reserved3: [7]u32,
    //0x140
    sdcr1: FmcSdcr,
    sdcr2: FmcSdcr,
    sdtr1: FmcSdtr,
    sdtr2: FmcSdtr,
    sdcmr: FmcSdcmr,
    sdrtr: FmcSdrtr,
    sdsr: FmcSdsr
};

pub const fmc: *volatile Fmc = @ptrFromInt(FMC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x15C, @sizeOf(Fmc));
}
