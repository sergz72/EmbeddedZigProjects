const ECDC_BASE = 0x40016C00;

pub const EcdcCtrl = bitpack struct(u32) {
    rb_ecdc_keyex_en: bool = false,
    rb_ecdc_normal_en: bool = false,
    reserved0: u1 = 0,
    rb_ecdc_mode_sel: bool = false,
    rb_ecdc_clkdiv_mask: u3 = 0,
    rb_ecdc_wrsram_en: bool = false,
    rb_ecdc_algrm_mod: bool = false,
    rb_ecdc_cipher_mod: bool = false,
    rb_ecdc_klen_mask: u2 = 0,
    reserved1: u1 = 0,
    rb_ecdc_dat_mod: bool = false,
    reserved2: u3 = 0,
    rb_ecdc_ie_single: bool = false,
    rb_ecdc_ie_wrsram: bool = false,
    reserved3: u5 = 0,
    rb_ecdc_clock_select: bool = false,
    rb_ecdc_aes_sm4_clock_en: bool = false,
    reserved4: u6 = 0,
};

pub const EcdcIntFg = bitpack struct(u32) {
    reserved0: u16 = 0,
    rb_ecdc_if_single: bool = false,
    rb_ecdc_if_wrsram: bool = false,
    reserved1: u14 = 0,
};

pub const Ecdc = extern struct {
    ctrl: EcdcCtrl,
    intfg: EcdcIntFg,
    key: [8]u32,
    iv: [4]u32,
    reserved0: [2]u32,
    sgsd: [4]u32,
    sgrt: [4]u32,
    src_addr: u32,
    dst_addr: u32,
    sram_len: u32,
};

pub const ecdc: *volatile Ecdc = @ptrFromInt(ECDC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x6C, @sizeOf(Ecdc));
}
