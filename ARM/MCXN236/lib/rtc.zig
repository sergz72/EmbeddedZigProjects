const RTC0_BASE = 0x4004C000;

pub const Month = enum(u4) {
    reserved = 0,
    january = 1,
    february = 2,
    march = 3,
    april = 4,
    may = 5,
    june = 6,
    july = 7,
    august = 8,
    september = 9,
    october = 10,
    november = 11,
    december = 12
};

pub const Yearmon = bitpack struct(u16) {
    mon_cnt: Month = .january,
    reserved0: u4 = 0,
    yrofst: u8 = 0,
};

pub const Dow = enum(u3) {
    sunday = 0,
    monday = 1,
    tuesday = 2,
    wednesday = 3,
    thursday = 4,
    friday = 5,
    saturday = 6,
};

pub const Days = bitpack struct(u16) {
    day_cnt: u5 = 1,
    reserved0: u3 = 0,
    dow: Dow = .sunday,
    reserved1: u5 = 0,
};

pub const Hourmin = bitpack struct(u16) {
    min_cnt: u6 = 0,
    reserved0: u2 = 0,
    hour_cnt: u5 = 0,
    reserved1: u3 = 0,
};

pub const Seconds = bitpack struct(u16) {
    sec_cnt: u6 = 0,
    reserved0: u10 = 0,
};

pub const AlmYearmon = bitpack struct(u16) {
    alm_mon: u4 = 0,
    reserved0: u4 = 0,
    alm_year: u8 = 0,
};

pub const AlmDays = bitpack struct(u16) {
    alm_day: u5 = 0,
    reserved0: u11 = 0,
};

pub const AlmHourmin = bitpack struct(u16) {
    alm_min: u6 = 0,
    reserved0: u2 = 0,
    alm_hour: u5 = 0,
    reserved1: u3 = 0,
};

pub const AlmSeconds = bitpack struct(u16) {
    alm_sec: u6 = 0,
    reserved0: u2 = 0,
    dec_sec: bool = false,
    inc_sec: bool = false,
    reserved1: u6 = 0,
};

pub const AlmMatch = enum(u2) {
    hours = 0,
    days = 1,
    months = 2,
    year = 3,
};

pub const Clkout = enum(u2) {
    no_output_clk = 0,
    clk_1hz_fine = 1,
    clk_32_168khz = 2,
    clk_1hz_coarse = 3,
};

pub const Ctrl = bitpack struct(u16) {
    fineen: bool = false,
    comp_en: bool = false,
    alm_match: AlmMatch = .hours,
    reserved0: u2 = 0,
    dst_en: bool = false,
    reserved1: u1 = 0,
    swr: bool = false,
    clk_sel: bool = false,
    clko_dis: bool = false,
    reserved2: u2 = 0,
    clkout: Clkout = .no_output_clk,
    reserved3: u1 = 0,
};

pub const Status = bitpack struct(u16) {
    inval_bit: bool = false,
    write_prot_en: bool = false,
    reserved0: u3 = 0,
    cmp_int: bool = false,
    we: u2 = 0,
    bus_err: bool = false,
    reserved1: u2 = 0,
    cmp_done: bool = false,
    reserved2: u4 = 0,
};

pub const Ir = bitpack struct(u16) {
    reserved0: u2 = 0,
    alm_i: bool = false,
    day_i: bool = false,
    hour_i: bool = false,
    min_i: bool = false,
    i_1hz: bool = false,
    i_2hz: bool = false,
    i_4hz: bool = false,
    i_8hz: bool = false,
    i_16hz: bool = false,
    i_32hz: bool = false,
    i_64hz: bool = false,
    i_128hz: bool = false,
    i_256hz: bool = false,
    i_512hz: bool = false,
};

pub const DstHour = bitpack struct(u16) {
    dst_end_hour: u5 = 0,
    reserved0: u3 = 0,
    dst_start_hour: u5 = 0,
    reserved1: u3 = 0,
};

pub const DstMonth = bitpack struct(u16) {
    dst_end_month: u4 = 0,
    reserved0: u4 = 0,
    dst_start_month: u4 = 0,
    reserved1: u4 = 0,
};

pub const DstDay = bitpack struct(u16) {
    dst_end_day: u5 = 0,
    reserved0: u3 = 0,
    dst_start_day: u5 = 0,
    reserved1: u3 = 0,
};

pub const Compen = bitpack struct(u16) {
    compen_val: u16 = 0,
};

pub const Rtc = extern struct {
    yearmon: Yearmon,
    days: Days,
    hourmin: Hourmin,
    seconds: Seconds,
    alm_yearmon: AlmYearmon,
    alm_days: AlmDays,
    alm_hourmin: AlmHourmin,
    alm_seconds: AlmSeconds,
    ctrl: Ctrl,
    status: Status,
    isr: Ir,
    ier: Ir,
    reserved0: [2]u16,
    test2: u16,
    reserved1: [2]u16,
    hour: DstHour,
    month: DstMonth,
    day: DstDay,
    compen: Compen,
};

pub const rtc0: *volatile Rtc = @ptrFromInt(RTC0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2A, @sizeOf(Rtc));
}
