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
    reserved1: u23 = 0,
};

pub const CodeOp = enum(u3) {
    noop = 0,
    single_write = 1,
    obk_alternate_sector_erase = 2,
    sector_erase = 3,
    bank_erase = 4,
    mass_erase = 5,
    option_change = 6,
    obk_swap = 7
};

pub const FlashOpsr = bitpack struct(u32) {
    addr_op: u20,
    reserved0: u1,
    data_op: bool,
    bk_op: bool,
    sysf_op: bool,
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

pub const FlashNssr = bitpack struct(u32) {
    bsy: bool,
    wbne: bool,
    reserved0: u1,
    dbne: bool,
    reserved1: u12,
    eop: bool,
    wrperr: bool,
    pgserr: bool,
    strberr: bool,
    incerr: bool,
    obkerr: bool,
    obkwerr: bool,
    optchangeerr: bool,
    reserved2: u8
};

pub const FlashSecsr = bitpack struct(u32) {
    bsy: bool,
    wbne: bool,
    reserved0: u1,
    dbne: bool,
    reserved1: u12,
    eop: bool,
    wrperr: bool,
    pgserr: bool,
    strberr: bool,
    incerr: bool,
    obkerr: bool,
    obkwerr: bool,
    reserved2: u9
};

pub const FlashNscr = bitpack struct(u32) {
    lock: bool = true,
    pg: bool = false,
    ser: bool = false,
    ber: bool = false,
    fw: bool = false,
    strt: bool = false,
    snb: u7 = 0,
    reserved0: u2 = 0,
    mer: bool = false,
    eopie: bool = false,
    wrperrie: bool = false,
    pgserrie: bool = false,
    strberrie: bool = false,
    incerrie: bool = false,
    obkerrie: bool = false,
    obkwerrie: bool = false,
    optchangeerrie: bool = false,
    reserved1: u7 = 0,
    bksel: bool = false,
};

pub const FlashSeccr = bitpack struct(u32) {
    lock: bool = true,
    pg: bool = false,
    ser: bool = false,
    ber: bool = false,
    fw: bool = false,
    strt: bool = false,
    snb: u7 = 0,
    reserved0: u2 = 0,
    mer: bool = false,
    eopie: bool = false,
    wrperrie: bool = false,
    pgserrie: bool = false,
    strberrie: bool = false,
    incerrie: bool = false,
    obkerrie: bool = false,
    obkwerrie: bool = false,
    reserved1: u6 = 0,
    inv: bool = false,
    reserved2: u1 = 0,
    bksel: bool = false,
};

pub const FlashNsccr = bitpack struct(u32) {
    reserved0: u16 = 0,
    clr_eop: bool = false,
    clr_wrperr: bool = false,
    clr_pgserr: bool = false,
    clr_strberr: bool = false,
    clr_incerr: bool = false,
    clr_obkerr: bool = false,
    clr_obkwerr: bool = false,
    clr_optchangeerr: bool = false,
    reserved1: u8 = 0,
};

pub const FlashSecccr = bitpack struct(u32) {
    reserved0: u16 = 0,
    clr_eop: bool = false,
    clr_wrperr: bool = false,
    clr_pgserr: bool = false,
    clr_strberr: bool = false,
    clr_incerr: bool = false,
    clr_obkerr: bool = false,
    clr_obkwerr: bool = false,
    reserved1: u9 = 0,
};

pub const FlashPrivcfgr = bitpack struct(u32) {
    spriv: bool = false,
    nspriv: bool = false,
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
    hdp1_ext: u7 = 0,
    reserved0: u9 = 0,
    hdp2_ext: u7 = 0,
    reserved1: u9 = 0
};

pub const FlashBorLev = enum(u2) {
    _2v1 = 0,
    _2v4 = 1,
    _2v7 = 2,
    _2v1_2 = 3
};

pub const FlashBootUbe = enum(u8) {
    system_flash = 0xC3,
    user_flash = 0xB4
};

pub const FlashOptsr = bitpack struct(u32) {
    bor_lev: FlashBorLev,
    borh_en: bool,
    iwdg_sw: bool,
    wwdg_sw: bool,
    reserved0: u1,
    nrst_stop: bool,
    nrst_stdby: bool,
    product_state: u8,
    io_vdd_hslv: bool,
    io_vddio2_hslv: bool,
    reserved1: u2,
    iwdg_stop: bool,
    iwdg_stdby: bool,
    boot_ube: FlashBootUbe,
    reserved2: u1,
    swap_bank: bool
};

pub const FlashTzen = enum(u8) {
    enabled = 0xc3,
    disabled = 0xb4
};

pub const FlashOptsr2 = bitpack struct(u32) {
    reserved0: u2,
    sram13_rst: bool,
    sram2_rst: bool,
    bkpram_ecc: bool,
    sram3_ecc: bool,
    sram2_ecc: bool,
    reserved1: u1,
    usbpd_dis: bool,
    reserved2: u15,
    tzen: FlashTzen
};

pub const FlashBootLock = enum(u8) {
    unlocked = 0xC3,
    locked = 0xB4
};

pub const FlashBootr = bitpack struct(u32) {
    lock: FlashBootLock,
    add: u24
};

pub const FlashSecwm = bitpack struct(u32) {
    secwm1_strt: u7,
    reserved0: u9 = 0,
    secwm1_end: u7,
    reserved1: u9 = 0,
};

pub const FlashEdata = bitpack struct(u32) {
    edata1_strt: u3,
    reserved0: u12,
    edata1_en: bool,
    reserved1: u16
};

pub const FlashHdp = bitpack struct(u32) {
    hdp1_strt: u7,
    reserved0: u9,
    hdp1_end: u7,
    reserved1: u9
};

pub const FlashEcccorr = bitpack struct(u32) {
    addr_ecc: u16 = 0,
    reserved0: u4 = 0,
    obk_ecc: bool = false,
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
    reserved0: u4 = 0,
    obk_ecc: bool = false,
    edata_ecc: bool = false,
    bk_ecc: bool = false,
    sysf_ecc: bool = false,
    otp_ecc: bool = false,
    reserved1: u6 = 0,
    eccd: bool = false,
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
    nskeyr: u32,
    seckeyr: u32,
    optkeyr: u32,
    nsobkkeyr: u32,
    secobkkeyr: u32,
    opsr: FlashOpsr,
    optcr: FlashOptcr,
    nssr: FlashNssr,
    secsr: FlashSecsr,
    nscr: FlashNscr,
    seccr: FlashSeccr,
    nsccr: FlashNsccr,
    secccr: FlashSecccr,
    reserved0: u32,
    privcfgr: FlashPrivcfgr,
    nsobkcfgr: FlashObkcfgr,
    secobkcfgr: FlashObkcfgr,
    hdpextr: FlashHdpextr,
    reserved1: u32,
    optsr_cur: FlashOptsr,
    optsr_prg: FlashOptsr,
    reserved2: [2]u32,
    nsepochr_cur: u32,
    nsepochr_prg: u32,
    secepochr_cur: u32,
    secepochr_prg: u32,
    optsr2_cur: FlashOptsr2,
    optsr2_prg: FlashOptsr2,
    reserved5: [2]u32,
    nsbootr_cur: FlashBootr,
    nsbootr_prg: FlashBootr,
    secbootr_cur: FlashBootr,
    secbootr_prg: FlashBootr,
    otpblr_cur: u32,
    otpblr_prg: u32,
    reserved6: [2]u32,
    secbb1r: [4]u32,
    reserved7: [4]u32,
    privbb1r: [4]u32,
    reserved8: [4]u32,
    secwm1r_cur: FlashSecwm,
    secwm1r_prg: FlashSecwm,
    wrp1r_cur: u32,
    wrp1r_prg: u32,
    edata1r_cur: FlashEdata,
    edata1r_prg: FlashEdata,
    hdp1r_cur: FlashHdp,
    hdp1r_prg: FlashHdp,
    ecccorr: FlashEcccorr,
    eccdetr: FlashEccdetr,
    eccdr: u32,
    reserved9: [37]u32,
    secbb2r: [4]u32,
    reserved10: [4]u32,
    privbb2r: [4]u32,
    reserved11: [4]u32,
    secwm2r_cur: FlashSecwm,
    secwm2r_prg: FlashSecwm,
    wrp2r_cur: u32,
    wrp2r_prg: u32,
    edata2r_cur: FlashEdata,
    edata2r_prg: FlashEdata,
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
        self.nscr.bksel = bank != 0;
        self.nscr.snb = @truncate(sector);
    }

    pub fn sectorErase(self: *volatile Flash, address: usize) FlashError!void {
        self.nsccr = FlashNsccr{}; // clear all flags
        try self.setBankAndSector(address);
        self.nscr.ser = true;
        self.nscr.strt = true;
        defer self.nscr.ser = false;
        try self.wait(ERASE_TIMEOUT);
    }

    pub fn write(self: *volatile Flash, address: usize, data: []const u8) FlashError!void {
        if (address & 0x0F != 0 or address < FLASH_BASE_ADDR or address >= FLASH_BASE_ADDR + 2 * FLASH_BANK_SIZE) {
            return FlashError.InvalidAddress;
        }
        self.nsccr = FlashNsccr{}; // clear all flags
        self.nscr.pg = true;
        defer self.nscr.pg = false;
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
