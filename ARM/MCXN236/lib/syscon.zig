const SYSCON0_BASE = 0x40000000;


pub const Ahbmatprio = bitpack struct(u32) {
    pri_cpu0_cbus: u2 = 0,
    pri_cpu0_sbus: u2 = 0,
    reserved0: u4 = 0,
    dma0: u2 = 0,
    dma1: u2 = 0,
    pri_pkc_els: u2 = 0,
    reserved1: u12 = 0,
    pri_usb_hs: u2 = 0,
    reserved2: u4 = 0
};

pub const Cpu0stckcal = bitpack struct(u32) {
    tenms: u24 = 0,
    skew: bool = false,
    noref: bool = false,
    reserved0: u6 = 0,
};

pub const Nmisrc = bitpack struct(u32) {
    irqcpu0: u8 = 0,
    reserved0: u23 = 0,
    nmiencpu0: bool = false,
};

pub const Presetctrl0 = bitpack struct(u32) {
    reserved0: u9 = 0,
    fmu_rst: bool = false,
    reserved1: u2 = 0,
    mux_rst: bool = false,
    port0_rst: bool = false,
    port1_rst: bool = false,
    port2_rst: bool = false,
    port3_rst: bool = false,
    port4_rst: bool = false,
    reserved2: u1 = 0,
    gpio0_rst: bool = false,
    gpio1_rst: bool = false,
    gpio2_rst: bool = false,
    gpio3_rst: bool = false,
    gpio4_rst: bool = false,
    reserved3: u1 = 0,
    pint_rst: bool = false,
    dma0_rst: bool = false,
    crc_rst: bool = false,
    reserved4: u4 = 0,
};

pub const Presetctrl1 = bitpack struct(u32) {
    mrt_rst: bool = false,
    ostimer_rst: bool = false,
    reserved0: u1 = 0,
    adc0_rst: bool = false,
    adc1_rst: bool = false,
    reserved1: u1 = 0,
    rtc_rst: bool = false,
    reserved2: u3 = 0,
    utick_rst: bool = false,
    fc0_rst: bool = false,
    fc1_rst: bool = false,
    fc2_rst: bool = false,
    fc3_rst: bool = false,
    fc4_rst: bool = false,
    fc5_rst: bool = false,
    fc6_rst: bool = false,
    fc7_rst: bool = false,
    reserved3: u2 = 0,
    micfil_rst: bool = false,
    timer2_rst: bool = false,
    reserved4: u3 = 0,
    timer0_rst: bool = false,
    timer1_rst: bool = false,
    reserved5: u3 = 0,
    smartdma_rst: bool = false,
};

pub const Presetctrl2 = bitpack struct(u32) {
    reserved0: u1 = 0,
    dma1_rst: bool = false,
    reserved1: u2 = 0,
    flexio_rst: bool = false,
    sai0_rst: bool = false,
    sai1_rst: bool = false,
    tro_rst: bool = false,
    freqme_rst: bool = false,
    reserved2: u5 = 0,
    flexcan0_rst: bool = false,
    flexcan1_rst: bool = false,
    usb_hs_rst: bool = false,
    usb_hs_phy_rst: bool = false,
    reserved3: u3 = 0,
    timer3_rst: bool = false,
    timer4_rst: bool = false,
    puf_rst: bool = false,
    pkc_rst: bool = false,
    reserved4: u7 = 0,
};

pub const Presetctrl3 = bitpack struct(u32) {
    i3c0_rst: bool = false,
    i3c1_rst: bool = false,
    reserved0: u2 = 0,
    qdc0_rst: bool = false,
    qdc1_rst: bool = false,
    pwm0_rst: bool = false,
    pwm1_rst: bool = false,
    aoi0_rst: bool = false,
    reserved1: u10 = 0,
    vref_rst: bool = false,
    reserved2: u3 = 0,
    ewm_rst: bool = false,
    eim_rst: bool = false,
    reserved3: u7 = 0,
};

pub const Ahbclkctrl0 = bitpack struct(u32) {
    reserved0: u1 = 0,
    rom: bool = true,
    ramb_ctrl: bool = false,
    ramc_ctrl: bool = false,
    ramd_ctrl: bool = false,
    rame_ctrl: bool = false,
    reserved1: u3 = 0,
    fmu: bool = true,
    fmc: bool = true,
    reserved2: u1 = 0,
    mux: bool = false,
    port0: bool = false,
    port1: bool = false,
    port2: bool = false,
    port3: bool = false,
    port4: bool = false,
    reserved3: u1 = 0,
    gpio0: bool = false,
    gpio1: bool = false,
    gpio2: bool = false,
    gpio3: bool = false,
    gpio4: bool = false,
    reserved4: u1 = 0,
    pint: bool = false,
    dma0: bool = false,
    crc: bool = false,
    wwdt0: bool = false,
    wwdt1: bool = false,
    reserved5: u2 = 0,
};

pub const Ahbclkctrl1 = bitpack struct(u32) {
    mrt: bool = false,
    ostimer: bool = false,
    reserved0: u1 = 0,
    adc0: bool = false,
    adc1: bool = false,
    reserved1: u1 = 0,
    rtc: bool = false,
    reserved2: u3 = 0,
    utick: bool = false,
    fc0: bool = false,
    fc1: bool = false,
    fc2: bool = false,
    fc3: bool = false,
    fc4: bool = false,
    fc5: bool = false,
    fc6: bool = false,
    fc7: bool = false,
    reserved3: u2 = 0,
    micfil: bool = false,
    timer2: bool = false,
    reserved4: u3 = 0,
    timer0: bool = false,
    timer1: bool = false,
    reserved5: u1 = 0,
    pkc_ram: bool = false,
    reserved6: u1 = 0,
    smartdma: bool = false,
};

pub const Ahbclkctrl2 = bitpack struct(u32) {
    reserved0: u1 = 0,
    dma1: bool = false,
    reserved1: u2 = 0,
    flexio: bool = false,
    sai0: bool = false,
    sai1: bool = false,
    tro: bool = false,
    freqme: bool = false,
    reserved2: u5 = 0,
    flexcan0: bool = false,
    flexcan1: bool = false,
    usb_hs: bool = false,
    usb_hs_phy: bool = false,
    els: bool = false,
    reserved3: u2 = 0,
    timer3: bool = false,
    timer4: bool = false,
    puf: bool = false,
    pkc: bool = false,
    reserved4: u1 = 0,
    scg: bool = false,
    reserved5: u2 = 0,
    gdet: bool = false,
    reserved6: u2 = 0,
};

pub const Ahbclkctrl3 = bitpack struct(u32) {
    i3c0: bool = false,
    i3c1: bool = false,
    reserved0: u2 = 0,
    qdc0: bool = false,
    qdc1: bool = false,
    pwm0: bool = false,
    pwm1: bool = false,
    evtg: bool = false,
    reserved1: u10 = 0,
    vref: bool = false,
    reserved2: u3 = 0,
    ewm: bool = false,
    eim: bool = false,
    erm: bool = false,
    intm: bool = false,
    reserved3: u5 = 0,
};

pub const Ckclksel = enum(u32) {
    ckclkdiv0 = 0,
    one_mhz = 1,
    lp_osc = 2,
    no_clock = 7
};

pub const Ctimerclksel = enum(u32) {
    fro_1m = 0,
    pll0 = 1,
    pll1_clk0 = 2,
    fro_hf = 3,
    fro_12_mhz = 4,
    sai0_mclk_in = 5,
    lp_osc = 6,
    sai1_mclk_in = 8,
    sai0_tx_bclk = 9,
    sai0_rx_bclk = 10,
    sai1_tx_bclk = 11,
    sai1_rx_bclk = 12,
    no_clock = 15
};

pub const Clkoutsel = enum(u32) {
    main_clk = 0,
    pll0_clk = 1,
    clkin = 2,
    fro_hf = 3,
    fro_12_mhz = 4,
    pll1_clk0 = 5,
    lp_osc = 6,
    usb_pll = 7,
    no_clock = 15
};

pub const Adcclksel = enum(u32) {
    pll0 = 1,
    fro_hf = 2,
    fro_12_mhz = 3,
    clkin = 4,
    pll1_clk0 = 5,
    usb_pll = 6,
    no_clock = 7
};

pub const Fcclksel = enum(u32) {
    pll_div = 1,
    fro_12_mhz = 2,
    fro_hf_div = 3,
    clk_1m = 4,
    usb_pll = 5,
    lp_osc = 6,
    no_clock = 7
};

pub const Clkdiv = bitpack struct(u32) {
    div: u8 = 0,
    reserved0: u21 = 0,
    reset: bool = false,
    halt: bool = true,
    unstab: bool = false,
};

pub const Slowclkdiv = bitpack struct(u32) {
    reserved0: u29 = 0,
    reset: bool = false,
    halt: bool = false,
    unstab: bool = false,
};

pub const Ahbclkdiv = bitpack struct(u32) {
    div: u8 = 0,
    reserved0: u23 = 0,
    unstab: bool = false,
};

pub const Frohfdiv = bitpack struct(u32) {
    div: u8 = 0,
    reserved0: u22 = 0,
    halt: bool = true,
    unstab: bool = false,
};

pub const Wdt0clkdiv = bitpack struct(u32) {
    div: u6 = 0,
    reserved0: u23 = 0,
    reset: bool = false,
    halt: bool = true,
    unstab: bool = false,
};

pub const Adcclkdiv = bitpack struct(u32) {
    div: u3 = 0,
    reserved0: u26 = 0,
    reset: bool = false,
    halt: bool = true,
    unstab: bool = false,
};

pub const Utickclkdiv = bitpack struct(u32) {
    div: u6 = 0,
    reserved0: u23 = 0,
    reset: bool = false,
    halt: bool = false,
    unstab: bool = false,
};

pub const ClkoutFrgctrl = bitpack struct(u32) {
    div: u8 = 255,
    mult: u8 = 0,
    reserved0: u16 = 0,
};

pub const Clkunlock = bitpack struct(u32) {
    unlock: bool = false,
    reserved0: u31 = 0,
};

pub const NvmCtrl = bitpack struct(u32) {
    dis_flash_spec: bool = false,
    dis_data_spec: bool = false,
    dis_flash_cache: bool = false,
    dis_flash_inst: bool = false,
    dis_flash_data: bool = true,
    clr_flash_cache: bool = false,
    reserved0: u4 = 1,
    flash_stall_en: bool = true,
    reserved1: u5 = 2,
    dis_mbecc_err_inst: bool = false,
    dis_mbecc_err_data: bool = true,
    reserved2: u14 = 0,
};

pub const Romcr = bitpack struct(u32) {
    rom_wait: bool = false,
    reserved0: u31 = 0,
};

pub const RamInterleave = bitpack struct(u32) {
    interleave: bool = false,
    reserved0: u31 = 0,
};

pub const Pllclkdivsel = enum(u32) {
    pll0 = 0,
    pll1_clk0 = 1,
    no_lock = 7
};

pub const I3cfclksel = enum(u32) {
    pll0 = 1,
    clkin = 2,
    fro_hf = 3,
    clk_1m = 4,
    pll1_clk0 = 5,
    usb_pll = 6,
    no_lock = 7
};

pub const Micfilfclksel = enum(u32) {
    fro_12m = 0,
    pll0 = 1,
    clkin = 2,
    fro_hf = 3,
    pll1_clk0 = 4,
    sai0_mclk = 5,
    usb_pll = 6,
    sai1_mclk = 8,
    no_clock = 15
};

pub const Micfilfclkdiv = bitpack struct(u32) {
    div: u3 = 0,
    reserved0: u26 = 2,
    reset: bool = false,
    halt: bool = true,
    unstab: bool = false,
};

pub const Flexioclksel = enum(u32) {
    pll0 = 1,
    clkin = 2,
    fro_hf = 3,
    fro_12m = 4,
    pll1_clk0 = 5,
    usb_pll = 6,
    no_clock = 7
};

pub const Flexcanclksel = enum(u32) {
    pll0 = 1,
    clkin = 2,
    fro_hf = 3,
    pll1_clk0 = 5,
    usb_pll = 6,
    no_clock = 7
};

pub const Ewm0clksel = bitpack struct(u32) {
    sel: bool = true,
    reserved0: u31 = 0,
};

pub const Wdt1clksel = enum(u32) {
    fro16k = 0,
    fro_hf_div = 1,
    clk_1m = 3
};

pub const Wdt1clkdiv = bitpack struct(u32) {
    div: u6 = 0,
    reserved0: u23 = 2,
    reset: bool = false,
    halt: bool = true,
    unstab: bool = false,
};

pub const Ostimerclksel = enum(u32) {
    clk_16k = 0,
    xtal32k = 1,
    clk_1m = 2,
    no_clock = 3
};

pub const Cmpfclksel = enum(u32) {
    pll0 = 1,
    fro_hf = 2,
    fro_12m = 3,
    clkin = 4,
    pll1_clk0 = 5,
    usb_pll = 6,
    no_clock = 7
};

pub const Cmpfclkdiv = bitpack struct(u32) {
    div: u4 = 0,
    reserved0: u25 = 2,
    reset: bool = false,
    halt: bool = true,
    unstab: bool = false,
};

pub const Cpustat = bitpack struct(u32) {
    cpu0sleeping: bool,
    reserved0: u1,
    cpu0lockup: bool,
    reserved1: u29,
};

pub const LpcacCtrl = bitpack struct(u32) {
    dis_lpcac: bool = true,
    clr_lpcac: bool = false,
    frc_no_alloc: bool = false,
    parity_miss_en: bool = false,
    dis_lpcac_wtbf: bool = true,
    lim_lpcac_wtbf: bool = true,
    parity_fault_en: bool = false,
    lpcac_xom: bool = false,
    reserved0: u24 = 0,
};

pub const Utickclksel = enum(u32) {
    clkin = 0,
    xtal32k = 1,
    clk_1m = 2,
    no_clock = 3
};

pub const Saiclksel = enum(u32) {
    pll0 = 1,
    clkin = 2,
    fro_hf = 3,
    pll1_clk0 = 4,
    usb_pll = 6,
    no_clock = 7
};

pub const Saiclkdiv = bitpack struct(u32) {
    div: u3 = 0,
    reserved0: u26 = 2,
    reset: bool = false,
    halt: bool = true,
    unstab: bool = false,
};

pub const ClockCtrl = bitpack struct(u32) {
    reserved0: u1 = 1,
    clkin_ena_fm_usbh_lpt: bool = false,
    fro1mhz_ena: bool = false,
    fro12mhz_ena: bool = false,
    fro_hf_ena: bool = false,
    clkin_ena: bool = false,
    fro1mhz_clk_ena: bool = false,
    reserved1: u25 = 1,
};

pub const Autoclkgateoverride = bitpack struct(u32) {
    reserved0: u2 = 3,
    ramb_ctrl: bool = true,
    ramc_ctrl: bool = true,
    ramd_ctrl: bool = true,
    rame_ctrl: bool = true,
    reserved1: u26 = 1023,
};

pub const Autoclkgateoverridec = bitpack struct(u32) {
    reserved0: u30 = 0,
    ramx: bool = false,
    rama: bool = false,
};

pub const Pwm0subctl = bitpack struct(u32) {
    clk0_en: bool = false,
    clk1_en: bool = false,
    clk2_en: bool = false,
    clk3_en: bool = false,
    reserved0: u8 = 0,
    dmavalm0: bool = false,
    dmavalm1: bool = false,
    dmavalm2: bool = false,
    dmavalm3: bool = false,
    reserved1: u16 = 0,
};

pub const Pwm1subctl = bitpack struct(u32) {
    clk0_en: bool = false,
    clk1_en: bool = false,
    clk2_en: bool = false,
    clk3_en: bool = false,
    reserved0: u8 = 0,
    dmavalm0: bool = false,
    dmavalm1: bool = false,
    dmavalm2: bool = false,
    dmavalm3: bool = false,
    reserved1: u16 = 0,
};

pub const Ctimerglobalstarten = bitpack struct(u32) {
    ctimer0_clk_en: bool = false,
    ctimer1_clk_en: bool = false,
    ctimer2_clk_en: bool = false,
    ctimer3_clk_en: bool = false,
    ctimer4_clk_en: bool = false,
    reserved0: u27 = 0,
};

pub const EccEnableCtrl = bitpack struct(u32) {
    rama_ecc_enable: bool = true,
    ramb_ramx_ecc_enable: bool = true,
    ramd_ramc_ecc_enable: bool = false,
    reserved0: u29 = 0,
};

pub const DeviceId0 = bitpack struct(u32) {
    reserved0: u20,
    rom_rev_minor: u4,
    reserved1: u8,
};

pub const Dieid = bitpack struct(u32) {
    minor_revision: u4,
    major_revision: u4,
    mco_num_in_die_id: u20,
    reserved0: u4,
};

pub const Syscon = extern struct {
    reserved0: [4]u32,
    ahbmatprio: Ahbmatprio,
    reserved1: [9]u32,
    cpu0stckcal: Cpu0stckcal,
    cpu0nsstckcal: Cpu0stckcal,
    reserved2: [2]u32,
    nmisrc: Nmisrc,
    reserved3: [45]u32,
    presetctrl0: Presetctrl0,
    presetctrl1: Presetctrl1,
    presetctrl2: Presetctrl2,
    presetctrl3: Presetctrl3,
    reserved4: [4]u32,
    presetctrlset: [4]u32,
    reserved5: [4]u32,
    presetctrlclr: [4]u32,
    reserved6: [44]u32,
    ahbclkctrl0: Ahbclkctrl0,
    ahbclkctrl1: Ahbclkctrl1,
    ahbclkctrl2: Ahbclkctrl2,
    ahbclkctrl3: Ahbclkctrl3,
    reserved7: [4]u32,
    ahbclkctrlset0: Ahbclkctrl0,
    ahbclkctrlset1: Ahbclkctrl1,
    ahbclkctrlset2: Ahbclkctrl2,
    ahbclkctrlset3: Ahbclkctrl3,
    reserved8: [4]u32,
    ahbclkctrlclr0: Ahbclkctrl0,
    ahbclkctrlclr1: Ahbclkctrl1,
    ahbclkctrlclr2: Ahbclkctrl2,
    ahbclkctrlclr3: Ahbclkctrl3,
    reserved9: [4]u32,
    systickclksel0: Ckclksel,
    reserved10: u32,
    traceclksel: Ckclksel,
    ctimerclksel: [5]Ctimerclksel,
    reserved11: [2]u32,
    clkoutsel: Clkoutsel,
    reserved12: [6]u32,
    adc0clksel: Ckclksel,
    reserved13: [2]u32,
    fcclksel: [8]Fcclksel,
    reserved14: [12]u32,
    systickclkdiv0: Clkdiv,
    reserved15: u32,
    traceclkdiv: Clkdiv,
    reserved16: [27]u32,
    slowclkdiv: Slowclkdiv,
    reserved17: u32,
    ahbclkdiv: Ahbclkdiv,
    clkoutdiv: Clkdiv,
    frohfdiv: Frohfdiv,
    wdt0clkdiv: Wdt0clkdiv,
    reserved18: u32,
    adc0clkdiv: Clkdiv,
    reserved19: [11]u32,
    pllclkdiv: Clkdiv,
    reserved20: [2]u32,
    ctimerclkdiv: [5]Clkdiv,
    pll1clk0div: Clkdiv,
    pll1clk1div: Clkdiv,
    reserved22: u32,
    utickclkdiv: Utickclkdiv,
    frgctrl: ClkoutFrgctrl,
    reserved23: u32,
    clkunlock: Clkunlock,
    nvm_ctrl: NvmCtrl,
    romcr: Romcr,
    reserved24: [3]u32,
    smartdmaint: u32,
    reserved25: [19]u32,
    adc1clksel: Adcclksel,
    adc1clkdiv: Adcclkdiv,
    reserved26: u32,
    interleave: RamInterleave,
    reserved27: [46]u32,
    pllclkdivsel: Pllclkdivsel,
    i3c0fclksel: I3cfclksel,
    reserved28: [3]u32,
    i3c0fclkdiv: Clkdiv,
    reserved29: u32,
    micfilfclksel: Ckclksel,
    micfilfclkdiv: Clkdiv,
    reserved30: [4]u32,
    flexioclksel: Flexioclksel,
    flexioclkdiv: Clkdiv,
    reserved31: [14]u32,
    flexcan0clksel: Flexcanclksel,
    flexcan0clkdiv: Clkdiv,
    flexcan1clksel: Flexcanclksel,
    flexcan1clkdiv: Clkdiv,
    reserved32: [9]u32,
    ewm0clksel: Ewm0clksel,
    wdt1clksel: Wdt1clksel,
    wdt1clkdiv: Wdt1clkdiv,
    ostimerclksel: Ostimerclksel,
    reserved33: [3]u32,
    cmp0fclksel: Cmpfclksel,
    cmp0fclkdiv: Cmpfclkdiv,
    cmp0rrclksel: Cmpfclksel,
    cmp0rrclkdiv: Cmpfclkdiv,
    cmp1fclksel: Cmpfclksel,
    cmp1fclkdiv: Cmpfclkdiv,
    cmp1rrclksel: Cmpfclksel,
    cmp1rrclkdiv: Cmpfclkdiv,
    reserved34: [127]u32,
    cpustat: Cpustat,
    reserved35: [5]u32,
    lpcac_ctrl: LpcacCtrl,
    reserved36: [10]u32,
    lp_flexcommclkdiv: [8]Clkdiv,
    reserved37: [2]u32,
    utickclksel: Utickclksel,
    reserved38: u32,
    sai0clksel: Saiclksel,
    sai1clksel: Saiclksel,
    sai0clkdiv: Saiclkdiv,
    sai1clkdiv: Saiclkdiv,
    reserved39: [98]u32,
    ctrl: ClockCtrl,
    reserved44: [69]u32,
    i3c1fclksel: I3cfclksel,
    reserved45: [3]u32,
    i3c1fclkdiv: Clkdiv,
    reserved46: [7]u32,
    gray_code_lsb: u32,
    gray_code_msb: u32,
    binary_code_lsb: u32,
    binary_code_msb: u32,
    reserved47: [165]u32,
    autoclkgateoverride: Autoclkgateoverride,
    reserved48: [9]u32,
    autoclkgateoverridec: Autoclkgateoverridec,
    reserved49: [2]u32,
    pwm0subctl: Pwm0subctl,
    pwm1subctl: Pwm1subctl,
    ctimerglobalstarten: Ctimerglobalstarten,
    ecc_enable_ctrl: EccEnableCtrl,
    reserved50: [106]u32,
    jtag_id: u32,
    device_type: u32,
    device_id0: DeviceId0,
    dieid: Dieid,
};

pub const syscon0: *volatile Syscon = @ptrFromInt(SYSCON0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1000, @sizeOf(Syscon));
}
