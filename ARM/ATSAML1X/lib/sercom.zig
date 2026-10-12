const SERCOM0_BASE = 0x42000400;
const SERCOM1_BASE = 0x42000800;
const SERCOM2_BASE = 0x42000C00;

pub const SercomI2c = extern struct {
    ctrla: u32,
    ctrlb: u32,
    reserved1: u32,
    baud: u32,
    reserved2: u32,
    intenclr: u8,
    reserved3: u8,
    intenset: u8,
    reserved4: u8,
    intflag: u8,
    reserved5: u8,
    status: u16,
    syncbusy: u32,
    reserved6: u32,
    addr: u32,
    data: u8,
    reserved7: [7]u8,
    dbgctrl: u8,
    reserved8: [3]u8
};

pub const SercomSpi = extern struct {
    ctrla: u32,
    ctrlb: u32,
    reserved1: u32,
    baud: u8,
    reserved2: [7]u8,
    intenclr: u8,
    reserved3: u8,
    intenset: u8,
    reserved4: u8,
    intflag: u8,
    reserved5: u8,
    status: u16,
    syncbusy: u32,
    reserved6: u32,
    addr: u32,
    data: u32,
    reserved7: u32,
    dbgctrl: u8,
    reserved8: [3]u8
};

pub const SercomUsart = extern struct {
    ctrla: u32,
    ctrlb: u32,
    ctrlc: u32,
    baud: u16,
    rxpl: u8,
    reserved1: [5]u8,
    intenclr: u8,
    reserved2: u8,
    intenset: u8,
    reserved3: u8,
    intflag: u8,
    reserved4: u8,
    status: u16,
    syncbusy: u32,
    rxerrcnt: u8,
    reserved5: [7]u8,
    data: u16,
    reserved6: [3]u16,
    dbgctrl: u8,
    reserved8: [3]u8
};

pub const Sercom = extern union {
    i2cs: SercomI2c,
    spis: SercomSpi,
    usart: SercomUsart
};

pub const sercom0: *volatile Sercom = @ptrFromInt(SERCOM0_BASE);
pub const sercom1: *volatile Sercom = @ptrFromInt(SERCOM1_BASE);
pub const sercom2: *volatile Sercom = @ptrFromInt(SERCOM2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x34, @sizeOf(SercomI2c));
    try std.testing.expectEqual(0x34, @sizeOf(SercomSpi));
    try std.testing.expectEqual(0x34, @sizeOf(SercomUsart));
}
