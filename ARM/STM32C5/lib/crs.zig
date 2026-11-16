const CRS_BASE = 0x40006000;

pub const CrsCr = bitpack struct(u32) {
    syncokie: bool = false,
    syncwarnie: bool = false,
    errie: bool = false,
    esyncie: bool = false,
    reserved0: u1 = 0,
    cen: bool = false,
    autotrimen: bool = false,
    swsync: bool = false,
    trim: u7 = 48,
    reserved1: u17 = 0,
};

pub const Syncdiv = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7
};

pub const CrsCfgr = bitpack struct(u32) {
    reload: u16 = 47999,
    felim: u8 = 34,
    syncdiv: Syncdiv = .div1,
    reserved0: u1 = 0,
    syncsrc: u2 = 2,
    reserved1: u1 = 0,
    syncpol: bool = false,
};

pub const CrsIsr = bitpack struct(u32) {
    syncokf: bool,
    syncwarnf: bool,
    errf: bool,
    esyncf: bool,
    reserved0: u4,
    syncerr: bool,
    syncmiss: bool,
    trimovf: bool,
    reserved1: u4,
    fedir: bool,
    fecap: u16,
};

pub const CrsIcr = bitpack struct(u32) {
    syncokc: bool = false,
    syncwarnc: bool = false,
    errc: bool = false,
    esyncc: bool = false,
    reserved0: u28 = 0,
};

pub const Crs = extern struct {
    cr: CrsCr,
    cfgr: CrsCfgr,
    isr: CrsIsr,
    icr: CrsIcr,
};

pub const crs: *volatile Crs = @ptrFromInt(CRS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10, @sizeOf(Crs));
}
