const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const TIMA0_BASE: usize = 0x40860000 + 0x400;
const TIMA1_BASE: usize = 0x40862000 + 0x400;
const TIMG0_BASE: usize = 0x40084000 + 0x400;
const TIMG12_BASE: usize = 0x40870000 + 0x400;
const TIMG6_BASE: usize = 0x40868000 + 0x400;
const TIMG7_BASE: usize = 0x4086A000 + 0x400;
const TIMG8_BASE: usize = 0x40090000 + 0x400;

pub const GptimerCountMode = enum(u2) {
    down = 0,
    updown = 1,
    up = 2
};

pub const GptimerCvae = enum(u2) {
    load = 0,
    unchanged = 1,
    zero = 2
};

pub const GptimerRepeat = enum(u3) {
    do_not_advance_following_zero_event = 0,
    continue_to_advance_following_zero_event = 1,
    continue_to_advance_following_zero_event_no_debug = 3,
};

pub const GptimerCtrCtl = packed struct(u32) {
    en: bool = false,
    repeat: GptimerRepeat = .do_not_advance_following_zero_event,
    cm: GptimerCountMode = .down,
    reserved: u1 = 0,
    clc: u3 = 7,
    cac: u3 = 7,
    czc: u3 = 7,
    reserved2: u1 = 0,
    drb: bool = false,
    fb: bool = false,
    frb: bool = false,
    reserved3: u3 = 0,
    slzerznez: bool = false,
    plen: bool = false,
    reserved4: u3 = 0,
    cvae: GptimerCvae = .load,
    reserved5: u2 = 0
};

pub const GptimerCCCtl = packed struct(u32) {
    ccond: u3 = 0,
    reserved: u1 = 0,
    acond: u3 = 0,
    reserved2: u1 = 0,
    lcond: u3 = 0,
    reserved3: u1 = 0,
    zcond: u3 = 0,
    reserved4: u2 = 0,
    coc: bool = false,
    ccupd: u3 = 0,
    reserved5: u1 = 0,
    cc2selu: u3 = 0,
    scerznez: bool = false,
    ccactupd: u3 = 0,
    cc2seld: u3 = 0
};

pub const GptimerCounterregs = extern struct {
    ctr: u32,
    ctrctl: GptimerCtrCtl,
    load: u32,
    reserved0: u32,
    cc: [6]u32,
    reserved1: [2]u32,
    ccctl: [6]GptimerCCCtl,
    reserved2: [2]u32,
    octl: [4]u32,
    reserved3: [4]u32,
    ccact: [4]u32,
    ifctl: [4]u32,
    reserved4: [4]u32,
    pl: u32,
    dbctl: u32,
    reserved5: [2]u32,
    tsel: u32,
    rc: u32,
    rcld: u32,
    qdir: u32,
    reserved6: [4]u32,
    fctl: u32,
    fifctl: u32,
};

pub const GptimerCommonregs = extern struct {
    ccpd: u32,
    odis: u32,
    cclkctl: u32,
    cps: u32,
    cpsv: u32,
    cttrigctl: u32,
    reserved0: u32,
    cttrig: u32,
    fsctl: u32,
    gctl: u32,
};

pub const GptimerIntIMask = packed struct(u32) {
    z: bool = false,
    l: bool = false,
    reserved: u2 = 0,
    ccd0: bool = false,
    ccd1: bool = false,
    ccd2: bool = false,
    ccd3: bool = false,
    ccu0: bool = false,
    ccu1: bool = false,
    ccu2: bool = false,
    ccu3: bool = false,
    ccd4: bool = false,
    ccd5: bool = false,
    ccu4: bool = false,
    ccu5: bool = false,
    reserved2: u8 = 0,
    f: bool = false,
    tov: bool = false,
    repc: bool = false,
    dc: bool = false,
    queierr: bool = false,
    reserved3: u3 = 0
};

pub const GptimerIntIIdx = enum(u32) {
    no_interrupt = 0,
    zero_event = 1,
    load_event = 2,
    ccd0 = 5,
    ccd1 = 6,
    ccd2 = 7,
    ccd3 = 8,
    ccu0 = 9,
    ccu1 = 10,
    ccu2 = 11,
    ccu3 = 12,
    ccd4 = 13,
    ccd5 = 14,
    ccu4 = 15,
    ccu5 = 16,
    fault = 0x19,
    tov = 0x1A,
    repc = 0x1B,
    dc = 0x1C,
    qeierr = 0x1D
};

pub const GptimerInt = extern struct {
    iidx: GptimerIntIIdx,
    reserved0: u32,
    imask: GptimerIntIMask,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const GptimerGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const Gptimer = extern struct {
    fsub_0: u32,
    fsub_1: u32,
    reserved1: [15]u32,
    fpub_0: u32,
    fpub_1: u32,
    reserved2: [237]u32,
    gprcm: GptimerGprcm,
    reserved3: [506]u32,
    clkdiv: common.ClkDiv,
    reserved4: u32,
    clksel: common.Clksel3,
    reserved5: [3]u32,
    pdbgctl: u32,
    reserved6: u32,
    cpu_int: GptimerInt,
    reserved7: u32,
    gen_event0: GptimerInt,
    reserved8: u32,
    gen_event1: GptimerInt,
    reserved9: [13]u32,
    evt_mode: u32,
    reserved10: [6]u32,
    desc: u32,
    commonregs: GptimerCommonregs,
    reserved11: [438]u32,
    counterregs: GptimerCounterregs,

    pub inline fn enablePower(self: *volatile Gptimer) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub inline fn reset(self: *volatile Gptimer) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }

    pub inline fn enableClock(self: *volatile Gptimer) void {
        self.commonregs.cclkctl = 1;
    }

    pub inline fn startCounter(self: *volatile Gptimer) void {
        self.counterregs.ctrctl.en = true;
    }

    pub inline fn stopCounter(self: *volatile Gptimer) void {
        self.counterregs.ctrctl.en = false;
    }

    pub inline fn setLoadValue(self: *volatile Gptimer, value: u32) void {
        self.counterregs.load = value;
    }

    pub fn initTimer(self: *volatile Gptimer, load_value: u32) void {
        self.setLoadValue(load_value);
        self.counterregs.cc[0] = 0;
        self.counterregs.ccctl[0] = .{};
        self.counterregs.ctrctl = .{
            .czc = 0, .clc = 0, .cac = 0, .repeat = .continue_to_advance_following_zero_event
        };
    }
};

pub const tima0: *volatile Gptimer = @ptrFromInt(TIMA0_BASE);
pub const tima1: *volatile Gptimer = @ptrFromInt(TIMA1_BASE);
pub const timg0: *volatile Gptimer = @ptrFromInt(TIMG0_BASE);
pub const timg12: *volatile Gptimer = @ptrFromInt(TIMG12_BASE);
pub const timg6: *volatile Gptimer = @ptrFromInt(TIMG6_BASE);
pub const timg7: *volatile Gptimer = @ptrFromInt(TIMG7_BASE);
pub const timg8: *volatile Gptimer = @ptrFromInt(TIMG8_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x18D8-0x400, @sizeOf(Gptimer));
}
