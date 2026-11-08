const DMA0_BASE = 0x40080000;
const DMA1_BASE = 0x400A0000;

pub const MpCsr = packed struct(u32) {
    reserved0: u1 = 0,
    edbg: bool = false,
    erca: bool = false,
    reserved1: u1 = 0,
    hae: bool = false,
    halt: bool = false,
    gclc: bool = false,
    gmrc: bool = false,
    ecx: bool = false,
    cx: bool = false,
    reserved2: u14 = 0,
    active_id: u4 = 0,
    reserved3: u3 = 0,
    active: bool = false,
};

pub const MpEs = packed struct(u32) {
    dbe: bool,
    sbe: bool,
    sge: bool,
    nce: bool,
    doe: bool,
    dae: bool,
    soe: bool,
    sae: bool,
    ecx: bool,
    reserved0: u15,
    errchn: u4,
    reserved1: u3,
    vld: bool,
};

pub const DmaCh = extern struct {
    csr: u32,
    es: u32,
    int: u32,
    sbr: u32,
    pri: u32,
    mux: u32,
    reserved0: [2]u32,
    saddr: u32,
    soff: u16,
    attr: u16,
    nbytes: u32,
    last_sda: u32,
    daddr: u32,
    doff: u16,
    citer: u16,
    dlast_sga: u32,
    dcsr: u16,
    biter: u16,
    reserved1: [1008]u32
};

pub const Dma = extern struct {
    csr: MpCsr,
    es: MpEs,
    int: u32,
    hrs: u32,
    reserved0: [60]u32,
    grpri: [16]u32,
    reserved1: [944]u32,
    ch: [16]DmaCh
};

pub const dma0: *volatile Dma = @ptrFromInt(DMA0_BASE);
pub const dma1: *volatile Dma = @ptrFromInt(DMA1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x11000, @sizeOf(Dma));
}
