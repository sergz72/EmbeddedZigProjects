const DMA1_BASE: usize = 0x40020000;
const DMA2_BASE: usize = 0x40020400;

pub const DmaSize = enum(u2) {
    _8 = 0,
    _16 = 1,
    _32 = 2
};

pub const DmaChannelCfgr = packed struct(u32) {
    en: bool = false,
    tcie: bool = false,
    htie: bool = false,
    teie: bool = false,
    dir_from_memory: bool = false,
    circ: bool = false,
    pinc: bool = false,
    minc: bool = false,
    psize: DmaSize = ._8,
    msize: DmaSize = ._8,
    pl: u2 = 0,
    mem2mem: bool = false,
    reserved: u17 = 0
};

pub const DmaChannel = extern struct {
    cfgr: DmaChannelCfgr,
    cntr: u32,
    paddr: u32,
    maddr: u32,
    reserved: u32
};

pub const DmaInterruptFlags = packed struct(u4) {
    gif: bool = false,
    tcif: bool = false,
    htif: bool = false,
    teif: bool = false,
};

pub const DmaIntfr = packed struct(u32) {
    ch1: DmaInterruptFlags = DmaInterruptFlags{},
    ch2: DmaInterruptFlags = DmaInterruptFlags{},
    ch3: DmaInterruptFlags = DmaInterruptFlags{},
    ch4: DmaInterruptFlags = DmaInterruptFlags{},
    ch5: DmaInterruptFlags = DmaInterruptFlags{},
    ch6: DmaInterruptFlags = DmaInterruptFlags{},
    ch7: DmaInterruptFlags = DmaInterruptFlags{},
    ch8: DmaInterruptFlags = DmaInterruptFlags{}
};

pub const DmaEIntfr = packed struct(u32) {
    ch9: DmaInterruptFlags = DmaInterruptFlags{},
    ch10: DmaInterruptFlags = DmaInterruptFlags{},
    ch11: DmaInterruptFlags = DmaInterruptFlags{},
    ch12: DmaInterruptFlags = DmaInterruptFlags{},
    reserved: u16 = 0
};

pub const Dma = extern struct {
    intfr: DmaIntfr,
    intfcr: DmaIntfr,
    channels: [10]DmaChannel,
    extem_intfr: DmaEIntfr,
    extem_intfcr: DmaEIntfr
};

pub const dma1: *volatile Dma = @ptrFromInt(DMA1_BASE);
pub const dma2: *volatile Dma = @ptrFromInt(DMA2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xD8, @sizeOf(Dma));
}


