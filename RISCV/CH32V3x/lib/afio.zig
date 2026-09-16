const AFIO_BASE: usize = 0x40010000;

pub const AfioEcr = packed struct(u32) {
    pin: u4,
    port: u3,
    evoe: bool,
    reserved: u24
};

pub const AfioPcfr1 = packed struct(u32) {
    spi1_rm: bool = false,
    i2c1_rm: bool = false,
    usart1_rm: bool = false,
    usart2_rm: bool = false,
    usart3_rm: u2 = 0,
    tim1_rm: u2 = 0,
    tim2_rm: u2 = 0,
    tim3_rm: u2 = 0,
    tim4_rm: bool = false,
    can1_rm: u2 = 0,
    pd01_rm: bool = false,
    tim5ch4_rm: bool = false,
    adc1_etrginj_rm: bool = false,
    adc1_etrgreg_rm: bool = false,
    adc2_etrginj_rm: bool = false,
    adc2_etrgreg_rm: bool = false,
    eth_rm: bool = false,
    can2_rm: bool = false,
    mii_rmii_sel: bool = false,
    sw_cfg: u3 = 0,
    reserved: u1 = 0,
    spi3_rm: bool = false,
    tim2tr1_rm: bool = false,
    ptp_pps_rm: bool = false,
    reserved2: u1 = 0,
};

pub const AfioPcfr2 = packed struct(u32) {
    reserved: u2 = 0,
    tim8_rm: bool = false,
    tim9_rm: u2 = 0,
    tim10_rm: u2 = 0,
    reserved2: u3 = 0,
    fsmc_nadv: bool = false,
    reserved3: u5 = 0,
    usart4_rm: u2 = 0,
    usart5_rm: u2 = 0,
    usart6_rm: u2 = 0,
    usart7_rm: u2 = 0,
    usart8_rm: u2 = 0,
    usart1_rm1: bool = false,
    reserved4: u5 = 0
};

pub const AfioExtiPort = enum(u4) {
    porta = 0,
    portb = 1,
    portc = 2,
    portd = 3,
    porte = 4
};

pub const AfioExtiCr1 = packed struct(u32) {
    exti0: AfioExtiPort = .porta,
    exti1: AfioExtiPort = .porta,
    exti2: AfioExtiPort = .porta,
    exti3: AfioExtiPort = .porta,
    reserved: u16 = 0
};

pub const AfioExtiCr2 = packed struct(u32) {
    exti4: AfioExtiPort = .porta,
    exti5: AfioExtiPort = .porta,
    exti6: AfioExtiPort = .porta,
    exti7: AfioExtiPort = .porta,
    reserved: u16 = 0
};

pub const AfioExtiCr3 = packed struct(u32) {
    exti8: AfioExtiPort = .porta,
    exti9: AfioExtiPort = .porta,
    exti10: AfioExtiPort = .porta,
    exti11: AfioExtiPort = .porta,
    reserved: u16 = 0
};

pub const AfioExtiCr4 = packed struct(u32) {
    exti12: AfioExtiPort = .porta,
    exti13: AfioExtiPort = .porta,
    exti14: AfioExtiPort = .porta,
    exti15: AfioExtiPort = .porta,
    reserved: u16 = 0
};

pub const Afio = extern struct {
    ecr: AfioEcr,
    pcfr1: AfioPcfr1,
    exticr1: AfioExtiCr1,
    exticr2: AfioExtiCr2,
    exticr3: AfioExtiCr3,
    exticr4: AfioExtiCr4,
    reserved: u32,
    pcfr2: AfioPcfr2
};

pub const afio: *volatile Afio = @ptrFromInt(AFIO_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Afio));
}
