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
    reqsel: u8 = 0,
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

    pub fn initMemoryToPeripheral8(self: *volatile GpdmaChannel, peripheral_address: u32, reqsel: u8) void {
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
