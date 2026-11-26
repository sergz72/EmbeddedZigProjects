const DMAC_BASE = 0x41004800;

pub const DmacCtrl = bitpack struct(u16) {
    swrst: bool = false,
    dmaenable: bool = false,
    crcenable: bool = false,
    reserved0: u5 = 0,
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
    noact = 0,
    io = 1,
};

pub const DmacCrcctrl = bitpack struct(u16) {
    crcbeatsize: DmacBeatsize = .byte,
    crcpoly: DmacCrcpoly = .crc16,
    reserved0: u4 = 0,
    crcsrc: DmacCrcsrc = .noact,
    reserved1: u2 = 0,
};

pub const DmacCrcstatus = bitpack struct(u8) {
    crcbusy: bool = false,
    crczero: bool = false,
    reserved0: u6 = 0,
};

pub const DmacDbgctrl = bitpack struct(u8) {
    dbgrun: bool = false,
    reserved0: u7 = 0,
};

pub const DmacQos = enum(u2) {
    disable = 0,
    low = 1,
    medium = 2,
    high = 3,
};

pub const DmacQosctrl = bitpack struct(u8) {
    wrbqos: DmacQos = .low,
    fqos: DmacQos = .low,
    dqos: DmacQos = .low,
    reserved0: u2 = 0,
};

pub const DmacPrictrl0 = bitpack struct(u32) {
    lvlpri0: u4 = 0,
    reserved0: u3 = 0,
    rrlvlen0: bool = false,
    lvlpri1: u4 = 0,
    reserved1: u3 = 0,
    rrlvlen1: bool = false,
    lvlpri2: u4 = 0,
    reserved2: u3 = 0,
    rrlvlen2: bool = false,
    lvlpri3: u4 = 0,
    reserved3: u3 = 0,
    rrlvlen3: bool = false,
};

pub const DmacIntpend = bitpack struct(u16) {
    id: u4 = 0,
    reserved0: u4 = 0,
    terr: bool = false,
    tcmpl: bool = false,
    susp: bool = false,
    reserved1: u2 = 0,
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

pub const DmacChctrla = bitpack struct(u8) {
    swrst: bool = false,
    enable: bool = false,
    reserved0: u6 = 0,
};

pub const DmacEvact = enum(u3) {
    noact = 0,
    trig = 1,
    ctrig = 2,
    cblock = 3,
    suspen = 4,
    resum = 5,
    sskip = 6,
};

pub const DmacTrigsrc = enum(u6) {
    disable = 0,
};

pub const DmacTrigact = enum(u2) {
    block = 0,
    beat = 2,
    transaction = 3,
};

pub const DmacCmd = enum(u2) {
    noact = 0,
    suspen = 1,
    resum = 2,
};

pub const DmacChctrlb = bitpack struct(u32) {
    evact: DmacEvact = .noact,
    evie: bool = false,
    evoe: bool = false,
    lvl: u2 = 0,
    reserved0: u1 = 0,
    trigsrc: DmacTrigsrc = .disable,
    reserved1: u8 = 0,
    trigact: DmacTrigact = .block,
    cmd: DmacCmd = .noact,
    reserved2: u6 = 0,
};

pub const DmacChInt = bitpack struct(u8) {
    terr: bool = false,
    tcmpl: bool = false,
    susp: bool = false,
    reserved0: u5 = 0,
};

pub const DmacChstatus = bitpack struct(u8) {
    pend: bool,
    busy: bool,
    ferr: bool,
    reserved0: u5,
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
    trigact: DmacTrigact,
};

pub const Dmac = extern struct {
    ctrl: DmacCtrl,
    crcctrl: DmacCrcctrl,
    crcdatain: u32,
    crcchksum: u32,
    crcstatus: DmacCrcstatus,
    dbgctrl: DmacDbgctrl,
    qosctrl: DmacQosctrl,
    reserved0: [1]u8,
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
    reserved3: [3]u8,
    chid: u8,
    chctrla: DmacChctrla,
    reserved4: [3]u8,
    chctrlb: DmacChctrlb,
    reserved5: [4]u8,
    chintenclr: DmacChInt,
    chintenset: DmacChInt,
    chintflag: DmacChInt,
    chstatus: DmacChstatus,
};

pub fn init() void {
    dmac.ctrl = DmacCtrl{};
    while (dmac.ctrl.dmaenable) {
        asm volatile ("nop");
    }
    dmac.ctrl = DmacCtrl{.swrst = true};
    while (dmac.ctrl.swrst) {
        asm volatile ("nop");
    }
    dmac.baseaddr = @intFromPtr(&descriptors[0]);
    dmac.wrbaddr = @intFromPtr(&writeback[0]);
    dmac.ctrl = DmacCtrl{.dmaenable = true, .lvlen0 = true};
}

pub fn buildAddress(address: usize, inc: bool, length: usize, beat_size: DmacBeatsize) usize {
    const beatsize: usize = switch (beat_size) {
        .byte => 1,
        .hword => 2,
        .word => 4,
    };
    return if (inc) address + length * beatsize else address;
}

pub fn channelSetup(channel: u4, init_data: *const DmaChannelInit) void {
    const len32 = @as(usize, init_data.length);
    const srcaddr = buildAddress(init_data.srcaddr, init_data.srcinc, len32, init_data.beatsize);
    const dstaddr = buildAddress(init_data.dstaddr, init_data.dstinc, len32, init_data.beatsize);
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
    dmac.chid = channel;
    dmac.chctrla = DmacChctrla{.trigact = init_data.trigact, .trigsrc = init_data.trigsrc};
    dmac.chintflag = DmacChInt{.tcmpl = true};
}

pub fn swStart(channel: u5) void {
    dmac.swtrigctrl = @as(u32, 1) << channel;
}

pub fn waitTransferComplete(channel: u5) void {
    dmac.chid = channel;
    while (!dmac.chintflag.tcmpl) {
        asm volatile ("nop");
    }
}

fn crcInit(src: DmacCrcsrc, poly: DmacCrcpoly, beat_size: DmacBeatsize) void {
    dmac.crcctrl = DmacCrcctrl{
        .crcbeatsize = .byte,
        .crcpoly = .crc16,
        .crcsrc = .disable,
        .crcmode = .default,
    };
    dmac.crcchksum = 0xFFFFFFFF;
    dmac.crcctrl = DmacCrcctrl{
        .crcbeatsize = beat_size,
        .crcpoly = poly,
        .crcsrc = src,
        .crcmode = .default,
    };
}

pub fn crc32(src: DmacCrcsrc, channel: u5, data: []const u8) u32 {
    crcInit(src, .crc32, .byte);
    var dummy: u8 = undefined;
    const init_data = &DmaChannelInit{
        .trigsrc = .disable,
        .beatsize = .byte,
        .srcinc = true,
        .dstinc = false,
        .length = @truncate(data.len),
        .srcaddr = @intFromPtr(data.ptr),
        .dstaddr = @intFromPtr(&dummy),
        .trigact = .block,
    };
    channelSetup(channel, init_data);
    dmac.chid = channel;
    dmac.chctrla = DmacChctrla{.enable = true};
    swStart(channel);
    waitTransferComplete(channel);
    return dmac.crcchksum;
}

pub fn initMemoryToPeripheral8(channel: u5, peripheral_address: u32, src: DmacTrigsrc) void {
    const init_data = &DmaChannelInit{
        .trigsrc = src,
        .beatsize = .byte,
        .srcinc = true,
        .dstinc = false,
        .length = 0,
        .srcaddr = 0,
        .dstaddr = peripheral_address,
        .trigact = .burst,
    };
    channelSetup(channel, init_data);
    dmac.chid = channel;
    dmac.chintenset = DmacChInt{.tcmpl = true, .terr = true};
}

pub fn clearInterruptFlags(channel: u5) void {
    dmac.chid = channel;
    dmac.chintflag = DmacChInt{.terr = true, .tcmpl = true, .susp = true};
}

pub fn startTransferMemoryToPeripheral8(channel: u5, data: []const u8) void {
    var d = &descriptors[channel];
    d.btcnt = @truncate(data.len);
    d.srcaddr = buildAddress(@intFromPtr(data.ptr), true, data.len, .byte);
    d.btctrl = DmacBtctrl{
        .beatsize = .byte,
        .srcinc = true,
        .dstinc = false,
        .valid = true,
        .blockact = .noact,
    };
    dmac.chid = channel;
    dmac.chctrla = DmacChctrla{.enable = true};
}

var descriptors: [32]DmacDescriptor align(16) = undefined;
var writeback: [32]DmacDescriptor align(16) = undefined;

pub const dmac: *volatile Dmac = @ptrFromInt(DMAC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x50, @sizeOf(Dmac));
}
