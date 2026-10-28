const std = @import("std");

const FMC_BASE: usize = 0x40022000;

const FLASH_UNLOCK_KEY1 = 0x45670123;
const FLASH_UNLOCK_KEY2 = 0xCDEF89AB;

const ERASE_TIMEOUT = 0x40000000; // internal flash erase operation timeout
const PROGRAMMING_TIMEOUT = 0x00100000; // internal flash program operation timeout
const OPERATION_TIMEOUT = 0x10000000; // flash common operation timeout

pub const PAGE_SIZE = 1024;

pub const FmcWsCnt = enum(u3) {
    _0upto24Mhz = 0,
    _1upto48Mhz = 1,
    _2upto72Mhz = 2
};

pub const FmcWs = packed struct(u32) {
    wscnt: FmcWsCnt = ._0upto24Mhz,
    reserved: u1 = 0,
    pfen: bool = true,
    reserved2: u10 = 1,
    pgw: bool = false,
    reserved3: u16 = 0
};

pub const FmcStat = packed struct(u32) {
    busy: bool = false,
    reserved: u1 = 0,
    pgerr: bool = false,
    pgaerr: bool = false,
    wperr: bool = false,
    endf: bool = false,
    reserved2: u26 = 0
};

pub const FmcCtl = packed struct(u32) {
    pg: bool = false,
    per: bool = false,
    mer: bool = false,
    reserved: u1 = 0,
    obpg: bool = false,
    ober: bool = false,
    start: bool = false,
    lk: bool = true,
    reserved2: u1 = 0,
    obwen: bool = false,
    errie: bool = false,
    reserved3: u1 = 0,
    endie: bool = false,
    obrld: bool = false,
    reserved4: u18 = 0
};

pub const FmcProtectionLevel = enum(u2) {
    no_protection = 0,
    low = 1,
    high = 3
};

pub const FlashObstat = packed struct(u32) {
    oberr: bool,
    plevel: FmcProtectionLevel,
    reserved: u5,
    ob_user: u8,
    ob_data: u16
};

pub const FmcError = error {
    Timeout,
    ProgramError,
    ProgramAlignmentError,
    ProtectionError,
    InvalidAddress
};

pub const Fmc = extern struct {
    ws: FmcWs,
    key: u32,
    obkey: u32,
    stat: FmcStat,
    ctl: FmcCtl,
    addr: u32,
    reserved: u32,
    obstat: FlashObstat,
    wp: u32,
    reserved2: [55]u32,
    //0x100
    pid: u32,

    pub fn flashUnlock(self: *volatile Fmc) void {
        self.key = FLASH_UNLOCK_KEY1;
        self.key = FLASH_UNLOCK_KEY2;
    }

    pub fn flashLock(self: *volatile Fmc) void {
        self.ctl.lk = true;
    }

    pub fn wait(self: *volatile Fmc, timeout: usize) FmcError!void {
        for (0..timeout) |_| {
            const sts = self.stat;
            if (sts.pgerr) {
                return FmcError.ProgramError;
            }
            if (sts.pgaerr) {
                return FmcError.ProgramAlignmentError;
            }
            if (sts.wperr) {
                return FmcError.ProtectionError;
            }
            if (!sts.busy) {
                return;
            }
        }
        return FmcError.Timeout;
    }

    pub fn pageErase(self: *volatile Fmc, address: usize) FmcError!void {
        self.ctl.per = true;
        self.addr = address;
        self.ctl.start = true;
        defer self.ctl.per = false;
        try self.wait(ERASE_TIMEOUT);
    }

    pub fn wordProgram(self: *volatile Fmc, address: usize, data: u32) FmcError!void {
        if (address & 3 != 0) {
            return FmcError.InvalidAddress;
        }
        self.ctl.pg = true;
        const p: *u32 = @ptrFromInt(address);
        p.* = data;
        defer self.ctl.pg = false;
        try self.wait(PROGRAMMING_TIMEOUT);
    }

    pub fn write32(self: *volatile Fmc, address: usize, data: []u32) FmcError!void {
        var a = address;
        for (data) |word| {
            try self.wordProgram(a, word);
            a += 4;
        }
    }

    pub fn write(self: *volatile Fmc, address: usize, data: []const u8) FmcError!void {
        var a = address;
        var l = data.len;
        var idx: usize = 0;
        while (l >= 4) {
            const word = std.mem.readInt(u32, data[idx..][0..4], .little);
            try self.wordProgram(a, word);
            a += 4;
            idx += 4;
            l -= 4;
        }
        if (l != 0) {
            var v: [4]u8 = .{0xFF, 0xFF, 0xFF, 0xFF};
            @memcpy(v[0..l], data[idx..]);
            const d = std.mem.readInt(u32, &v, .little);
            try self.wordProgram(a, d);
        }
    }
};

pub const fmc: *volatile Fmc = @ptrFromInt(FMC_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x104, @sizeOf(Fmc));
}
