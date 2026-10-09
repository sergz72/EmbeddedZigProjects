const sdram = @import("sdram");
const system_timer = @import("system_timer");

const FMC_BASE: usize = 0xA0000000;

pub const FMC_BANK1: usize = 0x60000000;
pub const FMC_BANK2: usize = 0x70000000;
pub const FMC_BANK3: usize = 0x80000000;
pub const FMC_BANK4: usize = 0x90000000;
pub const SDRAM_BANK1: usize = 0xC0000000;
pub const SDRAM_BANK2: usize = 0xD0000000;

pub const FmcBcr = packed struct(u32) {
    mbken: bool = false,
    muxen: bool = true,
    mtyp: u2 = 0,
    mwid: u2 = 0,
    faccen: bool = false,
    reserved: u1 = 0,
    bursten: bool = false,
    waitpol: bool = false,
    wrapmod: bool = false,
    waitcfg: bool = false,
    wren: bool = false,
    waiten: bool = false,
    extmod: bool = false,
    asyncwait: bool = false,
    cpsize: u3 = 0,
    cburstrw: bool = false,
    reserved2: u12 = 0
};

pub const FmcBtr = packed struct(u32) {
    addset: u4 = 0x0F,
    addhld: u4 = 0x0F,
    datast: u8 = 0xFF,
    burstrun: u4 = 0x0F,
    ckdiv: u4 = 0x0F,
    datlat: u4 = 0x0F,
    accmod: u2 = 0,
    reserved: u2 = 0
};

pub const FmcBwtrr = packed struct(u32) {
    addset: u4 = 0x0F,
    addhld: u4 = 0x0F,
    datast: u8 = 0xFF,
    burstrun: u4 = 0x0F,
    reserved: u8 = 0xFF,
    accmod: u2 = 0,
    reserved2: u2 = 0
};

pub const FmcBtcr = extern struct {
    bcr: FmcBcr,
    btr: FmcBtr
};

pub const FmcPcrPcr = packed struct(u32) {
    reserved: u1 = 0,
    pwaiten: bool = false,
    pbken: bool = false,
    ptyp: bool = true,
    pwid: u2 = 1,
    eccen: bool = false,
    reserved2: u2 = 0,
    tclr: u4 = 0,
    tar: u4 = 0,
    eccps: u3 = 0,
    reserved3: u12 = 0
};

pub const FmcPcrSr = packed struct(u32) {
    irs: bool = false,
    ils: bool = false,
    ifs: bool = false,
    iren: bool = false,
    ilen: bool = false,
    ifen: bool = false,
    fempt: bool = true,
    reserved: u25 = 0
};

pub const FmcPcrP = packed struct(u32) {
    set: u8 = 0xFC,
    wait: u8 = 0xFC,
    hold: u8 = 0xFC,
    hiz: u8 = 0xFC
};

pub const FmcPcr2 = extern struct {
    pcr: FmcPcrPcr,
    sr: FmcPcrSr,
    pmem: FmcPcrP,
    reserved: u32,
    pio: u32,
    eccr: u32,
    reserved2: [2]u32
};

pub const FmcPcr3 = extern struct {
    pcr: FmcPcrPcr,
    sr: FmcPcrSr,
    pmem: FmcPcrP,
    patt: FmcPcrP,
    reserved: u32,
    eccr: u32,
    reserved2: [2]u32
};

pub const FmcPcr4 = extern struct {
    pcr: FmcPcrPcr,
    sr: FmcPcrSr,
    pmem: FmcPcrP,
    patt: FmcPcrP,
    pio: FmcPcrP,
    reserved2: [3]u32
};

pub const FmcBwtr = extern struct {
    bwtr: FmcBwtrr,
    reserved: u32
};

pub const FmcSdclk = enum(u2) {
    disabled = 0,
    two_hclk_periods = 2,
    three_hclk_periods = 3
};

pub const FmcSdcr = packed struct(u32) {
    nc: sdram.SdramNc = ._8,
    nr: sdram.SdramNr = ._11,
    mwid: sdram.SdramMw = ._16,
    nb: bool = true,
    cas: sdram.SdramCasLatency = ._1,
    wp: bool = true,
    sdclk: FmcSdclk = .disabled,
    rburst: bool = false,
    rpipe: sdram.SdramPipe = ._0,
    reserved: u17 = 0
};

pub const FmcSdtr = packed struct(u32) {
    tmrd: sdram.SdramDelay = ._16,
    txsr: sdram.SdramDelay = ._16,
    tras: sdram.SdramDelay = ._16,
    trc: sdram.SdramDelay = ._16,
    twr: sdram.SdramDelay = ._16,
    trp: sdram.SdramDelay = ._16,
    trcd: sdram.SdramDelay = ._16,
    reserved: u4 = 0
};

pub const FmcSdcmrMode = enum(u3) {
    normal_mode = 0,
    clock_configuration_enable = 1,
    all_bank_precharge = 2,
    auto_refresh = 3,
    load_mode_register = 4,
    self_refresh = 5,
    power_down = 6
};

pub const FmcSdcmr = packed struct(u32) {
    mode: FmcSdcmrMode = .normal_mode,
    ctb2: bool = false,
    ctb1: bool = false,
    nrfs: sdram.SdramDelay = ._1,
    mrd: u13 = 0,
    reserved: u10 = 0
};

pub const FmcSdrtr = packed struct(u32) {
    cre: bool = false,
    count: u13 = 0,
    reie: bool = false,
    reserved: u17 = 0
};

pub const FsmcSdsrMode = enum(u2) {
    normal = 0,
    self_refresh = 1,
    power_down = 2,
    _
};

pub const FmcSdsr = packed struct(u32) {
    re: bool,
    modes1: FsmcSdsrMode,
    modes2: FsmcSdsrMode,
    busy: bool,
    reserved: u26
};

pub const SDRAMBank = enum(u1) {
    bank1 = 0,
    bank2 = 1
};

pub const FmcSdramInit = struct {
    bank: SDRAMBank,
    sdclk: FmcSdclk,
};

pub const Fmc = extern struct {
    btcr: [4]FmcBtcr,
    reserved: [16]u32,
    //0x60
    pcr2: FmcPcr2,
    pcr3: FmcPcr3,
    pcr4: FmcPcr4,
    reserved2: [17]u32,
    //0x104
    bwtr: [4]FmcBwtr,
    reserved3: [7]u32,
    //0x140
    sdcr: [2]FmcSdcr,
    sdtr: [2]FmcSdtr,
    sdcmr: FmcSdcmr,
    sdrtr: FmcSdrtr,
    sdsr: FmcSdsr,

    pub fn initSdram(self: *volatile Fmc, init: FmcSdramInit, settings: sdram.Sdram) void {
        const bank: usize = @intFromEnum(init.bank);
        const sdcr: FmcSdcr = .{
            .nc = settings.nc,
            .nr = settings.nr,
            .mwid = settings.mw,
            .nb = settings.four_banks,
            .cas = settings.cas_latency,
            .wp = false,
            .sdclk = .disabled,
            .rburst = settings.burst_read,
            .rpipe = settings.read_pipe,
        };
        const sdtr: FmcSdtr = .{
            .tmrd = settings.load_mode_register_to_active,
            .txsr = settings.exit_self_refresh_delay,
            .tras = settings.self_refresh_time,
            .trc = settings.row_cycle_delay,
            .twr = settings.recovery_delay,
            .trp = settings.row_precharge_delay,
            .trcd = settings.row_to_column_delay
        };
        if (init.bank == .bank2) {
            self.sdcr[0] = sdcr;
            self.sdtr[0] = sdtr;
        }
        self.sdcr[bank] = sdcr;
        self.sdtr[bank] = sdtr;
        self.sdramInitSequence();
    }

    fn sdramInitSequence(self: *volatile Fmc) void {
        _ = self;
        //todo
    }
};

pub const fmc: *volatile Fmc = @ptrFromInt(FMC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x15C, @sizeOf(Fmc));
}
