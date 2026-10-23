pub const SCFG_BASE = 0x40010000;

pub const ScfgCfg1 = packed struct(u32) {
    mem_map_sel: u2,
    reserved1: u2,
    pa11_12_rmp: bool = false,
    ir_pol: bool = false,
    ir_src_sel: u2 = 0,
    adc_dma_rmp: bool = false,
    usart1_tx_dma_rmp: bool = false,
    usart1_rx_dma_rmp: bool = false,
    tmr16_dma_rmp: bool = false,
    tmr17_dma_rmp: bool = false,
    tmr16_dma_rmp2: bool = false,
    tmr17_dma_rmp2: bool = false,
    reserved2: u9 = 0,
    spi2_dma_rmp: bool = false,
    usart2_dma_rmp: bool = false,
    reserved3: u1 = 0,
    i2c1_dma_rmp: bool = false,
    tmr1_dma_rmp: bool = false,
    reserved4: u1 = 0,
    tmr3_dma_rmp: bool = false,
    reserved5: u1 = 0
};

pub const ScfgCfg2 = packed struct(u32) {
    reserved1: u24 = 0,
    can1_tst_sel: bool = false,
    reserved2: u7 = 0
};

pub const ScfgIocfg = packed struct(u32) {
    nrst_rmp: bool,
    reserved1: u31
};

pub const ExtiPort = enum(u32) {
    A = 0,
    B = 1,
    F = 5
};

pub const Scfg = extern struct {
    cfg1: u32,
    cfg2: u32,
    exintc: [4]u32,
    reserved: [18]u32,
    iocfg: ScfgIocfg,

    pub fn setExtiPort(self: *volatile Scfg, exti: u4, port: ExtiPort) void {
        const index: usize = exti >> 2;
        const shift = (exti & 3) << 2;
        const mask: u32 = 0x0F << shift;
        const value = self.exintc[index];
        self.exintc[index] = (value & ~mask) | (@backingInt(port) << shift);
    }

};

pub const scfg: *volatile Scfg = @ptrFromInt(SCFG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x64, @sizeOf(Scfg));
}
