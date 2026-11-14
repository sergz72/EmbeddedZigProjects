const FLEXIO0_BASE = 0x40105000;

pub const Feature = enum(u16) {
    standard = 0,
    state_logic_parallel = 1,
    pinctrl = 2,
    state_logic_parallel_pinctrl = 3,
};

pub const Verid = bitpack struct(u32) {
    feature: Feature,
    minor: u8,
    major: u8,
};

pub const Param = bitpack struct(u32) {
    shifter: u8,
    timer: u8,
    pin: u8,
    trigger: u8,
};

pub const Ctrl = bitpack struct(u32) {
    flexen: bool = false,
    swrst: bool = false,
    fastacc: bool = false,
    reserved0: u27 = 0,
    dbge: bool = false,
    dozen: bool = false,
};

pub const Smod = enum(u3) {
    disable = 0,
    receive = 1,
    transmit = 2,
    matchstore = 4,
    matchcont = 5,
    state = 6,
    logic = 7,
};

pub const Pincfg = enum(u2) {
    disable = 0,
    opend_bidirouten = 1,
    bidir_outdata = 2,
    output = 3,
};

pub const Shiftctl = bitpack struct(u32) {
    smod: Smod = .disable,
    reserved0: u4 = 0,
    pinpol: bool = false,
    pinsel: u5 = 0,
    reserved1: u3 = 0,
    pincfg: Pincfg = .disable,
    reserved2: u5 = 0,
    timpol: bool = false,
    timsel: u3 = 0,
    reserved3: u5 = 0,
};

pub const Shiftcfg = bitpack struct(u32) {
    sstart: u2 = 0,
    reserved0: u2 = 0,
    sstop: u2 = 0,
    reserved1: u2 = 0,
    insrc: bool = false,
    latst: bool = false,
    reserved2: u2 = 0,
    ssize: bool = false,
    reserved3: u3 = 0,
    pwidth: u5 = 0,
    reserved4: u11 = 0,
};

pub const Timod = enum(u3) {
    disable = 0,
    dual8bit_baud = 1,
    dual8bit_pwm_h = 2,
    single16bit = 3,
    single16bit_disable = 4,
    dual8bit_word = 5,
    dual8bit_pwm_l = 6,
    single16bit_in_capture = 7,
};

pub const Timctl = bitpack struct(u32) {
    timod: Timod = .disable,
    reserved0: u2 = 0,
    onetim: bool = false,
    pinins: bool = false,
    pinpol: bool = false,
    pinsel: u5 = 0,
    reserved1: u3 = 0,
    pincfg: Pincfg = .disable,
    reserved2: u4 = 0,
    trgsrc: bool = false,
    trgpol: bool = false,
    trgsel: u6 = 0,
    reserved3: u2 = 0,
};

pub const Tstop = enum(u2) {
    stop_disable = 0,
    enable_tmrcmp = 1,
    enable_tmrdisable = 2,
    enable_tmr_cmp_dis = 3,
};

pub const Timena = enum(u3) {
    enable = 0,
    tmr_nminus1_en = 1,
    tmr_trighi_en = 2,
    tmr_trig_pin_hi_en = 3,
    tmr_pinrise_en = 4,
    tmr_pinrise_trighi_en = 5,
    tmr_trigrise_en = 6,
    tmr_trigedge_en = 7,
};

pub const Timdis = enum(u3) {
    never = 0,
    tmr_nminus1 = 1,
    tmr_cmp = 2,
    tmr_cmp_triglow = 3,
    pin_edge = 4,
    pin_edge_trighi = 5,
    trig_falledge = 6,
};

pub const Timrst = enum(u3) {
    never = 0,
    tmr_out_hi = 1,
    pin_eq_tmr_out = 2,
    trig_eq_tmr_out = 3,
    pin_rise_edge = 4,
    trig_rise_edge = 6,
    trig_edge = 7,
};

pub const Timdec = enum(u3) {
    flexio_clk_shiftclk_tmr_out = 0,
    trig_edge_shiftclk_tmr_out = 1,
    pin_edge_shiftclk_tmr_out = 2,
    trig_edge_shiftclk_trig_in = 3,
    flexio_clk_div16_shiftclk_tmr_out = 4,
    flexio_clk_div256_shiftclk_tmr_out = 5,
    pin_rise_shiftclk_pin_in = 6,
    trig_rise_shiftclk_trig_in = 7,
};

pub const Timout = enum(u2) {
    one = 0,
    zero = 1,
    one_tmrreset = 2,
    zero_tmrreset = 3,
};

pub const Timcfg = bitpack struct(u32) {
    reserved0: u1 = 0,
    tstart: bool = false,
    reserved1: u2 = 0,
    tstop: Tstop = .stop_disable,
    reserved2: u2 = 0,
    timena: Timena = .enable,
    reserved3: u1 = 0,
    timdis: Timdis = .never,
    reserved4: u1 = 0,
    timrst: Timrst = .never,
    reserved5: u1 = 0,
    timdec: Timdec = .flexio_clk_shiftclk_tmr_out,
    reserved6: u1 = 0,
    timout: Timout = .one,
    reserved7: u6 = 0,
};

pub const Flexio = extern struct {
    verid: Verid,
    param: Param,
    ctrl: Ctrl,
    pin: u32,
    shiftstat: u32,
    shifterr: u32,
    timstat: u32,
    reserved0: u32,
    shiftsien: u32,
    shifteien: u32,
    timien: u32,
    reserved1: u32,
    shiftsden: u32,
    reserved2: u32,
    timersden: u32,
    reserved3: u32,
    shiftstate: u32,
    reserved4: u32,
    trgstat: u32,
    trigien: u32,
    pinstat: u32,
    pinien: u32,
    pinren: u32,
    pinfen: u32,
    pinoutd: u32,
    pinoute: u32,
    pinoutdis: u32,
    pinoutclr: u32,
    pinoutset: u32,
    pinouttog: u32,
    reserved5: [2]u32,
    shiftctl: [8]Shiftctl,
    reserved6: [24]u32,
    shiftcfg: [8]Shiftcfg,
    reserved7: [56]u32,
    shiftbuf: [8]u32,
    reserved8: [24]u32,
    shiftbufbis: [8]u32,
    reserved9: [24]u32,
    shiftbufbys: [8]u32,
    reserved10: [24]u32,
    shiftbufbbs: [8]u32,
    reserved11: [24]u32,
    timctl: [8]Timctl,
    reserved12: [24]u32,
    timcfg: [8]Timcfg,
    reserved13: [24]u32,
    timcmp: [8]u32,
    reserved14: [88]u32,
    shiftbufnbs: [8]u32,
    reserved15: [24]u32,
    shiftbufhws: [8]u32,
    reserved16: [24]u32,
    shiftbufnis: [8]u32,
    reserved17: [24]u32,
    shiftbufoes: [8]u32,
    reserved18: [24]u32,
    shiftbufeos: [8]u32,
    reserved19: [24]u32,
    shiftbufhbs: [8]u32,
};

pub const flexio0: *volatile Flexio = @ptrFromInt(FLEXIO0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x920, @sizeOf(Flexio));
}
