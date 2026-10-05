const std = @import("std");
const hal = @import("hal");
const scd4x = @import("scd4x");
const veml = @import("veml7700");
const cc1101 = @import("cc1101");
const config = @import("config");

const cfg1: cc1101.CC1101Cfg = .{
    .mode = .gfsk1200,
    .freq = 433800,
    .packet_length = 64,
    .address = 1,
    .mcsm1 = .{},
    .tx_power = cc1101.CC1101TxPower433.m30.toU8()
};

pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};
pub var rx_buffer1: [64]u8 = undefined;

pub const cc1101_devices: [config.NUMBER_OF_CC1101_DEVICES]cc1101.CC1101Device = if (config.NUMBER_OF_CC1101_DEVICES == 2) .{
    .{
        .device = .{
            .timeout = hal.CC1101_TIMEOUT,
            .spi_write = hal.spi1Write,
            .spi_read_write = hal.spi1ReadWrite,
            .spi_transfer = hal.spi1Transfer,
            .spi_cs_set = hal.spi1CsSet,
            .get_gdo0 = hal.getGdo01,
            .get_gdo2 = hal.getGdo21,
            .rx_buffer = &rx_buffer1,
        },
        .cfg = cfg1
    },
    .{
        .device = .{
            .timeout = hal.CC1101_TIMEOUT,
            .spi_write = hal.spi2Write,
            .spi_read_write = hal.spi2ReadWrite,
            .spi_transfer = hal.spi2Transfer,
            .spi_cs_set = hal.spi2CsSet,
            .get_gdo0 = hal.getGdo02,
            .get_gdo2 = hal.getGdo22,
            .rx_buffer = &config.rx_buffer2,
        },
        .cfg = config.cfg2
    }
} else .{
    .{
        .device = .{
            .timeout = hal.CC1101_TIMEOUT,
            .spi_write = hal.spi1Write,
            .spi_read_write = hal.spi1ReadWrite,
            .spi_transfer = hal.spi1Transfer,
            .spi_cs_set = hal.spi1CsSet,
            .get_gdo0 = hal.getGdo01,
            .get_gdo2 = hal.getGdo21,
            .rx_buffer = &rx_buffer1,
        },
        .cfg = cfg1
    }
};

pub const panic = std.debug.no_panic;

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    hal.i2cScan(address) catch |err| {
        const e_no: u8 = @truncate(@intFromError(err));
        return [2]u8{'e', '0' + e_no};
    };
    return [2]u8{0,0};
}

pub fn scdRead(data: []u8) bool {
    hal.i2cRead(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    hal.i2cWrite(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    hal.i2cTransfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    hal.i2cWrite(veml.VEML7700_I2C_ADDRESS, wdata) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}
