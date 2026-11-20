const PINT0_BASE = 0x40004000;

pub const Pmctrl = bitpack struct(u32) {
    sel_pmatch: bool = false,
    ena_rxev: bool = false,
    reserved0: u22 = 0,
    pmat: u8 = 0,
};

pub const Pmsrc = bitpack struct(u32) {
    reserved0: u8 = 0,
    src0: u3 = 0,
    src1: u3 = 0,
    src2: u3 = 0,
    src3: u3 = 0,
    src4: u3 = 0,
    src5: u3 = 0,
    src6: u3 = 0,
    src7: u3 = 0,
};

pub const Cfg = enum(u3) {
    constant_high = 0,
    sticky_rising_edge = 1,
    sticky_falling_edge = 2,
    sticky_rising_falling_edge = 3,
    high_level = 4,
    low_level = 5,
    constant_zero = 6,
    event = 7,
};

pub const Pmcfg = bitpack struct(u32) {
    prod_endpts0: bool = false,
    prod_endpts1: bool = false,
    prod_endpts2: bool = false,
    prod_endpts3: bool = false,
    prod_endpts4: bool = false,
    prod_endpts5: bool = false,
    prod_endpts6: bool = false,
    reserved0: u1 = 0,
    cfg0: Cfg = .constant_high,
    cfg1: Cfg = .constant_high,
    cfg2: Cfg = .constant_high,
    cfg3: Cfg = .constant_high,
    cfg4: Cfg = .constant_high,
    cfg5: Cfg = .constant_high,
    cfg6: Cfg = .constant_high,
    cfg7: Cfg = .constant_high,
};

pub const Pint = extern struct {
    isel: u32,
    ienr: u32,
    sienr: u32,
    cienr: u32,
    ienf: u32,
    sienf: u32,
    cienf: u32,
    rise: u32,
    fall: u32,
    ist: u32,
    pmctrl: Pmctrl,
    pmsrc: Pmsrc,
    pmcfg: Pmcfg,
};

pub const pint0: *volatile Pint = @ptrFromInt(PINT0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x34, @sizeOf(Pint));
}
