const LPDMA1_BASE = 0x40020000;
const LPDMA2_BASE = 0x40021000;

pub const LpdmaPrivcfgr = bitpack struct(u32) {
    priv0: bool = false,
    priv1: bool = false,
    priv2: bool = false,
    priv3: bool = false,
    priv4: bool = false,
    priv5: bool = false,
    priv6: bool = false,
    priv7: bool = false,
    reserved0: u24 = 0,
};

pub const LpdmaRcfglockr = bitpack struct(u32) {
    lock0: bool = false,
    lock1: bool = false,
    lock2: bool = false,
    lock3: bool = false,
    lock4: bool = false,
    lock5: bool = false,
    lock6: bool = false,
    lock7: bool = false,
    reserved0: u24 = 0,
};

pub const LpdmaMisr = bitpack struct(u32) {
    mis0: bool,
    mis1: bool,
    mis2: bool,
    mis3: bool,
    mis4: bool,
    mis5: bool,
    mis6: bool,
    mis7: bool,
    reserved0: u24,
};

pub const LpdmaLbar = bitpack struct(u32) {
    reserved0: u16 = 0,
    lba: u16 = 0,
};

pub const LpdmaFcr = bitpack struct(u32) {
    reserved0: u8 = 0,
    tcf: bool = false,
    htf: bool = false,
    dtef: bool = false,
    ulef: bool = false,
    usef: bool = false,
    suspf: bool = false,
    tof: bool = false,
    reserved1: u17 = 0,
};

pub const LpdmaSr = bitpack struct(u32) {
    idlef: bool,
    reserved0: u7,
    tcf: bool,
    htf: bool,
    dtef: bool,
    ulef: bool,
    usef: bool,
    suspf: bool,
    tof: bool,
    reserved1: u17,
};

pub const LpdmaPrio = enum(u2) {
    low = 0,
    mid = 1,
    high = 2,
    very_high = 3
};

pub const LpdmaCr = bitpack struct(u32) {
    en: bool = false,
    reset: bool = false,
    susp: bool = false,
    reserved0: u5 = 0,
    tcie: bool = false,
    htie: bool = false,
    dteie: bool = false,
    uleie: bool = false,
    useie: bool = false,
    suspie: bool = false,
    toie: bool = false,
    reserved1: u1 = 0,
    lsm: bool = false,
    reserved2: u5 = 0,
    prio: LpdmaPrio = .low,
    reserved3: u8 = 0,
};

pub const LpdmaDwLog2 = enum(u2) {
    byte = 0,
    half_word = 1,
    word = 2
};

pub const LpdmaTr1 = bitpack struct(u32) {
    sdw_log2: LpdmaDwLog2 = .byte,
    reserved0: u1 = 0,
    sinc: bool = false,
    reserved1: u7 = 0,
    pam: bool = false,
    reserved2: u4 = 0,
    ddw_log2: LpdmaDwLog2 = .byte,
    reserved3: u1 = 0,
    dinc: bool = false,
    reserved4: u12 = 0,
};

pub const LpdmaTrigm = enum(u2) {
    block_level = 0,
    lli_level = 2,
    programmed_single_level = 3
};

pub const LpdmaTrigpol = enum(u2) {
    no_trigger = 0,
    rising_edge = 1,
    falling_edge = 2
};

pub const LpdmaTcem = enum(u2) {
    block_level = 0,
    lli_level = 2,
    channel_level = 3
};

pub const LpdmaReqsel = enum(u7) {
    adc1 = 0,
    adc2 = 1,
    tim6_upd = 2,
    tim7_upd = 3,
    spi1_rx = 4,
    spi1_tx = 5,
    spi2_rx = 6,
    spi2_tx = 7,
    spi3_rx = 8,
    spi3_tx = 9,
    i2c1_rx = 10,
    i2c1_tx = 11,
    usart1_rx = 12,
    usart1_tx = 13,
    usart2_rx = 14,
    usart2_tx = 15,
    usart3_rx = 16,
    usart3_tx = 17,
    uart4_rx = 18,
    uart4_tx = 19,
    uart5_rx = 20,
    uart5_tx = 21,
    lpuart1_rx = 22,
    lpuart1_tx = 23,
    tim1_cc1 = 24,
    tim1_cc2 = 25,
    tim1_cc3 = 26,
    tim1_cc4 = 27,
    tim1_upd = 28,
    tim1_trg = 29,
    tim1_com = 30,
    tim2_cc1 = 31,
    tim2_cc2 = 32,
    tim2_cc3 = 33,
    tim2_cc4 = 34,
    tim2_upd = 35,
    tim2_trg = 36,
    tim5_cc1 = 37,
    tim5_cc2 = 38,
    tim5_cc3 = 39,
    tim5_cc4 = 40,
    tim5_upd = 41,
    tim5_trg = 42,
    tim15_cc1 = 43,
    tim15_cc2 = 44,
    tim15_upd = 45,
    tim15_trg = 46,
    tim15_com = 47,
    tim16_cc1 = 48,
    tim16_upd = 49,
    tim17_cc1 = 50,
    tim17_upd = 51,
    lptim1_ic1 = 52,
    lptim1_ic2 = 53,
    lptim1_ue = 54,
    cordic_rd = 55,
    cordic_wr = 56,
    i3c1_rx = 57,
    i3c1_tx = 58,
    i3c1_tc = 59,
    i3c1_rs = 60,
    aes_out = 61,
    aes_in = 62,
    hash_in = 63,
    i2c2_rx = 64,
    i2c2_tx = 65,
    tim8_cc1 = 66,
    tim8_cc2 = 67,
    tim8_cc3 = 68,
    tim8_cc4 = 69,
    tim8_upd = 70,
    tim8_trg = 71,
    tim8_com = 72,
    dac_ch1 = 73,
    dac_ch2 = 74,
    usart6_rx = 75,
    usart6_tx = 76,
    uart7_tx = 77,
    uart7_rx = 78,
    adc3 = 79,
    tim3_cc1 = 80,
    tim3_cc2 = 81,
    tim3_cc3 = 82,
    tim3_cc4 = 83,
    tim3_upd = 84,
    tim3_trg = 85,
    tim4_cc1 = 86,
    tim4_cc2 = 87,
    tim4_cc3 = 88,
    tim4_cc4 = 89,
    tim4_upd = 90,
    tim4_trg = 91,
    saes_out = 92,
    saes_in = 93,
    xspi1 = 94
};

pub const LpdmaTr2 = bitpack struct(u32) {
    reqsel: LpdmaReqsel = .adc1,
    reserved0: u2 = 0,
    swreq: bool = false,
    reserved1: u1 = 0,
    breq: bool = false,
    pfreq: bool = false,
    reserved2: u1 = 0,
    trigm: LpdmaTrigm = .block_level,
    trigsel: u6 = 0,
    reserved3: u2 = 0,
    trigpol: LpdmaTrigpol = .no_trigger,
    reserved4: u4 = 0,
    tcem: LpdmaTcem = .block_level,
};

pub const LpdmaLlr = bitpack struct(u32) {
    la: u16 = 0,
    ull: bool = false,
    reserved1: u10 = 0,
    uda: bool = false,
    usa: bool = false,
    ub1: bool = false,
    ut2: bool = false,
    ut1: bool = false,
};

pub const LpdmaChannel = extern struct {
    lbar: LpdmaLbar,
    reserved2: [2]u32,
    fcr: LpdmaFcr,
    sr: LpdmaSr,
    cr: LpdmaCr,
    reserved3: [10]u32,
    tr1: LpdmaTr1,
    tr2: LpdmaTr2,
    br1: u32,
    sar: u32,
    dar: u32,
    reserved4: [10]u32,
    llr: LpdmaLlr,

    pub fn initMemoryToPeripheral8(self: *volatile LpdmaChannel, peripheral_address: u32, reqsel: LpdmaReqsel) void {
        self.cr = LpdmaCr{.susp = false, .en = false};
        self.cr = LpdmaCr{.reset = true};
        self.cr = LpdmaCr{.tcie = true, .dteie = true};
        self.tr1 = LpdmaTr1{.sinc = true};
        self.tr2 = LpdmaTr2{.dreq = true, .reqsel = reqsel};
        self.dar = peripheral_address;
    }

    pub fn clearInterruptFlags(self: *volatile LpdmaChannel) void {
        self.fcr = LpdmaFcr{.dtef = true, .ulef = true, .usef = true, .suspf = true,
                            .tof = true, .htf = true, .tcf = true};
    }
    
    pub fn startTransferMemoryToPeripheral8(self: *volatile LpdmaChannel, data: []const u8) void {
        self.clearInterruptFlags();
        self.sar = @intFromPtr(&data[0]);
        self.br1 = data.len;
        self.cr.en = true;
    }
};

pub const Lpdma = extern struct {
    reserved0: u32,
    privcfgr: LpdmaPrivcfgr,
    rcfglockr: LpdmaRcfglockr,
    misr: LpdmaMisr,
    reserved1: [16]u32,
    channels: [8]LpdmaChannel
};

pub const lpdma1: *volatile Lpdma = @ptrFromInt(LPDMA1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x450, @sizeOf(Lpdma));
}
