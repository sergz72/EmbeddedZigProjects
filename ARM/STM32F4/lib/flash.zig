const FLASH_BASE: usize = 0x40023C00;

pub const FLASH_KEY1 = 0x45670123;
pub const FLASH_KEY2 = 0xCDEF89AB;
pub const FLASH_OPT_KEY1 = 0x08192A3B;
pub const FLASH_OPT_KEY2 = 0x4C5D6E7F;


pub const FlashAcr = packed struct(u32) {
    latency: u4 = 0,
    reserved: u4 = 0,
    prften: bool = false,
    icen: bool = false,
    dcen: bool = false,
    icrst: bool = false,
    dcrst: bool = false,
    reserved2: u19 = 0
};

pub const FlashSr = packed struct(u32) {
    eop: bool = false,
    operr: bool = false,
    reserved: u2 = 0,
    wrperr: bool = false,
    pgaerr: bool = false,
    pgperr: bool = false,
    pgserr: bool = false,
    rderr: bool = false,
    reserved2: u7 = 0,
    bsy: bool = false,
    reserved3: u15 = 0
};

pub const FlashCr = packed struct(u32) {
    pg: bool = false,
    ser: bool = false,
    mer: bool = false,
    snb: u5 = 0,
    psize: u2 = 0,
    reserved2: u5 = 0,
    mer1: bool = false,
    strt: bool = false,
    reserved3: u7 = 0,
    eopie: bool = false,
    errie: bool = false,
    reserved4: u5 = 0,
    lock: bool = true
};

pub const Flash = extern struct {
    acr: FlashAcr,
    keyr: u32,
    optkeyr: u32,
    sr: FlashSr,
    cr: FlashCr,
    optcr: u32,
    optcr1: u32
};

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1C, @sizeOf(Flash));
}
