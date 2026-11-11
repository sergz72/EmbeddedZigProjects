const I2C1_BASE = 0x40005400;
const I2C2_BASE = 0x40005800;
const I2C3_BASE = 0x44002800;
const I2C4_BASE = 0x44002C00;

pub const I2cCr1 = packed struct(u32) {
    pe: bool = false,
    txie: bool = false,
    rxie: bool = false,
    addrie: bool = false,
    nackie: bool = false,
    stopie: bool = false,
    tcie: bool = false,
    errie: bool = false,
    dnf: u4 = 0,
    anfoff: bool = false,
    reserved0: u1 = 0,
    txdmaen: bool = false,
    rxdmaen: bool = false,
    sbc: bool = false,
    nostretch: bool = false,
    wupen: bool = false,
    gcen: bool = false,
    smbhen: bool = false,
    smbden: bool = false,
    alerten: bool = false,
    pecen: bool = false,
    fmp: bool = false,
    reserved1: u5 = 0,
    addraclr: bool = false,
    stopfaclr: bool = false,
};

pub const I2cCr2 = packed struct(u32) {
    sadd: u10 = 0,
    rd_wrn: bool = false,
    add10: bool = false,
    head10r: bool = false,
    start: bool = false,
    stop: bool = false,
    nack: bool = false,
    nbytes: u8 = 0,
    reload: bool = false,
    autoend: bool = false,
    pecbyte: bool = false,
    reserved0: u5 = 0,
};

pub const I2cOar1 = packed struct(u32) {
    oa1: u10 = 0,
    oa1mode: bool = false,
    reserved0: u4 = 0,
    oa1en: bool = false,
    reserved1: u16 = 0,
};

pub const I2cOar2 = packed struct(u32) {
    reserved0: u1 = 0,
    oa2: u7 = 0,
    oa2msk: u3 = 0,
    reserved1: u4 = 0,
    oa2en: bool = false,
    reserved2: u16 = 0,
};

pub const I2cTimingr = packed struct(u32) {
    scll: u8 = 0,
    sclh: u8 = 0,
    sdadel: u4 = 0,
    scldel: u4 = 0,
    reserved0: u4 = 0,
    presc: u4 = 0,
};

pub const I2cTimeoutr = packed struct(u32) {
    timeouta: u12 = 0,
    tidle: bool = false,
    reserved0: u2 = 0,
    timouten: bool = false,
    timeoutb: u12 = 0,
    reserved1: u3 = 0,
    texten: bool = false,
};

pub const I2cIsr = packed struct(u32) {
    txe: bool = true,
    txis: bool = false,
    rxne: bool = false,
    addr: bool = false,
    nackf: bool = false,
    stopf: bool = false,
    tc: bool = false,
    tcr: bool = false,
    berr: bool = false,
    arlo: bool = false,
    ovr: bool = false,
    pecerr: bool = false,
    timeout: bool = false,
    alert: bool = false,
    reserved0: u1 = 0,
    busy: bool = false,
    dir: bool = false,
    addcode: u7 = 0,
    reserved1: u8 = 0,
};

pub const I2cIcr = packed struct(u32) {
    reserved0: u3 = 0,
    addrcf: bool = false,
    nackcf: bool = false,
    stopcf: bool = false,
    reserved1: u2 = 0,
    berrcf: bool = false,
    arlocf: bool = false,
    ovrcf: bool = false,
    peccf: bool = false,
    timoutcf: bool = false,
    alertcf: bool = false,
    reserved2: u18 = 0,
};

pub const I2cPecr = packed struct(u32) {
    pec: u8 = 0,
    reserved0: u24 = 0,
};

pub const I2c = extern struct {
    cr1: I2cCr1,
    cr2: I2cCr2,
    oar1: I2cOar1,
    oar2: I2cOar2,
    timingr: I2cTimingr,
    timeoutr: I2cTimeoutr,
    isr: I2cIsr,
    icr: I2cIcr,
    pecr: I2cPecr,
    rxdr: u8,
    reserved0: [3]u8,
    txdr: u8,
    reserved1: [3]u8
};

pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);
pub const i2c2: *volatile I2c = @ptrFromInt(I2C2_BASE);
pub const i2c3: *volatile I2c = @ptrFromInt(I2C3_BASE);
pub const i2c4: *volatile I2c = @ptrFromInt(I2C4_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2C, @sizeOf(I2c));
}
