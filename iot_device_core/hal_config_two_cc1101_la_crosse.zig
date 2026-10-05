const cc1101 = @import("cc1101");

pub const NUMBER_OF_CC1101_DEVICES = 2;
pub var rx_buffer2: [64]u8 = undefined;
const cfg2: cc1101.CC1101Cfg = .{
    .mode = .gfsk1200,
    .freq = 433800,
    .packet_length = 64,
    .address = 1,
    .mcsm1 = .{},
    .tx_power = cc1101.CC1101TxPower433.m30.toU8()
};
