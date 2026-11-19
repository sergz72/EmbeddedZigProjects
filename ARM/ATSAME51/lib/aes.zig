const AES_BASE = 0x42002400;

pub const Aesmode = enum(u3) {
    ecb = 0,
    cbc = 1,
    ofb = 2,
    cfb = 3,
    counter = 4,
    ccm = 5,
    gcm = 6,
};

pub const AesCfbs = enum(u3) {
    _128bit = 0,
    _64bit = 1,
    _32bit = 2,
    _16bit = 3,
    _8bit = 4,
};

pub const AesKeysize = enum(u2) {
    _128bit = 0,
    _192bit = 1,
    _256bit = 2,
};

pub const AesCtrla = bitpack struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    aesmode: Aesmode = .ecb,
    cfbs: AesCfbs = ._128bit,
    keysize: AesKeysize = ._128bit,
    cipher: bool = false,
    startmode: bool = false,
    lod: bool = false,
    keygen: bool = false,
    xorkey: bool = false,
    reserved0: u1 = 0,
    ctype: u4 = 0,
    reserved1: u12 = 0,
};

pub const AesCtrlb = bitpack struct(u8) {
    start: bool = false,
    newmsg: bool = false,
    eom: bool = false,
    gfmul: bool = false,
    reserved0: u4 = 0,
};

pub const AesInt = bitpack struct(u8) {
    enccmp: bool = false,
    gfmcmp: bool = false,
    reserved0: u6 = 0,
};

pub const AesDbgctrl = bitpack struct(u8) {
    dbgrun: bool = false,
    reserved0: u7 = 0,
};

pub const Aes = extern struct {
    ctrla: AesCtrla,
    ctrlb: AesCtrlb,
    intenclr: AesInt,
    intenset: AesInt,
    intflag: AesInt,
    databufptr: u8,
    dbgctrl: AesDbgctrl,
    reserved0: u16,
    keyword: [8]u32,
    reserved1: [3]u32,
    indata: u32,
    intvectv: [4]u32,
    reserved2: [4]u32,
    hashkey: [4]u32,
    ghash: [4]u32,
    reserved4: u32,
    ciplen: u32,
    randseed: u32,
};

pub const aes: *volatile Aes = @ptrFromInt(AES_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x88, @sizeOf(Aes));
}
