const RCC_BASE = 0x44020C00;

pub const RccCr1 = bitpack struct(u32) {
    hsison: bool = false,
    hsidiv3on: bool = true,
    hsikon: bool = false,
    hsikeron: bool = false,
    hsisrdy: bool = false,
    hsidiv3rdy: bool = true,
    hsikrdy: bool = false,
    reserved0: u1 = 0,
    psison: bool = false,
    psidiv3on: bool = false,
    psikon: bool = false,
    psikeron: bool = false,
    psisrdy: bool = false,
    psidiv3rdy: bool = false,
    psikrdy: bool = false,
    reserved1: u1 = 0,
    hseon: bool = false,
    hserdy: bool = false,
    hsebyp: bool = false,
    hsecsson: bool = false,
    hseext: bool = false,
    reserved2: u11 = 0,
};

pub const Sikdiv = enum(u4) {
    div1 = 0,
    div1p5 = 2,
    div2 = 3,
    div2p5 = 4,
    div3 = 5,
    div3p5 = 6,
    div4 = 7,
    div4p5 = 8,
    div5 = 9,
    div5p5 = 10,
    div6 = 11,
    div6p5 = 12,
    div7 = 13,
    div7p5 = 14,
    div8 = 15
};

pub const Psirefsrc = enum(u2) {
    hse = 0,
    lse = 1,
    hsi_div18 = 2,
};

pub const Psiref = enum(u3) {
    _32768Hz = 0,
    _8Mhz = 1,
    _16Mhz = 2,
    _24Mhz = 3,
    _25Mhz = 4,
    _32Mhz = 5,
    _48Mhz = 6,
    _50Mhz = 7
};

pub const Psifreq = enum(u2) {
    _100Mhz = 0,
    _144Mhz = 1,
    _160Mhz = 2
};

pub const RccCr2 = bitpack struct(u32) {
    hsikdiv: Sikdiv = .div1,
    reserved0: u4 = 0,
    psikdiv: Sikdiv = .div1,
    reserved1: u4 = 0,
    psirefsrc: Psirefsrc = .hse,
    reserved2: u2 = 0,
    psiref: Psiref = ._32768Hz,
    reserved3: u5 = 0,
    psifreq: Psifreq = ._100Mhz,
    reserved4: u2 = 0,
};

pub const Sw = enum(u2) {
    hsidiv3 = 0,
    hsis = 1,
    hse = 2,
    psis = 3,
};

pub const Mco1sel = enum(u3) {
    system_clock = 0,
    hse = 1,
    lse = 2,
    lsi = 3,
    psik = 4,
    hsik = 5,
    psis = 6,
    hsis = 7
};

pub const Mco2sel = enum(u3) {
    system_clock = 0,
    hse = 1,
    lse = 2,
    lsi = 3,
    psik = 4,
    hsik = 5,
    psidiv3 = 6,
    hsidiv3 = 7
};

pub const RccCfgr1 = bitpack struct(u32) {
    sw: Sw = .hsidiv3,
    reserved0: u1 = 0,
    sws: Sw = .hsidiv3,
    reserved1: u1 = 0,
    stopwuck: bool = false,
    rtcpre: u9 = 0,
    reserved2: u2 = 0,
    mco1pre: u4 = 0,
    mco1sel: Mco1sel = .system_clock,
    mco2pre: u4 = 0,
    mco2sel: Mco2sel = .system_clock
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
    reserved0: u1 = 0,
    ppre2: RccCfgrPpre = .off,
    reserved1: u1 = 0,
    ppre3: RccCfgrPpre = .off,
    reserved2: u1 = 0,
    ahb1dis: bool = false,
    ahb2dis: bool = false,
    reserved3: u1 = 0,
    ahb4dis: bool = false,
    apb1dis: bool = false,
    apb2dis: bool = false,
    apb3dis: bool = false,
    reserved4: u9 = 0,
};

pub const RccCier = bitpack struct(u32) {
    lsirdyie: bool = false,
    lserdyie: bool = false,
    hsisrdyie: bool = false,
    hsidiv3rdyie: bool = false,
    hsikrdyie: bool = false,
    psisrdyie: bool = false,
    psidiv3rdyie: bool = false,
    psikrdyie: bool = false,
    hserdyie: bool = false,
    reserved0: u23 = 0,
};

pub const RccCifr = bitpack struct(u32) {
    lsirdyf: bool,
    lserdyf: bool,
    hsisrdyf: bool,
    hsidiv3rdyf: bool,
    hsikrdyf: bool,
    psisrdyf: bool,
    psidiv3rdyf: bool,
    psikrdyf: bool,
    hserdyf: bool,
    reserved0: u1,
    hsecssf: bool,
    lsecssf: bool,
    reserved1: u20,
};

pub const RccCicr = bitpack struct(u32) {
    lsirdyc: bool = false,
    lserdyc: bool = false,
    hsisrdyc: bool = false,
    hsidiv3rdyc: bool = false,
    hsikrdyc: bool = false,
    psisrdyc: bool = false,
    psidiv3rdyc: bool = false,
    psikrdyc: bool = false,
    hserdyc: bool = false,
    reserved0: u1 = 0,
    hsecssc: bool = false,
    lsecssc: bool = false,
    reserved1: u20 = 0,
};

pub const RccAhb1rstr = bitpack struct(u32) {
    lpdma1rst: bool = false,
    lpdma2rst: bool = false,
    reserved0: u10 = 0,
    crcrst: bool = false,
    reserved1: u1 = 0,
    cordicrst: bool = false,
    reserved2: u2 = 0,
    ramcfgrst: bool = false,
    reserved3: u1 = 0,
    ethrst: bool = false,
    reserved4: u12 = 0,
};

pub const RccAhb2rstr = bitpack struct(u32) {
    gpioarst: bool = false,
    gpiobrst: bool = false,
    gpiocrst: bool = false,
    gpiodrst: bool = false,
    gpioerst: bool = false,
    gpiofrst: bool = false,
    gpiogrst: bool = false,
    gpiohrst: bool = false,
    reserved0: u2 = 0,
    adcrst: bool = false,
    dac1rst: bool = false,
    reserved1: u4 = 0,
    aesrst: bool = false,
    hashrst: bool = false,
    rngrst: bool = false,
    pkarst: bool = false,
    saesrst: bool = false,
    ccbrst: bool = false,
    reserved2: u2 = 0,
    adc3rst: bool = false,
    reserved3: u7 = 0,
};

pub const RccAhb4rstr = bitpack struct(u32) {
    reserved0: u20 = 0,
    xspi1rst: bool = false,
    reserved1: u11 = 0,
};

pub const RccApb1lrstr = bitpack struct(u32) {
    tim2rst: bool = false,
    tim3rst: bool = false,
    tim4rst: bool = false,
    tim5rst: bool = false,
    tim6rst: bool = false,
    tim7rst: bool = false,
    tim12rst: bool = false,
    reserved0: u7 = 0,
    spi2rst: bool = false,
    spi3rst: bool = false,
    reserved1: u1 = 0,
    usart2rst: bool = false,
    usart3rst: bool = false,
    uart4rst: bool = false,
    uart5rst: bool = false,
    i2c1rst: bool = false,
    i2c2rst: bool = false,
    i3c1rst: bool = false,
    crsrst: bool = false,
    usart6rst: bool = false,
    reserved2: u4 = 0,
    uart7rst: bool = false,
    reserved3: u1 = 0,
};

pub const RccApb1hrstr = bitpack struct(u32) {
    reserved0: u3 = 0,
    comprst: bool = false,
    reserved1: u5 = 0,
    fdcanrst: bool = false,
    reserved2: u22 = 0,
};

pub const RccApb2rstr = bitpack struct(u32) {
    reserved0: u11 = 0,
    tim1rst: bool = false,
    spi1rst: bool = false,
    tim8rst: bool = false,
    usart1rst: bool = false,
    reserved1: u1 = 0,
    tim15rst: bool = false,
    tim16rst: bool = false,
    tim17rst: bool = false,
    reserved2: u5 = 0,
    usbrst: bool = false,
    reserved3: u7 = 0,
};

pub const RccApb3rstr = bitpack struct(u32) {
    reserved0: u1 = 0,
    sbsrst: bool = false,
    reserved1: u4 = 0,
    lpuart1rst: bool = false,
    reserved2: u4 = 0,
    lptim1rst: bool = false,
    reserved3: u20 = 0,
};

pub const RccAhb1enr = bitpack struct(u32) {
    lpdma1en: bool = false,
    lpdma2en: bool = false,
    reserved0: u6 = 1,
    flitfen: bool = true,
    reserved1: u3 = 0,
    crcen: bool = false,
    reserved2: u1 = 0,
    cordicen: bool = false,
    reserved3: u2 = 0,
    ramcfgen: bool = false,
    ethcken: bool = false,
    ethen: bool = false,
    ethtxen: bool = false,
    ethrxen: bool = false,
    reserved4: u8 = 3,
    sram2en: bool = true,
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
    reserved0: u2 = 0,
    adcen: bool = false,
    dac1en: bool = false,
    reserved1: u4 = 0,
    aesen: bool = false,
    hashen: bool = false,
    rngen: bool = false,
    pkaen: bool = false,
    saesen: bool = false,
    ccben: bool = false,
    reserved2: u2 = 0,
    adc3en: bool = false,
    reserved3: u7 = 0,
};

pub const RccAhb4enr = bitpack struct(u32) {
    reserved0: u20 = 0,
    xspi1en: bool = false,
    reserved1: u11 = 0,
};

pub const RccApb1lenr = bitpack struct(u32) {
    tim2en: bool = false,
    tim3en: bool = false,
    tim4en: bool = false,
    tim5en: bool = false,
    tim6en: bool = false,
    tim7en: bool = false,
    tim12en: bool = false,
    reserved0: u4 = 0,
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
    reserved3: u4 = 0,
    uart7en: bool = false,
    reserved4: u1 = 0,
};

pub const RccApb1henr = bitpack struct(u32) {
    reserved0: u3 = 0,
    compen: bool = false,
    reserved1: u5 = 0,
    fdcanen: bool = false,
    reserved2: u22 = 0,
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
    reserved2: u5 = 0,
    usben: bool = false,
    reserved3: u7 = 0,
};

pub const RccApb3enr = bitpack struct(u32) {
    reserved0: u1 = 0,
    sbsen: bool = false,
    reserved1: u4 = 0,
    lpuart1en: bool = false,
    reserved2: u4 = 0,
    lptim1en: bool = false,
    reserved3: u9 = 0,
    rtcapben: bool = false,
    reserved4: u10 = 0,
};

pub const RccAhb1lpenr = bitpack struct(u32) {
    lpdma1lpen: bool = true,
    lpdma2lpen: bool = true,
    reserved0: u6 = 0,
    flitflpen: bool = true,
    reserved1: u3 = 0,
    crclpen: bool = true,
    reserved2: u1 = 0,
    cordiclpen: bool = true,
    reserved3: u2 = 0,
    ramcfglpen: bool = true,
    ethcklpen: bool = true,
    ethlpen: bool = true,
    ethtxlpen: bool = true,
    ethrxlpen: bool = true,
    reserved4: u4 = 0,
    icachelpen: bool = true,
    reserved5: u3 = 0,
    sram2lpen: bool = true,
    sram1lpen: bool = true,
};

pub const RccAhb2lpenr = bitpack struct(u32) {
    gpioalpen: bool = true,
    gpioblpen: bool = true,
    gpioclpen: bool = true,
    gpiodlpen: bool = true,
    gpioelpen: bool = true,
    gpioflpen: bool = true,
    gpioglpen: bool = true,
    gpiohlpen: bool = true,
    reserved0: u2 = 0,
    adclpen: bool = true,
    dac1lpen: bool = true,
    reserved1: u4 = 0,
    aeslpen: bool = true,
    hashlpen: bool = true,
    rnglpen: bool = true,
    pkalpen: bool = true,
    saeslpen: bool = true,
    ccblpen: bool = true,
    reserved2: u2 = 0,
    adc3lpen: bool = true,
    reserved3: u7 = 0,
};

pub const RccAhb4lpenr = bitpack struct(u32) {
    reserved0: u20 = 0,
    xspi1lpen: bool = true,
    reserved1: u11 = 0,
};

pub const RccApb1llpenr = bitpack struct(u32) {
    tim2lpen: bool = true,
    tim3lpen: bool = true,
    tim4lpen: bool = true,
    tim5lpen: bool = true,
    tim6lpen: bool = true,
    tim7lpen: bool = true,
    tim12lpen: bool = true,
    reserved0: u4 = 0,
    wwdglpen: bool = true,
    reserved1: u2 = 0,
    spi2lpen: bool = true,
    spi3lpen: bool = true,
    reserved2: u1 = 0,
    usart2lpen: bool = true,
    usart3lpen: bool = true,
    uart4lpen: bool = true,
    uart5lpen: bool = true,
    i2c1lpen: bool = true,
    i2c2lpen: bool = true,
    i3c1lpen: bool = true,
    crslpen: bool = true,
    usart6lpen: bool = true,
    reserved3: u4 = 0,
    uart7lpen: bool = true,
    reserved4: u1 = 0,
};

pub const RccApb1hlpenr = bitpack struct(u32) {
    reserved0: u3 = 0,
    complpen: bool = true,
    reserved1: u5 = 0,
    fdcanlpen: bool = true,
    reserved2: u22 = 0,
};

pub const RccApb2lpenr = bitpack struct(u32) {
    reserved0: u11 = 0,
    tim1lpen: bool = true,
    spi1lpen: bool = true,
    tim8lpen: bool = true,
    usart1lpen: bool = true,
    reserved1: u1 = 0,
    tim15lpen: bool = true,
    tim16lpen: bool = true,
    tim17lpen: bool = true,
    reserved2: u5 = 0,
    usblpen: bool = true,
    reserved3: u7 = 0,
};

pub const RccApb3lpenr = bitpack struct(u32) {
    reserved0: u1 = 0,
    sbslpen: bool = true,
    reserved1: u4 = 0,
    lpuart1lpen: bool = true,
    reserved2: u4 = 0,
    lptim1lpen: bool = true,
    reserved3: u9 = 0,
    rtcapblpen: bool = true,
    reserved4: u10 = 0,
};

pub const Uartsel = enum(u2) {
    pclk = 0,
    psik = 1,
    hsik = 2,
    lse = 3,
};

pub const Lpuartsel = enum(u2) {
    pclk3 = 0,
    hsik = 1,
    lse = 2,
    lsi = 3,
};

pub const Spisel = enum(u2) {
    pclk1 = 0,
    psis = 1,
    psik = 2,
    audioclk = 3,
};

pub const Fdcansel = enum(u2) {
    pclk1 = 0,
    psis = 1,
    psik = 2,
    hse = 3,
};

pub const RccCcipr1 = bitpack struct(u32) {
    usart1sel: Uartsel = .pclk,
    usart2sel: Uartsel = .pclk,
    usart3sel: Uartsel = .pclk,
    uart4sel: Uartsel = .pclk,
    uart5sel: Uartsel = .pclk,
    usart6sel: Uartsel = .pclk,
    uart7sel: Uartsel = .pclk,
    lpuart1sel: Lpuartsel = .pclk3,
    spi1sel: Spisel = .pclk1,
    spi2sel: Spisel = .pclk1,
    spi3sel: Spisel = .pclk1,
    reserved0: u4 = 0,
    fdcansel: Fdcansel = .pclk1,
    reserved1: u4 = 0,
};

pub const I2csel = enum(u2) {
    pclk1 = 0,
    psik = 1,
    hsik = 2,
};

pub const Adcdacsel = enum(u2) {
    hclk = 0,
    psis = 1,
    psik = 2,
    hsik = 3,
};

pub const Adcdacpre = enum(u3) {
    off = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7
};

pub const Lptimsel = enum(u2) {
    pclk3 = 0,
    hsik = 1,
    lse = 2,
    lsi = 3
};

pub const Ck48sel = enum(u2) {
    unknown = 0,
    psi_div3 = 1,
    hsi_div3 = 2,
    hse = 3,
};

pub const Systicksel = enum(u2) {
    hclk_div8 = 0,
    lsi_ker = 1,
    lse = 2
};

pub const RccCcipr2 = bitpack struct(u32) {
    i2c1sel: I2csel = .pclk1,
    i2c2sel: I2csel = .pclk1,
    reserved0: u2 = 0,
    i3c1sel: I2csel = .pclk1,
    reserved1: u2 = 0,
    adcdacsel: Adcdacsel = .hclk,
    adcdacpre: Adcdacpre = .off,
    dacsel: bool = false,
    lptim1sel: Lptimsel = .pclk3,
    reserved2: u6 = 0,
    ck48sel: Ck48sel = .unknown,
    reserved3: u4 = 0,
    systicksel: Systicksel = .hclk_div8,
};

pub const Xspi1sel = enum(u2) {
    hclk4 = 0,
    psik = 1,
    hsik = 2,
};

pub const Ethptpclksel = enum(u2) {
    disabled = 0,
    hclk1 = 1,
    psis = 2,
    psik = 3,
};

pub const Ethclksel = enum(u2) {
    disabled = 0,
    psis = 1,
    psik = 2,
    hse = 3,
};

pub const Ethclkdiv = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
};

pub const RccCcipr3 = bitpack struct(u32) {
    xspi1sel: Xspi1sel = .hclk4,
    reserved0: u6 = 0,
    ethrefclksel: bool = false,
    reserved1: u1 = 0,
    ethptpclksel: Ethptpclksel = .disabled,
    reserved2: u1 = 0,
    ethclksel: Ethclksel = .disabled,
    reserved3: u11 = 0,
    ethclkdiv: Ethclkdiv = .div1,
    ethptpdiv: u4 = 0,
};

pub const Lsedrv = enum(u2) {
    low = 0,
    medium_low = 1,
    medium_high = 2,
    high = 3,
};

pub const Rtcsel = enum(u2) {
    disabled = 0,
    lse = 1,
    lsi = 2,
    hse = 3,
};

pub const RccRtccr = bitpack struct(u32) {
    lseon: bool = false,
    lserdy: bool = false,
    lsebyp: bool = false,
    lsedrv: Lsedrv = .low,
    lsecsson: bool = false,
    lsecssd: bool = false,
    lseext: bool = false,
    rtcsel: Rtcsel = .disabled,
    reserved0: u5 = 0,
    rtcen: bool = false,
    rtcdrst: bool = false,
    reserved1: u7 = 0,
    lscoen: bool = false,
    lscosel: bool = false,
    lsion: bool = false,
    lsirdy: bool = false,
    reserved2: u4 = 0,
};

pub const RccRsr = bitpack struct(u32) {
    reserved0: u23 = 0,
    rmvf: bool = false,
    reserved1: u2 = 0,
    pinrstf: bool = false,
    borrstf: bool = false,
    sftrstf: bool = false,
    iwdgrstf: bool = false,
    wwdgrstf: bool = false,
    lpwrrstf: bool = false,
};

pub const RccPrivcfgr = bitpack struct(u32) {
    reserved0: u1 = 0,
    priv: bool = false,
    reserved1: u30 = 0,
};

pub const Rcc = extern struct {
    cr1: RccCr1,
    cr2: RccCr2,
    reserved0: [5]u32,
    cfgr1: RccCfgr1,
    cfgr2: RccCfgr2,
    reserved1: [11]u32,
    cier: RccCier,
    cifr: RccCifr,
    cicr: RccCicr,
    reserved2: u32,
    ahb1rstr: RccAhb1rstr,
    ahb2rstr: RccAhb2rstr,
    reserved3: u32,
    ahb4rstr: RccAhb4rstr,
    reserved4: u32,
    apb1lrstr: RccApb1lrstr,
    apb1hrstr: RccApb1hrstr,
    apb2rstr: RccApb2rstr,
    apb3rstr: RccApb3rstr,
    reserved5: u32,
    ahb1enr: RccAhb1enr,
    ahb2enr: RccAhb2enr,
    reserved6: u32,
    ahb4enr: RccAhb4enr,
    reserved7: u32,
    apb1lenr: RccApb1lenr,
    apb1henr: RccApb1henr,
    apb2enr: RccApb2enr,
    apb3enr: RccApb3enr,
    reserved8: u32,
    ahb1lpenr: RccAhb1lpenr,
    ahb2lpenr: RccAhb2lpenr,
    reserved9: u32,
    ahb4lpenr: RccAhb4lpenr,
    reserved10: u32,
    apb1llpenr: RccApb1llpenr,
    apb1hlpenr: RccApb1hlpenr,
    apb2lpenr: RccApb2lpenr,
    apb3lpenr: RccApb3lpenr,
    reserved11: u32,
    ccipr1: RccCcipr1,
    ccipr2: RccCcipr2,
    ccipr3: RccCcipr3,
    reserved12: [3]u32,
    rtccr: RccRtccr,
    rsr: RccRsr,
    reserved13: [7]u32,
    privcfgr: RccPrivcfgr,
};

pub const rcc: *volatile Rcc = @ptrFromInt(RCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x118, @sizeOf(Rcc));
}
