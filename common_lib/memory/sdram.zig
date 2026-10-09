pub const SdramNc = enum(u2) {
    _8 = 0,
    _9 = 1,
    _10 = 2,
    _11 = 3
};

pub const SdramNr = enum(u2) {
    _11 = 0,
    _12 = 1,
    _13 = 2
};

pub const SdramMw = enum(u2) {
    _8 = 0,
    _16 = 1,
    _32 = 2
};

pub const SdramCasLatency = enum(u2) {
    _1 = 1,
    _2 = 2,
    _3 = 3
};

pub const SdramPipe = enum(u2) {
    _0 = 0,
    _1 = 1,
    _2 = 2
};

pub const SdramDelay = enum(u4) {
    _1 = 0,
    _2 = 1,
    _3 = 2,
    _4 = 3,
    _5 = 4,
    _6 = 5,
    _7 = 6,
    _8 = 7,
    _9 = 8,
    _10 = 9,
    _11 = 10,
    _12 = 11,
    _13 = 12,
    _14 = 13,
    _15 = 14,
    _16 = 15
};

pub const Sdram = struct {
    nc: SdramNc,
    nr: SdramNr,
    mw: SdramMw,
    four_banks: bool,
    cas_latency: SdramCasLatency,
    burst_read: bool,
    read_pipe: SdramPipe,
    load_mode_register_to_active: SdramDelay,
    exit_self_refresh_delay: SdramDelay,
    self_refresh_time: SdramDelay,
    row_cycle_delay: SdramDelay,
    recovery_delay: SdramDelay,
    row_precharge_delay: SdramDelay,
    row_to_column_delay: SdramDelay
};

pub const IS42S16400J_7:Sdram = .{
    .nc = ._8,
    .nr = ._12,
    .mw = ._16,
    .four_banks = true,
    .cas_latency = ._3,
    .burst_read = false,
    .read_pipe = ._1,
    .load_mode_register_to_active = ._2,
    .exit_self_refresh_delay = ._7,
    .self_refresh_time = ._4,
    .row_cycle_delay = ._7,
    .recovery_delay = ._2,
    .row_precharge_delay = ._2,
    .row_to_column_delay = ._2
};
