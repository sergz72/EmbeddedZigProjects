const std = @import("std");
const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const FLASHCTL_BASE: usize = 0x400CD000 + 0x1020;

pub const FlashCtlError = error {
    Timeout,
    FailWeprot,
    FailVerify,
    FailIllAddr,
    FailMode,
    FailInvData,
    FailMisc,
    Fail
};

pub const FlashCtlEvtMode = packed struct(u32) {
    int0_cfg: common.EvtCfg,
    reserved: u30
};

pub const FlashCommand = enum(u3) {
    no_operation = 0,
    program = 1,
    erase = 2,
    read_verify = 3,
    mode_change = 4,
    clear_status = 5,
    blank_verify = 6
};

pub const FlashCommandSize = enum(u3) {
    one_word = 0,
    two_words = 1,
    four_words = 2,
    eight_words = 3,
    sector = 4,
    bank = 5
};

pub const FlashCtlCmdType = packed struct(u32) {
    command: FlashCommand = .no_operation,
    reserved: u1 = 0,
    size: FlashCommandSize = .one_word,
    reserved2: u25 = 0
};

pub const FlashCommandMode = enum(u4) {
    read = 0,
    read_margin0 = 2,
    read_margin1 = 4,
    read_margin0b = 6,
    read_margin1b = 7,
    program_verify = 9,
    program_single_word = 10,
    erase_verify = 11,
    erase_sector = 12,
    program_multiple_words = 14,
    erase_bank = 15
};

pub const FlashRegion = enum(u4) {
    main = 1,
    non_main = 2,
    trim = 4,
    engr = 8
};

pub const FlashCtlCmdCtl = packed struct(u32) {
    modesel: FlashCommandMode = .read,
    reserved: u5 = 0,
    regionsel: FlashRegion = .main,
    reserved2: u1 = 0,
    preveren: bool = true,
    postveren: bool = true,
    addrxlateovr: bool = false,
    eccgenovr: bool = false,
    progmaskdis: bool = false,
    erasemaskdis: bool = false,
    sserasedis: bool = false,
    dataveren: bool = false,
    reserved3: u10 = 0
};

pub const FlashCtlCfgPcnt = packed struct(u32) {
    maxpcntovr: bool = false,
    reserved: u3 = 0,
    maxpcntval: u8 = 0,
    reserved2: u20 = 0
};

pub const FlashCtlStatCmd = packed struct(u32) {
    cmddone: bool,
    cmdpass: bool,
    cmdinprogress: bool,
    reserved: u1,
    failweprot: bool,
    failverify: bool,
    faililladdr: bool,
    failmode: bool,
    failinvdata: bool,
    reserved2: u3,
    failmisc: bool,
    reserved3: u19
};

pub const FlashCtlStatAddr = packed struct(u32) {
    bankaddr: u16,
    regionid: u5,
    bankid: u5,
    reserved: u6
};

pub const FlashCtlStatMode = packed struct(u32) {
    banknotinrd: bool,
    reserved: u7,
    bankmode: u4,
    reserved2: u4,
    bank2trdy: bool,
    bank1trdy: bool,
    reserved3: u14
};

pub const FlashCtlGblInfo0 = packed struct(u32) {
    sectorsize: u16,
    numbanks: u3,
    reserved: u13
};

pub const FlashCtlGblInfo1 = packed struct(u32) {
    datawidth: u8,
    eccwidth: u5,
    reserved: u3,
    redwidth: u3,
    reserved2: u13
};

pub const FlashCtlGblInfo2 = packed struct(u32) {
    dataregisters: u4,
    reserved: u28
};

pub const FlashBankInfo1 = packed struct(u32) {
    nonmainsize: u8,
    trimsize: u8,
    engrsize: u8,
    reserved: u8
};

pub const FlashBankInfo = extern struct {
    info0: u32,
    info1: FlashBankInfo1,
    reserved: [2]u32
};

pub const FlashCtl = extern struct {
    iidx: u32,
    reserved1: u32,
    imask: u32,
    reserved2: u32,
    ris: u32,
    reserved3: u32,
    mis: u32,
    reserved4: u32,
    iset: u32,
    reserved5: u32,
    iclr: u32,
    reserved6: [37]u32,
    evt_mode: FlashCtlEvtMode,
    reserved7: [6]u32,
    desc: u32,
    cmdexec: u32,
    cmdtype: FlashCtlCmdType,
    cmdctl: FlashCtlCmdCtl,
    reserved8: [5]u32,
    cmdaddr: u32,
    cmdbyten: u32,
    reserved9: u32,
    cmddataindex: u32,
    cmddata: [32]u32,
    cmddataecc: [8]u32,
    cmdweprota: u32,
    cmdweprotb: u32,
    cmdweprotc: u32,
    reserved10: [13]u32,
    cmdweprotnm: u32,
    cmdweprottr: u32,
    cmdweproten: u32,
    reserved11: [101]u32,
    cfgcmd: u32,
    cfgpcnt: FlashCtlCfgPcnt,
    reserved12: [6]u32,
    statcmd: FlashCtlStatCmd,
    stataddr: FlashCtlStatAddr,
    statpcnt: u32,
    statmode: FlashCtlStatMode,
    reserved13: [4]u32,
    gblinfo0: FlashCtlGblInfo0,
    gblinfo1: FlashCtlGblInfo1,
    gblinfo2: FlashCtlGblInfo2,
    reserved14: u32,
    bank_info: [5]FlashBankInfo,

    pub fn unprotectSector(self: *volatile FlashCtl, address: usize) FlashCtlError!void {
        const sector = address / 1024;
        if (sector < 32 or sector > 255 + 32) {
            return FlashCtlError.FailIllAddr;
        }
        const bit: u5 = @truncate((sector - 32) >> 3);
        self.cmdweprotb &= ~(@as(u32, 1) << bit);
    }

    pub fn protectSector(self: *volatile FlashCtl, address: usize) FlashCtlError!void {
        const sector = address / 1024;
        if (sector < 32 or sector > 255 + 32) {
            return FlashCtlError.FailIllAddr;
        }
        const bit: u5 = @truncate((sector - 32) >> 3);
        self.cmdweprotb |= @as(u32, 1) << bit;
    }

    noinline fn executeCommandFromRam(self: *volatile FlashCtl) linksection(".ramfunc") FlashCtlError!void {
        self.cmdexec = 1;
        while (true) {
            const status = self.statcmd;
            if (status.faililladdr) return FlashCtlError.FailIllAddr;
            if (status.failweprot) return FlashCtlError.FailWeprot;
            if (status.failinvdata) return FlashCtlError.FailInvData;
            if (status.failmode) return FlashCtlError.FailMode;
            if (status.failmisc) return FlashCtlError.FailMisc;
            if (status.failverify) return FlashCtlError.FailVerify;
            if (status.cmddone) {
                if (status.cmdpass) return;
                return FlashCtlError.Fail;
            }
        }
    }

    pub fn erase(self: *volatile FlashCtl, size: FlashCommandSize, address: u32) FlashCtlError!void {
        try self.unprotectSector(address);
        self.cmdtype = FlashCtlCmdType{.command = .erase, .size = size};
        self.cmdaddr = address;
        return self.executeCommandFromRam();
    }

    fn programMemoryConfig(self: *volatile FlashCtl, byten: u32, address: u32) void {
        self.cmdtype = FlashCtlCmdType{.command = .program, .size = .one_word};
        self.cmdbyten = byten;
        self.cmdaddr = address;
    }

    fn programMemory8Config(self: *volatile FlashCtl, address: u32, data: u8) void {
        self.programMemoryConfig(0x101, address);
        self.cmddata[0] = data;
    }

    fn programMemory16Config(self: *volatile FlashCtl, address: u32, data: u16) void {
        self.programMemoryConfig(0x103, address);
        self.cmddata[0] = data;
    }

    fn programMemory32Config(self: *volatile FlashCtl, address: u32, data: u32) void {
        self.programMemoryConfig(0x10F, address);
        self.cmddata[0] = data;
    }

    fn programMemory64Config(self: *volatile FlashCtl, address: u32, data1: u32, data2: u32) void {
        self.programMemoryConfig(0x1FF, address);
        self.cmddata[0] = data1;
        self.cmddata[1] = data2;
    }

    pub fn programMemory8(self: *volatile FlashCtl, address: u32, data: u8) FlashCtlError!void {
        try self.unprotectSector(address);
        self.programMemory8Config(address, data);
        try self.executeCommandFromRam();
    }

    pub fn programMemory16(self: *volatile FlashCtl, address: u32, data: u16) FlashCtlError!void {
        try self.unprotectSector(address);
        self.programMemory16Config(address, data);
        try self.executeCommandFromRam();
    }

    pub fn programMemory32(self: *volatile FlashCtl, address: u32, data: u32) FlashCtlError!void {
        try self.unprotectSector(address);
        self.programMemory32Config(address, data);
        try self.executeCommandFromRam();
    }

    pub fn programMemory64(self: *volatile FlashCtl, address: u32, data1: u32, data2: u32) FlashCtlError!void {
        try self.unprotectSector(address);
        self.programMemory64Config(address, data1, data2);
        try self.executeCommandFromRam();
    }

    pub fn write(self: *volatile FlashCtl, address: usize, data: []u8) FlashCtlError!void {
        var a = address;
        var l = data.len;
        var idx: usize = 0;
        while (l >= 4) {
            const word = std.mem.readInt(u32, data[idx..][0..4], .little);
            try self.programMemory32(a, word);
            a += 4;
            idx += 4;
            l -= 4;
        }
        if (l >= 2) {
            const hword = std.mem.readInt(u16, data[idx..][0..2], .little);
            try self.programMemory16(a, hword);
            a += 2;
            idx += 2;
            l -= 2;
        }
        if (l != 0) {
            try self.programMemory8(a, data[idx]);
        }
    }
};

pub const flashctl: *volatile FlashCtl = @ptrFromInt(FLASHCTL_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x1450-0x1020, @sizeOf(FlashCtl));
}
