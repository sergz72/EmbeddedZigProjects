const NVMCTRL_BASE = 0x41004000;

pub const NvmctrlCmd = enum(u7) {
    reserved = 0,
    erase_row = 2,
    write_page = 4,
    erase_auxillary_row = 5,
    write_auxillary_page = 6,
    security_flow_command = 0x0A,
    write_lockbits = 0x0F,
    rwwee_erase_row = 0x1A,
    rwee_write_page = 0x1C,
    lock_region = 0x40,
    unlock_region = 0x41,
    set_power_reduction_mode = 0x42,
    clear_power_reduction_mode = 0x43,
    page_buffer_clear = 0x44,
    set_security_bit = 0x45,
    invalidate_all = 0x46
};

pub const NvmctrlCtrla = bitpack struct(u16) {
    cmd: NvmctrlCmd = .reserved,
    reserved0: u1 = 0,
    cmdex: u8 = 0xA5
};

pub const NvmctrlRws = enum(u4) {
    single = 0,
    half = 1,
    dual = 2,
};

pub const NvmctrlSleepprm = enum(u2) {
    wakeonaccess = 0,
    wakeupinstant = 1,
    disabled = 3,
};

pub const NvmctrlReadmode = enum(u2) {
    no_miss_penalty = 0,
    low_power = 1,
    deterministic = 2,
};

pub const NvmctrlCtrlb = bitpack struct(u32) {
    reserved0: u1 = 0,
    rws: NvmctrlRws = .single,
    reserved1: u2 = 0,
    manw: bool = false,
    sleepprm: NvmctrlSleepprm = .wakeonaccess,
    reserved2: u6 = 0,
    readmode: NvmctrlReadmode = .no_miss_penalty,
    cachedis: bool = false,
    reserved3: u13 = 0,
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
    nvmp: u16 = 0,
    psz: NvmctrlPsz = ._8,
    reserved0: u13 = 0,
};

pub const NvmctrlInt = bitpack struct(u8) {
    ready: bool = false,
    err: bool = false,
    reserved0: u6 = 0,
};

pub const NvmctrlStatus = bitpack struct(u16) {
    prm: bool = false,
    load: bool = false,
    proge: bool = false,
    locke: bool = false,
    nvme: bool = false,
    reserved0: u3 = 0,
    sb: bool = false,
    reserved1: u7 = 0,
};

pub const Nvmctrl = extern struct {
    ctrla: NvmctrlCtrla,
    reserved0: u16,
    ctrlb: NvmctrlCtrlb,
    param: NvmctrlParam,
    intenclr: NvmctrlInt,
    reserved1: [3]u8,
    intenset: NvmctrlInt,
    reserved2: [3]u8,
    intflag: NvmctrlInt,
    reserved3: [3]u8,
    status: NvmctrlStatus,
    reserved4: u16,
    addr: u32,
    lock: u16,
    reserved5: u16
};

pub const nvmctrl: *volatile Nvmctrl = @ptrFromInt(NVMCTRL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Nvmctrl));
}
