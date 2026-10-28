const std = @import("std");

pub const FLASH_BASE = 0x40022000;

const FLASH_UNLOCK_KEY1 = 0x45670123;
const FLASH_UNLOCK_KEY2 = 0xCDEF89AB;

const ERASE_TIMEOUT = 0x40000000; // internal flash erase operation timeout
const PROGRAMMING_TIMEOUT = 0x00100000; // internal flash program operation timeout
const OPERATION_TIMEOUT = 0x10000000; // flash common operation timeout

pub const SECTOR_SIZE = 1024;

pub const FlashWtcyc = enum(u3) {
    _upto32MHz = 0,
    _upto64MHz = 1,
    _upto96MHz = 2,
    _upto128MHz = 3,
    _upto160MHz = 4,
    _upto180MHz = 5
};

pub const FlashPsr = packed struct(u32) {
    wtcyc: FlashWtcyc = ._upto32MHz,
    reserved1: u1 = 0,
    pft_en: bool = true,
    pft_enf: bool = true,
    pft_en2: bool = false,
    pft_enf2: bool = true,
    pft_lat_dis: bool = false,
    reserved2: u23 = 0
};

pub const FlashSts = packed struct(u32) {
    obf: bool = false,
    reserved1: u1 = 0,
    prgmerr: bool = false,
    reserved2: u1 = 0,
    epperr: bool = false,
    odf: bool = false,
    reserved3: u26 = 0
};

pub const FlashCtrl = packed struct(u32) {
    fprgm: bool = false,
    secers: bool = false,
    bankers: bool = false,
    reserved1: u1 = 0,
    usdprgm: bool = false,
    usders: bool = false,
    erstr: bool = false,
    oplk: bool = true,
    reserved2: u1 = 0,
    usdulks: bool = false,
    errie: bool = false,
    reserved3: u1 = 0,
    odfie: bool = false,
    reserved4: u19 = 0
};

pub const FlashUsd = packed struct(u32) {
    usderr: bool,
    fap: bool,
    ssb0: u8,
    ssb1: u8,
    user_d0: u8,
    fap_hl: bool,
    reserved: u5
};

pub const FlashFapSts = packed struct(u32) {
    fap: u8,
    nfap: u8,
    reserved1: u16
};

pub const FlashSlibSts0 = packed struct(u32) {
    btm_ap_enf: bool,
    reserved1: u1,
    em_slib_enf: bool,
    slib_enf: bool,
    reserved2: u12,
    em_slib_inst_ss: u8,
    reserved3: u8
};

pub const FlashSlib = packed struct(u32) {
    slib_ss: u11 = 0,
    slib_inst_ss: u11 = 0,
    slib_es: u10 = 0
};

pub const FlashSlibMiscSts = packed struct(u32) {
    slib_pwd_err: bool,
    slib_pwd_ok: bool,
    slib_ulkf: bool,
    reserved1: u29
};

pub const FlashCrcCtrl = packed struct(u32) {
    crc_sn: u16 = 0,
    crc_strt: bool = false,
    reserved1: u15 = 0,
};

pub const FlashEmSlibSet = packed struct(u32) {
    em_slib_set: u16 = 0,
    em_slib_iss_set: u8 = 0,
    reserved1: u8 = 0
};

pub const FlashBtmModeSet = enum(u32) {
    boot_memory_as_flash_extension = 0,
    boot_memory_as_system_area = 0xFF
};

pub const FlashError = error {
    Timeout,
    EppError,
    ProgramError,
    InvalidAddress
};

pub const Flash = extern struct {
    psr: FlashPsr,
    unlock: u32,
    usd_unlock: u32,
    sts: FlashSts,
    ctrl: FlashCtrl,
    addr: u32,
    reserved: u32,
    usd: FlashUsd,
    epps: u32,
    fap_sts: FlashFapSts,
    reserved2: [19]u32,
    slib_sts0: FlashSlibSts0,
    slib_sts1: FlashSlib,
    slib_pwd_clr: u32,
    slib_misc_sts: FlashSlibMiscSts,
    crc_addr: u32,
    crc_ctrl: FlashCrcCtrl,
    crc_chkr: u32,
    reserved3: [52]u32,
    slib_set_pwd: u32,
    slib_set_range: FlashSlib,
    em_slib_set: FlashEmSlibSet,
    btm_mode_set: FlashBtmModeSet,
    slib_unlock: u32,

    pub fn flashUnlock(self: *volatile Flash) void {
        self.unlock = FLASH_UNLOCK_KEY1;
        self.unlock = FLASH_UNLOCK_KEY2;
    }

    pub fn flashLock(self: *volatile Flash) void {
        self.ctrl.oplk = true;
    }

    pub fn wait(self: *volatile Flash, timeout: usize) FlashError!void {
        for (0..timeout) |_| {
            const sts = self.sts;
            if (sts.epperr) {
                return FlashError.EppError;
            }
            if (sts.prgmerr) {
                return FlashError.ProgramError;
            }
            if (!sts.obf) {
                return;
            }
        }
        return FlashError.Timeout;
    }

    pub fn sectorErase(self: *volatile Flash, address: usize) FlashError!void {
        self.ctrl.secers = true;
        self.addr = address;
        self.ctrl.erstr = true;
        defer self.ctrl.secers = false;
        try self.wait(ERASE_TIMEOUT);
    }

    pub fn wordProgram(self: *volatile Flash, address: usize, data: u32) FlashError!void {
        if (address & 3 != 0) {
            return FlashError.InvalidAddress;
        }
        self.ctrl.fprgm = true;
        const p: *u32 = @ptrFromInt(address);
        p.* = data;
        defer self.ctrl.fprgm = false;
        try self.wait(PROGRAMMING_TIMEOUT);
    }

    pub fn halfWordProgram(self: *volatile Flash, address: usize, data: u16) FlashError!void {
        if (address & 1 != 0) {
            return FlashError.InvalidAddress;
        }
        self.ctrl.fprgm = true;
        const p: *u16 = @ptrFromInt(address);
        p.* = data;
        defer self.ctrl.fprgm = false;
        try self.wait(PROGRAMMING_TIMEOUT);
    }

    pub fn write32(self: *volatile Flash, address: usize, data: []u32) FlashError!void {
        var a = address;
        for (data) |word| {
            try self.wordProgram(a, word);
            a += 4;
        }
    }

    pub fn write16(self: *volatile Flash, address: usize, data: []u16) FlashError!void {
        var a = address;
        for (data) |hword| {
            try self.halfWordProgram(a, hword);
            a += 2;
        }
    }

    pub fn write(self: *volatile Flash, address: usize, data: []const u8) FlashError!void {
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
        if (l >= 2) {
            const hword = std.mem.readInt(u16, data[idx..][0..2], .little);
            try self.halfWordProgram(a, hword);
            a += 2;
            idx += 2;
            l -= 2;
        }
        if (l != 0) {
            const hword: u16 = data[idx];
            try self.halfWordProgram(a, hword);
        }
    }
};

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x174, @sizeOf(Flash));
}
