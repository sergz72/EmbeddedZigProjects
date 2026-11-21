const DBGMCU_BASE = 0xE0042000;

pub const DbgmcuDevId = enum(u12) {
    f405_407_415_417 = 0x413,
    f42x_f43x = 0x419,
};

pub const DbgmcuIdcode = bitpack struct(u32) {
    dev_id: DbgmcuDevId,
    reserved0: u4,
    rev_id: u16,
};

pub const DbgmcuTraceMode = enum(u2) {
    async = 0,
    sync_port_width_1 = 1,
    sync_port_width_2 = 2,
    sync_port_width_4 = 3
};

pub const DbgmcuCr = bitpack struct(u32) {
    dbg_sleep: bool = false,
    dbg_stop: bool = false,
    dbg_standby: bool = false,
    reserved0: u2 = 0,
    trace_ioen: bool = false,
    trace_mode: DbgmcuTraceMode = .async,
    reserved1: u24 = 0,
};

pub const DbgmcuApb1Fz = bitpack struct(u32) {
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
    dbg_iwdeg_stop: bool = false,
    reserved1: u8 = 0,
    dbg_j2c1_smbus_timeout: bool = false,
    dbg_j2c2_smbus_timeout: bool = false,
    dbg_j2c3smbus_timeout: bool = false,
    reserved2: u1 = 0,
    dbg_can1_stop: bool = false,
    dbg_can2_stop: bool = false,
    reserved3: u5 = 0,
};

pub const DbgmcuApb2Fz = bitpack struct(u32) {
    dbg_tim1_stop: bool = false,
    dbg_tim8_stop: bool = false,
    reserved0: u14 = 0,
    dbg_tim9_stop: bool = false,
    dbg_tim10_stop: bool = false,
    dbg_tim11_stop: bool = false,
    reserved1: u13 = 0,
};

pub const DbgMcu = extern struct {
    idcode: DbgmcuIdcode,
    cr: DbgmcuCr,
    apb1: DbgmcuApb1Fz,
    apb2: DbgmcuApb2Fz,
};

pub const dbg: *volatile DbgMcu = @ptrFromInt(DBGMCU_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10, @sizeOf(DbgMcu));
}
