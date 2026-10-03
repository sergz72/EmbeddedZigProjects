const SYSCFG_BASE: usize = 0x40010000;

pub const SyscfgCfg0 = packed struct(u32) {
    boot_mode: u2,
    reserved0: u2 = 0,
    pa11_pa12_rmp: bool = false,
    reserved1: u3 = 0,
    adc_dma_rmp: bool = false,
    usart1_tx_dma_rmp: bool = false,
    usart1_rx_dma_rmp: bool = false,
    timer15_dma_rmp: bool = false,
    timer16_dma_rmp: bool = false,
    reserved2: u6 = 0,
    pb9_hcce: bool = false,
    reserved3: u12 = 0
};

pub const SyscfgCfg2 = packed struct(u32) {
    lockup_lock: bool = false,
    sram_parity_error_lock: bool = false,
    lvd_lock: bool = false,
    reserved0: u5 = 0,
    sram_pcef: bool = false,
    reserved1: u23 = 0
};

pub const Syscfg = extern struct {
    cfg0: SyscfgCfg0,
    reserved0: u32,
    extiss: [4]u32,
    cfg2: SyscfgCfg2,
    reserved1: [57]u32,
    cpu_irq_lat: u32,

    pub fn setExtiPort(self: *volatile Syscfg, exti: u4, port: u4) void {
        const index: usize = exti >> 2;
        const shift = (exti & 3) << 2;
        const mask: u32 = 0x0F << shift;
        const value = self.extiss0[index];
        self.extiss0[index] = (value & ~mask) | (@as(u32, port) << shift);
    }
};

pub const syscfg: *volatile Syscfg = @ptrFromInt(SYSCFG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x104, @sizeOf(Syscfg));
} 
