const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const SPI0_BASE: usize = 0x40468000 + 0x800;
const SPI1_BASE: usize = 0x4046A000 + 0x800;

pub const SpiDmaTxIIdx = enum(u32) {
    no_interupt = 0,
    transmit_event = 5
};

pub const SpiDmaTxInt = packed struct(u32) {
    reserved: u4 = 0,
    tx: bool = false,
    reserved2: u27 = 0
};

pub const SpiDmaTx = extern struct {
    iidx: SpiDmaTxIIdx,
    reserved0: u32,
    imask: SpiDmaTxInt,
    reserved1: u32,
    ris: SpiDmaTxInt,
    reserved2: u32,
    mis: SpiDmaTxInt,
    reserved3: u32,
    iset: SpiDmaTxInt,
    reserved4: u32,
    iclr: SpiDmaTxInt
};

pub const SpiDmaRxIIdx = enum(u32) {
    no_interupt = 0,
    receive_timeout = 3,
    receive_event = 4
};

pub const SpiDmaRxInt = packed struct(u32) {
    reserved: u2 = 0,
    rtout: bool = false,
    rx: bool = false,
    reserved2: u28 = 0
};

pub const SpiDmaRx = extern struct {
    iidx: SpiDmaRxIIdx,
    reserved0: u32,
    imask: SpiDmaRxInt,
    reserved1: u32,
    ris: SpiDmaRxInt,
    reserved2: u32,
    mis: SpiDmaRxInt,
    reserved3: u32,
    iset: SpiDmaRxInt,
    reserved4: u32,
    iclr: SpiDmaRxInt
};

pub const SpiIntIIdx = enum(u32) {
    no_interupt = 0,
    rx_fifo_overflow = 1,
    transmit_parity_event = 2,
    receive_timeout = 3,
    receive_event = 4,
    transmit_event = 5,
    transmit_buffer_empty = 6,
    end_of_transmit_event = 7,
    dma_done_rx = 8,
    dma_done_tx = 9,
    tx_fifo_underflow = 10,
    rx_fifo_full = 11
};

pub const SpiIntInt = packed struct(u32) {
    rxfifo_ovf: bool = false,
    per: bool = false,
    rtout: bool = false,
    rx: bool = false,
    tx: bool = false,
    txempty: bool = false,
    idle: bool = false,
    dma_done_rx: bool = false,
    dma_done_tx: bool = false,
    txfifo_unf: bool = false,
    rxfull: bool = false,
    reserved: u21 = 0
};

pub const SpiInt = extern struct {
    iidx: SpiIntIIdx,
    reserved0: u32,
    imask: SpiIntInt,
    reserved1: u32,
    ris: SpiIntInt,
    reserved2: u32,
    mis: SpiIntInt,
    reserved3: u32,
    iset: SpiIntInt,
    reserved4: u32,
    iclr: SpiIntInt
};

pub const SpiGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    clkcfg: u32,
    reserved0: [2]u32,
    stat: u32,
};

pub const SpiEvtMode = packed struct(u32) {
    int0_cfg: common.EvtCfg = .software_mode,
    int1_cfg: common.EvtCfg = .hardware_mode,
    int2_cfg: common.EvtCfg = .hardware_mode,
    reserved: u26 = 0
};

pub const SpiDss = enum(u5) {
    reserved = 0,
    spi4 = 3,
    spi5 = 4,
    spi6 = 5,
    spi7 = 6,
    spi8 = 7,
    spi9 = 8,
    spi10 = 9,
    spi11 = 10,
    spi12 = 11,
    spi13 = 12,
    spi14 = 13,
    spi15 = 14,
    spi16 = 15
};

pub const SpiFrf = enum(u2) {
    motorola_3wire = 0,
    motorola_4wire = 1,
    ti = 2,
    national = 3
};

pub const SpiCtl0 = packed struct(u32) {
    dss: SpiDss = .reserved,
    frf: SpiFrf = .motorola_3wire,
    packen: bool = false,
    spo: bool = false,
    sph: bool = false,
    reserved: u2 = 0,
    cssel: u2 = 0,
    csclr: bool = false,
    reserved3: u17 = 0
};

pub const SpiCtr1 = packed struct(u32) {
    enable: bool = false,
    lbm: bool = false,
    cp: bool = false,
    pod: bool = false,
    msb: bool = false,
    pren: bool = false,
    pes: bool = false,
    reserved: u1 = 0,
    pten: bool = false,
    reserved2: u2 = 0,
    cdenable: bool = false,
    cdmode: u4 = 0,
    repeattx: u8 = 0,
    rxtimeout: u6 = 0,
    reserved3: u2 = 0
};

pub const SpiClkCtl = packed struct(u32) {
    scr: u10 = 0,
    reserved: u18 = 0,
    dsample: u4 = 0
};

pub const SpiTxIflsel = enum(u3) {
    p75_empty = 1,
    p5_empty = 2,
    p25_empty = 3,
    empty = 5,
    has_more_than_one_frame_free = 7
};

pub const SpiRxIflsel = enum(u3) {
    p25_full = 1,
    p5_full = 2,
    p75_full = 3,
    full = 5,
    contains_more_than_one_frame = 7
};

pub const SpiIfls = packed struct(u32) {
    txiflsel: SpiTxIflsel = .p5_empty,
    rxiflsel: SpiRxIflsel = .p5_full,
    reserved: u26 = 0
};

pub const SpiStat = packed struct(u32) {
    tfe: bool,
    tnf: bool,
    rfe: bool,
    rnf: bool,
    busy: bool,
    reserved: u27 = 0
};

pub const Spi = extern struct {
    gprcm: SpiGprcm,
    reserved1: [506]u32,
    clkdiv: common.ClkDiv,
    clksel: common.Clksel4,
    reserved2: [4]u32,
    pdbgctl: common.PdbgCtl,
    reserved3: u32,
    cpu_int: SpiInt,
    reserved4: u32,
    dma_trig_rx: SpiDmaRx,
    reserved5: u32,
    dma_trig_tx: SpiDmaTx,
    reserved6: [13]u32,
    evt_mode: SpiEvtMode,
    intctl: u32,
    reserved7: [6]u32,
    ctl0: SpiCtl0,
    ctl1: SpiCtr1,
    clkctl: SpiClkCtl,
    ifls: SpiIfls,
    stat: SpiStat,
    reserved8: [7]u32,
    rxdata: u32,
    reserved9: [3]u32,
    txdata: u32,

    pub inline fn enablePower(self: *volatile Spi) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub inline fn reset(self: *volatile Spi) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }
};

pub const spi0: *volatile Spi = @ptrFromInt(SPI0_BASE);
pub const spi1: *volatile Spi = @ptrFromInt(SPI1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1144-0x800, @sizeOf(Spi));
}
