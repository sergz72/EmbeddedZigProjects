const std = @import("std");
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

pub const CrcpData = extern union {
    b: u8,
    h: u16,
    w: u32
};

pub const Crcp = extern struct {
    gprcm: CrcpGprcmRegs,
    reserved1: [507]u32,
    clksel: u32,
    reserved2: [61]u32,
    desc: u32,
    crcctrl: CrcpCtrl,
    crcseed: CrcpData,
    crcin: CrcpData,
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

    pub fn crc32(self: *volatile Crcp, data: []const u8) u32 {
        self.crcctrl = CrcpCtrl{};
        self.crcseed.w = 0xFFFFFFFF;
        var idx: usize = 0;
        var l = data.len;
        while (l != 0) {
            if (l >= 4) {
                const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .little);
                self.crcin.w = d;
                l -= 4;
                idx += 4;
                continue;
            }
            if (l >= 2) {
                const d: u16 = std.mem.readInt(u16, data[idx..][0..2], .little);
                self.crcin.h = d;
                l -= 2;
                idx += 2;
                continue;
            }
            self.crcin.b = data[idx];
            l = 0;
        }
        return self.crcout;
    }

    pub fn crc16(self: *volatile Crcp, data: []const u8) u16 {
        self.crcctrl = CrcpCtrl{.polysize = true};
        self.crcseed.h = 0xFFFF;
        for (data) |d| {
            self.crcin.b = d;
        }
        return @truncate(self.crcout);
    }
};

pub const crcp: *volatile Crcp = @ptrFromInt(CRCP_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x2000-0x800, @sizeOf(Crcp));
}
