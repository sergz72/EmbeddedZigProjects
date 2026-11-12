const pwr = @import("pwr");
const flash = @import("flash");
const icache = @import("icache");

const RCC_BASE = 0x44020C00;

const PLL_MEDIUM_MIN_FREQUENCY = 150000000;
const PLL_MEDIUM_MAX_FREQUENCY = 420000000;

pub const PllCharacteristics = struct {
    wide_min_frequency: usize,
    wide_max_frequency: usize
};

pub const PllCharacteristicsH503 = PllCharacteristics{
    .wide_min_frequency = 128000000,
    .wide_max_frequency = 560000000
};

pub const PllCharacteristicsH563 = PllCharacteristics{
    .wide_min_frequency = 192000000,
    .wide_max_frequency = 836000000
};

pub const RccHsiDiv = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3
};

pub const RccCr = bitpack struct(u32) {
    hsion: bool = true,
    hsirdy: bool = true,
    hsikeron: bool = false,
    hsidiv: RccHsiDiv = .div2,
    hsidivf: bool = true,
    _r0: u2 = 0,
    csion: bool = false,
    csirdy: bool = false,
    csikeron: bool = false,
    _r1: u1 = 0,
    hsi48on: bool = false,
    hsi48rdy: bool = false,
    _r2: u2 = 0,
    hseon: bool = false,
    hserdy: bool = false,
    hsebyp: bool = false,
    hsecsson: bool = false,
    hseext: bool = false,
    _r3: u3 = 0,
    pll1on: bool = false,
    pll1rdy: bool = false,
    pll2on: bool = false,
    pll2rdy: bool = false,
    pll3on: bool = false,
    pll3rdy: bool = false,
    _r4: u2 = 0
};

pub const RccHsicfgr = bitpack struct(u32) {
    hsical: u12,
    _r0: u4 = 0,
    hsitrim: u7 = 0x40,
    _r1: u9 = 0,
};

pub const RccCsicfgr = bitpack struct(u32) {
    csical: u10,
    _r0: u6 = 0,
    csitrim: u6 = 0x20,
    _r1: u10 = 0,
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

pub const RccCfgr1 = bitpack struct(u32) {
    sw: RccCfgrSw = .hsi,
    sws: RccCfgrSw = .hsi,
    stopwuck: bool = false,
    stopkerwuck: bool = false,
    rtcpre: u6 = 0,
    _r0: u1 = 0,
    timpre: bool = false,
    _r1: u2 = 0,
    mco1pre: u4 = 0,
    mco1sel: RccCfgrMco1Sel = .hsi,
    mco2pre: u4 = 0,
    mco2sel: RccCfgrMco2Sel = .sysck,
};

pub const RccCfgrPre = enum(u4) {
    off = 0,
    div2 = 8,
    div4 = 9,
    div8 = 10,
    div16 = 11,
    div64 = 12,
    div128 = 13,
    div256 = 14,
    div512 = 15,

    pub fn toInt(self: RccCfgrPre) usize {
        return switch (self) {
            .off => 1,
            .div2 => 2,
            .div4 => 4,
            .div8 => 8,
            .div16 => 16,
            .div64 => 64,
            .div128 => 128,
            .div256 => 256,
            .div512 => 512
        };
    }
};

pub const RccCfgrPpre = enum(u3) {
    off = 0,
    div2 = 4,
    div4 = 5,
    div8 = 6,
    div16 = 7,

    pub fn toInt(self: RccCfgrPpre) usize {
        return switch (self) {
            .off => 1,
            .div2 => 2,
            .div4 => 4,
            .div8 => 8,
            .div16 => 16,
        };
    }
};

pub const RccCfgr2 = bitpack struct(u32) {
    hpre: RccCfgrPre = .off,
    ppre1: RccCfgrPpre = .off,
    _r0: u1 = 0,
    ppre2: RccCfgrPpre = .off,
    _r1: u1 = 0,
    ppre3: RccCfgrPpre = .off,
    _r2: u1 = 0,
    ahb1dis: bool = false,
    ahb2dis: bool = false,
    _r3: u1 = 0,
    ahb4dis: bool = false,
    apb1dis: bool = false,
    apb2dis: bool = false,
    apb3dis: bool = false,
    _r4: u9 = 0
};

pub const RccPllSrc = enum(u2) {
    off = 0,
    hsi = 1,
    csi = 2,
    hse = 3
};

pub const RccPllRge = enum(u2) {
    _1to2 = 0,
    _2to4 = 1,
    _4to8 = 2,
    _8to16 = 3
};

pub const RccPllCfgr = bitpack struct(u32) {
    src: RccPllSrc = .off,
    rge: RccPllRge = ._1to2,
    fracen: bool = false,
    vcosel: bool = false,
    _r0: u2 = 0,
    m: u6 = 0,
    _r1: u2 = 0,
    pen: bool = false,
    qen: bool = false,
    ren: bool = false,
    _r2: u13 = 0
};

pub const RccPllDivr = bitpack struct(u32) {
    divn: u9 = 0x80,
    divp: u7 = 1,
    divq: u7 = 1,
    _r0: u1 = 0,
    divr: u7 = 1,
    _r1: u1 = 0,
};

pub const RccPllFracr = bitpack struct(u32) {
    reserved: u3 = 0,
    fracn: u13 = 0,
    reserved2: u16 = 0
};

pub const RccPllDiv = extern struct {
    divr: RccPllDivr,
    fracr: RccPllFracr,
};

pub const RccCier = bitpack struct(u32) {
    lsirdyie: bool = false,
    lserdyie: bool = false,
    csirdyie: bool = false,
    hsirdyie: bool = false,
    hserdyie: bool = false,
    hsi48rdyie: bool = false,
    pll1rdyie: bool = false,
    pll2rdyie: bool = false,
    pll3rdyie: bool = false,
    _r2: u23 = 0
};

pub const RccCi = bitpack struct(u32) {
    lsirdy: bool = false,
    lserdy: bool = false,
    csirdy: bool = false,
    hsirdy: bool = false,
    hserdy: bool = false,
    hsi48rdy: bool = false,
    pll1rdy: bool = false,
    pll2rdy: bool = false,
    pll3rdy: bool = false,
    reserved: u1 = 0,
    hsecss: bool = false,
    _r2: u21 = 0
};

pub const RccAhb1enr = bitpack struct(u32) {
    gpdma1en: bool = false,
    gpdma2en: bool = false,
    reserved0: u6 = 1,
    flitfen: bool = true,
    reserved1: u3 = 0,
    crcen: bool = false,
    reserved2: u1 = 0,
    cordicen: bool = false,
    fmacen: bool = false,
    reserved3: u1 = 0,
    ramcfgen: bool = false,
    reserved4: u1 = 0,
    ethen: bool = false,
    ethtxen: bool = false,
    ethrxen: bool = false,
    reserved5: u2 = 0,
    tzsc1en: bool = false,
    reserved6: u3 = 5,
    bkpramen: bool = true,
    reserved7: u1 = 1,
    dcacheen: bool = true,
    sram1en: bool = true,
};

pub const RccAhb2enr = bitpack struct(u32) {
    gpioaen: bool = false,
    gpioben: bool = false,
    gpiocen: bool = false,
    gpioden: bool = false,
    gpioeen: bool = false,
    gpiofen: bool = false,
    gpiogen: bool = false,
    gpiohen: bool = false,
    gpioien: bool = false,
    reserved0: u1 = 0,
    adc12en: bool = false,
    dac12en: bool = false,
    dcmi_pssien: bool = false,
    reserved1: u4 = 0,
    hashen: bool = false,
    rngen: bool = false,
    reserved2: u11 = 3,
    sram3en: bool = true,
    sram2en: bool = true,
};

pub const RccAhb4enr = bitpack struct(u32) {
    reserved0: u11 = 0,
    sdmmc1en: bool = false,
    sdmmc2en: bool = false,
    reserved1: u3 = 0,
    fmcen: bool = false,
    reserved2: u3 = 0,
    octospi1en: bool = false,
    reserved3: u11 = 0,
};

pub const RccApb1lenr = bitpack struct(u32) {
    tim2en: bool = false,
    tim3en: bool = false,
    tim4en: bool = false,
    tim5en: bool = false,
    tim6en: bool = false,
    tim7en: bool = false,
    tim12en: bool = false,
    tim13en: bool = false,
    tim14en: bool = false,
    reserved0: u2 = 0,
    wwdgen: bool = false,
    reserved1: u2 = 0,
    spi2en: bool = false,
    spi3en: bool = false,
    reserved2: u1 = 0,
    usart2en: bool = false,
    usart3en: bool = false,
    uart4en: bool = false,
    uart5en: bool = false,
    i2c1en: bool = false,
    i2c2en: bool = false,
    i3c1en: bool = false,
    crsen: bool = false,
    usart6en: bool = false,
    usart10en: bool = false,
    usart11en: bool = false,
    cecen: bool = false,
    reserved3: u1 = 0,
    uart7en: bool = false,
    uart8en: bool = false,
};

pub const RccApb1henr = bitpack struct(u32) {
    uart9en: bool = false,
    uart12en: bool = false,
    reserved0: u1 = 0,
    dtsen: bool = false,
    reserved1: u1 = 0,
    lptim2en: bool = false,
    reserved2: u3 = 0,
    fdcan12en: bool = false,
    reserved3: u13 = 0,
    ucpden: bool = false,
    reserved4: u8 = 0,
};

pub const RccApb2enr = bitpack struct(u32) {
    reserved0: u11 = 0,
    tim1en: bool = false,
    spi1en: bool = false,
    tim8en: bool = false,
    usart1en: bool = false,
    reserved1: u1 = 0,
    tim15en: bool = false,
    tim16en: bool = false,
    tim17en: bool = false,
    spi4en: bool = false,
    spi6en: bool = false,
    sai1en: bool = false,
    sai2en: bool = false,
    reserved2: u1 = 0,
    usbfsen: bool = false,
    reserved3: u7 = 0,
};

pub const RccApb3enr = bitpack struct(u32) {
    reserved0: u1 = 0,
    sbsen: bool = false,
    reserved1: u3 = 0,
    spi5en: bool = false,
    lpuart1en: bool = false,
    i2c3en: bool = false,
    i2c4en: bool = false,
    reserved2: u2 = 0,
    lptim1en: bool = false,
    lptim3en: bool = false,
    lptim4en: bool = false,
    lptim5en: bool = false,
    lptim6en: bool = false,
    reserved3: u4 = 0,
    vrefen: bool = false,
    rtcapben: bool = false,
    reserved4: u10 = 0,
};

pub const RccEnr = extern struct{
    ahb1: RccAhb1enr,
    ahb2: RccAhb2enr,
    reserved11: u32,
    ahb4: RccAhb4enr,
    reserved13: u32,
    apb1l: RccApb1lenr,
    apb1h: RccApb1henr,
    apb2: RccApb2enr,
    apb3: RccApb3enr,
    reserved14: u32,
};

pub const RccBdcr = bitpack struct(u32) {
    lseon: bool = false,
    lserdy: bool = false,
    lsebyp: bool = false,
    lsedrv: u2 = 0,
    lsecsson: bool = false,
    lsecssd: bool = false,
    lseext: bool = false,
    rtcsel: u2 = 0,
    _r0: u5 = 0,
    rtcen: bool = false,
    vswrst: bool = false,
    _r1: u7 = 0,
    lscoen: bool = false,
    lscosel: bool = false,
    lsion: bool = false,
    lsirdy: bool = false,
    _r2: u4 = 0,
};

pub const RccRsr = bitpack struct(u32) {
    _r0: u23 = 0,
    rmvf: bool = false,
    _r1: u2 = 0,
    pinrstf: bool = true,
    borrstf: bool = true,
    sftrstf: bool = false,
    iwdgrstf: bool = false,
    wwdgrstf: bool = false,
    lpwrrstf: bool = false
};

pub const RccSeccfgr = bitpack struct(u32) {
    hsisec: bool = false,
    hsesec: bool = false,
    csisec: bool = false,
    lsisec: bool = false,
    lsesec: bool = false,
    sysclksec: bool = false,
    prescsec: bool = false,
    pll1sec: bool = false,
    pll2sec: bool = false,
    pll3sec: bool = false,
    reserved: u1 = 0,
    hsi48sec: bool = false,
    rmvfsec: bool = false,
    ckperselsec: bool = false,
    _r0: u18 = 0,
};

pub const RccPrivcfgr = bitpack struct(u32) {
    spriv: bool = false,
    nspriv: bool = false,
    _r0: u30 = 0,
};

pub const RccAhb1Rstr = bitpack struct(u32) {
    gpdma1rst: bool = false,
    gpdma2rst: bool = false,
    reserved1: u10 = 0,
    crcrst: bool = false,
    reserved2: u1 = 0,
    cordicrst: bool = false,
    fmacrst: bool = false,
    reserved3: u1 = 0,
    ramcfgrst: bool = false,
    reserved4: u1 = 0,
    ethrst: bool = false,
    reserved5: u12 = 0
};

pub const RccAhb2Rstr = bitpack struct(u32) {
    gpioarst: bool = false,
    gpiobrst: bool = false,
    gpiocrst: bool = false,
    gpiodrst: bool = false,
    gpioerst: bool = false,
    gpiofrst: bool = false,
    gpiogrst: bool = false,
    gpiohrst: bool = false,
    gpioirst: bool = false,
    reserved4: u1 = 0,
    adcrst: bool = false,
    dac1rst: bool = false,
    dcmi_pssirst: bool = false,
    reserved6: u3 = 0,
    aesrst: bool = false,
    hashrst: bool = false,
    rngrst: bool = false,
    pkarst: bool = false,
    saesrst: bool = false,
    reserved7: u11 = 0
};

pub const RccAhb4Rstr = bitpack struct(u32) {
    reserved0: u7 = 0,
    otfdec1rst: bool = false,
    reserved4: u3 = 0,
    sdmmc1rst: bool = false,
    sdmmc2rst: bool = false,
    reserved1: u3 = 0,
    fmcrst: bool = false,
    reserved2: u3 = 0,
    octospi1rst: bool = false,
    reserved3: u11 = 0
};

pub const RccApb1lRstr = bitpack struct(u32) {
    tim2rst: bool = false,
    tim3rst: bool = false,
    tim4rst: bool = false,
    tim5rst: bool = false,
    tim6rst: bool = false,
    tim7rst: bool = false,
    tim12rst: bool = false,
    tim13rst: bool = false,
    tim14rst: bool = false,
    reserved4: u5 = 0,
    spi2rst: bool = false,
    spi3rst: bool = false,
    reserved5: u1 = 0,
    usart2rst: bool = false,
    usart3rst: bool = false,
    uart4rst: bool = false,
    uart5rst: bool = false,
    i2c1rst: bool = false,
    i2c2rst: bool = false,
    i3c1rst: bool = false,
    crsrst: bool = false,
    usart6rst: bool = false,
    usart10rst: bool = false,
    usart11rst: bool = false,
    cecrst: bool = false,
    reserved11: u1 = 0,
    uart7rst: bool = false,
    uart8rst: bool = false
};

pub const RccApb1hRstr = bitpack struct(u32) {
    uart9rst: bool = false,
    uart12rst: bool = false,
    reserved1: u1 = 0,
    dtsrst: bool = false,
    reserved2: u1 = 0,
    lptim2rst: bool = false,
    reserved3: u3 = 0,
    fdcan12rst: bool = false,
    reserved4: u13 = 0,
    ucpdrst: bool = false,
    reserved5: u8 = 0
};

pub const RccApb2Rstr = bitpack struct(u32) {
    reserved0: u11 = 0,
    tim1rst: bool = false,
    spi1rst: bool = false,
    tim8rst: bool = false,
    usart1rst: bool = false,
    reserved2: u1 = 0,
    tim15rst: bool = false,
    tim16rst: bool = false,
    tim17rst: bool = false,
    spi4rst: bool = false,
    spi6rst: bool = false,
    sai1rst: bool = false,
    sai2rst: bool = false,
    reserved6: u1 = 0,
    usbrst: bool = false,
    reserved7: u7 = 0
};

pub const RccApb3Rstr = bitpack struct(u32) {
    reserved0: u1 = 0,
    sbsrst: bool = false,
    reserved1: u3 = 0,
    spi5rst: bool = false,
    lpuart1rst: bool = false,
    i2c3rst: bool = false,
    i2c4rst: bool = false,
    reserved2: u2 = 0,
    lptim1rst: bool = false,
    lptim3rst: bool = false,
    lptim4rst: bool = false,
    lptim5rst: bool = false,
    lptim6rst: bool = false,
    reserved3: u4 = 0,
    vrefrst: bool = false,
    reserved4: u11 = 0
};

pub const UsartSel = enum(u3) {
    rcc_pclk2 = 0,
    pll2_q = 1,
    pll3_q = 2,
    hsi_ker = 3,
    csi_ker = 4,
    lse = 5
};

pub const RccCcipr1 = bitpack struct(u32) {
    usart1sel: UsartSel = .rcc_pclk2,
    usart2sel: UsartSel = .rcc_pclk2,
    usart3sel: UsartSel = .rcc_pclk2,
    uart4sel: UsartSel = .rcc_pclk2,
    uart5sel: UsartSel = .rcc_pclk2,
    usart6sel: UsartSel = .rcc_pclk2,
    uart7sel: UsartSel = .rcc_pclk2,
    uart8sel: UsartSel = .rcc_pclk2,
    uart9sel: UsartSel = .rcc_pclk2,
    usart10sel: UsartSel = .rcc_pclk2,
    reserved0: u1 = 0,
    timicsel: bool = false,
};

pub const LptimSel = enum(u3) {
    pclk3 = 0,
    pll2p = 1,
    pll3r = 2,
    lse_ker = 3,
    lsi_ker = 4,
    per = 5
};

pub const RccCcipr2 = bitpack struct(u32) {
    usart11sel: UsartSel = .rcc_pclk2,
    reserved0: u1 = 0,
    usart12sel: UsartSel = .rcc_pclk2,
    reserved1: u1 = 0,
    lptim1sel: LptimSel = .pclk3,
    reserved2: u1 = 0,
    lptim2sel: LptimSel = .pclk3,
    reserved3: u1 = 0,
    lptim3sel: LptimSel = .pclk3,
    reserved4: u1 = 0,
    lptim4sel: LptimSel = .pclk3,
    reserved5: u1 = 0,
    lptim5sel: LptimSel = .pclk3,
    reserved6: u1 = 0,
    lptim6sel: LptimSel = .pclk3,
    reserved7: u1 = 0,
};

pub const SpiSel = enum(u3) {
    pll1q = 0,
    pll2p = 1,
    pll3p = 2,
    audioclk = 3,
    per = 4,
};

pub const Spi4Sel = enum(u3) {
    pclk2 = 0,
    pll2q = 1,
    pll3q = 2,
    hsi_ker = 3,
    csi_ker = 4,
    hse = 5
};

pub const LpuartSel = enum(u3) {
    pclk3 = 0,
    pll2q = 1,
    pll3q = 2,
    hsi_ker = 3,
    csi_ker = 4,
    lse = 5
};

pub const RccCcipr3 = bitpack struct(u32) {
    spi1sel: SpiSel = .pll1q,
    spi2sel: SpiSel = .pll1q,
    spi3sel: SpiSel = .pll1q,
    spi4sel: Spi4Sel = .pclk2,
    spi5sel: Spi4Sel = .pclk2,
    spi6sel: Spi4Sel = .pclk2,
    reserved0: u6 = 0,
    lpuart1sel: LpuartSel = .pclk3,
    reserved1: u5 = 0,
};

pub const OctospiSel = enum(u2) {
    hclk4 = 0,
    pll1q = 1,
    pll2r = 2,
    per = 3
};

pub const SystickSel = enum(u2) {
    hclk_div8 = 0,
    lsi_ker = 1,
    lse = 2
};

pub const UsbfsSel = enum(u2) {
    no_clock = 0,
    pll1q = 1,
    pll3q = 2,
    hsi48 = 3
};

pub const I2cSel = enum(u2) {
    pclk1 = 0,
    pll3r = 1,
    hsi_ker = 2,
    csi_ker = 3
};

pub const I3cSel = enum(u2) {
    pclk1 = 0,
    pll3r = 1,
    hsi_ker = 2,
};

pub const RccCcipr4 = bitpack struct(u32) {
    octospi1sel: OctospiSel = .hclk4,
    systicksel: SystickSel = .hclk_div8,
    usbfssel: UsbfsSel = .no_clock,
    sdmmc1sel: bool = false,
    sdmmc2sel: bool = false,
    reserved0: u8 = 0,
    i2c1sel: I2cSel = .pclk1,
    i2c2sel: I2cSel = .pclk1,
    i2c3sel: I2cSel = .pclk1,
    i2c4sel: I2cSel = .pclk1,
    i3c1sel: I3cSel = .pclk1,
    i3c2sel: I3cSel = .pclk1,
    reserved1: u4 = 0
};

pub const AdcDacSel = enum(u3) {
    hclk = 0,
    sys = 1,
    pll2r = 2,
    hse = 3,
    hsi_ker = 4,
    csi_ker = 5
};

pub const RngSel = enum(u2) {
    hsi48 = 0,
    pll1q = 1,
    lse = 2,
    lsi_ker = 3
};

pub const CecSel = enum(u2) {
    lse = 0,
    lsi_ker = 1,
    csi_ker_div122 = 2
};

pub const FdcanSel = enum(u2) {
    hse = 0,
    pll1q = 1,
    pll2q = 2
};

pub const SaiSel = enum(u3) {
    pll1q = 0,
    pll2p = 1,
    pll3p = 2,
    audioclk = 3,
    per = 4
};

pub const CkPerSel = enum(u2) {
    hsi_ker = 0,
    csi_ker = 1,
    hse = 2
};

pub const RccCcipr5 = bitpack struct(u32) {
    adcdacsel: AdcDacSel = .hclk,
    dacsel: bool = false,
    rngsel: RngSel = .hsi48,
    cecsel: CecSel = .lse,
    fdcan12sel: FdcanSel = .hse,
    reserved0: u6 = 0,
    sai1sel: SaiSel = .pll1q,
    sai2sel: SaiSel = .pll1q,
    reserved1: u8 = 0,
    ckpersel: CkPerSel = .hsi_ker
};

pub const PllInit = struct {
    hse_frequency: usize = 8000000,
    pllm: u6 = 1,
    pllp_frequency: usize = 0,
    pllq_frequency: usize = 0,
    pllr_frequency: usize = 0,
    pll_characteristics: PllCharacteristics = PllCharacteristicsH563
};

pub const RccInit = struct {
    pll1_init: PllInit = .{
        .pllp_frequency = 48000000,
        .pllq_frequency = 48000000
    },
    hsebypass: bool = false,
    hpre: RccCfgrPre = .off,
    ppre1: RccCfgrPpre = .off,
    ppre2: RccCfgrPpre = .off,
    ppre3: RccCfgrPpre = .off
};

pub const RccError = error{
    InvalidConfig,
    InvalidPllm,
    PllFrequencyError
};

pub const RccPll = enum(usize) {
    pll1 = 0,
    pll2 = 1,
    pll3 = 2
};

pub const Rcc = extern struct {
    cr: RccCr,
    reserved1: [3]u32,
    hsicfgr: RccHsicfgr,
    crrcr: u32,
    csicfgr: RccCsicfgr,
    cfgr1: RccCfgr1,
    cfgr2: RccCfgr2,
    reserved2: u32,
    pllcfgr: [3]RccPllCfgr,
    plldiv: [3]RccPllDiv,
    reserved5: u32,
    cier: RccCier,
    cifr: RccCi,
    cicr: RccCi,
    reserved6: u32,
    ahb1rstr: RccAhb1Rstr,
    ahb2rstr: RccAhb2Rstr,
    reserved7: u32,
    ahb4rstr: RccAhb4Rstr,
    reserved9: u32,
    apb1lrstr: RccApb1lRstr,
    apb1hrstr: RccApb1hRstr,
    apb2rstr: RccApb2Rstr,
    apb3rstr: RccApb3Rstr,
    reserved10: u32,
    hpenr: RccEnr,
    lpenr: RccEnr,
    ccipr1: RccCcipr1,
    ccipr2: RccCcipr2,
    ccipr3: RccCcipr3,
    ccipr4: RccCcipr4,
    ccipr5: RccCcipr5,
    reserved19: u32,
    bdcr: RccBdcr,
    rsr: RccRsr,
    reserved20: [6]u32,
    seccfgr: RccSeccfgr,
    privcfgr: RccPrivcfgr,

    pub fn hsi48On(self: *volatile Rcc) void {
        self.cr.hsi48on = true;
        while (!self.cr.hsi48rdy) {
            asm volatile ("nop");
        }
    }

    pub fn hseOn(self: *volatile Rcc, hsebyp: bool) void {
        self.cr.hsebyp = hsebyp;
        self.cr.hseon = true;
        while (!self.cr.hserdy) {
            asm volatile ("nop");
        }
    }

    pub fn pllOn(self: *volatile Rcc, pll: RccPll) void {
        switch (pll) {
            .pll1 => {
                self.cr.pll1on = true;
                while (!self.cr.pll1rdy) {
                    asm volatile ("nop");
                }
            },
            .pll2 => {
                self.cr.pll2on = true;
                while (!self.cr.pll2rdy) {
                    asm volatile ("nop");
                }
            },
            .pll3 => {
                self.cr.pll3on = true;
                while (!self.cr.pll3rdy) {
                    asm volatile ("nop");
                }
            }
        }
    }

    pub fn clockSwitch(self: *volatile Rcc, sw: RccCfgrSw) void {
        self.cfgr1.sw = sw;
        while (self.cfgr1.sws != sw) {
            asm volatile ("nop");
        }
    }

    pub fn pllInit(self: *volatile Rcc, pll: RccPll, config: *const PllInit) RccError!void {
        if (config.hse_frequency == 0 or config.pllm == 0 or
            (config.pllp_frequency == 0 and config.pllq_frequency == 0 and config.pllr_frequency == 0))
            return RccError.InvalidConfig;

        const refclk = config.hse_frequency / config.pllm;
        if (refclk < 1000000 or refclk > 16000000)
            return RccError.InvalidPllm;

        const medium_vco_frequency_range = refclk < 2000000;

        var pll_min_frequency: usize = undefined;
        var pll_max_frequency: usize = undefined;
        if (medium_vco_frequency_range) {
            pll_min_frequency = PLL_MEDIUM_MIN_FREQUENCY;
            pll_max_frequency = PLL_MEDIUM_MAX_FREQUENCY;
        }
        else {
            pll_min_frequency = config.pll_characteristics.wide_min_frequency;
            pll_max_frequency = config.pll_characteristics.wide_max_frequency;
        }

        var plln = pll_min_frequency / refclk + 1;
        var pll_frequency = refclk * plln;
        var pllp: usize = 1;
        var pllq: usize = 1;
        var pllr: usize = 1;
        while (pll_frequency <= pll_max_frequency) {
            if ((config.pllp_frequency == 0 or pll_frequency % config.pllp_frequency == 0) and
                (config.pllq_frequency == 0 or pll_frequency % config.pllq_frequency == 0) and
                (config.pllr_frequency == 0 or pll_frequency % config.pllr_frequency == 0)) {
                if (config.pllq_frequency != 0)
                    pllq = pll_frequency / config.pllq_frequency;
                if (config.pllr_frequency != 0)
                    pllr = pll_frequency / config.pllr_frequency;
                if (config.pllp_frequency != 0) {
                    pllp = pll_frequency / config.pllp_frequency;
                    if (pllp != 0 and pllp & 1 == 0)
                        break;
                } else {
                    break;
                }
            }
            pll_frequency += refclk;
            plln += 1;
        }
        if (pll_frequency > pll_max_frequency)
            return RccError.PllFrequencyError;

        var pll_clock_range: RccPllRge = undefined;
        if (refclk < 2000000) {
            pll_clock_range = ._1to2;
        } else if (refclk < 4000000) {
            pll_clock_range = ._2to4;
        } else if (refclk < 8000000) {
            pll_clock_range = ._4to8;
        } else {
            pll_clock_range = ._8to16;
        }

        const pllno = @backingInt(pll);
        self.pllcfgr[pllno] = RccPllCfgr{
            .src = .hse,
            .pen = config.pllp_frequency != 0,
            .qen = config.pllq_frequency != 0,
            .ren = config.pllr_frequency != 0,
            .vcosel = medium_vco_frequency_range,
            .rge = pll_clock_range,
            .m = config.pllm
        };

        self.plldiv[pllno].divr = RccPllDivr{
            .divn = @truncate(plln - 1),
            .divp = @truncate(pllp - 1),
            .divq = @truncate(pllq - 1),
            .divr = @truncate(pllr - 1)
        };

        self.pllOn(pll);
    }

    pub fn init(self: *volatile Rcc, config: *const RccInit) RccError!void {
        if (config.pll1_init.hse_frequency == 0 or config.pll1_init.pllm == 0 or config.pll1_init.pllp_frequency == 0)
            return RccError.InvalidConfig;

        self.hseOn(config.hsebypass);

        const hclk_frequency = config.pll1_init.pllp_frequency / config.hpre.toInt();

        var flash_latency: u4 = 0;
        if (hclk_frequency > 100000000)
        {
            if (hclk_frequency <= 150000000) {
                pwr.pwr.setVos(.scale2);
                flash_latency = calculateFlashLatencyVos2(hclk_frequency);
            }
            else if (hclk_frequency <= 200000000) {
                pwr.pwr.setVos(.scale1);
                flash_latency = calculateFlashLatencyVos1(hclk_frequency);
            }
            else {
                pwr.pwr.setVos(.scale0);
                flash_latency = calculateFlashLatencyVos0(hclk_frequency);
            }
        }
        else {
            pwr.pwr.setVos(.scale3);
            flash_latency = calculateFlashLatencyVos3(hclk_frequency);
        }

        self.cfgr2 = RccCfgr2{
            .hpre = config.hpre,
            .ppre1 = config.ppre1,
            .ppre2 = config.ppre2,
            .ppre3 = config.ppre3
        };

        try self.pllInit(.pll1, &config.pll1_init);

        const wrhighfreq: u2 = @truncate(flash_latency / 2);
        flash.flash.acr = flash.FlashAcr{
            .prften = true,
            .wrhighfreq = wrhighfreq,
            .latency = flash_latency
        };

        icache.icache.enable();

        self.clockSwitch(.pll1);
    }

    pub fn getResetCause(self: *volatile Rcc) []const u8 {
        const rsr = self.rsr;
        self.rsr.rmvf = true; // Clear reset flags after reading
        if (rsr.lpwrrstf) return "Low Power Reset";
        if (rsr.wwdgrstf) return "WWDG Reset";
        if (rsr.iwdgrstf) return "IWDG Reset";
        if (rsr.sftrstf) return "Software Reset";
        if (rsr.borrstf) return "BOR Reset";
        if (rsr.pinrstf) return "PIN Reset";
        return "Unknown Reset Cause";
    }

    pub fn enableUsbClock(self: *volatile Rcc, source: UsbfsSel) void {
        self.ccipr4.usbfssel = source;
        self.hpenr.apb2.usbfsen = true;
    }
};

fn calculateFlashLatencyVos3(hclk: usize) u4 {
  return @truncate((hclk - 1) / 20000000);
}

fn calculateFlashLatencyVos2(hclk: usize) u4 {
  return @truncate((hclk - 1) / 30000000);
}

fn calculateFlashLatencyVos1(hclk: usize) u4 {
  return @truncate((hclk - 1) / 34000000);
}

fn calculateFlashLatencyVos0(hclk: usize) u4 {
  return @truncate((hclk - 1) / 42000000);
}

pub const rcc: *volatile Rcc = @ptrFromInt(RCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x118, @sizeOf(Rcc));
}
