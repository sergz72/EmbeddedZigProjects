const RCC_BASE = 0x40021000;

pub const RccCtlr = bitpack struct(u32) {
    hsion: bool = true,
    hsirdy: bool = true,
    reserved0: u1 = 0,
    hsitrim: u5 = 16,
    reserved1: u8 = 0,
    hseon: bool = false,
    hserdy: bool = false,
    hsebyp: bool = false,
    csson: bool = false,
    usbhs_pllon: bool = false,
    usbhs_pllrdy: bool = false,
    usbss_pllon: bool = false,
    usbss_pllrdy: bool = false,
    pllon: bool = false,
    pllrdy: bool = false,
    eth_pllon: bool = false,
    eth_pllrdy: bool = false,
    serdes_pllon: bool = false,
    serdes_pllrdy: bool = false,
    reserved2: u1 = 0,
    css_hse_dis: bool = false,
};

pub const RccCfgr0Sw = enum(u2) {
    hsi = 0,
    hse = 1,
    pll = 2
};

pub const RccCfgrHpre = enum(u4) {
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

pub const RccCfgrMco = enum(u4) {
    off = 0,
    sysclk = 4,
    hsi = 5,
    hse = 6,
    plldiv2 = 7,
    utmi = 8,
    usbss_plldiv2 = 9,
    eth_pll = 10,
    serdes_pll = 11
};

pub const RccCfgr0 = bitpack struct(u32) {
    sw: RccCfgr0Sw = .hsi,
    sws: RccCfgr0Sw = .hsi,
    hpre: RccCfgrHpre = .off,
    ppre1: RccCfgrPpre = .off,
    ppre2: RccCfgrPpre = .off,
    adcpre: u2 = 0,
    fpre: bool = false,
    pllxtpre: bool = false,
    reserved0: u3 = 0,
    rgmiion: bool = false,
    pipeon: bool = false,
    utmion: bool = false,
    mco: RccCfgrMco = .off,
    reserved1: u2 = 0,
    adc_duty_sel: bool = false,
    adcsrc: bool = false,
};

pub const RccSyspllSel = enum(u3) {
    pll_clk = 0,
    usbhs_pll = 4,
    eth_pll = 5,
    serdes_pll_div2 = 6,
    usbs_pll = 7
};

pub const RccPllSrc = enum(u3) {
    hsi = 0,
    hse = 1,
    usbhs_pll = 4,
    eth_pll = 5,
    usbss_pll = 6,
    serdes_pll_div2 = 7
};
    
pub const RccPllcfgr = bitpack struct(u32) {
    pllmul: u5 = 4,
    pllsrc: RccPllSrc = .hsi,
    pll_src_div: u6 = 0,
    reserved0: u14 = 0,
    syspll_sel: RccSyspllSel = .pll_clk,
    syspll_gate: bool = false,
};

pub const RccIntr = bitpack struct(u32) {
    lsirdyf: bool = false,
    lserdyf: bool = false,
    hsirdyf: bool = false,
    hserdyf: bool = false,
    pllrdyf: bool = false,
    ethpllrdyf: bool = false,
    serdespllrdyf: bool = false,
    cssf: bool = false,
    lsirdyie: bool = false,
    lserdyie: bool = false,
    hsirdyie: bool = false,
    hserdyie: bool = false,
    pllrdyie: bool = false,
    ethpllrdyie: bool = false,
    serdespllrdyie: bool = false,
    reserved0: u1 = 0,
    lsirdyc: bool = false,
    lserdyc: bool = false,
    hsirdyc: bool = false,
    hserdyc: bool = false,
    pllrdyc: bool = false,
    ethpllrdyc: bool = false,
    serdespllrdyc: bool = false,
    cssc: bool = false,
    reserved1: u8 = 0,
};

pub const RccHb2prstr = bitpack struct(u32) {
    afiorst: bool = false,
    hsadcrst: bool = false,
    ioparst: bool = false,
    iopbrst: bool = false,
    iopcrst: bool = false,
    iopdrst: bool = false,
    ioperst: bool = false,
    iopfrst: bool = false,
    reserved0: u1 = 0,
    adc1rst: bool = false,
    adc2rst: bool = false,
    tim1rst: bool = false,
    spi1rst: bool = false,
    tim8rst: bool = false,
    usart1rst: bool = false,
    i2c4rst: bool = false,
    sairst: bool = false,
    reserved1: u1 = 0,
    sdiorst: bool = false,
    tim9rst: bool = false,
    tim10rst: bool = false,
    tim11rst: bool = false,
    tim12rst: bool = false,
    opcmrst: bool = false,
    reserved2: u1 = 0,
    dfsdmrst: bool = false,
    ecdcrst: bool = false,
    gpharst: bool = false,
    reserved3: u2 = 0,
    ltdcrst: bool = false,
    i3crst: bool = false,
};

pub const RccHb1prstr = bitpack struct(u32) {
    tim2rst: bool = false,
    tim3rst: bool = false,
    tim4rst: bool = false,
    tim5rst: bool = false,
    tim6rst: bool = false,
    tim7rst: bool = false,
    usart6rst: bool = false,
    usart7rst: bool = false,
    usart8rst: bool = false,
    lptim1rst: bool = false,
    lptim2rst: bool = false,
    wwdgrst: bool = false,
    qspi1rst: bool = false,
    qspi2rst: bool = false,
    spi2rst: bool = false,
    spi3rst: bool = false,
    spi4rst: bool = false,
    usart2rst: bool = false,
    usart3rst: bool = false,
    usart4rst: bool = false,
    usart5rst: bool = false,
    i2c1rst: bool = false,
    i2c2rst: bool = false,
    reserved0: u1 = 0,
    can3rst: bool = false,
    can1rst: bool = false,
    can2rst: bool = false,
    bkprst: bool = false,
    pwrrst: bool = false,
    dacrst: bool = false,
    i2c3rst: bool = false,
    swpmirst: bool = false,
};

pub const RccHbpcenr = bitpack struct(u32) {
    dma1en: bool = false,
    dma2en: bool = false,
    reserved0: u4 = 0,
    crcen: bool = false,
    reserved1: u1 = 0,
    fmcen: bool = false,
    rngen: bool = false,
    sdmmcen: bool = false,
    usbhsen: bool = false,
    usbssen: bool = false,
    dvpen: bool = false,
    ethmacen: bool = false,
    reserved2: u2 = 0,
    otgfsen: bool = false,
    uhsifen: bool = false,
    usbpden: bool = false,
    serdesen: bool = false,
    reserved3: u1 = 0,
    poicen: bool = false,
    reserved4: u9 = 0,
};

pub const RccHb2pcenr = bitpack struct(u32) {
    afioen: bool = false,
    hsadcen: bool = false,
    iopaen: bool = false,
    iopben: bool = false,
    iopcen: bool = false,
    iopden: bool = false,
    iopeen: bool = false,
    iopfen: bool = false,
    reserved0: u1 = 0,
    adc1en: bool = false,
    adc2en: bool = false,
    tim1en: bool = false,
    spi1en: bool = false,
    tim8en: bool = false,
    usart1en: bool = false,
    i2c4en: bool = false,
    saien: bool = false,
    reserved1: u1 = 0,
    sdioen: bool = false,
    tim9en: bool = false,
    tim10en: bool = false,
    tim11en: bool = false,
    tim12en: bool = false,
    opcmen: bool = false,
    reserved2: u1 = 0,
    dfsdmen: bool = false,
    ecdcen: bool = false,
    gphaen: bool = false,
    reserved3: u2 = 0,
    ltdcen: bool = false,
    i3cen: bool = false,
};

pub const RccHb1pcenr = bitpack struct(u32) {
    tim2en: bool = false,
    tim3en: bool = false,
    tim4en: bool = false,
    tim5en: bool = false,
    tim6en: bool = false,
    tim7en: bool = false,
    usart6en: bool = false,
    usart7en: bool = false,
    usart8en: bool = false,
    lptim1en: bool = false,
    lptim2en: bool = false,
    wwdgen: bool = false,
    qspi1en: bool = false,
    qspi2en: bool = false,
    spi2en: bool = false,
    spi3en: bool = false,
    spi4en: bool = false,
    usart2en: bool = false,
    usart3en: bool = false,
    usart4en: bool = false,
    usart5en: bool = false,
    i2c1en: bool = false,
    i2c2en: bool = false,
    reserved0: u1 = 0,
    can3en: bool = false,
    can1en: bool = false,
    can2en: bool = false,
    bkpen: bool = false,
    pwren: bool = false,
    dacen: bool = false,
    i2c3en: bool = false,
    swpmien: bool = false,
};

pub const RccCfgrRtcsel = enum(u2) {
    off = 0,
    lse = 1,
    lsi = 2,
    hse = 3
};

pub const RccBdctlr = bitpack struct(u32) {
    lseon: bool = false,
    lserdy: bool = false,
    lsebyp: bool = false,
    cco: bool = false,
    asoe: bool = false,
    asos: bool = false,
    rtcsel: RccCfgrRtcsel = .off,
    rtcen: bool = false,
    rtccal: u7 = 0,
    bdrst: bool = false,
    reserved0: u15 = 0,
};

pub const RccRstsckr = bitpack struct(u32) {
    lsion: bool = false,
    lsirdy: bool = false,
    reserved0: u22 = 8,
    rmvf: bool = false,
    reserved1: u1 = 0,
    pinrstf: bool = false,
    porrstf: bool = true,
    sftrstf: bool = false,
    iwdgrstf: bool = false,
    wwdgrstf: bool = false,
    lkuprstf: bool = false,
};

pub const RccHbrstr = bitpack struct(u32) {
    dma1rst: bool = false,
    dma2rst: bool = false,
    reserved0: u6 = 0,
    fmcrst: bool = false,
    rngrst: bool = false,
    sdmmcrst: bool = false,
    usbhsrst: bool = false,
    usbssrst: bool = false,
    dvprst: bool = false,
    ethmacrst: bool = false,
    reserved1: u2 = 0,
    otgfsrst: bool = false,
    uhsifrst: bool = false,
    usbpdrst: bool = false,
    serdesrst: bool = false,
    reserved2: u1 = 0,
    poicrst: bool = false,
    reserved3: u9 = 0,
};

pub const RccCfgr2 = bitpack struct(u32) {
    uhsifdiv: u6 = 0,
    uhsifsrc: u2 = 0,
    ltdcdiv: u6 = 0,
    ltdcsrc: u2 = 0,
    usbfsdiv: u4 = 0,
    usbfssrc: bool = false,
    reserved0: u2 = 0,
    rngsrc: bool = false,
    i2s2src: bool = false,
    i2s3src: bool = false,
    reserved1: u2 = 0,
    hsadcsrc: u2 = 0,
    eth1gsrc: u2 = 0,
};

pub const RccUsbssPllRefsel = enum(u3) {
    _20Mhz = 0,
    _24Mhz = 1,
    _25Mhz = 2,
    _30Mhz = 3,
    _32Mhz = 4,
    _40Mhz = 5,
    _60Mhz = 6,
    _80Mhz = 7
};

pub const RccUsbhsPllRefsel = enum(u2) {
    _25Mhz = 0,
    _20Mhz = 1,
    _24Mhz = 2,
    _32Mhz = 3
};

pub const RccUsbhsPllSrc = enum(u2) {
    hse = 0,
    his = 1,
    ethclk_20m = 2,
    sys_pll_clk = 3
};

pub const RccPllcfgr2 = bitpack struct(u32) {
    usbhspllsrc: RccUsbhsPllSrc = .hse,
    usbhspll_refsel: RccUsbhsPllRefsel = ._25Mhz,
    usbsspll_refsel: RccUsbssPllRefsel = ._25Mhz,
    reserved0: u1 = 0,
    usbhspll_in_div: u5 = 0,
    reserved1: u3 = 0,
    serdespll_mul: u4 = 8,
    reserved2: u12 = 0,
};

pub const Rcc = extern struct {
    ctlr: RccCtlr,
    cfgr0: RccCfgr0,
    pllcfgr: RccPllcfgr,
    intr: RccIntr,
    hb2prstr: RccHb2prstr,
    hb1prstr: RccHb1prstr,
    hbpcenr: RccHbpcenr,
    hb2pcenr: RccHb2pcenr,
    hb1pcenr: RccHb1pcenr,
    bdctlr: RccBdctlr,
    rstsckr: RccRstsckr,
    hbrstr: RccHbrstr,
    cfgr2: RccCfgr2,
    pllcfgr2: RccPllcfgr2,

    pub fn init(self: *volatile Rcc) void {
        self.cfgr0 = RccCfgr0{};
        while (self.cfgr0.sws != .hsi) {
            asm volatile("nop");
        }
        self.ctlr.pllon = false;
    }
};

pub const rcc: *volatile Rcc = @ptrFromInt(RCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x38, @sizeOf(Rcc));
}
