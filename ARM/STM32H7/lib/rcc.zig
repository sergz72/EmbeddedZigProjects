const RCC_BASE: usize = 0x58024400;

pub const RccHsiDiv = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3
};

pub const RccCr = packed struct(u32) {
    hsion: bool = true,
    hsikeron: bool = false,
    hsirdy: bool = false,
    hsidiv: RccHsiDiv = .div1,
    hsidivf: bool = false,
    reserved: u1 = 0,
    csion: bool = true,
    csirdy: bool = false,
    csikeron: bool = false,
    reserved2: u2 = 0,
    hsi48on: bool = true,
    hsi48rdy: bool = false,
    d1ckrdy: bool = false,
    d2ckrdy: bool = false,
    hseon: bool = false,
    hserdy: bool = false,
    hsebyp: bool = false,
    hsecsson: bool = false,
    reserved3: u4 = 0,
    pll1on: bool = false,
    pll1rdy: bool = false,
    pll2on: bool = false,
    pll2rdy: bool = false,
    pll3on: bool = false,
    pll3rdy: bool = false,
    reserved4: u2 = 0
};

pub const RccHsiCfgr = packed struct(u32) {
    cal: u12,
    reserved: u12 = 0,
    trim: u7 = 0x40,
    reserved2: u1 = 0
};

pub const RccCsiCfgr = packed struct(u32) {
    cal: u12,
    reserved: u12 = 0,
    trim: u6 = 0x20,
    reserved2: u2 = 0
};

pub const RccCfgrSw = enum(u3) {
    hsi = 0,
    csi = 1,
    hse = 2,
    pll1 = 3
};

pub const RccCfgrMco = enum(u4) {
    off = 0,
    sysclk = 4,
    hsi = 5,
    hse = 6,
    plldiv2 = 7,
    pll2 = 8,
    pll3div2 = 9,
    xt1 = 10,
    pll3 = 11
};

pub const RccCfgrMco1Sel = enum(u3) {
    hsi = 0,
    csi = 1,
    hse = 2,
    pll1 = 3,
    hsi48 = 4
};

pub const RccCfgrMco2Sel = enum(u3) {
    sysck = 0,
    pll2 = 1,
    hse = 2,
    pll1 = 3,
    csi = 4,
    lsi = 5
};

pub const RccCfgr = packed struct(u32) {
    sw: RccCfgrSw = RccCfgrSw.hsi,
    sws: RccCfgrSw = RccCfgrSw.hsi,
    stopwuck: bool = false,
    stopkerwuck: bool = false,
    rtcpre: u6 = 0,
    hrtimsel: bool = false,
    tmpre: bool = false,
    reserved: u2 = 0,
    mco1pre: u4 = 0,
    mco1sel: RccCfgrMco1Sel = RccCfgrMco1Sel.hsi,
    mco2pre: u4 = 0,
    mco2sel: RccCfgrMco2Sel = RccCfgrMco2Sel.sysck
};

pub const RccD1CfgrPre = enum(u4) {
    off = 0,
    div2 = 8,
    div4 = 9,
    div8 = 10,
    div16 = 11,
    div64 = 12,
    div128 = 13,
    div256 = 14,
    div512 = 15
};

pub const RccCfgrPpre = enum(u3) {
    off = 0,
    div2 = 4,
    div4 = 5,
    div8 = 6,
    div16 = 7
};

pub const RccD1Cfgr = packed struct(u32) {
    hpre: RccD1CfgrPre = .off,
    d1ppre: RccCfgrPpre = .off,
    reserved: u1 = 0,
    d1cppre: RccD1CfgrPre = .off,
    reserved2: u20 = 0
};

pub const RccD2Cfgr = packed struct(u32) {
    reserved: u4 = 0,
    d2ppre1: RccCfgrPpre = .off,
    reserved2: u1 = 0,
    d2ppre2: RccCfgrPpre = .off,
    reserved3: u21 = 0
};

pub const RccD3Cfgr = packed struct(u32) {
    reserved: u4 = 0,
    d23ppre: RccCfgrPpre = .off,
    reserved3: u25 = 0
};

pub const RccPllSrc = enum(u2) {
    hsi = 0,
    csi = 1,
    hse = 2,
    off = 3
};

pub const RccPllCkSelr = packed struct(u32) {
    pllsrc: RccPllSrc = .hsi,
    reserved: u2 = 0,
    divm: u6 = 0x20,
    reserved2: u2 = 0,
    divm2: u6 = 0x20,
    reserved3: u2 = 0,
    divm3: u6 = 0x20,
    reserved4: u6 = 0
};

pub const RccPllRge = enum(u2) {
    _1to2 = 0,
    _2to4 = 1,
    _4to8 = 2,
    _8to16 = 3
};

pub const RccPllCfg = packed struct(u4) {
    fracen: bool = false,
    vcosel: bool = false,
    rge: RccPllRge = ._1to2
};

pub const RccPllOutCfg = packed struct(u3) {
    divpen: bool = true,
    divqen: bool = true,
    divren: bool = true
};

pub const RccPllCfgr = packed struct(u32) {
    pll1: RccPllCfg = .{},
    pll2: RccPllCfg = .{},
    pll3: RccPllCfg = .{},
    reserved: u4 = 0,
    pll1out: RccPllOutCfg = .{},
    pll2out: RccPllOutCfg = .{},
    pll3out: RccPllOutCfg = .{},
    reserved2: u7 = 0
};

pub const RccPllDivr = packed struct(u32) {
    divn: u9 = 0x80,
    divp: u7 = 1,
    divq: u7 = 1,
    reserved: u1 = 0,
    divr: u7 = 1,
    reserved2: u1 = 0
};

pub const RccPllFracr = packed struct(u32) {
    reserved: u3 = 0,
    fracn: u13 = 0,
    reserved2: u16 = 0
};

pub const RccPllDiv = extern struct {
    divr: RccPllDivr,
    fracr: RccPllFracr
};

pub const RccD1Ccipr = packed struct(u32) {
    fmcsel: u2 = 0,
    reserved: u2 = 0,
    qspisel: u2 = 0,
    reserved2: u2 = 0,
    dsisel: bool = false,
    reserved3: u7 = 0,
    sdmmcsel: bool = false,
    reserved4: u11 = 0,
    ckpersel: u2 = 0,
    reserved5: u2 = 0
};

pub const RccAhb3 = packed struct(u32) {
    mdma: bool = false,
    reserved: u3 = 0,
    dma2: bool = false,
    jpgdec: bool = false,
    reserved2: u2 = 0,
    flitf: bool = false,
    reserved3: u3 = 0,
    fcm: bool = false,
    reserved4: u1 = 0,
    qspi: bool = false,
    reserved5: u1 = 0,
    sdmmc1: bool = false,
    reserved6: u11 = 0,
    dtcm1: bool = false,
    dtcm2: bool = false,
    itcm: bool = false,
    axisram: bool = false
};

pub const RccAhb1 = packed struct(u32) {
    dma1: bool = false,
    dma2: bool = false,
    reserved: u3 = 0,
    adc12: bool = false,
    reserved2: u8 = 0,
    art: bool = false,
    eth1mac: bool = false,
    eth1tx: bool = false,
    eth1rx: bool = false,
    reserved3: u7 = 0,
    usb1otghs: bool = false,
    usb1otghsulpi: bool = false,
    usb2otghs: bool = false,
    usb2otghsulpi: bool = false,
    reserved4: u3 = 0
};

pub const RccAhb2 = packed struct(u32) {
    dcim: bool = false,
    reserved: u3 = 0,
    crypt: bool = false,
    hash: bool = false,
    rng: bool = false,
    reserved2: u2 = 0,
    sdmmc2: bool = false,
    reserved3: u19 = 0,
    sram1: bool = false,
    sram2: bool = false,
    sram3: bool = false
};

pub const RccAhb4 = packed struct(u32) {
    gpioa: bool = false,
    gpiob: bool = false,
    gpioc: bool = false,
    gpiod: bool = false,
    gpioe: bool = false,
    gpiof: bool = false,
    gpiog: bool = false,
    gpioh: bool = false,
    gpioi: bool = false,
    gpioj: bool = false,
    gpiok: bool = false,
    reserved: u8 = 0,
    crc: bool = false,
    reserved2: u1 = 0,
    bdma: bool = false,
    reserved3: u2 = 0,
    adc3: bool = false,
    hsem: bool = false,
    reserved4: u2 = 0,
    bkpram: bool = false,
    reserved5: u3 = 0
};

pub const RccBus = extern struct {
    ahb3: RccAhb3,
    ahb1: RccAhb1,
    ahb2: RccAhb2,
    ahb4: RccAhb4,
    apb3: u32,
    apb1l: u32,
    apb1h: u32,
    apb2: u32,
    apb4: u32
};

pub const RccEnr = extern struct {
    rsr: u32,
    hp: RccBus,
    reserved: u32,
    lp: RccBus,
    reserved2: [4]u32
};

pub const Rcc = extern struct {
    cr: RccCr,
    hsicfgr: RccHsiCfgr,
    crrcr: u32,
    csicfgr: RccCsiCfgr,
    cfgr: RccCfgr,
    reserved: u32,
    d1cfgr: RccD1Cfgr,
    d2cfgr: RccD2Cfgr,
    d3cfgr: RccD3Cfgr,
    reserved2: u32,
    pllckselr: RccPllCkSelr,
    pllcfgr: RccPllCfgr,
    plldiv: [3]RccPllDiv,
    reserved3: u32,
    d1ccipr: RccD1Ccipr,
    d2ccip1r: u32,
    d2ccip2r: u32,
    d3ccipr: u32,
    reserved4: u32,
    cier: u32,
    cifr: u32,
    cicr: u32,
    reserved5: u32,
    bdcr: u32,
    csr: u32,
    reserved6: u32,
    rstr: RccBus,
    gcr: u32,
    reserved7: u32,
    d3amr: u32,
    reserved8: [9]u32,
    enr: [3]RccEnr
};

pub const rcc: *volatile Rcc = @ptrFromInt(RCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1F0, @sizeOf(Rcc));
}
