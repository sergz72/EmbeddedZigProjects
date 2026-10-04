const DMA_BASE: usize = 0x40020000;

pub const DmaSize = enum(u2) {
    _8 = 0,
    _16 = 1,
    _32 = 2
};

pub const DmaChannelCtl = packed struct(u32) {
    chen: bool = false,
    ftfie: bool = false,
    htfie: bool = false,
    errie: bool = false,
    dir: bool = false,
    cmen: bool = false,
    pnaga: bool = false,
    mnaga: bool = false,
    pwidth: DmaSize = ._8,
    mwidth: DmaSize = ._8,
    prio: u2 = 0,
    m2m: bool = false,
    reserved: u17 = 0
};

pub const DmaChannel = extern struct {
    ctl: DmaChannelCtl,
    cnt: u32,
    paddr: u32,
    maddr: u32,
    reserved: u32
};

pub const DmaInterruptFlags = packed struct(u4) {
    gif: bool = false,
    ftfif: bool = false,
    htfif: bool = false,
    errif: bool = false,
};

pub const DmaIntf = packed struct(u32) {
    ch0: DmaInterruptFlags = DmaInterruptFlags{},
    ch1: DmaInterruptFlags = DmaInterruptFlags{},
    ch2: DmaInterruptFlags = DmaInterruptFlags{},
    ch3: DmaInterruptFlags = DmaInterruptFlags{},
    ch4: DmaInterruptFlags = DmaInterruptFlags{},
    reserved: u12 = 0
};

pub const Dma = extern struct {
    intf: DmaIntf,
    intfc: DmaIntf,
    channels: [5]DmaChannel
};

pub const dma: *volatile Dma = @ptrFromInt(DMA_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x6C, @sizeOf(Dma));
}


