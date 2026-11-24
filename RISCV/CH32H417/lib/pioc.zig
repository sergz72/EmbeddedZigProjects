const PIOC_BASE = 0x40025C00;

pub const PiocSfrStatusReg = bitpack struct(u8) {
    sb_flag_c: bool = false,
    sb_gp_bit_x: bool = false,
    sb_flag_z: bool = false,
    sb_gp_bit_y: bool = false,
    sb_en_tout_rst: bool = false,
    sb_stack_used: bool = false,
    reserved0: u2 = 0,
};

pub const PiocSfrBitCycle = bitpack struct(u8) {
    sb_bit_cycle: u7 = 0,
    sb_bit_tx_o0: bool = false,
};

pub const PiocSfrPortDir = bitpack struct(u8) {
    sb_port_dir0: bool,
    sb_port_dir1: bool,
    sb_port_pu0: bool,
    sb_port_pu1: bool,
    sb_port_mod0: bool,
    sb_port_mod1: bool,
    sb_port_mod2: bool,
    sb_port_mod3: bool,
};

pub const PiocSfrBitConfig = bitpack struct(u8) {
    sb_bit_cyc_cnt3: bool,
    sb_bit_cyc_cnt4: bool,
    sb_bit_cyc_cnt5: bool,
    sb_bit_cyc_cnt6: bool,
    sb_bit_cyc_tail: bool,
    sb_port_in_edge: bool,
    sb_bit_code_mod: bool,
    sb_bit_tx_en: bool,
};

pub const PiocSfrSysCfg = bitpack struct(u8) {
    sb_mst_clk_gate: bool = false,
    sb_mst_reset: bool = false,
    sb_mst_io_en0: bool = false,
    sb_mst_io_en1: bool = false,
    sb_mst_cfg_b4: bool = false,
    sb_data_mw_sr: bool = false,
    sb_data_sw_mr: bool = false,
    sb_int_req: bool = false,
};

pub const Pioc = extern struct {
    indir_port: [2]u8,
    prg: u8,
    status: PiocSfrStatusReg,
    indir_addr: u8,
    tmr0_count: u8,
    timer: u8,
    tmr0_init: u8,
    bit_cycle: PiocSfrBitCycle,
    indir_addr2: u8,
    port_dir: PiocSfrPortDir,
    port_io: u8,
    bit: PiocSfrBitConfig,
    reserved0: [15]u8,
    sys: PiocSfrSysCfg,
    ctrl_rd: u8,
    ctrl_wr: u8,
    data_exch: u8,
    data_reg: [32]u8,
};

pub const pioc: *volatile Pioc = @ptrFromInt(PIOC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x40, @sizeOf(Pioc));
}
