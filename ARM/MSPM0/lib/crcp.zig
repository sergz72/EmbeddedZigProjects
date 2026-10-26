const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const CRCP_BASE: usize = 0x40440000 + 0x800;

pub const CrcpGprcmRegs = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const CrcpCtrl = packed struct(u32) {
    polysize: bool = false,
    bitreverse: bool = false,
    input_endianess: bool = false,
    reserved: u1 = 0,
    output_byteswap: bool = false,
    reserved1: u27 = 0
};

pub const Crcp = extern struct {
    gprcm: CrcpGprcmRegs,
    reserved1: [507]u32,
    clksel: u32,
    reserved2: [61]u32,
    desc: u32,
    crcctrl: CrcpCtrl,
    crcseed: u32,
    crcin: u32,
    crcout: u32,
    crcpoly: u32,
    reserved3: [443]u32,
    crcin_idx: [512]u32,

    pub inline fn enablePower(self: *volatile Crcp) void {
        const v = common.GprcmPwren{.enable = true};
        self.gprcm.pwren = v;
    }

    pub inline fn reset(self: *volatile Crcp) void {
        const v = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
        self.gprcm.rstctl = v;
    }
};

pub const crcp: *volatile Crcp = @ptrFromInt(CRCP_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2000-0x800, @sizeOf(Crcp));
}
