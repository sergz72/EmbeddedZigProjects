const PSSI_BASE = 0x4202C400;

pub const Edm = enum(u2) {
    _8bit = 0,
    _16bit = 3
};

pub const Derdycfg = enum(u3) {
    de_and_rdy_disabled = 0,
    rdy_enabled = 1,
    de_enabled = 2,
    de_and_rdy_enabled = 3,
    rdy_bidir = 4,
    rdy_on_de = 5,
    de_on_rdy = 6,
    de_bidir = 7
};

pub const PssiCr = packed struct(u32) {
    reserved0: u5 = 0,
    ckpol: bool = false,
    depol: bool = false,
    reserved1: u1 = 0,
    rdypol: bool = false,
    reserved2: u1 = 0,
    edm: Edm = ._8bit,
    reserved3: u2 = 0,
    enable: bool = false,
    reserved4: u3 = 0,
    derdycfg: Derdycfg = .de_and_rdy_disabled,
    reserved5: u9 = 1,
    dmaen: bool = true,
    outen: bool = false,
};

pub const PssiSr = packed struct(u32) {
    reserved0: u2,
    rtt4b: bool,
    rtt1b: bool,
    reserved1: u28,
};

pub const PssiRis = packed struct(u32) {
    reserved0: u1,
    ovr_ris: bool,
    reserved1: u30,
};

pub const PssiIer = packed struct(u32) {
    reserved0: u1 = 0,
    ovr_ie: bool = false,
    reserved1: u30 = 0,
};

pub const PssiMis = packed struct(u32) {
    reserved0: u1,
    ovr_mis: bool,
    reserved1: u30,
};

pub const PssiIcr = packed struct(u32) {
    reserved0: u1 = 0,
    ovr_isc: bool = false,
    reserved1: u30 = 0,
};

pub const PssiDr = packed struct(u32) {
    byte0: u8 = 0,
    byte1: u8 = 0,
    byte2: u8 = 0,
    byte3: u8 = 0,
};

pub const Pssi = extern struct {
    cr: PssiCr,
    sr: PssiSr,
    ris: PssiRis,
    ier: PssiIer,
    mis: PssiMis,
    icr: PssiIcr,
    reserved0: [4]u32,
    dr: PssiDr,
};

pub const pssi: *volatile Pssi = @ptrFromInt(PSSI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2C, @sizeOf(Pssi));
}
