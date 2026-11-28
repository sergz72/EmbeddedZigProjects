const std = @import("std");
const nvic = @import("nvic");

const FMU0_BASE = 0x40043000;

const ERASE_TIMEOUT = 0x00100000; // internal flash erase operation timeout
const PROGRAMMING_TIMEOUT = 0x00100000; // internal flash program operation timeout

pub const SECTOR_SIZE = 8192;
pub const PAGE_SIZE = 128;
pub const PHRASE_SIZE = 16;

pub const Cmdprt = enum(u2) {
    secure_normal = 0,
    secure_privileged = 1,
    nonsecure_normal = 2,
    nonsecure_privileged = 3
};

pub const Pewen = enum(u2) {
    disabled = 0,
    enabled_program_and_erase = 1,
    enabled_program = 2,
};

pub const Fstat = bitpack struct(u32) {
    fail: bool = false,
    reserved0: u1 = 0,
    cmdabt: bool = false,
    reserved1: u1 = 0,
    pviol: bool = false,
    accerr: bool = false,
    cwsabt: bool = false,
    ccif: bool = true,
    cmdprt: Cmdprt = .secure_normal,
    reserved2: u1 = 0,
    cmdp: bool = false,
    cmddid: u4 = 0,
    dfdif: bool = false,
    salv_used: bool = false,
    reserved3: u6 = 0,
    pewen: Pewen = .disabled,
    reserved4: u5 = 0,
    perdy: bool = false,
};

pub const Fcnfg = bitpack struct(u32) {
    reserved0: u7 = 0,
    ccie: bool = false,
    ersreq: bool = false,
    reserved1: u7 = 0,
    dfdie: bool = false,
    reserved2: u7 = 0,
    ersien0: u4 = 0,
    ersien1: u4 = 0,
};

pub const Fctrl = bitpack struct(u32) {
    rwsc: u4 = 0,
    reserved0: u12 = 0,
    fdfd: bool = false,
    reserved1: u7 = 0,
    abtreq: bool = false,
    reserved2: u7 = 0,
};

pub const FmuCommand = enum(u8) {
    rd1all = 0,
    rd1blk = 1,
    rd1scr = 2,
    rd1pg = 3,
    rd1phr = 4,
    rdmisr = 5,
    rd1iscr = 0x12,
    rd1ipg = 0x13,
    rd1iphr = 0x14,
    rdimisr = 0x15,
    pgmpg = 0x23,
    pgmphr = 0x24,
    ersall = 0x40,
    ersscr = 0x42
};

pub const FmuError = error {
    CcifTimeout,
    PewenTimeout,
    AccessError,
    CommandAbort,
    ProtectionViolation,
    CommandWriteSequenceAbort,
    DoubleBitFault,
    InvalidAddress,
    Fail,
    UnknownError,
};

pub const Fmu = extern struct {
    fstat: Fstat,
    fcnfg: Fcnfg,
    fctrl: Fctrl,
    reserved0: u32,
    command: FmuCommand,
    reserved1: [3]u8,
    parameter: u8,
    reserved2: [3]u8,
    fccob: [6]u32,
};

noinline fn waitCcif(timeout: usize) linksection(".ramfunc") FmuError!void {
    for (0..timeout) |_| {
        if (fmu0.fstat.ccif) return;
    }
    return FmuError.CcifTimeout;
}

noinline fn clearErrors() linksection(".ramfunc") void {
    fmu0.fstat = Fstat{.cmdabt = true, .pviol = true, .accerr = true, .cwsabt = true, .dfdif = true};
}

//linksection(".ramfunc")
noinline fn start(command: FmuCommand, timeout: usize)  FmuError!void {
    try waitCcif(timeout);
    clearErrors();
    fmu0.command = command;
    fmu0.parameter = 0;
    fmu0.fstat = Fstat{.ccif = true};
    for (0..timeout) |_| {
        const fstat = fmu0.fstat;
        if (fstat.ccif) {
            try decodeError();
            return FmuError.UnknownError;
        }
        if (fstat.pewen == .enabled_program_and_erase) {
            return;
        }
    }
    return FmuError.PewenTimeout;
}

noinline fn decodeError() linksection(".ramfunc") FmuError!void {
    const fstat = fmu0.fstat;
    if (fstat.cmdabt) return FmuError.CommandAbort;
    if (fstat.pviol) return FmuError.ProtectionViolation;
    if (fstat.accerr) return FmuError.AccessError;
    if (fstat.cwsabt) return FmuError.CommandWriteSequenceAbort;
    if (fstat.dfdif) return FmuError.DoubleBitFault;
    if (fstat.fail) return FmuError.Fail;
}

noinline fn finish(timeout: usize) linksection(".ramfunc") FmuError!void {
    fmu0.fstat = Fstat{.perdy = true};
    try waitCcif(timeout);
    try decodeError();
}

pub noinline fn sectorErase(address: usize) linksection(".ramfunc") FmuError!void {
    if (address & (SECTOR_SIZE - 1) != 0 or address > 0xFFFFF) return FmuError.InvalidAddress;
    const p: [*]u32 = @ptrFromInt(address);
    const primask = nvic.getPrimask();
    nvic.disableIrq();
    defer nvic.setPrimask(primask);
    try start(.ersscr, ERASE_TIMEOUT);
    p[0] = 0;
    p[1] = 0;
    p[2] = 0;
    p[3] = 0;
    try finish(ERASE_TIMEOUT);

}

noinline fn write(phrase: bool, address: usize, data: []const u8) linksection(".ramfunc") FmuError!void {
    const size: usize = if (phrase) PHRASE_SIZE else PAGE_SIZE;
    const mask = size - 1;
    if (address & mask != 0 or address > 0xFFFFF) return FmuError.InvalidAddress;
    var p: [*]u32 = @ptrFromInt(address);
    var l = data.len;
    var idx: usize = 0;
    const cmd = if (phrase) FmuCommand.pgmphr else FmuCommand.pgmpg;
    while (l != 0) {
        var tl = @min(l, size);
        var rest = size - tl;
        l -= tl;
        try start(cmd, PROGRAMMING_TIMEOUT);
        while (tl >= 4) {
            const word = std.mem.readInt(u32, data[idx..][0..4], .little);
            p[0] = word;
            p += 1;
            idx += 4;
            tl -= 4;
        }
        if (tl != 0) {
            var v: [4]u8 = .{0xFF, 0xFF, 0xFF, 0xFF};
            @memcpy(v[0..tl], data[idx..]);
            const d = std.mem.readInt(u32, &v, .little);
            p[0] = d;
            p += 1;
        }
        while (rest != 0) {
            p[0] = 0xFFFFFFFF;
            p += 1;
            rest -= 4;
        }
        try finish(PROGRAMMING_TIMEOUT);
    }
}

pub noinline fn writePhrases(address: usize, data: []const u8) linksection(".ramfunc") FmuError!void {
    try write(true, address, data);
}

pub noinline fn writePages(address: usize, data: []const u8) linksection(".ramfunc") FmuError!void {
    try write(false, address, data);
}

pub const fmu0: *volatile Fmu = @ptrFromInt(FMU0_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x30, @sizeOf(Fmu));
}
