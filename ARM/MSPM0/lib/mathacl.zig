const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

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

pub const MathaclError = error {
    DivideByZero,
    Underflow,
    Overflow,
    MathError
};

pub const MathaclDivResultUnsigned = struct {
    quotient: u32,
    remainder: u32
};

pub const MathaclDivResultSigned = struct {
    quotient: i32,
    remainder: i32
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

    fn wait(self: *volatile Mathacl) MathaclError!void {
        while (self.status.busy) {
            asm volatile("nop");
        }
        defer self.statusclr = MathaclStatusClr{
            .clr_uf = true,
            .clr_ovf = true,
            .clr_err = true
        };
        if (self.status.uf) return MathaclError.Underflow;
        if (self.status.ovf) return MathaclError.Overflow;
        if (self.status.err != 0) return MathaclError.MathError;
    }

    pub fn divremUnsigned(self: *volatile Mathacl, numerator: u32, denominator: u32) MathaclError!MathaclDivResultUnsigned {
        if (denominator == 0) return MathaclError.DivideByZero;
        self.ctl = MathaclCtl{
            .func = MathaclFunc.div,
            .optype = false
        };
        self.op2 = denominator;
        self.op1 = numerator;

        try self.wait();

        return MathaclDivResultUnsigned{
            .quotient = self.res1,
            .remainder = self.res2
        };
    }

    pub fn divremSigned(self: *volatile Mathacl, numerator: i32, denominator: i32) MathaclError!MathaclDivResultSigned {
        if (denominator == 0) return MathaclError.DivideByZero;
        self.ctl = MathaclCtl{
            .func = MathaclFunc.div,
            .optype = true
        };
        self.op2 = @bitCast(denominator);
        self.op1 = @bitCast(numerator);

        try self.wait();

        return MathaclDivResultSigned{
            .quotient = @bitCast(self.res1),
            .remainder = @bitCast(self.res2)
        };
    }
};

pub const mathacl: *volatile Mathacl = @ptrFromInt(MATHACL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1144-0x800, @sizeOf(Mathacl));
}
