const DMA0_BASE = 0x40080000;
const DMA1_BASE = 0x400A0000;

pub const MpCsr = bitpack struct(u32) {
    reserved0: u1 = 0,
    edbg: bool = false,
    erca: bool = false,
    reserved1: u1 = 0,
    hae: bool = false,
    halt: bool = false,
    gclc: bool = false,
    gmrc: bool = false,
    ecx: bool = false,
    cx: bool = false,
    reserved2: u14 = 0,
    active_id: u4 = 0,
    reserved3: u3 = 0,
    active: bool = false,
};

pub const MpEs = bitpack struct(u32) {
    dbe: bool,
    sbe: bool,
    sge: bool,
    nce: bool,
    doe: bool,
    dae: bool,
    soe: bool,
    sae: bool,
    ecx: bool,
    reserved0: u15,
    errchn: u4,
    reserved1: u3,
    vld: bool,
};

pub const DmaMux = enum(u7) {
    disabled = 0,
    int0 = 3,
    int1 = 4,
    int2 = 5,
    int3 = 6,
    ctimer0_m0 = 7,
    ctimer0_m1 = 8,
    ctimer1_m0 = 9,
    ctimer1_m1 = 10,
    ctimer2_m0 = 11,
    ctimer2_m1 = 12,
    ctimer3_m0 = 13,
    ctimer3_m1 = 14,
    ctimer4_m0 = 15,
    ctimer4_m1 = 16,
    wuu0 = 17,
    micfil0 = 18,
    adc0_fifoa = 21,
    adc0_fifob = 22,
    adc1_fifoa = 23,
    adc1_fifob = 24,
    cmp0 = 28,
    cmp1 = 29,
    evtg0_out0a = 31,
    evtg0_out0b = 32,
    evtg0_out1a = 33,
    evtg0_out1b = 34,
    evtg0_out2a = 35,
    evtg0_out2b = 36,
    evtg0_out3a = 37,
    evtg0_out3b = 38,
    pwm0_capt0 = 39,
    pwm0_capt1 = 40,
    pwm0_capt2 = 41,
    pwm0_capt3 = 42,
    pwm0_val0 = 43,
    pwm0_val1 = 44,
    pwm0_val2 = 45,
    pwm0_val3 = 46,
    pwm1_capt0 = 47,
    pwm1_capt1 = 48,
    pwm1_capt2 = 49,
    pwm1_capt3 = 50,
    pwm1_val0 = 51,
    pwm1_val1 = 52,
    pwm1_val2 = 53,
    pwm1_val3 = 54,
    lptmr0 = 57,
    lptmr1 = 58,
    can0 = 59,
    can1 = 60,
    flexio0_0 = 61,
    flexio0_1 = 62,
    flexio0_2 = 63,
    flexio0_3 = 64,
    flexio0_4 = 65,
    flexio0_5 = 66,
    flexio0_6 = 67,
    flexio0_7 = 68,
    flexcomm0_rx = 69,
    flexcomm0_tx = 70,
    flexcomm1_rx = 71,
    flexcomm1_tx = 72,
    flexcomm2_rx = 73,
    flexcomm2_tx = 74,
    flexcomm3_rx = 75,
    flexcomm3_tx = 76,
    flexcomm4_rx = 77,
    flexcomm4_tx = 78,
    flexcomm5_rx = 79,
    flexcomm5_tx = 80,
    flexcomm6_rx = 81,
    flexcomm6_tx = 82,
    flexcomm7_rx = 83,
    flexcomm7_tx = 84,
    i3c0_rx = 95,
    i3c0_tx = 96,
    i3c1_rx = 97,
    i3c1_tx = 98,
    sai0_rx = 99,
    sai0_tx = 100,
    sai1_rx = 101,
    sai1_tx = 102,
    gpio0_0 = 108,
    gpio0_1 = 109,
    gpio1_0 = 110,
    gpio1_1 = 111,
    gpio2_0 = 112,
    gpio2_1 = 113,
    gpio3_0 = 114,
    gpio3_1 = 115,
    gpio4_0 = 116,
    gpio4_1 = 117,
    gpio5_0 = 118,
    gpio5_1 = 119
};

pub const ChCsr = bitpack struct(u32) {
    erq: bool = false,
    earq: bool = false,
    eei: bool = false,
    ebw: bool = false,
    reserved0: u26 = 0,
    done: bool = false,
    active: bool = false,
};

pub const ChEs = bitpack struct(u32) {
    dbe: bool = false,
    sbe: bool = false,
    sge: bool = false,
    nce: bool = false,
    doe: bool = false,
    dae: bool = false,
    soe: bool = false,
    sae: bool = false,
    reserved0: u23 = 0,
    err: bool = false,
};

pub const ChSbr = bitpack struct(u32) {
    mid: u5 = 6,
    reserved0: u9 = 0,
    sec: bool = false,
    pal: bool = false,
    emi: bool = false,
    reserved1: u15 = 0,
};

pub const ChPri = bitpack struct(u32) {
    apl: u3 = 0,
    reserved0: u27 = 0,
    dpa: bool = false,
    ecp: bool = false,
};

pub const ChMux = bitpack struct(u32) {
    src: DmaMux = .disabled,
    reserved0: u25 = 0,
};

pub const Ssize = enum(u3) {
    _8bit = 0,
    _16bit = 1,
    _32bit = 2,
    _64bit = 3,
    _16byte = 4,
    _32byte = 5
};

pub const Smod = enum(u5) {
    disable = 0,
    enable = 1,
};

pub const TcdAttr = bitpack struct(u16) {
    dsize: u3 = 0,
    dmod: u5 = 0,
    ssize: Ssize = ._8bit,
    smod: Smod = .disable,
};

pub const TcdNbytesMloffno = bitpack struct(u32) {
    nbytes: u30 = 0,
    dmloe: bool = false,
    smloe: bool = false,
};

pub const TcdNbytesMloffyes = bitpack struct(u32) {
    nbytes: u10 = 0,
    mloff: u20 = 0,
    dmloe: bool = false,
    smloe: bool = false,
};

pub const TcdNbytesMloff = extern union {
    no: TcdNbytesMloffno,
    yes: TcdNbytesMloffyes,
};

pub const TcdCiterLinkno = bitpack struct(u16) {
    iter: u15 = 0,
    elink: bool = false,
};

pub const TcdCiterLinkyes = bitpack struct(u16) {
    iter: u9 = 0,
    linkch: u4 = 0,
    reserved0: u2 = 0,
    elink: bool = false,
};

pub const TcdIterElink = extern union {
    no: TcdCiterLinkno,
    yes: TcdCiterLinkyes,
};

pub const Bwc = enum(u2) {
    no_stall = 0,
    engine_stalls_4 = 2,
    engine_stalls_8 = 3,
};

pub const TcdCsr = bitpack struct(u16) {
    start: bool = false,
    intmajor: bool = false,
    inthalf: bool = false,
    dreq: bool = false,
    esg: bool = false,
    majorelink: bool = false,
    eeop: bool = false,
    esda: bool = false,
    majorlinkch: u4 = 0,
    reserved0: u2 = 0,
    bwc: Bwc = .no_stall,
};

pub const DmaTcd = extern struct {
    csr: ChCsr,
    es: ChEs,
    int: u32,
    sbr: ChSbr,
    pri: ChPri,
    mux: ChMux,
    reserved0: [2]u32,
    saddr: u32,
    soff: u16,
    attr: TcdAttr,
    nbytes: TcdNbytesMloff,
    slast: u32,
    daddr: u32,
    doff: u16,
    citer: TcdIterElink,
    dlast: u32,
    dcsr: TcdCsr,
    biter: TcdIterElink,
    reserved1: [1008]u32
};

pub const Dma = extern struct {
    csr: MpCsr,
    es: MpEs,
    int: u32,
    hrs: u32,
    reserved0: [60]u32,
    grpri: [16]u32,
    reserved1: [944]u32,
    tcd: [16]DmaTcd
};

pub const dma0: *volatile Dma = @ptrFromInt(DMA0_BASE);
pub const dma1: *volatile Dma = @ptrFromInt(DMA1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x11000, @sizeOf(Dma));
}
