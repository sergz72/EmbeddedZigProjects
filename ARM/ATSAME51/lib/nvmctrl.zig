const std = @import("std");

const NVMCTRL_BASE = 0x41004000;

const PAGE_SIZE: usize  = 512;
const BLOCK_SIZE: usize = 8192;

pub const NvmctrlWmode = enum(u2) {
    manual = 0,
    automatic_double_word_write = 1,
    automatic_quad_word_write = 2,
    automatic_page_write = 3
};

pub const NvmctrlPrm = enum(u2) {
    semiauto = 0,
    fullauto = 1,
    manual = 3,
};

pub const NvmctrlCtrla = bitpack struct(u16) {
    reserved0: u2 = 1,
    autows: bool = true,
    suspen: bool = false,
    wmode: NvmctrlWmode = .manual,
    prm: NvmctrlPrm = .semiauto,
    rws: u4 = 0,
    ahbns0: bool = false,
    ahbns1: bool = false,
    cachedis0: bool = false,
    cachedis1: bool = false,
};

pub const NvmctrlCommand = enum(u7) {
    erase_page = 0,
    erase_block = 1,
    write_page = 3,
    write_quad_word = 4,
    software_reset = 16,
    lock_region = 17,
    unlock_region = 18,
    set_power_reduction_mode = 19,
    clear_power_reduction_mode = 20,
    page_buffer_clear = 21,
    set_security_bit = 22,
    bank_swap_and_system_reset = 23,
    chip_erase_lock = 24,
    chip_erase_unlock = 25,
    set_bootprot_dis = 26,
    clear_bootprot_dis = 27,
    see_use_sector0 = 48,
    see_use_sector1 = 49,
    see_sector_reallocation = 50,
    see_flush = 51,
    see_lock = 52,
    see_unlock = 53,
    see_lock_registers = 54,
    see_unlock_registers = 55
};

pub const NvmctrlCtrlb = bitpack struct(u16) {
    cmd: NvmctrlCommand = .erase_page,
    reserved0: u1 = 0,
    cmdex: u8 = 0xA5
};

pub const NvmctrlPsz = enum(u3) {
    _8 = 0,
    _16 = 1,
    _32 = 2,
    _64 = 3,
    _128 = 4,
    _256 = 5,
    _512 = 6,
    _1024 = 7,
};

pub const NvmctrlParam = bitpack struct(u32) {
    nvmp: u16,
    psz: NvmctrlPsz,
    reserved0: u12,
    see: bool,
};

pub const NvmctrlInt = bitpack struct(u16) {
    done: bool = false,
    addre: bool = false,
    proge: bool = false,
    locke: bool = false,
    eccse: bool = false,
    eccde: bool = false,
    nvme: bool = false,
    susp: bool = false,
    seesfull: bool = false,
    seesovf: bool = false,
    seewrc: bool = false,
    reserved0: u5 = 0,
};
    
pub const NvmctrlStatus = bitpack struct(u16) {
    ready: bool,
    prm: bool,
    load: bool,
    susp: bool,
    afirst: bool,
    bpdis: bool,
    reserved0: u2,
    bootprot: u4,
    reserved1: u4,
};

pub const NvmctrlType = enum(u2) {
    none = 0,
    single = 1,
    dual = 2,
};

pub const NvmctrlEccerr = bitpack struct(u32) {
    addr: u24,
    reserved0: u4,
    typel: NvmctrlType = .none,
    typeh: NvmctrlType = .none,
};

pub const NvmctrlDbgctrl = bitpack struct(u8) {
    eccdis: bool = false,
    eccelog: bool = false,
    reserved0: u6 = 0,
};

pub const NvmctrlSeecfg = bitpack struct(u8) {
    wmode: bool = false,
    aprdis: bool = false,
    reserved0: u6 = 0,
};

pub const NvmctrlSeestat = bitpack struct(u32) {
    asees: bool,
    load: bool,
    busy: bool,
    lock: bool,
    rlock: bool,
    reserved0: u3,
    sblk: u4,
    reserved1: u4,
    psz: u3,
    reserved2: u13,
};

pub const NvmctrlError = error {
    Timeout,
    InvalidAddress,
    ProgramError,
    LockError,
    NvmeError,
    NonSecureCheckError
};

pub const Nvmctrl = extern struct {
    ctrla: NvmctrlCtrla,
    reserved0: u16,
    ctrlb: NvmctrlCtrlb,
    reserved1: u16,
    param: NvmctrlParam,
    intenclr: NvmctrlInt,
    intenset: NvmctrlInt,
    intflag: NvmctrlInt,
    status: NvmctrlStatus,
    addr: u32,
    runlock: u32,
    pbldata: u32,
    reserved2: u32,
    eccerr: NvmctrlEccerr,
    dbgctrl: NvmctrlDbgctrl,
    reserved3: u8,
    seecfg: NvmctrlSeecfg,
    reserved4: u8,
    seestat: NvmctrlSeestat,

    fn waitForReady(self: *volatile Nvmctrl) void {
        while (!self.status.ready) {
            asm volatile ("nop");
        }
    }

    fn clearInterruptFlags(self: *volatile Nvmctrl) void {
        self.intflag = NvmctrlInt{
            .done = true,
            .proge = true,
            .locke = true,
            .nvme = true,
            .keye = true,
            .nschk = true
        };
    }

    fn command(self: *volatile Nvmctrl, address: usize, cmd: NvmctrlCommand) NvmctrlError!void {
        self.waitForReady();
        self.clearInterruptFlags();
        self.addr = address;
        self.ctrla = NvmctrlCtrla{.cmd = cmd};
        self.waitForReady();
        const flags = self.intflag;
        if (flags.proge) return NvmctrlError.ProgramError;
        if (flags.locke) return NvmctrlError.LockError;
        if (flags.nvme) return NvmctrlError.NvmeError;
        if (flags.nschk) return NvmctrlError.NonSecureCheckError;
    }

    pub fn pageErase(self: *volatile Nvmctrl, address: usize) NvmctrlError!void {
        const a = address & ~(PAGE_SIZE-1);
        try self.command(a, .erase_page); 
    }

    pub fn writePage(self: *volatile Nvmctrl, address: usize, data: []const u8) NvmctrlError!void {
        if (address & (PAGE_SIZE-1) != 0) {
            return NvmctrlError.InvalidAddress;
        }

        if (data.len == 0) {
            return;
        }

        var p: [*]u32 = @ptrFromInt(address);

        try self.command(address, .page_buffer_clear);

        var l = if (data.len > PAGE_SIZE) PAGE_SIZE else data.len;
        var idx: usize = 0;
        while (l >= 4) {
            const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .little);
            p[0] = d;
            p += 1;
            idx += 4;
            l -= 4;
        }
        if (l != 0) {
            var v: [4]u8 = .{0xFF, 0xFF, 0xFF, 0xFF};
            @memcpy(v[0..l], data[idx..]);
            const d = std.mem.readInt(u32, &v, .little);
            p[0] = d;
        }
        try self.command(address, .write_page);
    }
};

pub const nvmctrl: *volatile Nvmctrl = @ptrFromInt(NVMCTRL_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x30, @sizeOf(Nvmctrl));
}
