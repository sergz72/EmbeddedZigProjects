const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

//const AESADV_BASE: usize = 0x40442000 + 0x800;

pub const aesadv_dma_trig_dataout_regs = extern struct {
    iidx: u32,
    reserved0: u32,
    imask: u32,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};
pub const aesadv_dma_trig_datain_regs = extern struct {
    iidx: u32,
    reserved0: u32,
    imask: u32,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};
pub const aesadv_cpu_int_regs = extern struct {
    iidx: u32,
    reserved0: u32,
    imask: u32,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};
pub const aesadv_gprcm_regs = extern struct {
    pwren: u32,
    rstctl: u32,
    reserved0: [3]u32,
    stat: u32,
};
pub const Aesadv = extern struct {
    gprcm: aesadv_gprcm_regs,
    reserved1: [512]u32,
    pdbgctl: u32,
    reserved2: u32,
    cpu_int: aesadv_cpu_int_regs,
    reserved3: u32,
    dma_trig_datain: aesadv_dma_trig_datain_regs,
    reserved4: u32,
    dma_trig_dataout: aesadv_dma_trig_dataout_regs,
    reserved5: [13]u32,
    evt_mode: u32,
    reserved6: [7]u32,
    gcmccm_tag0: u32,
    gcmccm_tag1: u32,
    gcmccm_tag2: u32,
    gcmccm_tag3: u32,
    ghash_h0: u32,
    ghash_h1: u32,
    ghash_h2: u32,
    ghash_h3: u32,
    key0: u32,
    key1: u32,
    key2: u32,
    key3: u32,
    key4: u32,
    key5: u32,
    key6: u32,
    key7: u32,
    iv0: u32,
    iv1: u32,
    iv2: u32,
    iv3: u32,
    ctrl: u32,
    c_length_0: u32,
    c_length_1: u32,
    aad_length: u32,
    data0: u32,
    data1: u32,
    data2: u32,
    data3: u32,
    tag0: u32,
    tag1: u32,
    tag2: u32,
    tag3: u32,
    status: u32,
    data_in: u32,
    data_out: u32,
    reserved7: [17]u32,
    force_in_av: u32,
    ccm_aln_wrd: u32,
    blk_cnt0: u32,
    blk_cnt1: u32,
    reserved8: [5]u32,
    dma_hs: u32,
};

pub const aesadv: *volatile Aesadv = @ptrFromInt(AESADV_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1120-0x800, @sizeOf(Aesadv));
}
