const std = @import("std");

const NVMCTRL_BASE = 0x41004000;

const PAGE_SIZE: usize  = 64;
const ROW_SIZE: usize   = 256;

pub const NvmCmd = enum(u7) {
    reserved = 0,
    erase = 2,
    write_page = 4,
    set_power_reduction_mode = 0x42,
    clear_power_reduction_mode = 0x43,
    page_buffer_clear = 0x44,
    invalidate_cache = 0x46,
    set_dal0 = 0x4B,
    set_dal1 = 0x4C
};

pub const NvmctrlCtrlA = packed struct(u16) {
    cmd: NvmCmd = .reserved,
    reserved: u1 = 0,
    cmdex: u8 = 0xA5
};

pub const NvmctrlCtrlB = packed struct(u32) {
    reserved: u1 = 0,
    rws: u4 = 0,
    reserved2: u3 = 0,
    sleepprm: u2 = 0,
    reserved3: u1 = 0,
    fwup: bool = false,
    reserved4: u4 = 0,
    readmode: u2 = 0,
    cachedis: bool = false,
    reserved5: u13 = 0
};

pub const NvmEvCtrl = packed struct(u8) {
    autowei: bool = false,
    autowinv: bool = false,
    reserved: u6 = 0
};

pub const NvmctrlInt = packed struct(u8) {
    done: bool = false,
    proge: bool = false,
    locke: bool = false,
    nvme: bool = false,
    keye: bool = false,
    nschk: bool = false,
    reserved: u2 = 0
};

pub const NvmctrlStatus = packed struct(u16) {
    prm: bool,
    load: bool,
    ready: bool,
    dalfuse: u2,
    reserved: u11
};

pub const NvmctrlArray = enum(u2) {
    flash = 0,
    data_flash = 1,
    nvm_rows = 2
};

pub const NvmctrlAddr = packed struct(u32) {
    aoffset: u16 = 0,
    reserved: u6 = 0,
    array: NvmctrlArray = .flash,
    reserved2: u8 = 0
};

pub const NvmctrlLck = packed struct(u16) {
    b: bool,
    a: bool,
    s: bool,
    reserved: u5 = 0,
    key: u8 = 0xA5
};

pub const NvmctrlParam = packed struct(u32) {
    flashp: u16,
    psz: u3,
    reserved: u1,
    dflashp: u12
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
    ctrla: NvmctrlCtrlA,
    reserved1: u16,
    ctrlb: NvmctrlCtrlB,
    ctrlc: u8,
    reserved2: u8,
    evctrl: NvmEvCtrl,
    reserved3: u8,
    intenclr: NvmctrlInt,
    reserved4: [3]u8,
    intenset: NvmctrlInt,
    reserved5: [3]u8,
    intflag: NvmctrlInt,
    reserved6: [3]u8,
    status: NvmctrlStatus,
    reserved7: u16,
    addr: NvmctrlAddr,
    sulck: NvmctrlLck,
    nsulck: NvmctrlLck,
    param: NvmctrlParam,
    reserved8: [2]u32,
    dscc: u32,
    secctrl: u32,
    scfgb: u32,
    scfgad: u32,
    nonsec: u32,
    nschk: u32,

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

    fn command(self: *volatile Nvmctrl, address: usize, data_flash: bool, cmd: NvmCmd) NvmctrlError!void {
        self.waitForReady();
        self.clearInterruptFlags();
        self.addr = NvmctrlAddr{.aoffset = @truncate(address), .array = if (data_flash) NvmctrlArray.data_flash else NvmctrlArray.flash};
        self.ctrla = NvmctrlCtrlA{.cmd = cmd};
        self.waitForReady();
        const flags = self.intflag;
        if (flags.proge) return NvmctrlError.ProgramError;
        if (flags.locke) return NvmctrlError.LockError;
        if (flags.nvme) return NvmctrlError.NvmeError;
        if (flags.nschk) return NvmctrlError.NonSecureCheckError;
    }

    pub fn rowErase(self: *volatile Nvmctrl, address: usize, data_flash: bool) NvmctrlError!void {
        const a = address & ~(ROW_SIZE-1);
        try self.command(a, data_flash, .erase);
    }

    pub fn writePage(self: *volatile Nvmctrl, address: usize, data: []const u8, data_flash: bool) NvmctrlError!void {
        if (address & (PAGE_SIZE-1) != 0) {
            return NvmctrlError.InvalidAddress;
        }

        if (data.len == 0) {
            return;
        }

        var p: [*]u32 = @ptrFromInt(address);

        try self.command(address, data_flash, .page_buffer_clear);

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
        try self.command(address, data_flash, .write_page);
    }
};

pub const nvmctrl: *volatile Nvmctrl = @ptrFromInt(NVMCTRL_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x48, @sizeOf(Nvmctrl));
}
