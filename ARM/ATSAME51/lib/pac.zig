const PAC_BASE = 0x40000000;

pub const Perid = enum(u16) {
    pac           = 0, // Instance index for PAC (PAC) 
    pm            = 1, // Instance index for PM (PM) 
    mclk          = 2, // Instance index for MCLK (MCLK) 
    rstc          = 3, // Instance index for RSTC (RSTC) 
    oscctrl       = 4, // Instance index for OSCCTRL (OSCCTRL) 
    osc32kctrl    = 5, // Instance index for OSC32KCTRL (OSC32KCTRL) 
    supc          = 6, // Instance index for SUPC (SUPC) 
    gclk          = 7, // Instance index for GCLK (GCLK) 
    wdt           = 8, // Instance index for WDT (WDT) 
    rtc           = 9, // Instance index for RTC (RTC) 
    eic           =10, // Instance index for EIC (EIC) 
    freqm         =11, // Instance index for FREQM (FREQM) 
    sercom0       =12, // Instance index for SERCOM0 (SERCOM0) 
    sercom1       =13, // Instance index for SERCOM1 (SERCOM1) 
    tc0           =14, // Instance index for TC0 (TC0) 
    tc1           =15, // Instance index for TC1 (TC1) 
    usb           =32, // Instance index for USB (USB) 
    dsu           =33, // Instance index for DSU (DSU) 
    nvmctrl       =34, // Instance index for NVMCTRL (NVMCTRL) 
    cmcc          =35, // Instance index for CMCC (CMCC) 
    port          =36, // Instance index for PORT (PORT) 
    dmac          =37, // Instance index for DMAC (DMAC) 
    hmatrix       =38, // HSB Matrix (HMATRIX) 
    evsys         =39, // Instance index for EVSYS (EVSYS) 
    sercom2       =41, // Instance index for SERCOM2 (SERCOM2) 
    sercom3       =42, // Instance index for SERCOM3 (SERCOM3) 
    tcc0          =43, // Instance index for TCC0 (TCC0) 
    tcc1          =44, // Instance index for TCC1 (TCC1) 
    tc2           =45, // Instance index for TC2 (TC2) 
    tc3           =46, // Instance index for TC3 (TC3) 
    ramecc        =48, // Instance index for RAMECC (RAMECC) 
    can0          =64, // Control Area Network (CAN0) 
    can1          =65, // Control Area Network (CAN1) 
    tcc2          =67, // Instance index for TCC2 (TCC2) 
    tcc3          =68, // Instance index for TCC3 (TCC3) 
    tc4           =69, // Instance index for TC4 (TC4) 
    tc5           =70, // Basic Timer Counter (TC5) 
    pdec          =71, // Instance index for PDEC (PDEC) 
    ac            =72, // Instance index for AC (AC) 
    aes           =73, // Advanced Encryption Standard (AES) 
    trng          =74, // Instance index for TRNG (TRNG) 
    icm           =75, // Integrity Check Monitor (ICM) 
    pukcc         =76, // Instance index for PUKCC (PUKCC) 
    qspi          =77, // Instance index for QSPI (QSPI) 
    ccl           =78, // Instance index for CCL (CCL) 
    sercom4       =96, // Instance index for SERCOM4 (SERCOM4) 
    sercom5       =97, // Serial Communication Interface (SERCOM5) 
    tcc4          =100, // Instance index for TCC4 (TCC4) 
    adc0          =103, // Instance index for ADC0 (ADC0) 
    adc1          =104, // Instance index for ADC1 (ADC1) 
    dac           =105, // Instance index for DAC (DAC) 
    i2s           =106, // Instance index for I2S (I2S) 
    pcc           =107, // Instance index for PCC (PCC) 
};

pub const PacKey = enum(u8) {
    off = 0,
    clr = 1,
    set = 2,
    setlck = 3,
};

pub const PacWrctrl = bitpack struct(u32) {
    perid: Perid = .pac,
    key: PacKey = .off,
    reserved0: u8 = 0,
};

pub const PacEvctrl = bitpack struct(u8) {
    err: bool = false,
    reserved0: u7 = 0,
};

pub const PacIntflagahb = bitpack struct(u32) {
    flash: bool = false,
    flash_alt: bool = false,
    seeprom: bool = false,
    ramcm4s: bool = false,
    rampppdsu: bool = false,
    ramdmawr: bool = false,
    ramdmacicm: bool = false,
    hpb0: bool = false,
    hpb1: bool = false,
    hpb2: bool = false,
    hpb3: bool = false,
    pukcc: bool = false,
    sdhc0: bool = false,
    reserved0: u1 = 0,
    qspi: bool = false,
    reserved1: u17 = 0,
};

pub const PacIntflaga = bitpack struct(u32) {
    pac: bool = false,
    pm: bool = false,
    mclk: bool = false,
    rstc: bool = false,
    oscctrl: bool = false,
    osc32kctrl: bool = false,
    supc: bool = false,
    gclk: bool = false,
    wdt: bool = false,
    rtc: bool = false,
    eic: bool = false,
    freqm: bool = false,
    sercom0: bool = false,
    sercom1: bool = false,
    tc0: bool = false,
    tc1: bool = false,
    reserved0: u16 = 0,
};

pub const PacIntflagb = bitpack struct(u32) {
    usb: bool = false,
    dsu: bool = false,
    nvmctrl: bool = false,
    cmcc: bool = false,
    port: bool = false,
    dmac: bool = false,
    reserved0: u1 = 0,
    evsys: bool = false,
    reserved1: u1 = 0,
    sercom2: bool = false,
    sercom3: bool = false,
    tcc0: bool = false,
    tcc1: bool = false,
    tc2: bool = false,
    tc3: bool = false,
    reserved2: u1 = 0,
    ramecc: bool = false,
    reserved3: u15 = 0,
};

pub const PacIntflagc = bitpack struct(u32) {
    can0: bool = false,
    can1: bool = false,
    reserved0: u1 = 0,
    tcc2: bool = false,
    tcc3: bool = false,
    tc4: bool = false,
    tc5: bool = false,
    pdec: bool = false,
    ac: bool = false,
    aes: bool = false,
    trng: bool = false,
    icm: bool = false,
    pukcc: bool = false,
    qspi: bool = false,
    ccl: bool = false,
    reserved1: u17 = 0,
};

pub const PacIntflagd = bitpack struct(u32) {
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

pub const Pac = extern struct {
    wrctrl: PacWrctrl,
    evctrl: PacEvctrl,
    reserved0: [3]u8,
    intenclr: PacEvctrl,
    intenset: PacEvctrl,
    reserved1: [6]u8,
    intflagahb: PacIntflagahb,
    intflaga: PacIntflaga,
    intflagb: PacIntflagb,
    intflagc: PacIntflagc,
    intflagd: PacIntflagd,
    reserved2: [4]u32,
    statusa: PacIntflaga,
    statusb: PacIntflagb,
    statusc: PacIntflagc,
    statusd: PacIntflagd,
};

pub const pac: *volatile Pac = @ptrFromInt(PAC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x44, @sizeOf(Pac));
}
