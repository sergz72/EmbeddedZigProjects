const ERTC_BASE = 0x40002800;

const ERTC_UNLOCK1 = 0xCA;
const ERTC_UNLOCK2 = 0x53;

pub const ErtcTime = packed struct(u32) {
    su: u4 = 0,
    st: u3 = 0,
    reserved1: u1 = 0,
    mu: u4 = 0,
    mt: u3 = 0,
    reserved2: u1 = 0,
    hu: u4 = 0,
    ht: u2 = 0,
    ampm: bool = false,
    reserved3: u9 = 0
};

pub const ErtcWeekday = enum(u3) {
    Monday = 1,
    Tuesday = 2,
    Wednesday = 3,
    Thursday = 4,
    Friday = 5,
    Saturday = 6,
    Sunday = 7
};

pub const ErtcDate = packed struct(u32) {
    du: u4 = 1,
    dt: u2 = 0,
    reserved1: u2 = 0,
    mu: u4 = 1,
    mt: u1 = 0,
    wk: ErtcWeekday = .Monday,
    yu: u4 = 0,
    yt: u4 = 0,
    reserved3: u8 = 0
};

pub const ErtcOutsel = enum(u2) {
    disabled = 0,
    alarm_a = 1
};

pub const ErtcCtrl = packed struct(u32) {
    reserved1: u3 = 0,
    tsedg: bool = false,
    rcden: bool = false,
    dren: bool = false,
    hm: bool = false,
    reserved2: u1 = 0,
    alaen: bool = false,
    reserved3: u2 = 0,
    tsen: bool = false,
    alaien: bool = false,
    reserved5: u2 = 0,
    tsien: bool = false,
    add1h: bool = false,
    dec1h: bool = false,
    bpr: bool = false,
    calosel: bool = false,
    outp: bool = false,
    outsel: ErtcOutsel = .disabled,
    caloen: bool = false,
    reserved7: u8 = 0
};

pub const ErtcSts = packed struct(u32) {
    alawf: bool = true,
    reserved1: u2 = 0,
    tadjf: bool = false,
    initf: bool = false,
    updf: bool = false,
    imf: bool = false,
    imen: bool = false,
    alaf: bool = false,
    reserved3: u2 = 0,
    tsf: bool = false,
    tsof: bool = false,
    tp1f: bool = false,
    reserved5: u2 = 0,
    calupdf: bool = false,
    reserved7: u15 = 0
};

pub const ErtcDiv = packed struct(u32) {
    divb: u15 = 0xFF,
    reserved1: u1 = 0,
    diva: u7 = 0x7F,
    reserved3: u9 = 0
};

pub const ErtcAlarm = packed struct(u32) {
    su: u4 = 0,
    st: u3 = 0,
    mask1: bool = false,
    mu: u4 = 0,
    mt: u3 = 0,
    mask2: bool = false,
    hu: u4 = 0,
    ht: u2 = 0,
    ampm: bool = false,
    mask3: bool = false,
    du: u4 = 0,
    dt: u2 = 0,
    wksel: bool = false,
    mask4: bool = false
};

pub const ErtcTadj = packed struct(u32) {
    decsbs: u15 = 0,
    reserved1: u16 = 0,
    add1s: bool = false
};

pub const ErtcTstm = packed struct(u32) {
    su: u4,
    st: u3,
    reserved1: u1,
    mu: u4,
    mt: u3,
    reserved2: u1,
    hu: u4,
    ht: u2,
    ampm: bool,
    reserved3: u9
};

pub const ErtcTsdt = packed struct(u32) {
    du: u4,
    dt: u2,
    reserved1: u2,
    mu: u4,
    mt: u1,
    wk: ErtcWeekday,
    reserved2: u16
};

pub const ErtcScal = packed struct(u32) {
    dec: u9 = 0,
    reserved1: u4 = 0,
    cal16: bool = false,
    cal8: bool = false,
    add: bool = false,
    reserved2: u16 = 0
};

pub const ErtcTamp = packed struct(u32) {
    tp1en: bool = false,
    tp1edg: bool = false,
    tpien: bool = false,
    reserved1: u4 = 0,
    tptsen: bool = false,
    tpfreq: u3 = 0,
    tpflt: u2 = 0,
    tppr: u2 = 0,
    tppu: bool = false,
    reserved4: u2 = 0,
    outtype: bool = false,
    reserved6: u13 = 0
};

pub const ErtcAlasbs = packed struct(u32) {
    sbs: u15 = 0,
    reserved: u9 = 0,
    sbsmsk: u4 = 0,
    reserved2: u4 = 0
};

pub const Ertc = extern struct {
    time: ErtcTime,
    date: ErtcDate,
    ctrl: ErtcCtrl,
    sts: ErtcSts,
    div: ErtcDiv,
    reserved: [2]u32,
    ala: ErtcAlarm,
    reserved2: u32,
    wp: u32,
    sbs: u32,
    tadj: ErtcTadj,
    tstm: ErtcTstm,
    tsdt: ErtcTsdt,
    tssbs: u32,
    scal: ErtcScal,
    tamp: ErtcTamp,
    alasbs: ErtcAlasbs,
    reserved5: [2]u32,
    bpr: [5]u32,
};

pub const ertc: *volatile Ertc = @ptrFromInt(ERTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x64, @sizeOf(Ertc));
}
