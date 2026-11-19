const DMAC_BASE = 0x4100A000;

pub const DmacTrigsrc = enum(u7) {
    disable = 0,
    rtc = 1,
    dsu_dcc0 = 2,
    dsu_dcc1 = 3,
    sercom0_rx = 4,
    sercom0_tx = 5,
    sercom1_rx = 6,
    sercom1_tx = 7,
    sercom2_rx = 8,
    sercom2_tx = 9,
    sercom3_rx = 10,
    sercom3_tx = 11,
    sercom4_rx = 12,
    sercom4_tx = 13,
    sercom5_rx = 14,
    sercom5_tx = 15,
    sercom6_rx = 0x10,
    sercom6_tx = 0x11,
    sercom7_rx = 0x12,
    sercom7_tx = 0x13,
    can0 = 0x14,
    can1 = 0x15,
    tcc0_ovf = 0x16,
    tcc0_mc0 = 0x17,
    tcc0_mc1 = 0x18,
    tcc0_mc2 = 0x19,
    tcc0_mc3 = 0x1A,
    tcc0_mc4 = 0x1B,
    tcc0_mc5 = 0x1C,
    tcc1_ovf = 0x1D,
    tcc1_mc0 = 0x1E,
    tcc1_mc1 = 0x1F,
    tcc1_mc2 = 0x20,
    tcc1_mc3 = 0x21,
    tcc2_ovf = 0x22,
    tcc2_mc0 = 0x23,
    tcc2_mc1 = 0x24,
    tcc2_mc2 = 0x25,
    tcc3_ovf = 0x26,
    tcc3_mc0 = 0x27,
    tcc3_mc1 = 0x28,
    tcc4_ovf = 0x29,
    tcc4_mc0 = 0x2A,
    tcc4_mc1 = 0x2B,
    tc0_ovf  = 0x2C,
    tc0_mc0  = 0x2D,
    tc0_mc1  = 0x2E,
    tc1_ovf  = 0x2F,
    tc1_mc0  = 0x30,
    tc1_mc1  = 0x31,
    tc2_ovf  = 0x32,
    tc2_mc0  = 0x33,
    tc2_mc1  = 0x34,
    tc3_ovf  = 0x35,
    tc3_mc0  = 0x36,
    tc3_mc1  = 0x37,
    tc4_ovf  = 0x38,
    tc4_mc0  = 0x39,
    tc4_mc1  = 0x3A,
    tc5_ovf  = 0x3B,
    tc5_mc0  = 0x3C,
    tc5_mc1  = 0x3D,
    tc6_ovf  = 0x3E,
    tc6_mc0  = 0x3F,
    tc6_mc1  = 0x40,
    tc7_ovf  = 0x41,
    tc7_mc0  = 0x42,
    tc7_mc1  = 0x43,
    adc0_resrdy = 0x44,
    adc0_seq = 0x45,
    adc1_resrdy = 0x46,
    adc1_seq = 0x47,
    dac_empty0 = 0x48,
    dac_empty1 = 0x49,
    dac_resrdy0 = 0x4A,
    dac_resrdy1 = 0x4B,
    i2s_rx0 = 0x4C,
    i2s_rx1 = 0x4D,
    i2s_tx0 = 0x4E,
    i2s_tx1 = 0x4F,
    pcc_rx = 0x50,
    aes_wr = 0x51,
    aes_rd = 0x52,
    qspi_rx = 0x53,
    qspi_tx = 0x54
};

pub const DmacTrigact = enum(u2) {
    block = 0,
    burst = 2,
    transaction = 3,
};

pub const DmacThreshold = enum(u2) {
    _1beat = 0,
    _2beats = 1,
    _4beats = 2,
    _8beats = 3,
};

pub const DmacChctrla = bitpack struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    reserved0: u4 = 0,
    runstdby: bool = false,
    reserved1: u1 = 0,
    trigsrc: DmacTrigsrc = .disable,
    reserved2: u5 = 0,
    trigact: DmacTrigact = .block,
    reserved3: u2 = 0,
    burstlen: u4 = 0,
    threshold: DmacThreshold = ._1beat,
    reserved4: u2 = 0,
};

pub const DmacCmd = enum(u8) {
    noact = 0,
    suspen = 1,
    resum = 2,
};

pub const DmacChPrilvl = enum(u8) {
    lvl0 = 0,
    lvl1 = 1,
    lvl2 = 2,
    lvl3 = 3,
};

pub const DmacEvact = enum(u3) {
    noact = 0,
    trig = 1,
    ctrig = 2,
    cblock = 3,
    suspen = 4,
    resum = 5,
    sskip = 6,
    incpri = 7,
};

pub const DmacEvomode = enum(u2) {
    default = 0,
    trigact = 1,
};

pub const DmacChevctrl = bitpack struct(u8) {
    evact: DmacEvact = .noact,
    reserved0: u1 = 0,
    evomode: DmacEvomode = .default,
    evie: bool = false,
    evoe: bool = false,
};

pub const DmacChInt = bitpack struct(u8) {
    terr: bool = false,
    tcmpl: bool = false,
    susp: bool = false,
    reserved0: u5 = 0,
};

pub const DmacChstatus = bitpack struct(u8) {
    pend: bool = false,
    busy: bool = false,
    ferr: bool = false,
    crcerr: bool = false,
    reserved0: u4 = 0,
};

pub const DmacChannel = extern struct {
    ctrla: DmacChctrla,
    ctrlb: DmacCmd,
    prilvl: DmacChPrilvl,
    evctrl: DmacChevctrl,
    reserved0: [5]u8,
    intenclr: DmacChInt,
    intenset: DmacChInt,
    intflag: DmacChInt,
    status: DmacChstatus,
};

pub const DmacCtrl = bitpack struct(u16) {
    swrst: bool = false,
    dmaenable: bool = false,
    reserved0: u6 = 0,
    lvlen0: bool = false,
    lvlen1: bool = false,
    lvlen2: bool = false,
    lvlen3: bool = false,
    reserved1: u4 = 0,
};

pub const DmacBeatsize = enum(u2) {
    byte = 0,
    hword = 1,
    word = 2,
};

pub const DmacCrcpoly = enum(u2) {
    crc16 = 0,
    crc32 = 1,
};

pub const DmacCrcsrc = enum(u6) {
    disable = 0,
    io = 1,
    chn0 = 32,
    chn1 = 33,
    chn2 = 34,
    chn3 = 35,
    chn4 = 36,
    chn5 = 37,
    chn6 = 38,
    chn7 = 39,
    chn8 = 40,
    chn9 = 41,
    chn10 = 42,
    chn11 = 43,
    chn12 = 44,
    chn13 = 45,
    chn14 = 46,
    chn15 = 47,
    chn16 = 48,
    chn17 = 49,
    chn18 = 50,
    chn19 = 51,
    chn20 = 52,
    chn21 = 53,
    chn22 = 54,
    chn23 = 55,
    chn24 = 56,
    chn25 = 57,
    chn26 = 58,
    chn27 = 59,
    chn28 = 60,
    chn29 = 61,
    chn30 = 62,
    chn31 = 63,
};

pub const DmacCrcmode = enum(u2) {
    default = 0,
    crcmon = 2,
    crcgen = 3,
};

pub const DmacCrcctrl = bitpack struct(u16) {
    crcbeatsize: DmacBeatsize = .byte,
    crcpoly: DmacCrcpoly = .crc16,
    reserved0: u4 = 0,
    crcsrc: DmacCrcsrc = .disable,
    crcmode: DmacCrcmode = .default,
};

pub const DmacCrcstatus = bitpack struct(u8) {
    crcbusy: bool = false,
    crczero: bool = false,
    crcerr: bool = false,
    reserved0: u5 = 0,
};

pub const DmacDbgctrl = bitpack struct(u8) {
    dbgrun: bool = false,
    reserved0: u7 = 0,
};

pub const DmacQos = enum(u2) {
    regular = 0,
    shortage = 1,
    sensitive = 2,
    critical = 3,
};

pub const DmacPrictrl0 = bitpack struct(u32) {
    lvlpri0: u5 = 0,
    qos0: DmacQos = .sensitive,
    rrlvlen0: bool = false,
    lvlpri1: u5 = 0,
    qos1: DmacQos = .sensitive,
    rrlvlen1: bool = false,
    lvlpri2: u5 = 0,
    qos2: DmacQos = .sensitive,
    rrlvlen2: bool = false,
    lvlpri3: u5 = 0,
    qos3: DmacQos = .sensitive,
    rrlvlen3: bool = false,
};

pub const DmacIntpend = bitpack struct(u16) {
    id: u5 = 0,
    reserved0: u3 = 0,
    terr: bool = false,
    tcmpl: bool = false,
    susp: bool = false,
    reserved1: u1 = 0,
    crcerr: bool = false,
    ferr: bool = false,
    busy: bool = false,
    pend: bool = false,
};

pub const DmacActive = bitpack struct(u32) {
    lvlex0: bool,
    lvlex1: bool,
    lvlex2: bool,
    lvlex3: bool,
    reserved0: u4,
    id: u5,
    reserved1: u2,
    abusy: bool,
    btcnt: u16,
};

pub const DmacStepSize = enum(u3) {
    x1 = 0,
    x2 = 1,
    x4 = 2,
    x8 = 3,
    x16 = 4,
    x32 = 5,
    x64 = 6,
    x128 = 7,
};

pub const DmaBlockact = enum(u2) {
    noact = 0,
    int = 1,
    suspen = 2,
    both = 3,
};

pub const DmacEvosel = enum(u2) {
    disable = 0,
    block = 1,
    beat = 3,
};

pub const DmacBtctrl = bitpack struct(u16) {
    valid: bool = false,
    evosel: DmacEvosel = .disable,
    blockact: DmaBlockact = .noact,
    reserved: u3 = 0,
    beatsize: DmacBeatsize = .byte,
    srcinc: bool = false,
    dstinc: bool = false,
    stepsel: bool = false,
    stepsize: DmacStepSize = .x1
};

pub const DmacDescriptor = extern struct {
    btctrl: DmacBtctrl,
    btcnt: u16,
    srcaddr: u32,
    dstaddr: u32,
    descaddr: u32,
};

pub const DmaChannelInit = struct {
    beatsize: DmacBeatsize,
    srcinc: bool,
    dstinc: bool,
    length: u16,
    srcaddr: usize,
    dstaddr: usize,
    trigsrc: DmacTrigsrc,
};

pub const Dmac = extern struct {
    ctrl: DmacCtrl,
    crcctrl: DmacCrcctrl,
    crcdatain: u32,
    crcchksum: u32,
    crcstatus: DmacCrcstatus,
    dbgctrl: DmacDbgctrl,
    reserved0: [2]u8,
    swtrigctrl: u32,
    prictrl0: DmacPrictrl0,
    reserved1: [8]u8,
    intpend: DmacIntpend,
    reserved2: [2]u8,
    intstatus: u32,
    busych: u32,
    pendch: u32,
    active: DmacActive,
    baseaddr: u32,
    wrbaddr: u32,
    reserved3: u32,
    ch: [32]DmacChannel,

    pub fn init(self: *volatile Dmac) void {
        self.ctrl = DmacCtrl{};
        while (self.ctrl.dmaenable) {
            asm volatile ("nop");
        }
        self.ctrl = DmacCtrl{.swrst = true};
        while (self.ctrl.swrst) {
            asm volatile ("nop");
        }
        self.baseaddr = @intFromPtr(&descriptors[0]);
        self.wrbaddr = @intFromPtr(&writeback[0]);
        self.ctrl = DmacCtrl{.dmaenable = true, .lvlen0 = true};
    }

    pub fn channelSetup(self: *volatile Dmac, channel: u5, init_data: *const DmaChannelInit) void {
        const beatsize: usize = switch (init_data.beatsize) {
            .byte => 1,
            .hword => 2,
            .word => 4,
        };
        const len32 = @as(usize, init_data.length);
        const srcaddr = if (init_data.srcinc) init_data.srcaddr + len32 * beatsize else init_data.srcaddr;
        const dstaddr = if (init_data.dstinc) init_data.dstaddr + len32 * beatsize else init_data.dstaddr;
        descriptors[channel] = DmacDescriptor{
            .btctrl = DmacBtctrl{
                .beatsize = init_data.beatsize,
                .srcinc = init_data.srcinc,
                .dstinc = init_data.dstinc,
                .valid = true,
                .blockact = .noact,
            },
            .btcnt = init_data.length,
            .srcaddr = srcaddr,
            .dstaddr = dstaddr,
            .descaddr = 0
        };
        const ch = &self.ch[channel];
        ch.ctrla = DmacChctrla{.trigact = .block, .trigsrc = init_data.trigsrc};
        ch.intflag = DmacChInt{.tcmpl = true};
        ch.ctrla.enable = true;
    }

    pub fn start(self: *volatile Dmac, channel: u5) void {
        self.swtrigctrl = @as(u32, 1) << channel;
    }

    pub fn waitTransferComplete(self: *volatile Dmac, channel: u5) void {
        const ch = &self.ch[channel];
        while (!ch.intflag.tcmpl) {
            asm volatile ("nop");
        }
    }

    fn crcInit(self: *volatile Dmac, src: DmacCrcsrc, poly: DmacCrcpoly, beat_size: DmacBeatsize) void {
        self.crcctrl = DmacCrcctrl{
            .crcbeatsize = .byte,
            .crcpoly = .crc16,
            .crcsrc = .disable,
            .crcmode = .default,
        };
        self.crcchksum = 0xFFFFFFFF;
        self.crcctrl = DmacCrcctrl{
            .crcbeatsize = beat_size,
            .crcpoly = poly,
            .crcsrc = src,
            .crcmode = .default,
        };
    }

    pub fn crc32(self: *volatile Dmac, src: DmacCrcsrc, channel: u5, data: []const u8) u32 {
        self.crcInit(src, .crc32, .byte);
        var dummy: u8 = undefined;
        const init_data = &DmaChannelInit{
            .trigsrc = .disable,
            .beatsize = .byte,
            .srcinc = true,
            .dstinc = false,
            .length = @truncate(data.len),
            .srcaddr = @intFromPtr(data.ptr),
            .dstaddr = @intFromPtr(&dummy),
        };
        self.channelSetup(channel, init_data);
        self.start(channel);
        self.waitTransferComplete(channel);
        return self.crcchksum;
    }
};

var descriptors: [32]DmacDescriptor align(16) = undefined;
var writeback: [32]DmacDescriptor align(16) = undefined;

pub const dmac: *volatile Dmac = @ptrFromInt(DMAC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x240, @sizeOf(Dmac));
}
