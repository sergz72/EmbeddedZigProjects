const std = @import("std");

const FLASH_BASE = 0x40022000;

const FLASH_UNLOCK_KEY1 = 0x45670123;
const FLASH_UNLOCK_KEY2 = 0xCDEF89AB;

const FLASH_BASE_ADDR = 0x08000000;
const FLASH_BANK_SIZE = 0x00100000;      // 1 MB per bank (2 MB device)
const FLASH_SECTOR_SIZE = 0x2000;        // 8 KB

const ERASE_TIMEOUT = 0x40000000; // internal flash erase operation timeout
const PROGRAMMING_TIMEOUT = 0x00100000; // internal flash program operation timeout

pub const FlashAcr = bitpack struct(u32) {
    latency: u4 = 3,
    wrhighfreq: u2 = 1,
    reserved0: u2 = 0,
    prften: bool = false,
    reserved: u7 = 0,
    empty: bool = false,
    reserved1: u15 = 0
};

pub const CodeOp = enum(u3) {
    noop = 0,
    single_write = 1,
    page_erase = 3,
    bank_erase = 4,
    mass_erase = 5,
    option_change = 6
};

pub const FlashOpsr = bitpack struct(u32) {
    addr_op: u16,
    reserved0: u5,
    data_op: bool,
    bk_op: bool,
    reserved2: u1,
    otp_op: bool,
    reserved1: u4,
    code_op: CodeOp
};

pub const FlashOptcr = bitpack struct(u32) {
    optlock: bool = true,
    optstrt: bool = false,
    reserved0: u29 = 0,
    swap_bank: bool = false,
};

pub const FlashSr = bitpack struct(u32) {
    bsy: bool,
    wbne: bool,
    reserved0: u1,
    dbne: bool,
    reserved3: u4,
    oemlock: bool,
    bslock: bool,
    reserved1: u6,
    eop: bool,
    wrperr: bool,
    pgserr: bool,
    strberr: bool,
    incerr: bool,
    reserved4: u2,
    optchangeerr: bool,
    reserved2: u8
};

pub const FlashCr = bitpack struct(u32) {
    lock: bool = true,
    pg: bool = false,
    per: bool = false,
    ber: bool = false,
    fw: bool = false,
    strt: bool = false,
    pnb: u7 = 0,
    reserved0: u2 = 0,
    mer: bool = false,
    eopie: bool = false,
    wrperrie: bool = false,
    pgserrie: bool = false,
    strberrie: bool = false,
    incerrie: bool = false,
    reserved2: u2 = 0,
    optchangeerrie: bool = false,
    reserved1: u5 = 0,
    edatasel: bool = false,
    reserved3: u1 = 0,
    bksel: bool = false,
};

pub const FlashCcr = bitpack struct(u32) {
    reserved0: u16 = 0,
    clr_eop: bool = false,
    clr_wrperr: bool = false,
    clr_pgserr: bool = false,
    clr_strberr: bool = false,
    clr_incerr: bool = false,
    reserved2: u2 = 0,
    clr_optchangeerr: bool = false,
    reserved1: u8 = 0,
};

pub const FlashPrivcfgr = bitpack struct(u32) {
    reserved1: u1 = 0,
    priv: bool = false,
    reserved0: u30 = 0,
};

pub const FlashObkcfgr = bitpack struct(u32) {
    lock: bool = false,
    swap_sect_req: bool = false,
    alt_sect: bool = false,
    alt_sect_erase: bool = false,
    reserved0: u12 = 0,
    swap_offset: u9 = 0x1FF,
    reserved1: u7 = 0,
};

pub const FlashHdpextr = bitpack struct(u32) {
    hdp1_ext: u6 = 0,
    reserved0: u10 = 0,
    hdp2_ext: u6 = 0,
    reserved1: u10 = 0
};

pub const FlashOptsr = bitpack struct(u32) {
    reserved3: u3,
    iwdg_sw: bool,
    wwdg_sw: bool,
    reserved0: u1,
    nrst_stop: bool,
    nrst_stdby: bool,
    rdp_level: u8,
    reserved1: u4,
    iwdg_stop: bool,
    iwdg_stdby: bool,
    boot_sel: bool,
    boot0: bool,
    reserved2: u5,
    edata_en: bool,
    single_bank: bool,
    swap_bank: bool
};

pub const FlashOptsr2 = bitpack struct(u32) {
    sram1_rst: bool,
    sram2_rst: bool,
    reserved0: u2,
    sram2_ecc: bool,
    reserved1: u27
};

pub const FlashBootLock = enum(u8) {
    unlocked = 0xC3,
    locked = 0xB4
};

pub const FlashBootr = bitpack struct(u32) {
    lock: FlashBootLock,
    add: u24
};

pub const FlashHdp = bitpack struct(u32) {
    hdp1_strt: u6,
    reserved0: u10,
    hdp1_end: u6,
    reserved1: u10
};

pub const FlashEcccorr = bitpack struct(u32) {
    addr_ecc: u16 = 0,
    reserved0: u5 = 0,
    edata_ecc: bool = false,
    bk_ecc: bool = false,
    sysf_ecc: bool = false,
    otp_ecc: bool = false,
    ecccie: bool = false,
    reserved1: u4 = 0,
    eccc: bool = false,
    reserved2: u1 = 0,
};

pub const FlashEccdetr = bitpack struct(u32) {
    addr_ecc: u16 = 0,
    reserved0: u5 = 0,
    data_ecc: bool = false,
    bk_ecc: bool = false,
    sysf_ecc: bool = false,
    otp_ecc: bool = false,
    reserved1: u6 = 0,
    eccd: bool = false,
};

pub const FlashEccdr = bitpack struct(u32) {
    data_ecc: u16,
    data_addr_ecc: u3,
    reserved0: u13,
};

pub const FlashError = error {
    Timeout,
    WriteProtectionError,
    ProgramError,
    StrobeError,
    InconsistencyError,
    InvalidAddress
};

pub const Flash = extern struct {
    acr: FlashAcr,
    keyr: u32,
    reserved12: u32,
    optkeyr: u32,
    reserved13: [2]u32,
    opsr: FlashOpsr,
    optcr: FlashOptcr,
    sr: FlashSr,
    reserved14: u32,
    cr: FlashCr,
    reserved15: u32,
    ccr: FlashCcr,
    reserved0: [2]u32,
    privcfgr: FlashPrivcfgr,
    reserved16: [2]u32,
    hdpextr: FlashHdpextr,
    reserved1: u32,
    optsr_cur: FlashOptsr,
    optsr_prg: FlashOptsr,
    reserved2: [6]u32,
    optsr2_cur: FlashOptsr2,
    optsr2_prg: FlashOptsr2,
    reserved5: [2]u32,
    bootr_cur: FlashBootr,
    bootr_prg: FlashBootr,
    reserved17: [2]u32,
    otpblr_cur: u32,
    otpblr_prg: u32,
    bl_com_cfg_cur: u32,
    bl_com_cfg_prg: u32,
    reserved6: u32,
    oemkeyr1: u32,
    reserved11: [4]u8,
    oemkeyr2: u32,
    reserved18: [4]u8,
    oemkeyr3: u32,
    reserved19: [4]u8,
    oemkeyr4: u32,
    reserved20: [4]u8,
    bskeyr: u32,
    reserved21: [32]u8,
    wrp1r_cur: u32,
    wrp1r_prg: u32,
    reserved22: [8]u8,
    hdp1r_cur: FlashHdp,
    hdp1r_prg: FlashHdp,
    ecccorr: FlashEcccorr,
    eccdetr: FlashEccdetr,
    eccdr: FlashEccdr,
    reserved23: [55]u32,
    wrp2r_cur: u32,
    wrp2r_prg: u32,
    reserved24: [2]u32,
    hdp2r_cur: FlashHdp,
    hdp2r_prg: FlashHdp,

    pub fn flashUnlock(self: *volatile Flash) void {
        self.nskeyr = FLASH_UNLOCK_KEY1;
        self.nskeyr = FLASH_UNLOCK_KEY2;
    }

    pub fn flashLock(self: *volatile Flash) void {
        self.nscr.lock = true;
    }

    pub fn wait(self: *volatile Flash, timeout: usize) FlashError!void {
        for (0..timeout) |_| {
            const sts = self.nssr;
            if (sts.wrperr) {
                return FlashError.WriteProtectionError;
            }
            if (sts.pgserr) {
                return FlashError.ProgramError;
            }
            if (sts.strberr) {
                return FlashError.StrobeError;
            }
            if (sts.incerr) {
                return FlashError.InconsistencyError;
            }
            if (!sts.bsy) {
                return;
            }
        }
        return FlashError.Timeout;
    }

    fn setBankAndSector(self: *volatile Flash, address: usize) FlashError!void {
        if (address < FLASH_BASE_ADDR) return FlashError.InvalidAddress;
        const bank: usize = if (address < FLASH_BASE_ADDR + FLASH_BANK_SIZE) 0 else 1;
        const sector = (address - (FLASH_BASE_ADDR + bank * FLASH_BANK_SIZE)) / FLASH_SECTOR_SIZE;
        if (sector > 127) return FlashError.InvalidAddress;
        self.cr.bksel = bank != 0;
        self.cr.snb = @truncate(sector);
    }

    pub fn sectorErase(self: *volatile Flash, address: usize) FlashError!void {
        self.ccr = FlashCcr{}; // clear all flags
        try self.setBankAndSector(address);
        self.cr.ser = true;
        self.cr.strt = true;
        defer self.cr.ser = false;
        try self.wait(ERASE_TIMEOUT);
    }

    pub fn write(self: *volatile Flash, address: usize, data: []const u8) FlashError!void {
        if (address & 0x0F != 0 or address < FLASH_BASE_ADDR or address >= FLASH_BASE_ADDR + 2 * FLASH_BANK_SIZE) {
            return FlashError.InvalidAddress;
        }
        self.ccr = FlashCcr{}; // clear all flags
        self.cr.pg = true;
        defer self.cr.pg = false;
        var l = data.len;
        var idx: usize = 0;
        var p: [*]u32 = @ptrFromInt(address);
        var buffer: [4]u32 = undefined;
        var byte_buffer = std.mem.sliceAsBytes(&buffer);
        while (l != 0) {
            const chunk_size = if (l >= 16) 16 else l;
            buffer[0] = 0xFFFFFFFF;
            buffer[1] = 0xFFFFFFFF;
            buffer[2] = 0xFFFFFFFF;
            buffer[3] = 0xFFFFFFFF;
            @memcpy(byte_buffer[0..chunk_size], data[idx..][0..chunk_size]);
            idx += chunk_size;
            l -= chunk_size;
            p[0] = buffer[0];
            p += 1;
            p[0] = buffer[1];
            p += 1;
            p[0] = buffer[2];
            p += 1;
            p[0] = buffer[3];
            p += 1;
            asm volatile ("dsb");
            try self.wait(PROGRAMMING_TIMEOUT);
        }
    }
};

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x200, @sizeOf(Flash));
}
