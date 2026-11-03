const USART1_BASE = 0x40013800;
const USART2_BASE = 0x40004400;
const USART3_BASE = 0x40004800;
const UART4_BASE = 0x40004C00;
const UART5_BASE = 0x40005000;
const USART6_BASE = 0x40006400;
const UART7_BASE = 0x40007800;
const UART8_BASE = 0x40007C00;
const UART9_BASE = 0x40008000;

pub const UsartCr1 = packed struct(u32) {
    ue: bool = false,
    uesm: bool = false,
    re: bool = false,
    te: bool = false,
    idleie: bool = false,
    rxfneie: bool = false,
    tcie: bool = false,
    txfnfie: bool = false,
    peie: bool = false,
    ps: bool = false,
    pce: bool = false,
    wake: bool = false,
    m0: bool = false,
    mme: bool = false,
    cmie: bool = false,
    over8: bool = false,
    dedt: u5 = 0,
    deat: u5 = 0,
    rtoie: bool = false,
    eobie: bool = false,
    m1: bool = false,
    fifoen: bool = false,
    txfeie: bool = false,
    rxffie: bool = false,
};

pub const UsartStopBits = enum(u2) {
    _1 = 0,
    _0p5 = 1,
    _2 = 2,
    _1p5 = 3
};

pub const UsartCr2 = packed struct(u32) {
    slven: bool = false,
    reserved0: u2 = 0,
    dis_nss: bool = false,
    addm7: bool = false,
    lbdl: bool = false,
    lbdie: bool = false,
    reserved1: u1 = 0,
    lbcl: bool = false,
    cpha: bool = false,
    cpol: bool = false,
    clken: bool = false,
    stop: UsartStopBits = ._1,
    linen: bool = false,
    swap: bool = false,
    rxinv: bool = false,
    txinv: bool = false,
    datainv: bool = false,
    msbfirst: bool = false,
    abren: bool = false,
    abrmod: u2 = 0,
    rtoen: bool = false,
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

pub const UsartCr3 = packed struct(u32) {
    eie: bool = false,
    iren: bool = false,
    irlp: bool = false,
    hdsel: bool = false,
    nack: bool = false,
    scen: bool = false,
    dmar: bool = false,
    dmat: bool = false,
    rtse: bool = false,
    ctse: bool = false,
    ctsie: bool = false,
    onebit: bool = false,
    ovrdis: bool = false,
    ddre: bool = false,
    dem: bool = false,
    dep: bool = false,
    reserved0: u1 = 0,
    scarcnt: u3 = 0,
    wus0: bool = false,
    wus1: bool = false,
    wufie: bool = false,
    txftie: bool = false,
    tcbgtie: bool = false,
    rxftcfg: Rxftcfg = ._0p125,
    rxftie: bool = false,
    txftcfg: Txftcfg = ._0p125
};

pub const UsartGtpr = packed struct(u32) {
    psc: u8 = 0,
    gt: u8 = 0,
    reserved0: u16 = 0,
};

pub const UsartRtor = packed struct(u32) {
    rto: u24 = 0,
    blen: u8 = 0,
};

pub const UsartRqr = packed struct(u32) {
    abrrq: bool = false,
    sbkrq: bool = false,
    mmrq: bool = false,
    rxfrq: bool = false,
    txfrq: bool = false,
    reserved0: u27 = 0,
};

pub const UsartIsr = packed struct(u32) {
    pe: bool,
    fe: bool,
    ne: bool,
    ore: bool,
    idle: bool,
    rxfne: bool,
    tc: bool,
    txfnf: bool,
    lbdf: bool,
    ctsif: bool,
    cts: bool,
    rtof: bool,
    eobf: bool,
    udr: bool,
    abre: bool,
    abrf: bool,
    busy: bool,
    cmf: bool,
    sbkf: bool,
    rwu: bool,
    wuf: bool,
    teack: bool,
    reack: bool,
    txfe: bool,
    rxff: bool,
    tcbgt: bool,
    rxft: bool,
    txft: bool,
    reserved0: u4
};

pub const UsartIcr = packed struct(u32) {
    pecf: bool = false,
    fecf: bool = false,
    necf: bool = false,
    orecf: bool = false,
    idlecf: bool = false,
    txfecf: bool = false,
    tccf: bool = false,
    tcbgtcf: bool = false,
    lbdcf: bool = false,
    ctscf: bool = false,
    reserved0: u1 = 0,
    rtocf: bool = false,
    eobcf: bool = false,
    udrcf: bool = false,
    reserved1: u3 = 0,
    cmcf: bool = false,
    reserved2: u2 = 0,
    wucf: bool = false,
    reserved3: u11 = 0,
};

pub const UsartPrescaler = enum(u32) {
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

pub const Usart = extern struct {
    cr1: UsartCr1,
    cr2: UsartCr2,
    cr3: UsartCr3,
    brr: u32,
    gtpr: UsartGtpr,
    rtor: UsartRtor,
    rqr: UsartRqr,
    isr: UsartIsr,
    icr: UsartIcr,
    rdr: u32,
    tdr: u32,
    presc: UsartPrescaler,

    pub fn init(self: *volatile Usart, baud_rate: u32, apbclock: u32) void {
        self.brr = apbclock / baud_rate;
        self.cr1 = UsartCr1{.ue = true, .te = true, .re = true, .rxfneie = true, .fifoen = true};
    }

    pub fn initDma(self: *volatile Usart, baud_rate: u32, apbclock: u32) void {
        self.init(baud_rate, apbclock);
        self.cr3 = UsartCr3{.dmat = true};
    }

    pub fn write(self: *volatile Usart, byte: u8) void {
        while (!self.isr.txfnf) { // TX fifo not full flag
            asm volatile ("nop");
        }
        self.tdr = byte;
    }
};

pub const usart1: *volatile Usart = @ptrFromInt(USART1_BASE);
pub const usart2: *volatile Usart = @ptrFromInt(USART2_BASE);
pub const usart3: *volatile Usart = @ptrFromInt(USART3_BASE);
pub const uart4: *volatile Usart = @ptrFromInt(UART4_BASE);
pub const uart5: *volatile Usart = @ptrFromInt(UART5_BASE);
pub const usart6: *volatile Usart = @ptrFromInt(USART6_BASE);
pub const uart7: *volatile Usart = @ptrFromInt(UART7_BASE);
pub const uart8: *volatile Usart = @ptrFromInt(UART8_BASE);
pub const uart9: *volatile Usart = @ptrFromInt(UART9_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Usart));

}
