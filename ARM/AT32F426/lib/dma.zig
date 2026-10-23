pub const DMA1_BASE = 0x40020000;

pub const DmaSt = packed struct(u32) {
    gf1: bool = false,
    fdtf1: bool = false,
    hdtf1: bool = false,
    dterrf1: bool = false,
    gf2: bool = false,
    fdtf2: bool = false,
    hdtf2: bool = false,
    dterrf2: bool = false,
    gf3: bool = false,
    fdtf3: bool = false,
    hdtf3: bool = false,
    dterrf3: bool = false,
    gf4: bool = false,
    fdtf4: bool = false,
    hdtf4: bool = false,
    dterrf4: bool = false,
    gf5: bool = false,
    fdtf5: bool = false,
    hdtf5: bool = false,
    dterrf5: bool = false,
    gf6: bool = false,
    fdtf6: bool = false,
    hdtf6: bool = false,
    dterrf6: bool = false,
    gf7: bool = false,
    fdtf7: bool = false,
    hdtf7: bool = false,
    dterrf7: bool = false,
    reserved1: u4 = 0
};

pub const DmaWidth = enum(u2) {
    _8 = 0,
    _16 = 1,
    _32 = 2,
};

pub const DmaPl = enum(u2) {
    low = 0,
    medium = 1,
    high = 2,
    very_high = 3
};

pub const DmaChannelCtrl = packed struct(u32) {
    chen: bool = false,
    fdtien: bool = false,
    hdtien: bool = false,
    dterrien: bool = false,
    dtd: bool = false,
    lm: bool = false,
    pincm: bool = false,
    mincm: bool = false,
    pwidth: DmaWidth = ._8,
    mwidth: DmaWidth = ._8,
    chpl: DmaPl,
    m2m: bool = false,
    reserved1: u17 = 0
};

pub const DmaChannel = extern struct {
    ctrl: DmaChannelCtrl,
    dtcnt: u32,
    paddr: u32,
    maddr: u32,
    reserved: u32
};

pub const Dma = extern struct {
    sts: DmaSt,
    clr: DmaSt,
    ch: [7]DmaChannel
};

pub const dma1: *volatile Dma = @ptrFromInt(DMA1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x94, @sizeOf(Dma));
}
