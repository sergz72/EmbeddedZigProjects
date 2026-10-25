const builtin = @import("builtin");
//const common = @import("common");
const common = if (builtin.is_test) @import("common.zig") else @import("common");

const DMA_BASE: usize = 0x4042A000 + 0x400;

pub const DmaCtl = packed struct(u32) {
    dmareq: bool = false,
    dmaen: bool = false,
    dmaautoen: u2 = 0,
    dmapreirq: u3 = 0,
    reserved: u1 = 0,
    dmasrcwidth: u3 = 0,
    reserved2: u1 = 0,
    dmadstwidth: u3 = 0,
    reserved3: u1 = 0,
    dmasrcincr: u4 = 0,
    dmadstincr: u4 = 0,
    dmaem: u2 = 0,
    reserved4: u2 = 0,
    dmatm: u2 = 0,
    reserved5: u2 = 0
};

pub const DmaSz = packed struct(u32) {
    sz: u16 = 0,
    reserved: u16 = 0
};

pub const DmaChan = extern struct {
    dmactl: DmaCtl,
    dmasa: u32,
    dmada: u32,
    dmasz: DmaSz,
};

pub const DmaIntIIdx = enum(u32) {
    no_interrupt = 0,
    dmasz0 = 1,
    dmasz1 = 2,
    dmasz2 = 3,
    dmasz3 = 4,
    dmasz4 = 5,
    dmasz5 = 6,
    dmasz6 = 7,
    dmasz7 = 8,
    dmasz8 = 9,
    dmasz9 = 10,
    dmasz10 = 11,
    dmasz11 = 12,
    dmasz12 = 13,
    dmasz13 = 14,
    dmasz14 = 15,
    dmasz15 = 16,
    preirq0 = 17,
    preirq1 = 18,
    preirq2 = 19,
    preirq3 = 20,
    preirq4 = 21,
    preirq5 = 22,
    preirq6 = 23,
    preirq7 = 24,
    address_error = 25,
    data_error = 26
};

pub const DmaIntInt = packed struct(u32) {
    ch0: bool = false,
    ch1: bool = false,
    ch2: bool = false,
    ch3: bool = false,
    ch4: bool = false,
    ch5: bool = false,
    ch6: bool = false,
    ch7: bool = false,
    ch8: bool = false,
    ch9: bool = false,
    ch10: bool = false,
    ch11: bool = false,
    ch12: bool = false,
    ch13: bool = false,
    ch14: bool = false,
    ch15: bool = false,
    preirqch0: bool = false,
    preirqch1: bool = false,
    preirqch2: bool = false,
    preirqch3: bool = false,
    preirqch4: bool = false,
    preirqch5: bool = false,
    preirqch6: bool = false,
    preirqch7: bool = false,
    addrerr: bool = false,
    dataerr: bool = false,
    reserved: u6 = 0
};

pub const DmaInt = extern struct {
    iidx: DmaIntIIdx,
    reserved0: u32,
    imask: DmaIntInt,
    reserved1: u32,
    ris: DmaIntInt,
    reserved2: u32,
    mis: DmaIntInt,
    reserved3: u32,
    iset: DmaIntInt,
    reserved4: u32,
    iclr: DmaIntInt
};

pub const DmaCh = packed struct(u32) {
    chanid: u8 = 0,
    reserved: u24 = 0
};

pub const DmaEvtMode = packed struct(u32) {
    int0_cfg: common.EvtCfg,
    evt1_cfg: common.EvtCfg,
    reserved: u28
};

pub const DmaBurstSz = enum(u2) {
    none = 0,
    _8 = 1,
    _16 = 2,
    _32 = 3
};

pub const DmaPrio = packed struct(u32) {
    roundrobin: bool = false,
    reserved: u15 = 0,
    burstsz: DmaBurstSz = .none,
    reserved2: u14 = 0
};

pub const DmaTctl = packed struct(u32) {
    dmatsel: u6 = 0,
    reserved: u1 = 0,
    dmaint: bool = false,
    reserved2: u24 = 0
};

pub const Dma = extern struct {
    fsub_0: DmaCh,
    fsub_1: DmaCh,
    reserved1: [15]u32,
    fpub_1: DmaCh,
    reserved2: [756]u32,
    pdbgctl: common.PdbgCtl,
    reserved3: u32,
    cpu_int: DmaInt,
    reserved4: u32,
    gen_event: DmaInt,
    reserved5: [25]u32,
    evt_mode: DmaEvtMode,
    reserved6: [6]u32,
    desc: u32,
    dmaprio: DmaPrio,
    reserved7: [3]u32,
    dmatrig: [16]DmaTctl,
    reserved8: [44]u32,
    dmachan: [16]DmaChan,

    pub inline fn enablePower(self: *volatile Dma) void {
        const v = common.GprcmPwren{.enable = true};
        self.gprcm.pwren = v;
    }

    pub inline fn reset(self: *volatile Dma) void {
        const v = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
        self.gprcm.rstctl = v;
    }
};

pub const dma: *volatile Dma = @ptrFromInt(DMA_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1300-0x400, @sizeOf(Dma));
}
