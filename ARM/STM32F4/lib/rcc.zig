const RCC_BASE: usize = 0x40023800;

pub const RccCr = packed struct(u32) {
    hsion: bool = true,
    hsirdy: bool = false,
    reserved: u1 = 0,
    hsitrim: u5 = 0x10,
    hsical: u8,
    hseon: bool = false,
    hserdy: bool = false,
    hsebyp: bool = false,
    csson: bool = false,
    reserved3: u4 = 0,
    pllon: bool = false,
    pllrdy: bool = false,
    plli2son: bool = false,
    plli2srdy: bool = false,
    pllsaion: bool = false,
    pllsairdy: bool = false,
    reserved4: u2 = 0
};

pub const RccPllCfgr = packed struct(u32) {
    pllm: u6 = 0x10,
    plln: u9 = 0xC0,
    reserved: u1 = 0,
    pllp: u2 = 0,
    reserved2: u4 = 0,
    pllsrc: bool = false,
    reserved3: u1 = 0,
    pllq: u4 = 8,
    reserved4: u4 = 0
};

pub const RccCfgrSw = enum(u2) {
    hsi = 0,
    hse = 1,
    pll1 = 2
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

pub const RccCfgrMco = enum(u2) {
    hsi = 0,
    lse = 1,
    hse = 2,
    pll = 3
};

pub const RccCfgrMcoPre = enum(u3) {
    off = 0,
    div2 = 4,
    div3 = 5,
    div4 = 6,
    div5 = 7
};

pub const RccCfgr = packed struct(u32) {
    sw: RccCfgrSw = .hsi,
    sws: RccCfgrSw = .hsi,
    hpre: RccCfgrHpre = .off,
    reserved: u2 = 0,
    ppre1: RccCfgrPpre = .off,
    ppre2: RccCfgrPpre = .off,
    rtcpre: u5 = 0,
    mco1: RccCfgrMco = .hsi,
    i2ssrc: bool = false,
    mco1pre: RccCfgrMcoPre = .off,
    mco2pre: RccCfgrMcoPre = .off,
    mco2: RccCfgrMco = .hsi
};

pub const RccAhb1Enr = packed struct(u32) {
    gpioaen: bool = false,
    gpioben: bool = false,
    gpiocen: bool = false,
    gpioden: bool = false,
    gpioeen: bool = false,
    gpiofen: bool = false,
    gpiogen: bool = false,
    gpiohen: bool = false,
    gpioien: bool = false,
    gpiojen: bool = false,
    gpioken: bool = false,
    reserved: u1 = 0,
    crcen: bool = false,
    reserved2: u5 = 0,
    bkpsramen: bool = false,
    reserved3: u1 = 0,
    ccmdataramen: bool = false,
    dma1en: bool = false,
    dma2en: bool = false,
    dma2den: bool = false,
    reserved4: u1 = 0,
    ethmacen: bool = false,
    ethmactxen: bool = false,
    ethmacrxen: bool = false,
    ethmacptpen: bool = false,
    otghsen: bool = false,
    otghsulpien: bool = false,
    reserved5: u1 = 0
};

pub const RccAhb2Enr = packed struct(u32) {
    dcmien: bool = false,
    reserved: u3 = 0,
    crypen: bool = false,
    hashen: bool = false,
    rngen: bool = false,
    otgfsen: bool = false,
    reserved2: u24 = 0
};

pub const RccAhb3Enr = packed struct(u32) {
    fmcen: bool = false,
    reserved: u31 = 0
};

pub const RccApb1Enr = packed struct(u32) {
    tim2en: bool = false,
    tim3en: bool = false,
    tim4en: bool = false,
    tim5en: bool = false,
    tim6en: bool = false,
    tim7en: bool = false,
    tim12en: bool = false,
    tim13en: bool = false,
    tim14en: bool = false,
    reserved: u2 = 0,
    wwdgen: bool = false,
    reserved2: u2 = 0,
    spi2en: bool = false,
    spi3en: bool = false,
    reserved3: u1 = 0,
    usart2en: bool = false,
    usart3en: bool = false,
    uart4en: bool = false,
    uart5en: bool = false,
    i2c1en: bool = false,
    i2c2en: bool = false,
    i2c3en: bool = false,
    reserved4: u1 = 0,
    can1en : bool = false,
    can2en: bool = false,
    reserved5: u1 = 0,
    pwren: bool = false,
    dacen: bool = false,
    uart7en: bool = false,
    uart8en: bool = false
};

pub const RccApb2Enr = packed struct(u32) {
    tim1en: bool = false,
    tim8en: bool = false,
    reserved: u2 = 0,
    usart1en: bool = false,
    usart6en: bool = false,
    reserved2: u2 = 0,
    adc1en: bool = false,
    adc2en: bool = false,
    adc3en: bool = false,
    sdioen: bool = false,
    spi1en: bool = false,
    spi4en: bool = false,
    syscfgen: bool = false,
    reserved3: u1 = 0,
    tim9en: bool = false,
    tim10en: bool = false,
    tim11en: bool = false,
    reserved4: u1 = 0,
    spi5en: bool = false,
    spi6en: bool = false,
    sai1en: bool = false,
    reserved5: u3 = 0,
    ltdcen: bool = false,
    reserved6: u5 = 0
};

pub const RccBdcrRtcSel = enum(u2) {
    off = 0,
    lse = 1,
    lsi = 2,
    hse = 3
};

pub const RccBdcr = packed struct(u32) {
    lseon: bool = false,
    lserdy: bool = false,
    lsebyp: bool = false,
    reserved: u5 = 0,
    rtcsel: RccBdcrRtcSel,
    reserved2: u5 = 0,
    rtcen: bool = false,
    bdrst: bool = false,
    reserved3: u15 = 0
};

pub const RccCsr = packed struct(u32) {
    lsion: bool = false,
    lsirdy: bool,
    reserved: u22 = 0,
    rmvf: bool = false,
    borrstf: bool,
    pinrstf: bool,
    porrstf: bool,
    sftrstf: bool,
    iwdgrstf: bool,
    wwdgrstf: bool,
    lpwrrstf: bool
};

pub const RccPll2Cfgr = packed struct(u32) {
    reserved: u6 = 0,
    plln: u9 = 0xC0,
    reserved2: u9 = 0,
    pllq: u4 = 4,
    pllr: u3 = 2,
    rezserved3: u1 = 0
};

pub const Rcc = extern struct {
    cr: RccCr,
    pllcfgr: RccPllCfgr,
    cfgr: RccCfgr,
    cir: u32,
    ahb1rstr: u32,
    ahb2rstr: u32,
    ahb3rstr: u32,
    reserved: u32,
    apb1rstr: u32,
    apb2rstr: u32,
    reserved2: [2]u32,
    ahb1enr: RccAhb1Enr,
    ahb2enr: RccAhb2Enr,
    ahb3enr: RccAhb3Enr,
    reserved3: u32,
    apb1enr: RccApb1Enr,
    apb2enr: RccApb2Enr,
    reserved4: [2]u32,
    ahb1lpenr: RccAhb1Enr,
    ahb2lpenr: RccAhb2Enr,
    ahb3lpenr: RccAhb3Enr,
    reserved5: u32,
    apb1lpenr: RccApb1Enr,
    apb2lpenr: RccApb2Enr,
    reserved6: [2]u32,
    bdcr: RccBdcr,
    csr: RccCsr,
    reserved7: [2]u32,
    sscgr: u32,
    plli2scfgr: RccPll2Cfgr,
    pllsaicfgr: RccPll2Cfgr,
    dckcfgr: u32
};

pub const rcc: *volatile Rcc = @ptrFromInt(RCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x90, @sizeOf(Rcc));
}
