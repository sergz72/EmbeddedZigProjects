const builtin = @import("builtin");
//const common = @import("common");
const common = if (builtin.is_test) @import("common.zig") else @import("common");

const MATHACL_BASE: usize = 0x40410000 + 0x800;

pub const MathaclGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const MathaclFunc = enum(u5) {
    nop = 0,
    sin_cos = 1,
    arctan = 2,
    div = 4,
    sqrt = 5,
    mul32_result = 6,
    sqrt32_result = 7,
    mul64_result1 = 8,
    mul64_result2 = 9,
    mac = 10,
    sqrt_and_accumulate = 11
};

pub const MathaclCtl = packed struct(u32) {
    func: MathaclFunc,
    optype: bool = false,
    reserved: u2 = 0,
    qval: u5 = 0,
    reserved2: u3 = 0,
    sfactor: u6 = 0,
    saten: bool = false,
    reserved3: u1 = 0,
    numiter: u5 = 0,
    reserved4: u3 = 0,
};

pub const MathaclStatus = packed struct(u32) {
    uf: bool = false,
    ovf: bool = false,
    err: u2 = 0,
    reserved: u4 = 0,
    busy: bool = false,
    reserved2: u23 = 0
};

pub const MathaclStatusClr = packed struct(u32) {
    clr_uf: bool = false,
    clr_ovf: bool = false,
    clr_err: bool = false,
    reserved2: u29 = 0
};

pub const Mathacl = extern struct {
    gprcm: MathaclGprcm,
    reserved1: [570]u32,
    ctl: MathaclCtl,
    reserved2: [5]u32,
    op2: u32,
    op1: u32,
    res1: u32,
    res2: u32,
    reserved3: [2]u32,
    status: MathaclStatus,
    reserved4: [3]u32,
    statusclr: MathaclStatusClr,

    pub inline fn enablePower(self: *volatile Mathacl) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub inline fn reset(self: *volatile Mathacl) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }
};

pub const mathacl: *volatile Mathacl = @ptrFromInt(MATHACL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1144-0x800, @sizeOf(Mathacl));
}
