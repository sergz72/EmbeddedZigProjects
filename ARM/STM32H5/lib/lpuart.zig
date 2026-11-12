const LPUART_BASE = 0x44002400;

pub const LpuartCr1 = bitpack struct(u32) {
    ue: bool = false,
    uesm: bool = false,
    re: bool = false,
    te: bool = false,
    idleie: bool = false,
    rxneie: bool = false,
    tcie: bool = false,
    txeie: bool = false,
    peie: bool = false,
    ps: bool = false,
    pce: bool = false,
    wake: bool = false,
    m0: bool = false,
    mme: bool = false,
    cmie: bool = false,
    reserved0: u1 = 0,
    dedt: u5 = 0,
    deat: u5 = 0,
    reserved1: u2 = 0,
    m1: bool = false,
    fifoen: bool = false,
    txfeie: bool = false,
    rxffie: bool = false,
};

pub const Stop = enum(u2) {
    _1 = 0,
    _2 = 2
};

pub const LpuartCr2 = bitpack struct(u32) {
    reserved0: u4 = 0,
    addm7: bool = false,
    reserved1: u7 = 0,
    stop: Stop = ._1,
    reserved2: u1 = 0,
    swap: bool = false,
    rxinv: bool = false,
    txinv: bool = false,
    datainv: bool = false,
    msbfirst: bool = false,
    reserved3: u4 = 0,
    add: u8 = 0,
};

pub const Rxftcfg = enum(u3) {
    _0p125 = 0,
    _0p25 = 1,
    _0p5 = 2,
    _0p75 = 3,
    _0p875 = 4,
    full = 5,
};

pub const Txftcfg = enum(u3) {
    _0p125 = 0,
    _0p25 = 1,
    _0p5 = 2,
    _0p75 = 3,
    _0p875 = 4,
    empty = 5
};

pub const LpuartCr3 = bitpack struct(u32) {
    eie: bool = false,
    reserved0: u2 = 0,
    hdsel: bool = false,
    reserved1: u2 = 0,
    dmar: bool = false,
    dmat: bool = false,
    rtse: bool = false,
    ctse: bool = false,
    ctsie: bool = false,
    reserved2: u1 = 0,
    ovrdis: bool = false,
    ddre: bool = false,
    dem: bool = false,
    dep: bool = false,
    reserved3: u4 = 0,
    wus0: bool = false,
    wus1: bool = false,
    wufie: bool = false,
    txftie: bool = false,
    reserved4: u1 = 0,
    rxftcfg: Rxftcfg = ._0p125,
    rxftie: bool = false,
    txftcfg: Txftcfg = ._0p125,
};

pub const LpuartRqr = bitpack struct(u32) {
    reserved0: u1 = 0,
    sbkrq: bool = false,
    mmrq: bool = false,
    rxfrq: bool = false,
    txfrq: bool = false,
    reserved1: u27 = 0,
};

pub const LpuartIsr = bitpack struct(u32) {
    pe: bool,
    fe: bool,
    ne: bool,
    ore: bool,
    idle: bool,
    rxfne: bool,
    tc: bool,
    txfnf: bool,
    reserved0: u1,
    ctsif: bool,
    cts: bool,
    reserved1: u5,
    busy: bool,
    cmf: bool,
    sbkf: bool,
    rwu: bool,
    wuf: bool,
    teack: bool,
    reack: bool,
    txfe: bool,
    rxff: bool,
    reserved2: u1,
    rxft: bool,
    txft: bool,
    reserved3: u4
};

pub const LpuartIcr = bitpack struct(u32) {
    pecf: bool = false,
    fecf: bool = false,
    necf: bool = false,
    orecf: bool = false,
    idlecf: bool = false,
    reserved0: u1 = 0,
    tccf: bool = false,
    reserved1: u2 = 0,
    ctscf: bool = false,
    reserved2: u7 = 0,
    cmcf: bool = false,
    reserved3: u2 = 0,
    wucf: bool = false,
    reserved4: u11 = 0,
};

pub const Prescaler = enum(u4) {
    B_0x0 = 0,
    B_0x1 = 1,
    B_0x2 = 2,
    B_0x3 = 3,
    B_0x4 = 4,
    B_0x5 = 5,
    B_0x6 = 6,
    B_0x7 = 7,
    B_0x8 = 8,
    B_0x9 = 9,
    B_0xA = 10,
    B_0xB = 11,
};

pub const LpuartPresc = enum(u32) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div6 = 3,
    div8 = 4,
    div10 = 5,
    div12 = 6,
    div16 = 7,
    div32 = 8,
    div64 = 9,
    div128 = 10,
    div256 = 11
};

pub const Lpuart = extern struct {
    cr1: LpuartCr1,
    cr2: LpuartCr2,
    cr3: LpuartCr3,
    brr: u32,
    reserved1: [8]u8,
    rqr: LpuartRqr,
    isr: LpuartIsr,
    icr: LpuartIcr,
    rdr: u32,
    tdr: u32,
    presc: LpuartPresc,

    pub fn init(self: *volatile Lpuart, baud_rate: u32, apbclock: u32) void {
        self.brr = apbclock / baud_rate;
        self.cr1 = LpuartCr1{.ue = true, .te = true, .re = true, .rxfneie = true, .fifoen = true};
    }

    pub fn initDma(self: *volatile Lpuart, baud_rate: u32, apbclock: u32) void {
        self.init(baud_rate, apbclock);
        self.cr3 = LpuartCr3{.dmat = true};
    }

    pub fn write(self: *volatile Lpuart, byte: u8) void {
        while (!self.isr.txfnf) { // TX fifo not full flag
            asm volatile ("nop");
        }
        self.tdr = byte;
    }
};

pub const lpuart: *volatile Lpuart = @ptrFromInt(LPUART_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Lpuart));

}
