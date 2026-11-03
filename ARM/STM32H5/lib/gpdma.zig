const GPDMA1_BASE = 0x40020000;
const GPDMA2_BASE = 0x40021000;

pub const GpdmaLbar = packed struct(u32) {
    reserved0: u16 = 0,
    lba: u16 = 0,
};

pub const GpdmaFcr = packed struct(u32) {
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

pub const GpdmaSr = packed struct(u32) {
    idlef: bool,
    reserved0: u7,
    tcf: bool,
    htf: bool,
    dtef: bool,
    ulef: bool,
    usef: bool,
    suspf: bool,
    tof: bool,
    reserved1: u1,
    fifol: u8,
    reserved2: u8
};

pub const GpdmaPrio = enum(u2) {
    low = 0,
    mid = 1,
    high = 2,
    very_high = 3
};

pub const GpdmaCr = packed struct(u32) {
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
    lap: bool = false,
    reserved2: u4 = 0,
    prio: GpdmaPrio = .low,
    reserved3: u8 = 0,
};

pub const GpdmaDwLog2 = enum(u2) {
    byte = 0,
    half_word = 1,
    word = 2
};

pub const GpdmaTr1 = packed struct(u32) {
    sdw_log2: GpdmaDwLog2 = .byte,
    reserved0: u1 = 0,
    sinc: bool = false,
    sbl_1: u6 = 0,
    reserved1: u1 = 0,
    pam: u2 = 0,
    sbx: bool = false,
    sap: bool = false,
    ssec: bool = false,
    ddw_log2: GpdmaDwLog2 = .byte,
    reserved2: u1 = 0,
    dinc: bool = false,
    dbl_1: u6 = 0,
    dbx: bool = false,
    dhx: bool = false,
    reserved3: u2 = 0,
    dap: bool = false,
    dsec: bool = false,
};

pub const Trigpol = enum(u2) {
    no_trigger = 0,
    rising_edge = 1,
    falling_edge = 2
};

pub const GpdmaTr2 = packed struct(u32) {
    reqsel: GpdmaReqsel = .adc1,
    reserved0: u1 = 0,
    swreq: bool = false,
    dreq: bool = false,
    breq: bool = false,
    pfreq: bool = false,
    reserved1: u1 = 0,
    trigm: u2 = 0,
    trigsel: u6 = 0,
    reserved2: u2 = 0,
    trigpol: Trigpol = .no_trigger,
    reserved3: u4 = 0,
    tcem: u2 = 0
};

pub const GpdmaLlr = packed struct(u32) {
    reserved0: u2 = 0,
    la: u14 = 0,
    ull: bool = false,
    reserved1: u8 = 0,
    ub2: bool = false,
    ut3: bool = false,
    uda: bool = false,
    usa: bool = false,
    ub1: bool = false,
    ut2: bool = false,
    ut1: bool = false,
};

pub const GpdmaBr1 = packed struct(u32) {
    bndt: u16 = 0,
    brc: u11 = 0,
    reserved0: u1 = 0,
    sdec: bool = false,
    ddec: bool = false,
    brsdec: bool = false,
    brddec: bool = false,
};

pub const GpdmaTr3 = packed struct(u32) {
    sao: u13 = 0,
    reserved0: u3 = 0,
    dao: u13 = 0,
    reserved1: u3 = 0,
};

pub const GpdmaBr2 = packed struct(u32) {
    brsao: u16 = 0,
    brdao: u16 = 0,
};

pub const GpdmaReqsel = enum(u8) {
    adc1 = 0,
    adc2 = 1,
    dac1_ch1 = 2,
    dac1_ch2 = 3,
    tim6_upd = 4,
    tim7_upd = 5,
    spi1_rx = 6,
    spi1_tx = 7,
    spi2_rx = 8,
    spi2_tx = 9,
    spi3_rx = 10,
    spi3_tx = 11,
    i2c1_rx = 12,
    i2c1_tx = 13,
    i2c2_rx = 15,
    i2c2_tx = 16,
    i2c3_rx = 18,
    i2c3_tx = 19,
    usart1_rx = 21,
    usart1_tx = 22,
    usart2_rx = 23,
    usart2_tx = 24,
    usart3_rx = 25,
    usart3_tx = 26,
    uart4_rx = 27,
    uart4_tx = 28,
    uart5_rx = 29,
    uart5_tx = 30,
    usart6_rx = 31,
    usart6_tx = 32,
    uart7_rx = 33,
    uart7_tx = 34,
    uart8_rx = 35,
    uart8_tx = 36,
    uart9_rx = 37,
    uart9_tx = 38,
    uart10_rx = 39,
    uart10_tx = 40,
    uart11_rx = 41,
    uart11_tx = 42,
    usart12_rx = 43,
    usart12_tx = 44,
    lpuart1_rx = 45,
    lpuart1_tx = 46,
    spi4_rx = 47,
    spi4_tx = 48,
    spi5_rx = 49,
    spi5_tx = 50,
    spi6_rx = 51,
    spi6_tx = 52,
    sai1_a = 53,
    sai1_b = 54,
    sai2_a = 55,
    sai2_b = 56,
    ospi1 = 57,
    tim1_cc1 = 58,
    tim1_cc2 = 59,
    tim1_cc3 = 60,
    tim1_cc4 = 61,
    tim1_upd = 62,
    tim1_trg = 63,
    tim1_com = 64,
    tim8_cc1 = 65,
    tim8_cc2 = 66,
    tim8_cc3 = 67,
    tim8_cc4 = 68,
    tim8_upd = 69,
    tim8_trg = 70,
    tim8_com = 71,
    tim2_cc1 = 72,
    tim2_cc2 = 73,
    tim2_cc3 = 74,
    tim2_cc4 = 75,
    tim2_upd = 76,
    tim3_cc1 = 77,
    tim3_cc2 = 78,
    tim3_cc3 = 79,
    tim3_cc4 = 80,
    tim3_upd = 81,
    tim3_trg = 82,
    tim4_cc1 = 83,
    tim4_cc2 = 84,
    tim4_cc3 = 85,
    tim4_cc4 = 86,
    tim4_upd = 87,
    tim5_cc1 = 88,
    tim5_cc2 = 89,
    tim5_cc3 = 90,
    tim5_cc4 = 91,
    tim5_upd = 92,
    tim5_trg = 93,
    tim15_cc1 = 94,
    tim15_upd = 95,
    tim15_trg = 96,
    tim15_com = 97,
    tim16_cc1 = 98,
    tim16_upd = 99,
    tim17_cc1 = 100,
    tim17_upd = 101,
    lptim1_ic1 = 102,
    lptim1_ic2 = 103,
    lptim1_ue = 104,
    lptim2_ic1 = 105,
    lptim2_ic2 = 106,
    lptim2_ue = 107,
    dcmi_or_pssi = 108,
    aes_out = 109,
    aes_in = 110,
    hash_in = 111,
    upcd1_rx = 112,
    upcd1_tx = 113,
    cordic_read = 114,
    cordic_write = 115,
    fmac_read = 116,
    fmac_write = 117,
    saea_out = 118,
    saea_in = 119,
    i3c1_rx = 120,
    i3c1_tx = 121,
    i3c1_tc = 122,
    i3c1_rst = 123,
    i2c4_rx = 124,
    i2c4_tx = 125,
    lptim3_ic1 = 127,
    lptim3_ic2 = 128,
    lptim3_ue = 129,
    lptim5_ic1 = 130,
    lptim5_ic2 = 131,
    lptim5_ue = 132,
    lptim6_ic1 = 133,
    lptim6_ic2 = 134,
    lptim6_ue = 135,
    i3c2_rx = 136,
    i3c2_tx = 137,
    i3c2_tc = 138,
    i3c2_rs = 139
};

pub const GpdmaChannel = extern struct {
    lbar: GpdmaLbar,
    reserved1: [2]u32,
    fcr: GpdmaFcr,
    sr: GpdmaSr,
    cr: GpdmaCr,
    reserved2: [10]u32,
    tr1: GpdmaTr1,
    tr2: GpdmaTr2,
    br1: GpdmaBr1,
    sar: u32,
    dar: u32,
    tr3: GpdmaTr3,
    br2: GpdmaBr2,
    reserved24: [8]u32,
    llr: GpdmaLlr,

    pub fn initMemoryToPeripheral8(self: *volatile GpdmaChannel, peripheral_address: u32, reqsel: GpdmaReqsel) void {
        self.cr = GpdmaCr{.susp = false, .en = false};
        self.cr = GpdmaCr{.reset = true};
        self.cr = GpdmaCr{.tcie = true, .dteie = true};
        self.tr1 = GpdmaTr1{.sinc = true};
        self.tr2 = GpdmaTr2{.dreq = true, .reqsel = reqsel};
        self.dar = peripheral_address;
    }

    pub fn clearInterruptFlags(self: *volatile GpdmaChannel) void {
        self.fcr = GpdmaFcr{.dtef = true, .ulef = true, .usef = true, .suspf = true,
                            .tof = true, .htf = true, .tcf = true};
    }
    pub fn startTransferMemoryToPeripheral8(self: *volatile GpdmaChannel, data: []const u8) void {
        self.clearInterruptFlags();
        self.sar = @intFromPtr(&data[0]);
        self.br1 = GpdmaBr1{.bndt = @truncate(data.len)};
        self.cr.en = true;
    }
};

pub const Gpdma = extern struct {
    seccfgr: u32,
    privcfgr: u32,
    rcfglockr: u32,
    misr: u32,
    smisr: u32,
    reserved0: [15]u32,
    channels: [8]GpdmaChannel,
};

pub const gpdma1: *volatile Gpdma = @ptrFromInt(GPDMA1_BASE);
pub const gpdma2: *volatile Gpdma = @ptrFromInt(GPDMA2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x450, @sizeOf(Gpdma));
}
