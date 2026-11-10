const LPUART0_BASE = 0x40092000;
const LPUART1_BASE = 0x40093000;
const LPUART2_BASE = 0x40094000;
const LPUART3_BASE = 0x40095000;
const LPUART4_BASE = 0x400B4000;
const LPUART5_BASE = 0x400B5000;
const LPUART6_BASE = 0x400B6000;
const LPUART7_BASE = 0x400B7000;

pub const Feature = enum(u16) {
    standard = 1,
    modem_irda = 3,
    modem_irda_idle = 7
};

pub const Verid = packed struct(u32) {
    feature: Feature,
    minor: u8,
    major: u8,
};

pub const Param = packed struct(u32) {
    txfifo: u8,
    rxfifo: u8,
    reserved0: u16,
};

pub const Global = packed struct(u32) {
    reserved0: u1 = 0,
    rst: bool = false,
    reserved1: u30 = 0,
};

pub const Trgsel = enum(u2) {
    disabled = 0,
    trg_rxd = 1,
    trg_cts = 2,
    trg_txd = 3,
};

pub const Pincfg = packed struct(u32) {
    trgsel: Trgsel = .disabled,
    reserved0: u30 = 0,
};

pub const Matcfg = enum(u2) {
    addr_match = 0,
    idle_match = 1,
    onoff_match = 2,
    rwu_match = 3,
};

pub const Baud = packed struct(u32) {
    sbr: u13 = 4,
    sbns: bool = false,
    rxedgie: bool = false,
    lbkdie: bool = false,
    resyncdis: bool = false,
    bothedge: bool = false,
    matcfg: Matcfg = .addr_match,
    ridmae: bool = false,
    rdmae: bool = false,
    reserved0: u1 = 0,
    tdmae: bool = false,
    osr: u5 = 15,
    m10: bool = false,
    maen2: bool = false,
    maen1: bool = false,
};

pub const Stat = packed struct(u32) {
    lbkfe: bool = false,
    ame: bool = false,
    reserved0: u6 = 0,
    msf: bool = false,
    tsf: bool = false,
    reserved1: u4 = 0,
    ma2f: bool = false,
    ma1f: bool = false,
    pf: bool = false,
    fe: bool = false,
    nf: bool = false,
    overrun: bool = false,
    idle: bool = false,
    rdrf: bool = false,
    tc: bool = true,
    tdre: bool = true,
    raf: bool = false,
    lbkde: bool = false,
    brk13: bool = false,
    rwuid: bool = false,
    rxinv: bool = false,
    msbf: bool = false,
    rxedgif: bool = false,
    lbkdif: bool = false,
};

pub const Idlecfg = enum(u3) {
    _1 = 0,
    _2 = 1,
    _4 = 2,
    _8 = 3,
    _16 = 4,
    _32 = 5,
    _64 = 6,
    _128 = 7,
};

pub const Ctrl = packed struct(u32) {
    pt: bool = false,
    pe: bool = false,
    ilt: bool = false,
    wake: bool = false,
    m: bool = false,
    rsrc: bool = false,
    dozeen: bool = false,
    loops: bool = false,
    idlecfg: Idlecfg = ._1,
    m7: bool = false,
    reserved0: u2 = 0,
    ma2ie: bool = false,
    ma1ie: bool = false,
    sbk: bool = false,
    rwu: bool = false,
    re: bool = false,
    te: bool = false,
    ilie: bool = false,
    rie: bool = false,
    tcie: bool = false,
    tie: bool = false,
    peie: bool = false,
    feie: bool = false,
    neie: bool = false,
    orie: bool = false,
    txinv: bool = false,
    txdir: bool = false,
    r9t8: bool = false,
    r8t9: bool = false,
};

pub const Data32 = packed struct(u32) {
    data: u10 = 0,
    linbrk: bool = false,
    idline: bool = false,
    rxempt: bool = true,
    fretsc: bool = false,
    paritye: bool = false,
    noisy: bool = false,
    reserved0: u16 = 0,
};

pub const Data = extern union {
    data8: u8,
    data32: Data32
};

pub const Match = packed struct(u32) {
    ma1: u10 = 0,
    reserved0: u6 = 0,
    ma2: u10 = 0,
    reserved1: u6 = 0,
};

pub const Tnp = enum(u2) {
    one_sample = 0,
    two_sample = 1,
    three_sample = 2,
    four_sample = 3,
};

pub const Modir = packed struct(u32) {
    txctse: bool = false,
    txrtse: bool = false,
    txrtspol: bool = false,
    rxrtse: bool = false,
    txctsc: bool = false,
    txctssrc: bool = false,
    reserved0: u2 = 0,
    rtswater: u3 = 0,
    reserved1: u5 = 0,
    tnp: Tnp = .one_sample,
    iren: bool = false,
    reserved2: u13 = 0,
};

pub const Fifosize = enum(u3) {
    _1 = 0,
    _4 = 1,
    _8 = 2,
    _16 = 3,
    _32 = 4,
    _64 = 5,
    _128 = 6,
    _256 = 7,
};

pub const Rxiden = enum(u3) {
    disabled = 0,
    _1 = 1,
    _2 = 2,
    _4 = 3,
    _8 = 4,
    _16 = 5,
    _32 = 6,
    _64 = 7,
};

pub const Fifo = packed struct(u32) {
    rxfifosize: Fifosize = ._8,
    rxfe: bool = false,
    txfifosize: Fifosize = ._8,
    txfe: bool = false,
    rxufe: bool = false,
    txofe: bool = false,
    rxiden: Rxiden = .disabled,
    reserved0: u1 = 0,
    rxflush: bool = false,
    txflush: bool = false,
    rxuf: bool = false,
    txof: bool = false,
    reserved1: u4 = 3,
    rxempt: bool = true,
    txempt: bool = true,
    reserved2: u8 = 0,
};

pub const Water = packed struct(u32) {
    txwater: u3 = 0,
    reserved0: u5 = 0,
    txcount: u4 = 0,
    reserved1: u4 = 0,
    rxwater: u3 = 0,
    reserved2: u5 = 0,
    rxcount: u4 = 0,
    reserved3: u4 = 0,
};

pub const Dataro = packed struct(u32) {
    data: u16,
    reserved0: u16,
};

pub const Mcr = packed struct(u32) {
    cts: bool = false,
    dsr: bool = false,
    rin: bool = false,
    dcd: bool = false,
    reserved0: u4 = 0,
    dtr: bool = false,
    rts: bool = false,
    reserved1: u22 = 0,
};

pub const Msr = packed struct(u32) {
    dcts: bool = false,
    ddsr: bool = false,
    dri: bool = false,
    ddcd: bool = false,
    cts: bool = false,
    dsr: bool = false,
    rin: bool = false,
    dcd: bool = false,
    reserved0: u24 = 0,
};

pub const Hdcr = packed struct(u32) {
    txstall: bool = false,
    rxsel: bool = false,
    rxwrmsk: bool = false,
    rxmsk: bool = false,
    reserved0: u4 = 0,
    rtsext: u8 = 0,
    reserved1: u16 = 0,
};

pub const Tocr = packed struct(u32) {
    toen: u4 = 0,
    reserved0: u4 = 0,
    toie: u4 = 0,
    reserved1: u20 = 0,
};

pub const Tof = enum(u4) {
    not_occurred = 0,
    occurred_clear = 1,
};

pub const Tosr = packed struct(u32) {
    toz: u4 = 15,
    reserved0: u4 = 0,
    tof: Tof = .not_occurred,
    reserved1: u20 = 0,
};

pub const Timeoutfg = enum(u2) {
    cnt_char = 0,
    cnt_idle = 1,
    cnt_busy_idle = 2,
    cnt_char_idle = 3,
};

pub const Timeout = packed struct(u32) {
    timeout: u14 = 0,
    reserved0: u16 = 0,
    cfg: Timeoutfg = .cnt_char,
};

pub const Tcbr = packed struct(u32) {
    data: u16 = 0,
    reserved0: u16 = 0,
};

pub const Tdbr = packed struct(u32) {
    data0: u8 = 0,
    data1: u8 = 0,
    data2: u8 = 0,
    data3: u8 = 0,
};

pub const Lpuart = extern struct {
    verid: Verid,
    param: Param,
    global: Global,
    pincfg: Pincfg,
    baud: Baud,
    stat: Stat,
    ctrl: Ctrl,
    data: Data,
    match: Match,
    modir: Modir,
    fifo: Fifo,
    water: Water,
    dataro: Dataro,
    reserved0: [3]u32,
    mcr: Mcr,
    msr: Msr,
    reir: u32,
    teir: u32,
    hdcr: Hdcr,
    reserved1: u32,
    tocr: Tocr,
    tosr: Tosr,
    timeout: [4]Timeout,
    reserved2: [100]u32,
    tcbr: [128]Tcbr,
    tdbr: [256]Tdbr,

    pub fn init(self: *volatile Lpuart, baud: usize, clock_frequency: usize) void {
        self.global = Global{ .rst = true };
        self.global = Global{};
        self.baud = Baud{
            .sbr = @truncate(clock_frequency / (baud * 16)),
            .osr = 15, // oversampling ratio = 16
        };
        self.ctrl = Ctrl{ .re = true, .te = true, .rie = true };
    }
};

pub const lpuart0: *volatile Lpuart = @ptrFromInt(LPUART0_BASE);
pub const lpuart1: *volatile Lpuart = @ptrFromInt(LPUART1_BASE);
pub const lpuart2: *volatile Lpuart = @ptrFromInt(LPUART2_BASE);
pub const lpuart3: *volatile Lpuart = @ptrFromInt(LPUART3_BASE);
pub const lpuart4: *volatile Lpuart = @ptrFromInt(LPUART4_BASE);
pub const lpuart5: *volatile Lpuart = @ptrFromInt(LPUART5_BASE);
pub const lpuart6: *volatile Lpuart = @ptrFromInt(LPUART6_BASE);
pub const lpuart7: *volatile Lpuart = @ptrFromInt(LPUART7_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x800, @sizeOf(Lpuart));
}
