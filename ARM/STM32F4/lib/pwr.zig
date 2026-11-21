const PWR_BASE = 0x40007000;

pub const PwrPls = enum(u3) {
    _2v0 = 0,
    _2v1 = 1,
    _2v3 = 2,
    _2v5 = 3,
    _2v6 = 4,
    _2v7 = 5,
    _2v8 = 6,
    _2v9 = 7
};

pub const PwrUd = enum(u2) {
    disable = 0,
    enable = 3
};

pub const PwrCr = bitpack struct(u32) {
    lpds: bool = false,
    pdds: bool = false,
    cwuf: bool = false,
    csbf: bool = false,
    pvde: bool = false,
    pls: PwrPls = ._2v0,
    dbp: bool = false,
    fpds: bool = false,
    lplvds: bool = false,
    mrlvds: bool = false,
    reserved0: u2 = 0,
    vos: u2 = 3,
    oden: bool = false,
    odswen: bool = false,
    uden: PwrUd = .disable,
    reserved1: u12 = 0,
};

pub const PwrCsr = bitpack struct(u32) {
    wuf: bool = false,
    sbf: bool = false,
    pvdo: bool = false,
    brr: bool = false,
    reserved0: u4 = 0,
    ewup: bool = false,
    bre: bool = false,
    reserved1: u4 = 0,
    vosrdy: bool = false,
    reserved2: u1 = 0,
    odrdy: bool = false,
    odswrdy: bool = false,
    udrdy: PwrUd = .disable,
    reserved3: u12 = 0,
};

pub const Pwr = extern struct {
    cr: PwrCr,
    csr: PwrCsr,
};

pub const pwr: *volatile Pwr = @ptrFromInt(PWR_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(8, @sizeOf(Pwr));
}
