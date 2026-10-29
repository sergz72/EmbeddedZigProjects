pub const IOMUX_BASE = 0x40010000;

pub const IomuxEvtout = packed struct(u32) {
    selpin: u4 = 0,
    selport: u3 = 0,
    evoen: bool = false,
    reserved1: u24 = 0
};

pub const ExintPort = enum(u32) {
    A = 0,
    B = 1,
    C = 2,
    D = 3,
    E = 4
};

pub const IomuxRemap = packed struct(u32) {
    spi1_mux_l: u1 = 0,
    i2c1_mux: bool = false,
    usart1_mux: bool = false,
    usart2_mux: bool = false,
    usart3_mux: u2 = 0,
    tmr1_mux: u2 = 0,
    tmr2_mux: u2 = 0,
    tmr3_mux: u2 = 0,
    tmr4_mux: bool = false,
    can_mux: u2 = 0,
    pd01_mux: bool = false,
    tmr5ch4_mux: bool = false,
    adc1_extrgpre_mux: bool = false,
    adc1_extrgord_mux: bool = false,
    adc2_extrgpre_mux: bool = false,
    adc2_extrgord_mux: bool = false,
    emac_mux: bool = false,
    can2_mux: bool = false,
    mii_rmii_sel_mux: bool = false,
    swjtag_mux: u3 = 0,
    reserved1: u1 = 0,
    spi3_mux: bool = false,
    tim2itr1_mux: bool = false,
    ptp_pps_mux: bool = false,
    spi1_mux_h: bool = false
};

pub const IomuxRemap2 = packed struct(u32) {
    tmr15_mux: bool = false,
    reserved1: u4 = 0,
    tmr9_mux: bool = false,
    tmr10_mux: bool = false,
    tmr11_mux: bool = false,
    tmr13_mux: bool = false,
    tmr14_mux: bool = false,
    xmc_nadv_mux: bool = false,
    reserved2: u6 = 0,
    spi4_mux: bool = false,
    i2c3_mux: bool = false,
    sdio2_mux: u2 = 0,
    spim_en: bool = false,
    reserved3: u10 = 0
};

pub const IomuxRemap3 = packed struct(u32) {
    tmr9_gmux: u4 = 0,
    reserved1: u28 = 0
};

pub const IomuxRemap4 = packed struct(u32) {
    tmr1_gmux: u4 = 0,
    tmr2_gmux: u2 = 0,
    tmr2itr1_gmux: u2 = 0,
    tmr3_gmux: u4 = 0,
    tmr4_gmux: u4 = 0,
    reserved1: u3 = 0,
    tmr5ch4_gmux: bool = false,
    reserved2: u12 = 0
};

pub const IomuxRemap5 = packed struct(u32) {
    usart5_gmux: u4 = 0,
    i2c1_gmux: u4 = 0,
    reserved1: u4 = 0,
    i2c3_gmux: u4 = 0,
    spi1_gmux: u4 = 0,
    spi2_gmux: u4 = 0,
    spi3_gmux: u4 = 0,
    spi4_gmux: u4 = 0
};

pub const IomuxRemap6 = packed struct(u32) {
    can1_gmux: u4 = 0,
    can2_gmux: u4 = 0,
    reserved1: u4 = 0,
    sdio2_gmux: u4 = 0,
    usart1_gmux: u4 = 0,
    usart2_gmux: u4 = 0,
    usart3_gmux: u4 = 0,
    uart4_gmux: u4 = 0,
};

pub const IomuxRemap7 = packed struct(u32) {
    ext_spim_gmux: u3 = 0,
    ext_spim_gen: bool = false,
    adc1_etp_gmux: bool = false,
    adc1_eto_gmux: bool = false,
    reserved1: u2 = 0,
    adc2_etp_gmux: bool = false,
    adc2_eto_gmux: bool = false,
    reserved2: u6 = 0,
    swjtag_gmux: u3 = 0,
    reserved3: u1 = 0,
    pd01_gmux: bool = false,
    reserved4: u3 = 0,
    xmc_gmux: u3 = 0,
    xmc_nadv_gmux: bool = false,
    reserved5: u4 = 0
};

pub const IomuxRemap8 = packed struct(u32) {
    reserved1: u16 = 0,
    emac_gmux: u2 = 0,
    mii_rmii_sel_gmux: bool = false,
    ptp_pps_gmux: bool = false,
    usart6_gmux: u4 = 0,
    uart7_gmux: u4 = 0,
    uart8_gmux: u4 = 0
};

pub const Iomux = extern struct {
    evtout: IomuxEvtout,
    remap: IomuxRemap,
    exintc: [4]u32,
    reserved1: u32,
    remap2: IomuxRemap2,
    remap3: IomuxRemap3,
    remap4: IomuxRemap4,
    remap5: IomuxRemap5,
    remap6: IomuxRemap6,
    remap7: IomuxRemap7,
    remap8: IomuxRemap8,

    pub fn interruptPort(self: *volatile Iomux, line: u4, port: ExintPort) void {
        const idx = line >> 2;
        const shift = (line & 0x3) << 2;
        self.exintc[idx] = (self.exintc[idx] & ~(0xF << shift)) | (@backingInt(port) << shift);
    }
};

pub const iomux: *volatile Iomux = @ptrFromInt(IOMUX_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x38, @sizeOf(Iomux));
}
