const rcc = @import("rcc");

const BKP_BASE = 0x40006C00;

pub const BkpData = extern struct {
    data: u16,
    reserved: u16
};

pub const BkpOctlr = packed struct(u16) {
    cal: u7 = 0,
    cco: bool = false,
    asoe: bool = false,
    asos: bool = false,
    reserved: u6 = 0
};

pub const BkpTpCtrl = packed struct(u16) {
    tpe: bool = false,
    tpal: bool = false,
    reserved: u14 = 0
};

pub const BkpTpCsr = packed struct(u16) {
    cte: bool = false,
    cti: bool = false,
    tpie: bool = false,
    reserved: u5 = 0,
    tef: bool = false,
    tif: bool = false,
    reserved2: u6 = 0
};

pub const Bkp = extern struct {
    reserved: u32,
    data: [10]BkpData,
    octlr: BkpOctlr,
    reserved2: u16,
    tpctlr: BkpTpCtrl,
    reserved3: u16,
    tpcsr: BkpTpCsr,
    reserved4: [5]u16,
    data2: [32]BkpData,


    pub fn enable() void {
        rcc.rcc.apb1pcenr.bkpen = true;
    }

    pub fn reset() void {
        rcc.rcc.bdctlr.bdrst = true;
        rcc.rcc.bdctlr.bdrst = false;
    }
};

pub const bkp: *volatile Bkp = @ptrFromInt(BKP_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xC0, @sizeOf(Bkp));
}
