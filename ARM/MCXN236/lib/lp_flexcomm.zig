const LP_FLEXCOMM0_BASE = 0x40092000;
const LP_FLEXCOMM1_BASE = 0x40093000;
const LP_FLEXCOMM2_BASE = 0x40094000;
const LP_FLEXCOMM3_BASE = 0x40095000;
const LP_FLEXCOMM4_BASE = 0x400B4000;
const LP_FLEXCOMM5_BASE = 0x400B5000;
const LP_FLEXCOMM6_BASE = 0x400B6000;
const LP_FLEXCOMM7_BASE = 0x400B7000;

pub const Istat = packed struct(u32) {
    uarttx: bool,
    uartrx: bool,
    spi: bool,
    reserved0: u1,
    i2cm: bool,
    i2cs: bool,
    reserved1: u26,
};

pub const Persel = enum(u3) {
    none = 0,
    uart = 1,
    spi = 2,
    i2c = 3,
    uarti2c = 7,
};

pub const Pselid = packed struct(u32) {
    persel: Persel = .none,
    lock: bool = false,
    uartpresent: bool = true,
    spipresent: bool = true,
    i2cpresent: bool = true,
    reserved0: u5 = 0,
    id: u20 = 259
};

pub const LpFlexcomm = extern struct {
    reserved0: [1021]u32,
    istat: Istat,
    pselid: Pselid,
};

pub const lp_flexcomm0: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM0_BASE);
pub const lp_flexcomm1: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM1_BASE);
pub const lp_flexcomm2: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM2_BASE);
pub const lp_flexcomm3: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM3_BASE);
pub const lp_flexcomm4: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM4_BASE);
pub const lp_flexcomm5: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM5_BASE);
pub const lp_flexcomm6: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM6_BASE);
pub const lp_flexcomm7: *volatile LpFlexcomm = @ptrFromInt(LP_FLEXCOMM7_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xFFC, @sizeOf(LpFlexcomm));
}
