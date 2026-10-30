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
    usbdiv_l: u2 = 0,
    clkout_sel_l: u3 = 0,
    usbdiv_h: u1 = 0,
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
    iomux: bool = false,
    exint: bool = false,
    gpioa: bool = false,
    gpiob: bool = false,
    gpioc: bool = false,
    gpiod: bool = false,
    gpioe: bool = false,
    reserved1: u2 = 0,
    adc1: bool = false,
    adc2: bool = false,
    tmr1: bool = false,
    spi1: bool = false,
    tmr8: bool = false,
    usart1: bool = false,
    adc3: bool = false,
    reserved2: u3 = 0,
    tmr9: bool = false,
    tmr10: bool = false,
    tmr11: bool = false,
    acc: bool = false,
    i2c3: bool = false,
    uart6: bool = false,
    uart7: bool = false,
    uart8: bool = false,
    reserved5: u5 = 0
};

pub const CrmApb1 = packed struct(u32) {
    tmr2: bool = false,
    tmr3: bool = false,
    tmr4: bool = false,
    tmr5: bool = false,
    tmr6: bool = false,
    tmr7: bool = false,
    tmr12: bool = false,
    tmr13: bool = false,
    tmr14: bool = false,
    reserved: u2 = 0,
    wwdt: bool = false,
    reserved2: u2 = 0,
    spi2: bool = false,
    spi3: bool = false,
    spi4: bool = false,
    usart2: bool = false,
    usart3: bool = false,
    uart4: bool = false,
    uart5: bool = false,
    i2c1: bool = false,
    i2c2: bool = false,
    usb: bool = false,
    reserved3: u1 = 0,
    can1: bool = false,
    can2: bool = false,
    bpr: bool = false,
    pwc: bool = false,
    dac: bool = false,
    reserved10: u2 = 0
};

pub const CrmAhbEn = packed struct(u32) {
    dma1en: bool = false,
    dma2en: bool = false,
    sramen: bool = true,
    reserved2: u1 = 0,
    flashen: bool = true,
    reserved3: u1 = 0,
    crcen: bool = false,
    reserved4: u1 = 0,
    xmcen: bool = false,
    reserved5: u1 = 0,
    sdio1en: bool = false,
    sdio2en: bool = false,
    reserved: u2 = 0,
    emacen: bool = false,
    emactxen: bool = false,
    emacrxen: bool = false,
    reserved6: u11 = 0,
    emacptpen: bool = false,
    reserved7: u3 = 0
};

pub const CrmRtcsel = enum(u2) {
    no_clock = 0,
    lext = 1,
    lick = 2,
    hext_div128 = 3
};

pub const CrmBpdc = packed struct(u32) {
    lexten: bool = false,
    lextstbl: bool = false,
    lextbyps: bool = false,
    reserved1: u5 = 0,
    rtcsel: CrmRtcsel = .no_clock,
    reserved2: u5 = 0,
    rtcen: bool = false,
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
    reserved1: u14 = 0,
    emacrst: bool = false,
    reserved6: u17 = 0
};

pub const CrmClkoutDiv = enum(u4) {
    div1 = 0,
    div2 = 8,
    div4 = 9,
    div8 = 10,
    div16 = 11,
    div64 = 12,
    div128 = 13,
    div256 = 14
};

pub const CrmMisc1 = packed struct(u32) {
    hickcal_key: u8 = 0,
    reserved1: u8 = 0,
    clkout_sel: u1 = 0,
    reserved2: u7 = 0,
    usbbufs: bool = false,
    hickdiv: bool = false,
    reserved4: u2 = 0,
    clkoutdiv: CrmClkoutDiv = .div1
};

pub const CrmHextDiv = enum(u2) {
    div2 = 0,
    div3 = 1,
    div4 = 2,
    div5 = 3
};

pub const CrmAutoStepEn = enum(u2) {
    disabled = 0,
    enabled = 3
};

pub const CrmMisc2 = packed struct(u32) {
    reserved1: u16 = 0,
    clk_to_tmr: bool = false,
    reserved2: u15 = 0
};

pub const CrmMisc3 = packed struct(u32) {
    reserved1: u4 = 0x0D,
    auto_step_en: CrmAutoStepEn = .disabled,
    reserved2: u2 = 0,
    hick_to_usb: bool = false,
    hick_to_sclk: bool = false,
    reserved3: u2 = 0,
    hextdiv: CrmHextDiv = .div4,
    reserved4: u1 = 0,
    emac_pps_sel: bool = false,
    reserved5: u16 = 0
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
    reserved: u32,
    misc1: CrmMisc1,
    reserved2: [7]u32,
    misc2: CrmMisc2,
    misc3: CrmMisc3,
    reserved3: u32,
    intmap: u32,

    pub fn getResetCause(self: *volatile Crm) []const u8 {
        const sts = self.ctrlsts;
        self.ctrlsts.rstfc = true; // Clear reset flags after reading
        if (sts.lprstf) return "Low Power Reset";
        if (sts.wwdtrstf) return "WWDT Reset";
        if (sts.wdtrstf) return "WDT Reset";
        if (sts.swrstf) return "Software Reset";
        if (sts.porrstf) return "POR Reset";
        if (sts.nrstf) return "NRST Reset";
        return "Unknown Reset Cause";
    }

    pub fn rtcEnable(self: *volatile Crm) void {
        self.bpdc.lexten = true;
        while (!self.bpdc.lextstbl) {
            asm volatile ("nop");
        }
        self.bpdc.rtcsel = .lext;
        self.bpdc.rtcen = true;
    }
};

pub const crm: *volatile Crm = @ptrFromInt(CRM_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x60, @sizeOf(Crm));
}
