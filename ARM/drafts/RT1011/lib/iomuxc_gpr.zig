const IOMUXC_GPR_BASE = 0x400AC000;

pub const IomuxSaiMclkSel = enum(u3) {
    ccm_ssi1 = 0,
    ccm_ssi3 = 2,
    iomux_sai1_ipg = 3,
    iomux_sai3_ipg = 5,
};

pub const IomuxSaiMclk3Sel = enum(u2) {
    ccm_spdif0 = 0,
    spdif_ext = 1,
    spdif_srclk = 2,
    spdif_outclock = 3,
};

pub const IomuxGpr1 = bitpack struct(u32) {
    sai1_mclk1_sel: IomuxSaiMclkSel = .ccm_ssi1,
    sai1_mclk2_sel: IomuxSaiMclkSel = .ccm_ssi1,
    sai1_mclk3_sel: IomuxSaiMclk3Sel = .ccm_spdif0,
    reserved0: u2 = 0,
    sai3_mclk3_sel: IomuxSaiMclk3Sel = .ccm_spdif0,
    gint: bool = false,
    reserved1: u6 = 0,
    sai1_mclk_dir: bool = false,
    reserved2: u1 = 0,
    sai3_mclk_dir: bool = false,
    exc_mon: bool = false,
    reserved3: u8 = 0,
    cm7_force_hclk_en: bool = false,
};

pub const IomuxGpr2 = bitpack struct(u32) {
    reserved0: u3 = 0,
    axbs_p_m0_high_priority: bool = false,
    axbs_p_m1_high_priority: bool = false,
    axbs_p_force_round_robin: bool = false,
    reserved1: u6 = 0,
    l2_mem_en_powersaving: bool = false,
    ram_auto_clk_gating_en: bool = false,
    l2_mem_deepsleep: bool = false,
    reserved2: u1 = 0,
    mqs_clk_div: u8 = 0,
    mqs_sw_rst: bool = false,
    mqs_en: bool = false,
    mqs_oversample: bool = false,
    reserved3: u5 = 0,
};

pub const IomuxGpr3 = bitpack struct(u32) {
    reserved0: u4 = 15,
    dcp_key_sel: bool = true,
    reserved1: u27 = 127,
};

pub const IomuxGpr4 = bitpack struct(u32) {
    edma_stop_req: bool = false,
    reserved0: u2 = 0,
    trng_stop_req: bool = false,
    reserved1: u1 = 0,
    sai1_stop_req: bool = false,
    reserved2: u1 = 0,
    sai3_stop_req: bool = false,
    reserved3: u2 = 0,
    pit_stop_req: bool = false,
    flexspi_stop_req: bool = false,
    flexio1_stop_req: bool = false,
    reserved4: u3 = 0,
    edma_stop_ack: bool = false,
    reserved5: u2 = 0,
    trng_stop_ack: bool = false,
    reserved6: u1 = 0,
    sai1_stop_ack: bool = false,
    reserved7: u1 = 0,
    sai3_stop_ack: bool = false,
    reserved8: u2 = 0,
    pit_stop_ack: bool = false,
    flexspi_stop_ack: bool = false,
    flexio1_stop_ack: bool = false,
    reserved9: u3 = 0,
};

pub const IomuxGpr5 = bitpack struct(u32) {
    reserved0: u6 = 0,
    wdog1_mask: bool = false,
    wdog2_mask: bool = false,
    reserved1: u20 = 0,
    vref_1m_clk_gpt1: bool = false,
    vref_1m_clk_gpt2: bool = false,
    reserved2: u2 = 0,
};

pub const IomuxGpr6 = bitpack struct(u32) {
    reserved0: u16 = 0,
    iomuxc_xbar_dir_sel_2: bool = false,
    iomuxc_xbar_dir_sel_3: bool = false,
    reserved1: u14 = 0,
};

pub const IomuxGpr7 = bitpack struct(u32) {
    lpi2c1_stop_req: bool = false,
    lpi2c2_stop_req: bool = false,
    reserved0: u2 = 0,
    lpspi1_stop_req: bool = false,
    lpspi2_stop_req: bool = false,
    reserved1: u2 = 0,
    lpuart1_stop_req: bool = false,
    lpuart2_stop_req: bool = false,
    lpuart3_stop_req: bool = false,
    lpuart4_stop_req: bool = false,
    reserved2: u4 = 0,
    lpi2c1_stop_ack: bool = false,
    lpi2c2_stop_ack: bool = false,
    reserved3: u2 = 0,
    lpspi1_stop_ack: bool = false,
    lpspi2_stop_ack: bool = false,
    reserved4: u2 = 0,
    lpuart1_stop_ack: bool = false,
    lpuart2_stop_ack: bool = false,
    lpuart3_stop_ack: bool = false,
    lpuart4_stop_ack: bool = false,
    reserved5: u4 = 0,
};

pub const IomuxGpr8 = bitpack struct(u32) {
    lpi2c1_ipg_stop_mode: bool = false,
    lpi2c1_ipg_doze: bool = false,
    lpi2c2_ipg_stop_mode: bool = false,
    lpi2c2_ipg_doze: bool = false,
    reserved0: u4 = 0,
    lpspi1_ipg_stop_mode: bool = false,
    lpspi1_ipg_doze: bool = false,
    lpspi2_ipg_stop_mode: bool = false,
    lpspi2_ipg_doze: bool = false,
    reserved1: u4 = 0,
    lpuart1_ipg_stop_mode: bool = false,
    lpuart1_ipg_doze: bool = false,
    lpuart2_ipg_stop_mode: bool = false,
    lpuart2_ipg_doze: bool = false,
    lpuart3_ipg_stop_mode: bool = false,
    lpuart3_ipg_doze: bool = false,
    lpuart4_ipg_stop_mode: bool = false,
    lpuart4_ipg_doze: bool = false,
    reserved2: u8 = 0,
};

pub const IomuxLockOcramTzAddr = enum(u5) {
    not_locked = 0,
    locked = 1,
};

pub const IomuxGpr10 = bitpack struct(u32) {
    niden: bool = true,
    dbg_en: bool = true,
    sec_err_resp: bool = true,
    reserved0: u1 = 0,
    dcpkey_ocotp_or_keymux: bool = false,
    reserved1: u3 = 0,
    ocram_tz_en: bool = false,
    ocram_tz_addr: u5 = 0,
    reserved2: u2 = 0,
    lock_niden: bool = false,
    lock_dbg_en: bool = false,
    lock_sec_err_resp: bool = false,
    reserved3: u1 = 0,
    lock_dcpkey_ocotp_or_keymux: bool = false,
    reserved4: u3 = 0,
    lock_ocram_tz_en: bool = false,
    lock_ocram_tz_addr: IomuxLockOcramTzAddr = .not_locked,
    reserved5: u2 = 0,
};

pub const IomuxLockM7Apc = enum(u2) {
    not_locked = 0,
    locked = 1,
};

pub const IomuxM7Apc = enum(u2) {
    no_protection = 0,
    protected = 1,
};

pub const IomuxGpr11 = bitpack struct(u32) {
    m7_apc_ac_r0_ctrl: IomuxM7Apc = .no_protection,
    m7_apc_ac_r1_ctrl: IomuxM7Apc = .no_protection,
    m7_apc_ac_r2_ctrl: IomuxM7Apc = .no_protection,
    m7_apc_ac_r3_ctrl: IomuxM7Apc = .no_protection,
    reserved0: u8 = 0,
    lock_m7_apc_ac_r0_ctrl: IomuxLockM7Apc = .not_locked,
    lock_m7_apc_ac_r1_ctrl: IomuxLockM7Apc = .not_locked,
    lock_m7_apc_ac_r2_ctrl: IomuxLockM7Apc = .not_locked,
    lock_m7_apc_ac_r3_ctrl: IomuxLockM7Apc = .not_locked,
    reserved1: u8 = 0,
};

pub const IomuxGpr12 = bitpack struct(u32) {
    flexio1_ipg_stop_mode: bool = false,
    flexio1_ipg_doze: bool = false,
    reserved0: u30 = 0,
};

pub const IomuxGpr13 = bitpack struct(u32) {
    reserved0: u13 = 0,
    cache_usb: bool = false,
    reserved1: u18 = 0,
};

pub const IomuxGpr16 = bitpack struct(u32) {
    reserved0: u2 = 0,
    flexram_bank_cfg_sel: bool = false,
    reserved1: u3 = 0,
    lock_vtor: bool = false,
    cm7_init_vtor: u25 = 16384,
};

pub const IomuxGpr17 = bitpack struct(u32) {
    flexram_bank_cfg: u8 = 0,
    reserved0: u24 = 0,
};

pub const IomuxGpr18 = bitpack struct(u32) {
    lock_m7_apc_ac_r0_bot: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r0_bot: u29 = 0,
};

pub const IomuxGpr19 = bitpack struct(u32) {
    lock_m7_apc_ac_r0_top: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r0_top: u29 = 0,
};

pub const IomuxGpr20 = bitpack struct(u32) {
    lock_m7_apc_ac_r1_bot: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r1_bot: u29 = 0,
};

pub const IomuxGpr21 = bitpack struct(u32) {
    lock_m7_apc_ac_r1_top: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r1_top: u29 = 0,
};

pub const IomuxGpr22 = bitpack struct(u32) {
    lock_m7_apc_ac_r2_bot: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r2_bot: u29 = 0,
};

pub const IomuxGpr23 = bitpack struct(u32) {
    lock_m7_apc_ac_r2_top: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r2_top: u29 = 0,
};

pub const IomuxGpr24 = bitpack struct(u32) {
    lock_m7_apc_ac_r3_bot: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r3_bot: u29 = 0,
};

pub const IomuxGpr25 = bitpack struct(u32) {
    lock_m7_apc_ac_r3_top: bool = false,
    reserved0: u2 = 0,
    m7_apc_ac_r3_top: u29 = 0,
};

pub const IomuxGpr27 = bitpack struct(u32) {
    reserved0: u12 = 0,
    flexspi_remap_addr_start: u20 = 0,
};

pub const IomuxGpr28 = bitpack struct(u32) {
    reserved0: u12 = 0,
    flexspi_remap_addr_end: u20 = 0,
};

pub const IomuxGpr29 = bitpack struct(u32) {
    reserved0: u12 = 0,
    flexspi_remap_addr_offset: u20 = 0,
};

pub const IomuxGpr = extern struct {
    gpr0: u32,
    gpr1: IomuxGpr1,
    gpr2: IomuxGpr2,
    gpr3: IomuxGpr3,
    gpr4: IomuxGpr4,
    gpr5: IomuxGpr5,
    gpr6: IomuxGpr6,
    gpr7: IomuxGpr7,
    gpr8: IomuxGpr8,
    gpr9: u32,
    gpr10: IomuxGpr10,
    gpr11: IomuxGpr11,
    gpr12: IomuxGpr12,
    gpr13: IomuxGpr13,
    gpr14: u32,
    gpr15: u32,
    gpr16: IomuxGpr16,
    gpr17: IomuxGpr17,
    gpr18: IomuxGpr18,
    gpr19: IomuxGpr19,
    gpr20: IomuxGpr20,
    gpr21: IomuxGpr21,
    gpr22: IomuxGpr22,
    gpr23: IomuxGpr23,
    gpr24: IomuxGpr24,
    gpr25: IomuxGpr25,
    gpr26: u32,
    gpr27: IomuxGpr27,
    gpr28: IomuxGpr28,
    gpr29: IomuxGpr29,
};

pub const iomuxc_gpr: *volatile IomuxGpr = @ptrFromInt(IOMUXC_GPR_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x78, @sizeOf(IomuxGpr));
}
