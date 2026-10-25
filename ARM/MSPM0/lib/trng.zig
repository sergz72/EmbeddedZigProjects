const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const TRNG_BASE: usize = 0x40444000 + 0x800;

pub const TrngIntIIdx = enum(u32) {
    no_interrupt = 0,
    health_test_failed = 1,
    command_failed = 2,
    command_done = 3,
    buffer_ready = 4,
};

pub const TrngIntInt = packed struct(u32) {
    health_test_failed: bool = false,
    command_failed: bool = false,
    command_done: bool = false,
    buffer_ready: bool = false,
    reserved: u28 = 0
};

pub const TrngInt = extern struct {
    iidx: TrngIntIIdx,
    reserved0: u32,
    imask: TrngIntInt,
    reserved1: u32,
    ris: TrngIntInt,
    reserved2: u32,
    mis: TrngIntInt,
    reserved3: u32,
    iset: TrngIntInt,
    reserved4: u32,
    iclr: TrngIntInt
};

pub const TrngGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const TrngPwrupPstatCfg = enum(u2) {
    disabled = 0,
    rise_10us_fall_50us = 1,
    rise_10us_fall_70us = 2,
    rise_10us_fall_90us = 3
};

pub const TrngPwrupPchrgCfg = enum(u2) {
    disabled = 0,
    _20us = 1,
    _30us = 2,
    _40us = 3
};

pub const TrngCmd = enum(u2) {
    off = 0,
    pwrup_dig = 1,
    pwrup_ana = 2,
    norm_func = 3
};

pub const TrngCtl = packed struct(u32) {
    cmd: TrngCmd = .off,
    reserved: u6 = 0,
    decim_rate: u3 = 0,
    reserved2: u5 = 0,
    pwrup_clkdiv: bool = false,
    pwrup_pchrg_cfg: TrngPwrupPchrgCfg = ._30us,
    pwrup_pstat_cfg: TrngPwrupPstatCfg = .rise_10us_fall_70us,
    reserved3: u11 = 0
};

pub const TrngFsmState = enum(u4) {
    off = 0,
    pwrup_es = 1,
    pwrdown_es = 2,
    norm_func = 3,
    test_dig = 7,
    err = 0x0A,
    test_ana = 0x0B
};

pub const TrngStat = packed struct(u32) {
    adap_fail: bool,
    rep_fail: bool,
    reserved: u6,
    issued_cmd: TrngCmd,
    reserved2: u6,
    fsm_state: TrngFsmState,
    reserved3: u12
};

pub const TrngTestResults = packed struct(u32) {
    dig_test: u8,
    ana_test: bool,
    reserved: u23
};

pub const TrngClkDivide = enum(u32) {
    div1 = 0,
    div2 = 1,
    div4 = 3,
    div6 = 5,
    div8 = 7
};

pub const Trng = extern struct {
    gprcm: TrngGprcm,
    reserved1: [514]u32,
    cpu_int: TrngInt,
    reserved2: [44]u32,
    desc: u32,
    ctl: TrngCtl,
    stat: TrngStat,
    data_capture: u32,
    test_results: TrngTestResults,
    clkdivide: TrngClkDivide,

    pub inline fn enablePower(self: *volatile Trng) void {
        const v = common.GprcmPwren{.enable = true};
        self.gprcm.pwren = v;
    }

    pub inline fn reset(self: *volatile Trng) void {
        const v = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
        self.gprcm.rstctl = v;
    }
};

pub const trng: *volatile Trng = @ptrFromInt(TRNG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1114-0x800, @sizeOf(Trng));
}
