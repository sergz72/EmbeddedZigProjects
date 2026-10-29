const std = @import("std");

pub const FLASH_BASE = 0x40022000;

const FLASH_UNLOCK_KEY1 = 0x45670123;
const FLASH_UNLOCK_KEY2 = 0xCDEF89AB;

const ERASE_TIMEOUT = 0x40000000; // internal flash erase operation timeout
const PROGRAMMING_TIMEOUT = 0x00100000; // internal flash program operation timeout
const OPERATION_TIMEOUT = 0x10000000; // flash common operation timeout

pub const PAGE_SIZE = 2048;

pub const BANK1_BASE = 0x08000000;
pub const BANK2_BASE = 0x08080000;
pub const BANK2_END = 0x080FFFFF;
pub const BANK3_BASE = 0x08400000;
pub const BANK3_END = 0x093FFFFF;

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
    ssb: u8,
    user_d0: u8,
    user_d1: u8,
    reserved: u6
};

pub const FlashCrcCtrl = packed struct(u32) {
    crc_ss: u12 = 0,
    crc_sn: u12 = 0,
    reserved: u7 = 0,
    crc_strt: bool = false
};

pub const FlashError = error {
    Timeout,
    EppError,
    ProgramError,
    InvalidAddress
};

pub const FlashBank = enum(usize) {
    bank1 = 0,
    bank2 = 1,
    bank3 = 2
};

pub const Flash = extern struct {
    psr: u32,
    unlock: u32,
    usd_unlock: u32,
    sts: FlashSts,
    ctrl: FlashCtrl,
    addr: u32,
    reserved: u32,
    usd: FlashUsd,
    epps: u32,
    reserved2: [8]u32,
    unlock2: u32,
    reserved3: u32,
    sts2: FlashSts,
    ctrl2: FlashCtrl,
    addr2: u32,
    reserved4: [11]u32,
    unlock3: u32,
    select: u32,
    sts3: FlashSts,
    ctrl3: FlashCtrl,
    addr3: u32,
    da: u32,
    reserved5: [12]u32,
    //0xcc
    slib_sts0: u32,
    slib_sts1: u32,
    slib_pwd_clr: u32,
    slib_misc_sts: u32,
    slib_set_pwd: u32,
    slib_set_range: u32,
    reserved6: [3]u32,
    slib_unlock: u32,
    crc_ctrl: FlashCrcCtrl,
    crc_chkr: u32,

    pub fn flashUnlock(self: *volatile Flash, bank: FlashBank) void {
        switch (bank) {
            .bank1 => {
                self.unlock = FLASH_UNLOCK_KEY1;
                self.unlock = FLASH_UNLOCK_KEY2;
            },
            .bank2 => {
                self.unlock2 = FLASH_UNLOCK_KEY1;
                self.unlock2 = FLASH_UNLOCK_KEY2;
            },
            .bank3 => {
                self.unlock3 = FLASH_UNLOCK_KEY1;
                self.unlock3 = FLASH_UNLOCK_KEY2;
            },
        }
    }

    pub fn flashLock(self: *volatile Flash, bank: FlashBank) void {
        switch (bank) {
            .bank1 => self.ctrl.oplk = true,
            .bank2 => self.ctrl2.oplk = true,
            .bank3 => self.ctrl3.oplk = true,
        }
    }

    pub fn wait(self: *volatile Flash, bank: FlashBank, timeout: usize) FlashError!void {
        for (0..timeout) |_| {
            const sts = switch (bank) {
                .bank1 => self.sts,
                .bank2 => self.sts2,
                .bank3 => self.sts3,
            };
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

    pub fn pageErase(self: *volatile Flash, bank: FlashBank,address: usize) FlashError!void {
        switch (bank) {
            .bank1 => {
                self.ctrl.secers = true;
                self.addr = address;
                self.ctrl.erstr = true;
                defer self.ctrl.secers = false;
                try self.wait(bank, ERASE_TIMEOUT);
            },
            .bank2 => {
                self.ctrl2.secers = true;
                self.addr2 = address;
                self.ctrl2.erstr = true;
                defer self.ctrl2.secers = false;
                try self.wait(bank, ERASE_TIMEOUT);
            },
            .bank3 => {
                self.ctrl3.secers = true;
                self.addr3 = address;
                self.ctrl3.erstr = true;
                defer self.ctrl3.secers = false;
                try self.wait(bank, ERASE_TIMEOUT);
            },
        }
    }

    pub fn wordProgram(self: *volatile Flash, bank: FlashBank, address: usize, data: u32) FlashError!void {
        if (address & 3 != 0) {
            return FlashError.InvalidAddress;
        }
        const p: *u32 = @ptrFromInt(address);
        switch (bank) {
            .bank1 => {
                self.ctrl.fprgm = true;
                p.* = data;
                defer self.ctrl.fprgm = false;
                try self.wait(bank, PROGRAMMING_TIMEOUT);
            },
            .bank2 => {
                self.ctrl2.fprgm = true;
                p.* = data;
                defer self.ctrl2.fprgm = false;
                try self.wait(bank, PROGRAMMING_TIMEOUT);
            },
            .bank3 => {
                self.ctrl3.fprgm = true;
                p.* = data;
                defer self.ctrl3.fprgm = false;
                try self.wait(bank, PROGRAMMING_TIMEOUT);
            },
        }
    }

    pub fn halfWordProgram(self: *volatile Flash, bank: FlashBank, address: usize, data: u16) FlashError!void {
        if (address & 1 != 0) {
            return FlashError.InvalidAddress;
        }
        const p: *u16 = @ptrFromInt(address);
        switch (bank) {
            .bank1 => {
                self.ctrl.fprgm = true;
                p.* = data;
                defer self.ctrl.fprgm = false;
                try self.wait(bank, PROGRAMMING_TIMEOUT);
            },
            .bank2 => {
                self.ctrl2.fprgm = true;
                p.* = data;
                defer self.ctrl2.fprgm = false;
                try self.wait(bank, PROGRAMMING_TIMEOUT);
            },
            .bank3 => {
                self.ctrl3.fprgm = true;
                p.* = data;
                defer self.ctrl3.fprgm = false;
                try self.wait(bank, PROGRAMMING_TIMEOUT);
            },
        }
    }

    pub fn write32(self: *volatile Flash, bank: FlashBank, address: usize, data: []u32) FlashError!void {
        var a = address;
        for (data) |word| {
            try self.wordProgram(bank, a, word);
            a += 4;
        }
    }

    pub fn write16(self: *volatile Flash, bank: FlashBank, address: usize, data: []u16) FlashError!void {
        var a = address;
        for (data) |hword| {
            try self.halfWordProgram(bank, a, hword);
            a += 2;
        }
    }

    pub fn write(self: *volatile Flash, bank: FlashBank, address: usize, data: []const u8) FlashError!void {
        var a = address;
        var l = data.len;
        var idx: usize = 0;
        while (l >= 4) {
            const word = std.mem.readInt(u32, data[idx..][0..4], .little);
            try self.wordProgram(bank, a, word);
            a += 4;
            idx += 4;
            l -= 4;
        }
        if (l >= 2) {
            const hword = std.mem.readInt(u16, data[idx..][0..2], .little);
            try self.halfWordProgram(bank, a, hword);
            a += 2;
            idx += 2;
            l -= 2;
        }
        if (l != 0) {
            const hword: u16 = data[idx];
            try self.halfWordProgram(bank, a, hword);
        }
    }
};

pub fn getBank(address: usize) FlashError!FlashBank {
    if (address >= BANK1_BASE and address < BANK2_BASE) {
        return .bank1;
    } else if (address >= BANK2_BASE and address <= BANK2_END) {
        return .bank2;
    } else if (address >= BANK3_BASE and address <= BANK3_END) {
        return .bank3;
    } else {
        return FlashError.InvalidAddress;
    }
}

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0xFC, @sizeOf(Flash));
}
