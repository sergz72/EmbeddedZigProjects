const MCLK_BASE = 0x40000800;

pub const MclkInten = bitpack struct(u8) {
    ckrdy: bool = false,
    reserved0: u7 = 0,
};

pub const MclkCpuDiv = enum(u8) {
    div1 = 1,
    div2 = 2,
    div4 = 4,
    div8 = 8,
    div16 = 16,
    div32 = 32,
    div64 = 64,
    div128 = 128
};

pub const Ahbmask = bitpack struct(u32) {
    hpb0: bool = true,
    hpb1: bool = true,
    hpb2: bool = true,
    hpb3: bool = true,
    dsu: bool = true,
    reserved0: u1 = 1,
    nvmctrl: bool = true,
    reserved1: u1 = 1,
    cmcc: bool = true,
    dmac: bool = true,
    usb: bool = true,
    reserved2: u1 = 1,
    pac: bool = true,
    qspi: bool = true,
    reserved3: u1 = 1,
    sdhc0: bool = true,
    reserved4: u1 = 1,
    can0: bool = true,
    can1: bool = true,
    icm: bool = true,
    pukcc: bool = true,
    qspi_2x: bool = true,
    nvmctrl_smeeprom: bool = true,
    nvmctrl_cache: bool = true,
    reserved5: u8 = 0,
};

pub const Apbamask = bitpack struct(u32) {
    pac: bool = true,
    pm: bool = true,
    mclk: bool = true,
    rstc: bool = true,
    oscctrl: bool = true,
    osc32kctrl: bool = true,
    supc: bool = true,
    gclk: bool = true,
    wdt: bool = true,
    rtc: bool = true,
    eic: bool = true,
    freqm: bool = false,
    sercom0: bool = false,
    sercom1: bool = false,
    tc0: bool = false,
    tc1: bool = false,
    reserved0: u16 = 0,
};

pub const Apbbmask = bitpack struct(u32) {
    usb: bool = false,
    dsu: bool = true,
    nvmctrl: bool = true,
    reserved0: u1 = 1,
    port: bool = true,
    reserved1: u2 = 0,
    evsys: bool = false,
    reserved2: u1 = 0,
    sercom2: bool = false,
    sercom3: bool = false,
    tcc0: bool = false,
    tcc1: bool = false,
    tc2: bool = false,
    tc3: bool = false,
    reserved3: u1 = 1,
    ramecc: bool = true,
    reserved4: u15 = 0,
};

pub const Apbcmask = bitpack struct(u32) {
    reserved0: u3 = 0,
    tcc2: bool = false,
    tcc3: bool = false,
    tc4: bool = false,
    tc5: bool = false,
    pdec: bool = false,
    ac: bool = false,
    aes: bool = false,
    trng: bool = false,
    icm: bool = false,
    reserved1: u1 = 1,
    qspi: bool = true,
    ccl: bool = false,
    reserved2: u17 = 0,
};

pub const Apbdmask = bitpack struct(u32) {
    sercom4: bool = false,
    sercom5: bool = false,
    reserved0: u2 = 0,
    tcc4: bool = false,
    reserved1: u2 = 0,
    adc0: bool = false,
    adc1: bool = false,
    dac: bool = false,
    i2s: bool = false,
    pcc: bool = false,
    reserved2: u20 = 0,
};

pub const Mclk = extern struct {
    reserved0: u8,
    intenclr: MclkInten,
    intenset: MclkInten,
    intflag: MclkInten,
    hsdiv: u8,
    cpudiv: MclkCpuDiv,
    reserved1: [10]u8,
    ahbmask: Ahbmask,
    apbamask: Apbamask,
    apbbmask: Apbbmask,
    apbcmask: Apbcmask,
    apbdmask: Apbdmask,
};

pub const mclk: *volatile Mclk = @ptrFromInt(MCLK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Mclk));
}
