const AFIO_BASE: usize = 0x40010000;

pub const AfioEcr = packed struct(u32) {
    pin: u4,
    port: u3,
    evoe: bool,
    reserved: u24
};

pub const AfioPcfr1 = packed struct(u32) {
    spi1_rm: u2 = 0,
    i2c1_rm: u3 = 0,
    usart1_rm: u2 = 0,
    usart2_rm: u3 = 0,
    usart3_rm: u2 = 0,
    usart4_rm: u3 = 0,
    tim1_rm: u3 = 0,
    tim2_rm: u3 = 0,
    tim3_rm: u2 = 0,
    pioc_rm: bool = false,
    sw_cfg: u3 = 0,
    reserved: u5 = 0
};

pub const AfioExtiPort = enum(u2) {
    porta = 0,
    portb = 2,
    portc = 3
};

pub const AfioExtiCr1 = packed struct(u32) {
    exti0: AfioExtiPort = .porta,
    exti1: AfioExtiPort = .porta,
    exti2: AfioExtiPort = .porta,
    exti3: AfioExtiPort = .porta,
    exti4: AfioExtiPort = .porta,
    exti5: AfioExtiPort = .porta,
    exti6: AfioExtiPort = .porta,
    exti7: AfioExtiPort = .porta,
    exti8: AfioExtiPort = .porta,
    exti9: AfioExtiPort = .porta,
    exti10: AfioExtiPort = .porta,
    exti11: AfioExtiPort = .porta,
    exti12: AfioExtiPort = .porta,
    exti13: AfioExtiPort = .porta,
    exti14: AfioExtiPort = .porta,
    exti15: AfioExtiPort = .porta
};

pub const AfioExtiCr2 = packed struct(u32) {
    exti16: AfioExtiPort = .porta,
    exti17: AfioExtiPort = .porta,
    exti18: AfioExtiPort = .porta,
    exti19: AfioExtiPort = .porta,
    exti20: AfioExtiPort = .porta,
    exti21: AfioExtiPort = .porta,
    exti22: AfioExtiPort = .porta,
    exti23: AfioExtiPort = .porta,
    reserved: u16 = 0
};

pub const AfioCtlr = packed struct(u32) {
    udm_pue: u2 = 1,
    udp_pue: u2 = 1,
    reserved: u2 = 0,
    usb_phy_v33: bool = true,
    usb_ioen: bool = false,
    usbd_phy_v33: bool = false,
    usbpd_in_hvt: bool = false,
    reserved2: u6 = 0,
    udp_bc_vsrc: bool = false,
    udm_bc_vsrc: bool = false,
    udp_bc_cmpo: bool = false,
    udm_bc_cmpo: bool = false,
    reserved3: u4 = 0,
    pa3_filt_en: bool = false,
    pa4_filt_en: bool = false,
    pb5_filt_en: bool = false,
    pb6_filt_en: bool = false,
    reserved4: u4 = 0
};

pub const Afio = extern struct {
    reserved: u32,
    pcfr1: AfioPcfr1,
    exticr1: AfioExtiCr1,
    exticr2: AfioExtiCr2,
    reserved2: [2]u32,
    ctlr: AfioCtlr
};

pub const afio: *volatile Afio = @ptrFromInt(AFIO_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1C, @sizeOf(Afio));
}
