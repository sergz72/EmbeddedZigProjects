const DCACHE_BASE = 0x40031400;

pub const DCachecmd = enum(u3) {
    nop = 0,
    clean = 1,
    cleaninv = 2,
    inv = 3
};

pub const DcacheCr = packed struct(u32) {
    en: bool = false,
    cacheinv: bool = false,
    reserved0: u6 = 0,
    cachecmd: DCachecmd = .nop,
    startcmd: bool = false,
    reserved1: u4 = 0,
    rhitmen: bool = false,
    rmissmen: bool = false,
    rhitmrst: bool = false,
    rmissmrst: bool = false,
    whitmen: bool = false,
    wmissmen: bool = false,
    whitmrst: bool = false,
    wmissmrst: bool = false,
    reserved2: u7 = 0,
    hburst: bool = false,
};

pub const DcacheSr = packed struct(u32) {
    busyf: bool,
    bsyendf: bool,
    errf: bool,
    busycmdf: bool,
    cmdendf: bool,
    reserved0: u27
};

pub const Dcacher = packed struct(u32) {
    reserved0: u1 = 0,
    bsyend: bool = false,
    err: bool = false,
    reserved1: u1 = 0,
    cmdend: bool = false,
    reserved2: u27 = 0
};

pub const DcacheCmdraddrr = packed struct(u32) {
    reserved0: u4 = 0,
    cmdstartaddr: u28 = 0,
};

pub const Dcache = extern struct {
    cr: DcacheCr,
    sr: DcacheSr,
    ier: Dcacher,
    fcr: Dcacher,
    rhmonr: u32,
    rmmonr: u32,
    reserved: [2]u32,
    whmonr: u32,
    wmmonr: u32,
    cmdrsaddrr: DcacheCmdraddrr,
    cmdreaddrr: DcacheCmdraddrr
};

pub const dcache: *volatile Dcache = @ptrFromInt(DCACHE_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Dcache));

}
