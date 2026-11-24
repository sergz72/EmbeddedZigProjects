const std = @import("std");

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

pub fn setKey(key: []const u8) bool {
    if (key.len != 16 and key.len != 32) {
        return false;
    }
    var idx: usize = 0;
    var keyidx: usize = 0;
    while (idx < key.len) : (idx += 4) {
        const k = std.mem.readInt(u32, key[idx..][0..4], .little);
        aes.keyword[keyidx] = k;
        keyidx += 1;
    }
    return true;
}

pub fn setIv(iv: []const u8) bool {
    if (iv.len != 16) {
        return false;
    }
    var idx: usize = 0;
    var ividx: usize = 0;
    while (idx < iv.len) : (idx += 4) {
        const k = std.mem.readInt(u32, iv[idx..][0..4], .little);
        aes.intvectv[ividx] = k;
        ividx += 1;
    }
    return true;
}

pub fn config(mode: Aesmode, keysize: AesKeysize, encrypt: bool) void {
    aes.ctrla = AesCtrla{.aesmode = mode, .keysize = keysize, .cipher = encrypt};
}

fn processBlock(data: []const u8, output: []u8, first: bool) bool {
    if (data.len < 16 or output.len < 16) {
        return false;
    }
    aes.databufptr = 0;
    var idx: usize = 0;
    while (idx < 16) : (idx += 4) {
        const d = std.mem.readInt(u32, data[idx..][0..4], .little);
        aes.indata = d;
    }
    if (first) {
        aes.ctrlb = AesCtrlb{.newmsg = true, .start = true};
    } else {
        aes.ctrlb = AesCtrlb{.start = true};
    }
    while (!aes.intflag.enccmp) {
        asm volatile ("nop");
    }
    aes.intflag = AesInt{.enccmp = true};
    aes.databufptr = 0;
    idx = 0;
    while (idx < 16) : (idx += 4) {
        const d = aes.indata;
        std.mem.writeInt(u32, output[idx..][0..4], d, .little);
    }
    return true;
}

pub fn processBlocks(data: []const u8, output: []u8) bool {
    if (data.len != output.len or data.len & 0x0F != 0) {
        return false;
    }
    if (data.len == 0) {
        return true;
    }
    aes.ctrla.enable = true;
    defer aes.ctrla.enable = false;
    var i: usize = 0;
    while (i < data.len) : (i += 16) {
        if (!processBlock(data[i..], output[i..], i == 0)) {
            return false;
        }
    }
    return true;
}

pub const aes: *volatile Aes = @ptrFromInt(AES_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x88, @sizeOf(Aes));
}
