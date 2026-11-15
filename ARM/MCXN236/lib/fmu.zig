const FMU0_BASE = 0x40043000;

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

pub const FmuError = error {
    Timeout
};

pub const Fmu = extern struct {
    fstat: Fstat,
    fcnfg: Fcnfg,
    fctrl: Fctrl,
    reserved0: [4]u8,
    fccob: [8]u32,
};

pub const fmu0: *volatile Fmu = @ptrFromInt(FMU0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Fmu));
}
