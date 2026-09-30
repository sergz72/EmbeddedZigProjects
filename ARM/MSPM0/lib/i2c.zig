const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const I2C0_BASE: usize = 0x400F0000 + 0x800;
const I2C1_BASE: usize = 0x400F2000 + 0x800;

pub const I2cSlave = extern struct {
    soar: u32,
    soar2: u32,
    sctr: u32,
    ssr: u32,
    srxdata: u32,
    stxdata: u32,
    sackctl: u32,
    sfifoctl: u32,
    sfifosr: u32,
    target_pecctl: u32,
    target_pecsr: u32,
};

pub const I2cMaster = extern struct {
    msa: u32,
    mctr: u32,
    msr: u32,
    mrxdata: u32,
    mtxdata: u32,
    mtpr: u32,
    mcr: u32,
    reserved0: [2]u32,
    mbmon: u32,
    mfifoctl: u32,
    mfifosr: u32,
    controller_i2cpecctl: u32,
    controller_pecsr: u32,
};

pub const I2cDmaTrig = extern struct {
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

pub const I2cIntIIdx = enum(u32) {
    no_interupt = 0,
    data_received = 1,
    data_transmitted = 2,
    receive_fifo_trigger = 3,
    transmit_fifo_trigger = 4,
    rx_fifo_full = 5,
    tx_fifo_empty = 6,
    nack = 8,
    start = 9,
    stop = 10,
    arbitration_lost = 11,
    dma_done_tx = 12,
    dma_done_rx = 13,
    pec = 14,
    timeout_a = 15,
    timeout_b = 16,
    target_data1 = 0x11,
    target_data2 = 0x12,
    target_receive_fifo_trigger = 0x13,
    target_transmit_fifo_trigger = 0x14,
    target_rx_fifo_full = 0x15,
    target_tx_fifo_empty = 0x16,
    target_start = 0x17,
    target_stop = 0x18,
    target_general_call = 0x19,
    target_dma_done_tx = 0x1A,
    target_dma_done_rx = 0x1B,
    target_pec = 0x1C,
    target_tx_fifo_underflow = 0x1D,
    target_rx_fifo_overflow = 0x1E,
    target_arbitration_lost = 0x1F,
    interrupt_overflow = 0x20
};

pub const I2cIntIMask = packed struct(u32) {
    crxdone: bool = false,
    ctxdone: bool = false,
    crxfifotrg: bool = false,
    ctxfifotrg: bool = false,
    crxfifofull: bool = false,
    ctxempty: bool = false,
    reserved: u1 = 0,
    cnack: bool = false,
    cstart: bool = false,
    cstop: bool = false,
    carblost: bool = false,
    cdma_done_tx: bool = false,
    cdma_done_rx: bool = false,
    cpec_rx_err: bool = false,
    timeouta: bool = false,
    timeoutb: bool = false,
    trxdone: bool = false,
    ttxdone: bool = false,
    trxfifotrg: bool = false,
    ttxfifotrg: bool = false,
    trxfifofull: bool = false,
    ttxempty: bool = false,
    tstart: bool = false,
    tstop: bool = false,
    tgencall: bool = false,
    tdma_done_tx: bool = false,
    tdma_done_rx: bool = false,
    tpec_rx_err: bool = false,
    ttx_unfl: bool = false,
    trx_ovfl: bool = false,
    tarblost: bool = false,
    intr_ovfl: bool = false
};

pub const I2cInt = extern struct {
    iidx: I2cIntIIdx,
    reserved0: u32,
    imask: I2cIntIMask,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const I2cGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    clkcfg: u32,
    reserved0: [2]u32,
    stat: u32,
};

pub const I2c = extern struct {
    gprcm: I2cGprcm,
    reserved1: [506]u32,
    clkdiv: common.ClkDiv,
    clksel: common.Clksel2,
    reserved2: [4]u32,
    pdbgctl: u32,
    reserved3: u32,
    cpu_int: I2cInt,
    reserved4: u32,
    dma_trig1: I2cDmaTrig,
    reserved5: u32,
    dma_trig0: I2cDmaTrig,
    reserved6: [13]u32,
    evt_mode: u32,
    intctl: u32,
    reserved7: [5]u32,
    desc: u32,
    reserved8: [64]u32,
    gfctl: u32,
    timeout_ctl: u32,
    timeout_cnt: u32,
    reserved9: u32,
    master: I2cMaster,
    reserved10: [2]u32,
    slave: I2cSlave,

    pub inline fn enablePower(self: *volatile I2c) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub inline fn reset(self: *volatile I2c) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }
};

pub const i2c0: *volatile I2c = @ptrFromInt(I2C0_BASE);
pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x127C-0x800, @sizeOf(I2c));
}
