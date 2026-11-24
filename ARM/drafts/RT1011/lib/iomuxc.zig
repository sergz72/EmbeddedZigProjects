const IOMUXC_BASE = 0x401F8000;

pub const IomuxMuxCtl = bitpack struct(u32) {
    mux_mode: u3,
    reserved0: u1 = 0,
    sion: bool,
    reserved1: u27 = 0,
};

pub const IomuxDse = enum(u3) {
    dse_0_output_driver_disabled_ = 0,
    dse_1_r0_150_ohm___3_3v__260_ohm_1_8v__240_ohm_for_ddr_ = 1,
    dse_2_r0_2 = 2,
    dse_3_r0_3 = 3,
    dse_4_r0_4 = 4,
    dse_5_r0_5 = 5,
    dse_6_r0_6 = 6,
    dse_7_r0_7 = 7,
};

pub const IomuxSpeed = enum(u2) {
    _low_50MHz = 0,
    _medium_100MHz = 1,
    _fast_150MHz = 2,
    _max_200MHz = 3,
};

pub const IomuxPus = enum(u2) {
    _100k_ohm_pull_down = 0,
    _47k_ohm_pull_up = 1,
    _100k_ohm_pull_up = 2,
    _22k_ohm_pull_up = 3,
};

pub const IomuxPadCtl = bitpack struct(u32) {
    sre: bool,
    reserved0: u2 = 0,
    dse: IomuxDse,
    speed: IomuxSpeed,
    reserved1: u3 = 0,
    ode: bool,
    pke: bool,
    pue: bool,
    pus: IomuxPus,
    hys: bool,
    reserved2: u15 = 0,
};

pub const IomuxSelectInput = bitpack struct(u32) {
    daisy: bool = false,
    reserved0: u31 = 0,
};

pub const IomuxDaisy = enum(u2) {
        gpio_ad_14_alt0 = 0,
        gpio_sd_06_alt1 = 1,
        gpio_12_alt1 = 2,
        gpio_02_alt3 = 3,
};

pub const IomuxSelectInput2 = bitpack struct(u32) {
    daisy: u2 = 0,
    reserved0: u30 = 0,
};

pub const Iomux = extern struct {
    reserved0: [4]u32,
    mux_ad: [15]IomuxMuxCtl,
    mux_sd: [15]IomuxMuxCtl,
    mux_gpio: [14]IomuxMuxCtl,
    pad_ad: [15]IomuxPadCtl,
    pad_sd: [15]IomuxPadCtl,
    pad_gpio: [14]IomuxPadCtl,
    otg_id: IomuxSelectInput,
    pwma: [4]IomuxSelectInput,
    pwmb: [4]IomuxSelectInput,
    dqs_fa: IomuxSelectInput,
    dqs_fb: IomuxSelectInput,
    kpp_col: [4]IomuxSelectInput,
    kpp_row: [4]IomuxSelectInput,
    lpi2c1_hreq: IomuxSelectInput2,
    lpi2c1_scl: IomuxSelectInput2,
    lpi2c1_sda: IomuxSelectInput2,
    lpi2c2_scl: IomuxSelectInput2,
    lpi2c2_sda: IomuxSelectInput2,
    lpspi1_pcs: IomuxSelectInput,
    lpspi1_sck: IomuxSelectInput,
    lpspi1_sdi: IomuxSelectInput,
    lpspi1_sdo: IomuxSelectInput,
    lpspi2_pcs: IomuxSelectInput,
    lpspi2_sck: IomuxSelectInput,
    lpspi2_sdi: IomuxSelectInput,
    lpspi2_sdo: IomuxSelectInput,
    lpuart1_rxd: IomuxSelectInput,
    lpuart1_txd: IomuxSelectInput,
    lpuart2_rxd: IomuxSelectInput,
    lpuart2_txd: IomuxSelectInput,
    lpuart3_rxd: IomuxSelectInput,
    lpuart3_txd: IomuxSelectInput,
    lpuart4_rxd: IomuxSelectInput,
    lpuart4_txd: IomuxSelectInput,
    nmi_glue: IomuxSelectInput,
    spdif_in1: IomuxSelectInput,
    spdif_tx_clk2: IomuxSelectInput,
    usb_otg_oc: IomuxSelectInput,
    xevg_glue: IomuxSelectInput,
};

pub const iomuxc: *volatile Iomux = @ptrFromInt(IOMUXC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x224, @sizeOf(Iomux));
}
