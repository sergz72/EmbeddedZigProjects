const AFIO_BASE = 0x40010000;

pub const AfioPcfr1 = bitpack struct(u32) {
    pd0pd1_rm: bool = false,
    adc1_etrgreg_rm: bool = false,
    adc1_etrginj_rm: bool = false,
    adc2_etrgreg_rm: bool = false,
    adc2_etrginj_rm: bool = false,
    reserved0: u1 = 0,
    uhsif_clk_rm: u2 = 0,
    uhsif_port_rm: u2 = 0,
    sdmmc_rm: u2 = 0,
    tim2itr1_rm: bool = false,
    reserved1: u3 = 0,
    vio18_io_hslv: bool = false,
    vio33_io_hslv: bool = false,
    vdd33_io_hslv: bool = false,
    reserved2: u1 = 0,
    usbpd_cc_hvt: bool = false,
    reserved3: u3 = 0,
    sw_cfg: u3 = 0,
    reserved4: u5 = 0,
};

pub const AfioExticr1 = bitpack struct(u32) {
    exti0: u4 = 0,
    exti1: u4 = 0,
    exti2: u4 = 0,
    exti3: u4 = 0,
    exti4: u4 = 0,
    exti5: u4 = 0,
    exti6: u4 = 0,
    exti7: u4 = 0,
};

pub const AfioExticr2 = bitpack struct(u32) {
    exti8: u4 = 0,
    exti9: u4 = 0,
    exti10: u4 = 0,
    exti11: u4 = 0,
    exti12: u4 = 0,
    exti13: u4 = 0,
    exti14: u4 = 0,
    exti15: u4 = 0,
};

pub const Afio = extern struct {
    pcfr1: AfioPcfr1,
    afr: [12]u32,
    reserved0: u32,
    exticr1: AfioExticr1,
    exticr2: AfioExticr2,
};

pub const AfioPort = enum(usize) {
    A = 0,
    B = 1,
    C = 2,
    D = 3,
    E = 4,
    F = 5
};

pub fn setGpioFunction(port: AfioPort, pin: u4, function: u4) void {
    @setRuntimeSafety(false);
    const afr_index = @backingInt(port) * 2 + pin / 8;
    const afr_shift = @as(u5, pin & 7) * 4;
    afio.afr[afr_index] = (afio.afr[afr_index] & ~(@as(u32, 0xF) << afr_shift)) | (@as(u32, function) << afr_shift);
}

pub const afio: *volatile Afio = @ptrFromInt(AFIO_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x40, @sizeOf(Afio));
}
