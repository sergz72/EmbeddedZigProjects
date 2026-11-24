const SERDES_BASE = 0x40027C00;

pub const SerdesCtrl = bitpack struct(u32) {
    clr_all: bool = true,
    reset_link: bool = true,
    reset_phy: bool = true,
    int_busy_en: bool = false,
    rx_polarity: bool = false,
    rx_en: bool = false,
    tx_en: bool = false,
    dma_en: bool = false,
    reserved0: u6 = 16,
    rx_pwr_up: bool = false,
    tx_pwr_up: bool = false,
    reserved1: u1 = 0,
    cont_en: bool = false,
    align_en: bool = true,
    reserved2: u13 = 0,
};

pub const SerdesIntEn = bitpack struct(u32) {
    phyrdy_ie: bool = false,
    tran_done_ie_recv_err_ie: bool = false,
    recv_done_ie: bool = false,
    fifo_ov_ie: bool = false,
    reserved0: u1 = 0,
    cominit_ie: bool = false,
    reserved1: u26 = 0,
};

pub const SerdesIntFs = bitpack struct(u32) {
    phyrdy_if: bool = false,
    tran_done_if_recv_err_if: bool = false,
    recv_done_if: bool = false,
    fifo_ov_if: bool = false,
    reserved0: u1 = 0,
    cominit_if: bool = false,
    reserved1: u10 = 0,
    phyrdy: bool = false,
    rx_seq_match: bool = false,
    recv_crc_ok: bool = false,
    pll_lock: bool = false,
    link_free: bool = false,
    r_fifo_rdy: bool = false,
    reserved2: u2 = 0,
    rx_seq_num: u4 = 0,
    tx_seq_num: u4 = 0,
};

pub const SerdesRtxCtrl = bitpack struct(u32) {
    serdes_tx_len: u16 = 0,
    link_init: bool = false,
    tx_vld: bool = false,
    buf_mode: bool = false,
    reserved0: u13 = 0,
};

pub const Serdes = extern struct {
    ctrl: SerdesCtrl,
    int_en: SerdesIntEn,
    int_fs: SerdesIntFs,
    rtx_ctrl: SerdesRtxCtrl,
    rx_len: u32,
    data0: u32,
    dma0: u32,
    rx_len1: u32,
    data1: u32,
    dma1: u32,
    reserved0: [6]u32,
};

pub const serdes: *volatile [2]Serdes = @ptrFromInt(SERDES_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x40, @sizeOf(Serdes));
}
