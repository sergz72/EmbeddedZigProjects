const AGT_BASE: usize = 0x40084000;

pub const AgtCr = packed struct(u8) {
    tstart: bool = false,
    tcstf: bool = false,
    tstop: bool = false,
    reserved: u1 = 0,
    tedgf: bool = false,
    tundf: bool = false,
    tcmaf: bool = false,
    tcmbf: bool = false
};

pub const AgtTmod = enum(u3) {
    timer = 0,
    pulse = 1,
    event_counter = 2,
    pulse_width_measurement = 3,
    pulse_period_measurement = 4
};

pub const AgtTck = enum(u3) {
    pclkb = 0,
    pclkb_div8 = 1,
    pclkb_div2 = 3,
    agtlclk = 4,
    underflow_from_agt0 = 5,
    agtsclk = 6
};

pub const AgtMr1 = packed struct(u8) {
    tmod: AgtTmod = .timer,
    tedgpl_both_edges: bool = false,
    tck: AgtTck = .pclkb,
    reserved: u1 = 0
};

pub const AgtCks = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7
};

pub const AgtMr2 = packed struct(u8) {
    cks: AgtCks,
    reserved: u4 = 0,
    lpm: bool = false
};

pub const AgtCmSr = packed struct(u8) {
    tcmea: bool = false,
    toea: bool = false,
    topola: bool = false,
    reserved: u1 = 0,
    tcmeb: bool = false,
    toeb: bool = false,
    topolb: bool = false,
    reserved2: u1 = 0
};

pub const Agt = extern struct {
    agt: u16,
    agtcma: u16,
    agtcmb: u16,
    reserved: u16,
    agtcr: AgtCr,
    agtmr1: AgtMr1,
    agtmr2: AgtMr2,
    reserved2: u8,
    agtioc: u8,
    agtisr: u8,
    agtcmsr: AgtCmSr,
    agtiosel: u8,
    reserved3: [240]u8
};

pub const agt: *volatile [2]Agt = @ptrFromInt(AGT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x100, @sizeOf(Agt));
}
