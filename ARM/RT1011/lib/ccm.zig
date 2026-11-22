const CCM_BASE = 0x400FC000;

pub const CcmCcr = bitpack struct(u32) {
    oscnt: u8 = 127,
    reserved0: u4 = 0,
    cosc_en: bool = true,
    reserved1: u8 = 8,
    reg_bypass_count: u6 = 0x20,
    rbc_en: bool = false,
    reserved2: u4 = 0,
};

pub const CcmCsr = bitpack struct(u32) {
    ref_en_b: bool,
    reserved0: u2,
    camp2_ready: bool,
    reserved1: u1,
    cosc_ready: bool,
    reserved2: u26,
};

pub const CcmCcsr = bitpack struct(u32) {
    pll3_sw_clk_sel: bool = false,
    reserved0: u31 = 0,
};

pub const CcmCbcdr = bitpack struct(u32) {
    reserved0: u8 = 0,
    ipg_podf: u2 = 0,
    ahb_podf: u3 = 0,
    reserved1: u12 = 0x14,
    periph_clk_sel: bool = false,
    reserved2: u6 = 0,
};

pub const CcmLpspiClkSel = enum(u2) {
    pll3_pfd1 = 0,
    pll3_pfd0 = 1,
    pll2 = 2,
    pll2_pfd2 = 3,
};

pub const CcmPeriphClk2Sel = enum(u2) {
    pll3_sw = 0,
    osc = 1,
    pll2_bypass = 2,
};

pub const CcmTraceClkSel = enum(u2) {
    pll2 = 0,
    pll2_pfd2 = 1,
    pll2_pfd0 = 2,
    pll2_pfd1 = 3,
};

pub const CcmPrePeriphClkSel = enum(u2) {
    pll2 = 0,
    pll3_pfd3 = 1,
    pll2_pfd3 = 2,
    pll6 = 3,
};

pub const CcmCbcmr = bitpack struct(u32) {
    reserved0: u4 = 0,
    lpspi_clk_sel: CcmLpspiClkSel = .pll2,
    reserved1: u6 = 0,
    periph_clk2_sel: CcmPeriphClk2Sel = .pll3_sw,
    trace_clk_sel: CcmTraceClkSel = .pll2_pfd0,
    reserved2: u2 = 0,
    pre_periph_clk_sel: CcmPrePeriphClkSel = .pll2_pfd3,
    reserved3: u6 = 0,
    lpspi_podf: u4 = 3,
    reserved4: u2 = 0,
};

pub const CcmSaiClkSel = enum(u2) {
    pll3_pfd2 = 0,
    pll3_sw = 1,
    pll4 = 2,
};

pub const CcmFlexspiClkSel = enum(u2) {
    pll2 = 0,
    pll3_sw = 1,
    pll2_pfd2 = 2,
    pll3_pfd0 = 3,
};

pub const CcmCscmr1 = bitpack struct(u32) {
    perclk_podf: u6 = 0,
    perclk_clk_sel: bool = false,
    reserved0: u3 = 0,
    sai1_clk_sel: CcmSaiClkSel = .pll4,
    reserved1: u2 = 3,
    sai3_clk_sel: CcmSaiClkSel = .pll4,
    reserved2: u7 = 0,
    flexspi_podf: u3 = 1,
    reserved3: u3 = 0,
    flexspi_clk_sel: CcmFlexspiClkSel = .pll2,
    flexspi_clk_src: bool = false,
};

pub const CcmFlexio1ClkSel = enum(u2) {
    pll4 = 0,
    pll3_pfd2 = 1,
    pll2 = 2,
    pll3_sw = 3,
};

pub const CcmAdcAclkPodf = enum(u4) {
    reserved = 0,
    div8 = 7,
    div12 = 11,
    div16 = 15,
};

pub const CcmCscmr2 = bitpack struct(u32) {
    reserved0: u19 = 0,
    flexio1_clk_sel: CcmFlexio1ClkSel = .pll3_sw,
    reserved1: u6 = 0,
    adc_aclk_podf: CcmAdcAclkPodf = .reserved,
    adc_aclk_en: bool = false,
};

pub const UartClkSel = enum(u2) {
    pll3_80m = 0,
    osc = 1,
    per_clk_root = 2,
};

pub const CcmCscdr1 = bitpack struct(u32) {
    uart_clk_podf: u6 = 0,
    uart_clk_sel: UartClkSel = .pll3_80m,
    reserved0: u17 = 0,
    trace_podf: u4 = 3,
    reserved1: u3 = 0,
};

pub const CcmCs1cdr = bitpack struct(u32) {
    sai1_clk_podf: u6 = 1,
    sai1_clk_pred: u3 = 3,
    flexio1_clk_pred: u3 = 1,
    reserved0: u4 = 1,
    sai3_clk_podf: u6 = 1,
    sai3_clk_pred: u3 = 3,
    flexio1_clk_podf: u4 = 7,
    reserved1: u3 = 0,
};

pub const CcmSpdif0ClkSel = enum(u2) {
    pll4 = 0,
    pll3_pfd2 = 1,
    pll3_sw = 3,
};

pub const CcmCdcdr = bitpack struct(u32) {
    reserved0: u20 = 63,
    spdif0_clk_sel: CcmSpdif0ClkSel = .pll3_sw,
    spdif0_clk_podf: u3 = 7,
    spdif0_clk_pred: u3 = 1,
    reserved1: u4 = 0,
};
    
pub const CcmCscdr2 = bitpack struct(u32) {
    reserved0: u18 = 0x39000,
    lpi2c_clk_sel: bool = false,
    lpi2c_clk_podf: u6 = 0,
    reserved1: u7 = 0,
};

pub const CcmCdhipr = bitpack struct(u32) {
    reserved0: u1,
    ahb_podf_busy: bool,
    reserved1: u1,
    flexspi_podf_busy: bool,
    perclk_podf_busy: bool,
    periph_clk_sel_busy: bool,
    reserved2: u26,
};

pub const Lpm = enum(u2) {
    run = 0,
    wait = 1,
    stop = 2,
};

pub const StbyCount = enum(u2) {
    _1 = 0,
    _3 = 1,
    _7 = 2,
    _15 = 3,
};

pub const CcmClpcr = bitpack struct(u32) {
    lpm: Lpm = .wait,
    reserved0: u3 = 6,
    arm_clk_dis_on_lpm: bool = true,
    sbyos: bool = true,
    dis_ref_osc: bool = false,
    vstby: bool = false,
    stby_count: StbyCount = ._1,
    cosc_pwrdown: bool = false,
    reserved1: u10 = 0,
    mask_core0_wfi: bool = false,
    reserved2: u3 = 0,
    mask_scu_idle: bool = false,
    mask_l2cc_idle: bool = false,
    reserved3: u4 = 0,
};

pub const CcmCisr = bitpack struct(u32) {
    lrf_pll: bool = false,
    reserved0: u5 = 0,
    cosc_ready: bool = false,
    reserved1: u9 = 0,
    flexspi_podf_loaded: bool = false,
    reserved2: u1 = 0,
    perclk_podf_loaded: bool = false,
    reserved3: u1 = 0,
    ahb_podf_loaded: bool = false,
    reserved4: u1 = 0,
    periph_clk_sel_loaded: bool = false,
    reserved5: u9 = 0,
};

pub const CcmCimr = bitpack struct(u32) {
    mask_lrf_pll: bool = true,
    reserved0: u5 = 31,
    mask_cosc_ready: bool = true,
    reserved1: u9 = 511,
    mask_flexspi_podf_loaded: bool = true,
    reserved2: u1 = 1,
    mask_perclk_podf_loaded: bool = true,
    reserved3: u1 = 1,
    mask_ahb_podf_loaded: bool = true,
    reserved4: u1 = 1,
    mask_periph_clk_sel_loaded: bool = true,
    reserved5: u9 = 511,
};

pub const CcmClko1Sel = enum(u4) {
    pll3_sw = 0,
    pll2 = 1,
    enet_pll = 2,
    core_clk_root = 11,
    ipg_clk_root = 12,
    perclk_root = 13,
    pll4_main = 15,
};

pub const CcmClko2Sel = enum(u5) {
    lpi2c_clk_root = 6,
    reserved = 10,
    osc = 14,
    lpspi_clk = 16,
    sai1_clk = 18,
    sai3_clk = 20,
    trace_clk = 22,
    flexspi_clk = 27,
    uart_clk = 28,
    spdif0_clk = 29,
};

pub const CcmCcosr = bitpack struct(u32) {
    clko1_sel: CcmClko1Sel = .pll2,
    clko1_div: u3 = 0,
    clko1_en: bool = false,
    clk_out_sel: bool = false,
    reserved0: u7 = 0,
    clko2_sel: CcmClko2Sel = .reserved,
    clko2_div: u3 = 0,
    clko2_en: bool = false,
    reserved1: u7 = 0,
};

pub const CcmCgpr = bitpack struct(u32) {
    pmic_delay_scaler: bool = false,
    reserved0: u3 = 0,
    efuse_prog_supply_gate: bool = false,
    reserved1: u9 = 0,
    sys_mem_ds_ctrl: u2 = 3,
    fpl: bool = false,
    int_mem_clk_lpm: bool = false,
    reserved2: u14 = 0,
};

pub const CcmClockGate = enum(u2) {
    off = 0,
    on_in_run_mode = 1,
    on = 3
};

pub const CcmCcgr0 = bitpack struct(u32) {
    aips_tz1: CcmClockGate = .on,
    aips_tz2: CcmClockGate = .on,
    mqs: CcmClockGate = .on,
    flexspi_exsc: CcmClockGate = .on,
    sim_m_clk_r_clk: CcmClockGate = .on,
    dcp: CcmClockGate = .on,
    pluart3: CcmClockGate = .on,
    cg7: CcmClockGate = .on,
    cg8: CcmClockGate = .on,
    cg9: CcmClockGate = .on,
    cg10: CcmClockGate = .on,
    trace: CcmClockGate = .on,
    gpt2_bus: CcmClockGate = .on,
    gpt2_serial: CcmClockGate = .on,
    lpuart2: CcmClockGate = .on,
    gpio2: CcmClockGate = .on,
};

pub const CcmCcgr1 = bitpack struct(u32) {
    lpspi1: CcmClockGate = .on,
    lpspi2: CcmClockGate = .on,
    cg2: CcmClockGate = .on,
    cg3: CcmClockGate = .on,
    cg4: CcmClockGate = .on,
    cg5: CcmClockGate = .on,
    pit: CcmClockGate = .on,
    cg7: CcmClockGate = .on,
    adc1: CcmClockGate = .on,
    cg9: CcmClockGate = .on,
    gpt1_bus: CcmClockGate = .on,
    gpt1_serial: CcmClockGate = .on,
    lpuart4: CcmClockGate = .on,
    gpio1: CcmClockGate = .on,
    csu: CcmClockGate = .on,
    gpio5: CcmClockGate = .on,
};

pub const CcmCcgr2 = bitpack struct(u32) {
    ocram_exsc: CcmClockGate = .on,
    cg1: CcmClockGate = .on,
    iomuxc_snvs: CcmClockGate = .on,
    lpi2c1: CcmClockGate = .on,
    lpi2c2: CcmClockGate = .on,
    cg5: CcmClockGate = .on,
    ocotp: CcmClockGate = .on,
    cg7: CcmClockGate = .on,
    cg8: CcmClockGate = .on,
    cg9: CcmClockGate = .on,
    cg10: CcmClockGate = .on,
    xbar1: CcmClockGate = .on,
    cg12: CcmClockGate = .on,
    cg13: CcmClockGate = .on,
    cg14: CcmClockGate = .on,
    cg15: CcmClockGate = .on,
};

pub const CcmCcgr3 = bitpack struct(u32) {
    cg0: CcmClockGate = .on,
    cg1: CcmClockGate = .on,
    cg2: CcmClockGate = .on,
    cg3: CcmClockGate = .on,
    aoi1: CcmClockGate = .on,
    cg5: CcmClockGate = .on,
    cg6: CcmClockGate = .on,
    ewm: CcmClockGate = .on,
    wdog1: CcmClockGate = .on,
    flexram: CcmClockGate = .on,
    cg10: CcmClockGate = .on,
    cg11: CcmClockGate = .on,
    cg12: CcmClockGate = .on,
    cg13: CcmClockGate = .on,
    ocram: CcmClockGate = .on,
    iomuxc_snvs_gpr: CcmClockGate = .on,
};

pub const CcmCcgr4 = bitpack struct(u32) {
    sim_m7_clk_r: CcmClockGate = .on,
    iomuxc: CcmClockGate = .on,
    iomuxc_gpr: CcmClockGate = .on,
    cg3: CcmClockGate = .on,
    sim_m7: CcmClockGate = .on,
    cg5: CcmClockGate = .on,
    sim_m: CcmClockGate = .on,
    sim_ems: CcmClockGate = .on,
    pwm1: CcmClockGate = .on,
    cg9: CcmClockGate = .on,
    cg10: CcmClockGate = .on,
    cg11: CcmClockGate = .on,
    cg12: CcmClockGate = .on,
    cg13: CcmClockGate = .on,
    cg14: CcmClockGate = .on,
    dma_ps: CcmClockGate = .on,
};

pub const CcmCcgr5 = bitpack struct(u32) {
    rim: CcmClockGate = .on,
    flexio1: CcmClockGate = .on,
    wdog3: CcmClockGate = .on,
    dma: CcmClockGate = .on,
    kpp: CcmClockGate = .on,
    wdog2: CcmClockGate = .on,
    cg6: CcmClockGate = .on,
    spdif: CcmClockGate = .on,
    cg8: CcmClockGate = .on,
    sai1: CcmClockGate = .on,
    cg10: CcmClockGate = .on,
    sai3: CcmClockGate = .on,
    lpuart1: CcmClockGate = .on,
    cg13: CcmClockGate = .on,
    snvs_hp: CcmClockGate = .on,
    snvs_lp: CcmClockGate = .on,
};

pub const CcmCcgr6 = bitpack struct(u32) {
    usboh3: CcmClockGate = .on,
    cg1: CcmClockGate = .on,
    cg2: CcmClockGate = .on,
    dcdc: CcmClockGate = .on,
    cg4: CcmClockGate = .on,
    flexspi: CcmClockGate = .on,
    trng: CcmClockGate = .on,
    cg7: CcmClockGate = .on,
    cg8: CcmClockGate = .on,
    cg9: CcmClockGate = .on,
    sim_per: CcmClockGate = .on,
    anadig: CcmClockGate = .on,
    cg12: CcmClockGate = .on,
    cg13: CcmClockGate = .on,
    cg14: CcmClockGate = .on,
    cg15: CcmClockGate = .on,
};

pub const CcmCmeor = bitpack struct(u32) {
    reserved0: u5 = 31,
    mod_en_ov_gpt: bool = true,
    mod_en_ov_pit: bool = true,
    reserved1: u2 = 3,
    mod_en_ov_trng: bool = true,
    reserved2: u22 = 0x3FFFFF,
};

pub const Ccm = extern struct {
    ccr: CcmCcr,
    reserved0: u32,
    csr: CcmCsr,
    ccsr: CcmCcsr,
    reserved1: u32,
    cbcdr: CcmCbcdr,
    cbcmr: CcmCbcmr,
    cscmr1: CcmCscmr1,
    cscmr2: CcmCscmr2,
    cscdr1: CcmCscdr1,
    cs1cdr: CcmCs1cdr,
    reserved2: u32,
    cdcdr: CcmCdcdr,
    reserved3: u32,
    cscdr2: CcmCscdr2,
    reserved4: [3]u32,
    cdhipr: CcmCdhipr,
    reserved5: [2]u32,
    clpcr: CcmClpcr,
    cisr: CcmCisr,
    cimr: CcmCimr,
    ccosr: CcmCcosr,
    cgpr: CcmCgpr,
    ccgr0: CcmCcgr0,
    ccgr1: CcmCcgr1,
    ccgr2: CcmCcgr2,
    ccgr3: CcmCcgr3,
    ccgr4: CcmCcgr4,
    ccgr5: CcmCcgr5,
    ccgr6: CcmCcgr6,
    reserved6: u32,
    cmeor: CcmCmeor,
};

pub const ccm: *volatile Ccm = @ptrFromInt(CCM_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x8C, @sizeOf(Ccm));
}
