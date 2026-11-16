const AES_BASE = 0x420C0000;

pub const Datatype = enum(u2) {
    no_swap = 0,
    half_word_swap = 1,
    byte_swap = 2,
    bit_level_swap = 3
};

pub const Mode = enum(u2) {
    encryption = 0,
    key_derivation = 1,
    decryption = 2
};

pub const Cphase = enum(u2) {
    init = 0,
    header = 1,
    payload = 2,
    final = 3
};

pub const Kmod = enum(u2) {
    normal = 0,
    shared = 2
};

pub const AesCr = bitpack struct(u32) {
    en: bool = false,
    datatype: Datatype = .no_swap,
    mode: Mode = .encryption,
    chmod: u2 = 0,
    reserved0: u4 = 0,
    dmainen: bool = false,
    dmaouten: bool = false,
    cphase: Cphase = .init,
    reserved1: u1 = 0,
    chmod_2: u1 = 0,
    reserved2: u1 = 0,
    keysize: bool = false,
    reserved3: u1 = 0,
    npblb: u4 = 0,
    kmod: Kmod = .normal,
    reserved4: u5 = 0,
    iprst: bool = false,
};

pub const AesSr = bitpack struct(u32) {
    reserved0: u1,
    rderrf: bool,
    wrerrf: bool,
    busy: bool,
    reserved1: u3,
    keyvalid: bool,
    reserved2: u24,
};

pub const AesIer = bitpack struct(u32) {
    ccfie: bool = false,
    rweie: bool = false,
    keie: bool = false,
    rngeie: bool = false,
    reserved0: u28 = 0,
};

pub const AesIsr = bitpack struct(u32) {
    ccf: bool,
    rweif: bool,
    keif: bool,
    rngeif: bool,
    reserved0: u28,
};

pub const AesIcr = bitpack struct(u32) {
    ccf: bool = false,
    rweif: bool = false,
    keif: bool = false,
    rngeif: bool = false,
    reserved0: u28 = 0,
};

pub const Aes = extern struct {
    cr: AesCr,
    sr: AesSr,
    dinr: u32,
    doutr: u32,
    keyr0: u32,
    keyr1: u32,
    keyr2: u32,
    keyr3: u32,
    ivr0: u32,
    ivr1: u32,
    ivr2: u32,
    ivr3: u32,
    keyr4: u32,
    keyr5: u32,
    keyr6: u32,
    keyr7: u32,
    suspr0: u32,
    suspr1: u32,
    suspr2: u32,
    suspr3: u32,
    suspr4: u32,
    suspr5: u32,
    suspr6: u32,
    suspr7: u32,
    reserved0: [168]u32,
    ier: AesIer,
    isr: AesIsr,
    icr: AesIcr,
};

pub const aes: *volatile Aes = @ptrFromInt(AES_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30C, @sizeOf(Aes));
}
