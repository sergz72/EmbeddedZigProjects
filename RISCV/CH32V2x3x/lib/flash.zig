const std = @import("std");

const FLASH_BASE: usize = 0x40022000;

const FLASH_UNLOCK_KEY1 = 0x45670123;
const FLASH_UNLOCK_KEY2 = 0xCDEF89AB;

const ERASE_TIMEOUT = 0x40000000; // internal flash erase operation timeout
const PROGRAMMING_TIMEOUT = 0x00100000; // internal flash program operation timeout
const OPERATION_TIMEOUT = 0x10000000; // flash common operation timeout

pub const PAGE_SIZE = 4096;

pub const FlashStat = packed struct(u32) {
    bsy: bool = false,
    wrbsy: u1 = 0,
    reserved: u2 = 0,
    wrprterr: bool = false,
    eop: bool = false,
    reserved2: u1 = 0,
    ehmods: bool = false,
    reserved3: u24 = 0
};

pub const FlashCtl = packed struct(u32) {
    pg: bool = false,
    per: bool = false,
    mer: bool = false,
    reserved: u1 = 0,
    obpg: bool = false,
    ober: bool = false,
    strt: bool = false,
    lock: bool = true,
    reserved2: u1 = 0,
    obwre: bool = false,
    errie: bool = false,
    reserved3: u1 = 0,
    eopie: bool = false,
    reserved4: u2 = 0,
    flock: bool = false,
    ftpg: bool = false,
    fter: bool = false,
    ber32: bool = false,
    reserved5: u2 = 0,
    pgstrt: bool = false,
    rsenact: bool = false,
    reserved6: u1 = 0,
    ehmod: bool = false,
    sckmod: bool = false,
    reserved7: u6 = 0
};

pub const FlashError = error {
    Timeout,
    ProtectionError,
    InvalidAddress
};

pub const Flash = extern struct {
    reserved2: u32,
    keyr: u32,
    obkeyr: u32,
    statr: FlashStat,
    ctlr: FlashCtl,
    addr: u32,
    reserved: u32,
    obr: u32,
    wpr: u32,
    flash_modekeyr: u32,

    pub fn flashUnlock(self: *volatile Flash) void {
        self.keyr = FLASH_UNLOCK_KEY1;
        self.keyr = FLASH_UNLOCK_KEY2;
    }

    pub fn flashLock(self: *volatile Flash) void {
        self.ctlr.lock = true;
    }

    pub fn wait(self: *volatile Flash, timeout: usize) FlashError!void {
        for (0..timeout) |_| {
            const sts = self.statr;
            if (sts.wrprterr) {
                return FlashError.ProtectionError;
            }
            if (!sts.bsy) {
                return;
            }
        }
        return FlashError.Timeout;
    }

    pub fn pageErase(self: *volatile Flash, address: usize) FlashError!void {
        self.statr = FlashStat{.eop = true, .wrprterr = true};
        self.ctlr.per = true;
        self.addr = address;
        self.ctlr.strt = true;
        defer self.ctlr.per = false;
        try self.wait(ERASE_TIMEOUT);
    }

    pub fn halfWordProgram(self: *volatile Flash, address: usize, data: u16) FlashError!void {
        if (address & 1 != 0) {
            return FlashError.InvalidAddress;
        }
        self.statr = FlashStat{.eop = true, .wrprterr = true};
        self.ctlr.pg = true;
        const p: *u16 = @ptrFromInt(address);
        p.* = data;
        defer self.ctlr.pg = false;
        try self.wait(PROGRAMMING_TIMEOUT);
    }

    pub fn write16(self: *volatile Flash, address: usize, data: []u16) FlashError!void {
        var a = address;
        for (data) |half| {
            try self.halfWordProgram(a, half);
            a += 2;
        }
    }

    pub fn write(self: *volatile Flash, address: usize, data: []const u8) FlashError!void {
        var a = address;
        var l = data.len;
        var idx: usize = 0;
        while (l >= 2) {
            const half = std.mem.readInt(u16, data[idx..][0..2], .little);
            try self.halfWordProgram(a, half);
            a += 2;
            idx += 2;
            l -= 2;
        }
        if (l != 0) {
            const v: u16 = @as(u16, data[idx]) | 0xFF00;
            try self.halfWordProgram(a, v);
        }
    }
};

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x28, @sizeOf(Flash));
}
