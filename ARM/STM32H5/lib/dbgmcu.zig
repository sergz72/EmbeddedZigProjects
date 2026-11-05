const DBGMCU_BASE = 0x44024000;

pub const DbgmcuDevId = enum(u12) {
    h562_563_573 = 0x484,
    h523_533 = 0x478,
    h503 = 0x474
};

pub const DbgmcuRevId = enum(u16) {
    A = 0x1000,
    Z = 0x1001,
    Y = 0x1002,
    X = 0x1007
};

pub const DbgmcuIdcode = packed struct(u32) {
    dev_id: DbgmcuDevId,
    reserved0: u4,
    rev_id: DbgmcuRevId
};

pub const DbgmcuTraceMode = enum(u2) {
    async = 0,
    sync_port_width_1 = 1,
    sync_port_width_2 = 2,
    sync_port_width_4 = 3
};

pub const DbgmcuCr = packed struct(u32) {
    reserved0: u1 = 0,
    dbg_stop: bool = false,
    dbg_standby: bool = false,
    reserved1: u1 = 0,
    trace_ioen: bool = false,
    trace_en: bool = false,
    trace_mode: DbgmcuTraceMode = .async,
    reserved2: u8 = 0,
    dcrt: bool = false,
    reserved3: u15 = 0,
};

pub const DbgmcuApb1lfzr = packed struct(u32) {
    dbg_tim2_stop: bool = false,
    dbg_tim3_stop: bool = false,
    dbg_tim4_stop: bool = false,
    dbg_tim5_stop: bool = false,
    dbg_tim6_stop: bool = false,
    dbg_tim7_stop: bool = false,
    dbg_tim12_stop: bool = false,
    dbg_tim13_stop: bool = false,
    dbg_tim14_stop: bool = false,
    reserved0: u2 = 0,
    dbg_wwdg_stop: bool = false,
    dbg_iwdg_stop: bool = false,
    reserved1: u8 = 0,
    dbg_i2c1_stop: bool = false,
    dbg_i2c2_stop: bool = false,
    dbg_i3c1_stop: bool = false,
    reserved2: u8 = 0,
};

pub const DbgmcuApb1hfzr = packed struct(u32) {
    reserved0: u5 = 0,
    dbg_lptim2_stop: bool = false,
    reserved1: u26 = 0,
};

pub const DbgmcuApb2fzr = packed struct(u32) {
    reserved0: u11 = 0,
    dbg_tim1_stop: bool = false,
    reserved1: u1 = 0,
    dbg_tim8_stop: bool = false,
    reserved2: u2 = 0,
    dbg_tim15_stop: bool = false,
    dbg_tim16_stop: bool = false,
    dbg_tim17_stop: bool = false,
    reserved3: u13 = 0,
};

pub const DbgmcuApb3fzr = packed struct(u32) {
    reserved0: u10 = 0,
    dbg_i2c3_stop: bool = false,
    dbg_i2c4_stop: bool = false,
    reserved1: u5 = 0,
    dbg_lptim1_stop: bool = false,
    dbg_lptim3_stop: bool = false,
    dbg_lptim4_stop: bool = false,
    dbg_lptim5_stop: bool = false,
    dbg_lptim6_stop: bool = false,
    reserved2: u8 = 0,
    dbg_rtc_stop: bool = false,
    reserved3: u1 = 0,
};

pub const DbgmcuAhb1fzr = packed struct(u32) {
    dbg_gpdma1_0_stop: bool = false,
    dbg_gpdma1_1_stop: bool = false,
    dbg_gpdma1_2_stop: bool = false,
    dbg_gpdma1_3_stop: bool = false,
    dbg_gpdma1_4_stop: bool = false,
    dbg_gpdma1_5_stop: bool = false,
    dbg_gpdma1_6_stop: bool = false,
    dbg_gpdma1_7_stop: bool = false,
    dbg_gpdma1_8_stop: bool = false,
    dbg_gpdma1_9_stop: bool = false,
    dbg_gpdma1_10_stop: bool = false,
    dbg_gpdma1_11_stop: bool = false,
    dbg_gpdma1_12_stop: bool = false,
    dbg_gpdma1_13_stop: bool = false,
    dbg_gpdma1_14_stop: bool = false,
    dbg_gpdma1_15_stop: bool = false,
    dbg_gpdma2_0_stop: bool = false,
    dbg_gpdma2_1_stop: bool = false,
    dbg_gpdma2_2_stop: bool = false,
    dbg_gpdma2_3_stop: bool = false,
    dbg_gpdma2_4_stop: bool = false,
    dbg_gpdma2_5_stop: bool = false,
    dbg_gpdma2_6_stop: bool = false,
    dbg_gpdma2_7_stop: bool = false,
    dbg_gpdma2_8_stop: bool = false,
    dbg_gpdma2_9_stop: bool = false,
    dbg_gpdma2_10_stop: bool = false,
    dbg_gpdma2_11_stop: bool = false,
    dbg_gpdma2_12_stop: bool = false,
    dbg_gpdma2_13_stop: bool = false,
    dbg_gpdma2_14_stop: bool = false,
    dbg_gpdma2_15_stop: bool = false,
};

pub const DbgmcuSr = packed struct(u32) {
    ap_present: u16 = 3,
    ap_enabled: u16 = 1,
};

pub const DbgmcuDbgAuthAck = packed struct(u32) {
    host_ack: bool,
    dev_ack: bool,
    reserved0: u30,
};

pub const DbgmcuPidr4 = packed struct(u32) {
    jep106con: u4,
    size: u4,
    reserved0: u24,
};

pub const DbgmcuPidr0 = packed struct(u32) {
    partnum: u8,
    reserved0: u24,
};

pub const DbgmcuPidr1 = packed struct(u32) {
    partnum: u4,
    jep106id: u4,
    reserved0: u24
};

pub const DbgmcuPidr2 = packed struct(u32) {
    jep106id: u3,
    jedec: bool,
    revision: u4,
    reserved0: u24
};

pub const DbgmcuPidr3 = packed struct(u32) {
    cmod: u4,
    revand: u4,
    reserved0: u24
};

pub const DbgmcuCidr0 = packed struct(u32) {
    preamble: u8,
    reserved0: u24
};

pub const DbgmcuCidr1 = packed struct(u32) {
    preamble: u4,
    class: u4,
    reserved0: u24,
};

pub const DbgmcuCidr2 = packed struct(u32) {
    preamble: u8,
    reserved0: u24,
};

pub const DbgmcuCidr3 = packed struct(u32) {
    preamble: u8,
    reserved0: u24,
};

pub const Dbgmcu = extern struct {
    idcode: DbgmcuIdcode,
    cr: DbgmcuCr,
    apb1lfzr: DbgmcuApb1lfzr,
    apb1hfzr: DbgmcuApb1hfzr,
    apb2fzr: DbgmcuApb2fzr,
    apb3fzr: DbgmcuApb3fzr,
    reserved0: [2]u32,
    ahb1fzr: DbgmcuAhb1fzr,
    reserved1: [54]u32,
    sr: DbgmcuSr,
    dbg_auth_host: u32,
    dbg_auth_device: u32,
    dbg_auth_ack: DbgmcuDbgAuthAck,
    reserved2: [945]u32,
    pidr4: DbgmcuPidr4,
    reserved3: [3]u32,
    pidr0: DbgmcuPidr0,
    pidr1: DbgmcuPidr1,
    pidr2: DbgmcuPidr2,
    pidr3: DbgmcuPidr3,
    cidr0: DbgmcuCidr0,
    cidr1: DbgmcuCidr1,
    cidr2: DbgmcuCidr2,
    cidr3: DbgmcuCidr3,
};

pub const dbgmcu: *volatile Dbgmcu = @ptrFromInt(DBGMCU_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1000, @sizeOf(Dbgmcu));

}
