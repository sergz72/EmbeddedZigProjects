pub const CRM_BASE = 0x40021000;

pub const CrmCtrl = packed struct(u32) {
    hicken: bool = true,
    hickstbl: bool = true,
    hicktrim: u6 = 0x20,
    hickcal: u8,
    hexten: bool = false,
    hextstbl: bool = false,
    hextbyps: bool = false,
    cfden: bool = false,
    reserved: u4 = 0,
    pllen: bool = false,
    pllstbl: bool = false,
    reserved2: u6 = 0
};

pub const CrmSclkSel = enum(u2) {
    hick = 0,
    hext = 1,
    pll = 2
};

pub const CrmAhbDiv = enum(u4) {
    div1 = 0,
    div2 = 8,
    div4 = 9,
    div8 = 10,
    div16 = 11,
    div64 = 12,
    div128 = 13,
    div256 = 14,
    div512 = 15
};

pub const CrmApbDiv = enum(u3) {
    div1 = 0,
    div2 = 4,
    div4 = 5,
    div8 = 6,
    div16 = 7
};

pub const CrmCfg = packed struct(u32) {
    sclksel: CrmSclkSel = .hick,
    sclksts: CrmSclkSel = .hick,
    ahbdiv: CrmAhbDiv = .div1,
    apb1div: CrmApbDiv = .div1,
    apb2div: CrmApbDiv = .div1,
    adcdiv_l: u2 = 0,
    pllrcs: bool = false,
    pllhextdiv: bool = false,
    pllmult_l: u4 = 0,
    reserved1: u2 = 0,
    clkout_sel_l: u3 = 0,
    reserved2: u1 = 0,
    adcdiv_h: u1 = 0,
    pllmult_h: u2 = 0,
    reserved3: u1 = 0
};

pub const CrmClkInt = packed struct(u32) {
    lickstblf: bool = false,
    lextstblf: bool = false,
    hickstblf: bool = false,
    hextstblf: bool = false,
    pllstblf: bool = false,
    reserved1: u2 = 0,
    cfdf: bool = false,
    lickstblien: bool = false,
    lextstblien: bool = false,
    hickstblien: bool = false,
    hextstblien: bool = false,
    pllstblien: bool = false,
    reserved2: u3 = 0,
    lickstblfc: bool = false,
    lextstblfc: bool = false,
    hickstblfc: bool = false,
    hextstblfc: bool = false,
    pllstblfc: bool = false,
    reserved3: u2 = 0,
    cfdfc: bool = false,
    reserved4: u8 = 0
};

pub const CrmApb2 = packed struct(u32) {
    scfgcmp: bool = false,
    exint: bool = false,
    reserved1: u7 = 0,
    adc1: bool = false,
    reserved2: u1 = 0,
    tmr1: bool = false,
    spi1: bool = false,
    reserved3: u1 = 0,
    usart1: bool = false,
    reserved4: u1 = 0,
    tmr15: bool = false,
    tmr16: bool = false,
    tmr17: bool = false,
    reserved5: u13 = 0
};

pub const CrmApb1 = packed struct(u32) {
    reserved1: u1 = 0,
    tmr3: bool = false,
    reserved2: u2 = 0,
    tmr6: bool = false,
    reserved3: u3 = 0,
    tmr4: bool = false,
    reserved4: u2 = 0,
    wwdt: bool = false,
    reserved5: u2 = 0,
    spi2: bool = false,
    reserved6: u2 = 0,
    usart2: bool = false,
    reserved7: u3 = 0,
    i2c1: bool = false,
    i2c2: bool = false,
    reserved8: u2 = 0,
    can1: bool = false,
    reserved9: u2 = 0,
    pwc: bool = false,
    reserved10: u3 = 0
};

pub const CrmAhbEn = packed struct(u32) {
    dma1en: bool = false,
    reserved1: u1 = 0,
    sramen: bool = true,
    reserved2: u1 = 0,
    flashen: bool = true,
    reserved3: u1 = 0,
    crcen: bool = false,
    reserved4: u10 = 0,
    gpioaen: bool = false,
    gpioben: bool = false,
    gpiocen: bool = false,
    reserved5: u2 = 0,
    gpiofen: bool = false,
    reserved6: u9 = 0
};

pub const CrmBpdc = packed struct(u32) {
    lexten: bool = false,
    lextstbl: bool = false,
    lextbyps: bool = false,
    lextdrv: u2 = 0,
    reserved1: u3 = 0,
    ertcsel: u2 = 0,
    reserved2: u5 = 0,
    ertcen: bool = false,
    bpdrst: bool = false,
    reserved3: u15 = 0
};

pub const CrmCtrlSts = packed struct(u32) {
    licken: bool = false,
    lickstbl: bool = false,
    reserved1: u22 = 0,
    rstfc: bool = false,
    reserved2: u1 = 0,
    nrstf: bool = true,
    porrstf: bool = true,
    swrstf: bool = false,
    wdtrstf: bool = false,
    wwdtrstf: bool = false,
    lprstf: bool = false
};

pub const CrmAhbRst = packed struct(u32) {
    dma1rst: bool = false,
    reserved1: u1 = 0,
    sramrst: bool = false,
    reserved2: u1 = 0,
    flashrst: bool = false,
    reserved3: u1 = 0,
    crcrst: bool = false,
    reserved4: u10 = 0,
    gpioarst: bool = false,
    gpiobrst: bool = false,
    gpiocrst: bool = false,
    reserved5: u2 = 0,
    gpiofrst: bool = false,
    reserved6: u9 = 0
};

pub const CrmPllFr = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5
};

pub const CrmPllRef = enum(u3) {
    _3p9_to_5MHz = 0,
    _5p2_to_6p25MHz = 1,
    _7p8125_to_8p33MHz = 2,
    _8p33_to_12p5MHz = 3,
    _15p625_to_20p83MHz = 4,
    _20p83_to_31p255MHz = 5
};

pub const CrmPll = packed struct(u32) {
    pllfr: CrmPllFr = .div1,
    reserved1: u1 = 0,
    pllms: u4 = 1,
    pllns: u9 = 0x1F,
    reserved2: u7 = 0,
    pllfref: CrmPllRef = ._3p9_to_5MHz,
    reserved3: u4 = 0,
    pllcfgen: bool = false
};

pub const CrmClkoutDiv = enum(u4) {
    div1 = 0,
    div2 = 8,
    div4 = 9,
    div8 = 10,
    div16 = 11,
    div64 = 12,
    div128 = 13,
    div256 = 14,
    div512 = 15
};

pub const CrmMisc1 = packed struct(u32) {
    hickcal_key: u8 = 0,
    reserved1: u8 = 0,
    clkout_sel: bool = false,
    reserved2: u8 = 0,
    hickdiv: bool = false,
    reserved4: u2 = 0,
    clkoutdiv: CrmClkoutDiv = .div1
};

pub const CrmApb3Div = enum(u3) {
    div1 = 0,
    div2 = 4,
    div4 = 5,
    div8 = 6,
    div16 = 7
};

pub const CrmHextDrv = enum(u2) {
    low = 0,
    medium_low = 1,
    medimum_high = 2,
    high = 3
};

pub const CrmVbathDiv = enum(u2) {
    div1 = 0,
    div2 = 2,
    div4 = 3
};

pub const CrmAutoStepEn = enum(u2) {
    disabled = 0,
    enabled = 3
};

pub const CrmMisc2 = packed struct(u32) {
    reserved1: u4 = 0x0D,
    auto_step_en: CrmAutoStepEn = .disabled,
    reserved2: u3 = 0,
    hick_to_sclk: bool = false,
    reserved3: u2 = 0,
    apb3div: CrmApb3Div = .div4,
    reserved4: u7 = 0,
    hextdrv: CrmHextDrv = .medimum_high,
    vbathdiv: CrmVbathDiv = .div4,
    reserved5: u6 = 0
};

pub const CrmCanClkSel = enum(u2) {
    hext = 0,
    pll = 1,
    pclk = 2
};

pub const CrmPiclks = packed struct(u32) {
    rtc_pclksel: bool = false,
    reserved1: u23 = 0,
    can1_clksel: CrmCanClkSel = .hext,
    reserved2: u6 = 0
};

pub const Crm = extern struct {
    ctrl: CrmCtrl,
    cfg: CrmCfg,
    clkint: CrmClkInt,
    apb2rst: CrmApb2,
    apb1rst: CrmApb1,
    ahben: CrmAhbEn,
    apb2en: CrmApb2,
    apb1en: CrmApb1,
    bpdc: CrmBpdc,
    ctrlsts: CrmCtrlSts,
    ahbrst: CrmAhbRst,
    pll: CrmPll,
    misc1: CrmMisc1,
    reserved2: [8]u32,
    misc2: CrmMisc2,
    reserved3: [4]u32,
    piclks: CrmPiclks
};

pub const crm: *volatile Crm = @ptrFromInt(CRM_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x6C, @sizeOf(Crm));
}
