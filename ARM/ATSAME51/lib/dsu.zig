const DSU_BASE = 0x41002000;

pub const DsuCtrl = bitpack struct(u8) {
    swrst: bool = false,
    reserved0: u1 = 0,
    crc: bool = false,
    mbist: bool = false,
    ce: bool = false,
    reserved1: u3 = 0,
};

pub const DsuStatusa = bitpack struct(u8) {
    done: bool = false,
    crstext: bool = false,
    berr: bool = false,
    fail: bool = false,
    perr: bool = false,
    reserved0: u3 = 0,
};

pub const DsuStatusb = bitpack struct(u8) {
    prot: bool,
    dbgpres: bool,
    dccd0: bool,
    dccd1: bool,
    hpe: bool,
    celck: bool,
    reserved0: u2,
};

pub const DsuSeries = enum(u6) {
    same51 = 1,
    same53 = 3,
    same54 = 4,
    samd51 = 6,
};

pub const DsuFamily = enum(u5) {
    samd5x = 0,
    same5x = 3,
};

pub const DsuProcessor = enum(u4) {
    cm4f = 6,
};

pub const DsuDid = bitpack struct(u32) {
    devsel: u8,
    revision: u4,
    die: u4,
    series: DsuSeries,
    reserved0: u1,
    family: DsuFamily,
    processor: DsuProcessor,
};

pub const DsuDccdmalevel = enum(u2) {
    empty = 0,
    full = 1,
};

pub const DsuCfg = bitpack struct(u32) {
    lqos: u2 = 2,
    dccdmalevel: DsuDccdmalevel = .empty,
    etbramen: bool = false,
    reserved0: u27 = 0,
};

pub const DsuEntry0 = bitpack struct(u32) {
    epres: bool,
    fmt: bool,
    reserved0: u10,
    addoff: u20,
};

pub const DsuMemtype = bitpack struct(u32) {
    smemp: bool,
    reserved0: u31,
};

pub const DsuPid4 = bitpack struct(u32) {
    jepcc: u4,
    fkbc: u4,
    reserved0: u24,
};

pub const DsuPid0 = bitpack struct(u32) {
    partnbl: u8,
    reserved0: u24,
};

pub const DsuPid1 = bitpack struct(u32) {
    partnbh: u4,
    jepidcl: u4,
    reserved0: u24,
};

pub const DsuPid2 = bitpack struct(u32) {
    jepidch: u3,
    jepu: bool,
    revision: u4,
    reserved0: u24,
};

pub const DsuPid3 = bitpack struct(u32) {
    cusmod: u4,
    revand: u4,
    reserved0: u24,
};

pub const DsuCid0 = bitpack struct(u32) {
    preambleb0: u8,
    reserved0: u24,
};

pub const DsuCid1 = bitpack struct(u32) {
    preamble: u4,
    cclass: u4,
    reserved0: u24,
};

pub const DsuCid2 = bitpack struct(u32) {
    preambleb2: u8,
    reserved0: u24,
};

pub const DsuCid3 = bitpack struct(u32) {
    preambleb3: u8,
    reserved0: u24,
};

pub const DsuError = error {
    BusError,
    Failure,
    ProtectionError
};

pub const Dsu = extern struct {
    ctrl: DsuCtrl,
    statusa: DsuStatusa,
    statusb: DsuStatusb,
    reserved0: u8,
    addr: u32,
    length: u32,
    data: u32,
    dcc: [2]u32,
    did: DsuDid,
    cfg: DsuCfg,
    reserved2: [52]u32,
    dcfg: [2]u32,
    reserved3: [962]u32,
    entry0: DsuEntry0,
    entry1: u32,
    end: u32,
    reserved4: [1008]u32,
    memtype: DsuMemtype,
    pid4: DsuPid4,
    pid5: u32,
    pid6: u32,
    pid7: u32,
    pid0: DsuPid0,
    pid1: DsuPid1,
    pid2: DsuPid2,
    pid3: DsuPid3,
    cid0: DsuCid0,
    cid1: DsuCid1,
    cid2: DsuCid2,
    cid3: DsuCid3,

    pub fn crc32(self: *volatile Dsu, data: []const u32) DsuError!u32 {
        self.addr = @intFromPtr(data.ptr);
        self.length = data.len * 4;
        self.data = 0xFFFFFFFF; // initial value
        self.statusa = DsuStatusa{.done = true, .berr = true, .fail = true, .perr = true};
        self.ctrl = DsuCtrl{.crc = true};
        while (true) {
            if (self.statusa.berr) return DsuError.BusError;
            if (self.statusa.fail) return DsuError.Failure;
            if (self.statusa.perr) return DsuError.ProtectionError;
            if (self.statusa.done) break;
        }
        return self.data;
    }
};

pub const dsu: *volatile Dsu = @ptrFromInt(DSU_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2000, @sizeOf(Dsu));
}
