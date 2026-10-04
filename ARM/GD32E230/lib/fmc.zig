const FMC_BASE: usize = 0x40022000;

pub const FmcWsCnt = enum(u3) {
    _0upto24Mhz = 0,
    _1upto48Mhz = 1,
    _2upto72Mhz = 2
};

pub const FmcWs = packed struct(u32) {
    wscnt: FmcWsCnt = ._0upto24Mhz,
    reserved: u1 = 0,
    pfen: bool = true,
    reserved2: u10 = 0,
    pgw: bool = false,
    reserved3: u16 = 0
};

pub const Fmc = extern struct {
    ws: FmcWs,
    key: u32,
    obkey: u32,
    stat: u32,
    ctl: u32,
    addr: u32,
    reserved: u32,
    obstat: u32,
    wp: u32,
    reserved2: [55]u32,
    //0x100
    pid: u32
};

pub const fmc: *volatile Fmc = @ptrFromInt(FMC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x104, @sizeOf(Fmc));
}
