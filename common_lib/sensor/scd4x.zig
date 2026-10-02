const std = @import("std");
const system_timer = @import("system_timer");

const SCD4x_RAW_DATA_SIZE = 9;
pub const SCD4X_SENSOR_ADDR = 0x62;

pub const SCD4xError = error {
    InvalidCRC,
    I2CErrorWrite,
    I2CErrorReadStatus,
    I2CErrorReadMeasurement
};

pub const SCD4xResult = struct {
    temperature_x100: u16,
    humidity_x100: u16,
    co2: u16
};

pub const SCD4x = struct {
    i2c_read: *const fn([]u8) bool,
    i2c_write: *const fn([]const u8) bool,
    raw_data: [SCD4x_RAW_DATA_SIZE]u8 = undefined,
    i2c_error_name: []const u8 = &.{},

    fn validateRawDataItem(self: *const SCD4x, offset: usize) SCD4xError!void {
        const hash_val = std.hash.crc.@"CRC-8/NRSC-5".hash(self.raw_data[offset..offset + 2]);
        if (hash_val != self.raw_data[offset + 2])
            return SCD4xError.InvalidCRC;
    }

    fn validateRawData(self: *const SCD4x) SCD4xError!void {
        try self.validateRawDataItem(0);
        try self.validateRawDataItem(3);
        try self.validateRawDataItem(6);
    }

    fn computeValues(self: *const SCD4x) SCD4xResult {
        const co2 = std.mem.readInt(u16, self.raw_data[0..2], .big);
        const t: isize = std.mem.readInt(u16, self.raw_data[3..5], .big);
        const h: usize = std.mem.readInt(u16, self.raw_data[6..8], .big);
        const tt = -4500 + ((17500 * t) >> 16);
        const utt:usize = @bitCast(tt);
        return .{
            .co2 = co2,
            .temperature_x100 = if (tt < 0) 0 else @truncate(utt),
            .humidity_x100 = @truncate((10000 * h) >> 16)
        };
    }

    pub fn startMeasurement(self: *const SCD4x) SCD4xError!void {
        const data: []const u8 = &.{0x21, 0x9D};
        if (!self.i2c_write(data))
            return SCD4xError.I2CErrorWrite;
    }

    pub fn powerDown(self: *const SCD4x) SCD4xError!void {
        const data: []const u8 = &.{0x36, 0xE0};
        if (!self.i2c_write(data))
            return SCD4xError.I2CErrorWrite;
    }

    pub fn wakeUp(self: *const SCD4x) SCD4xError!void {
        const data: []const u8 = &.{0x36, 0xF6};
        const result = self.i2c_write(data);
        system_timer.delayms(30);
        if (!result)
            return SCD4xError.I2CErrorWrite;
    }

    fn getStatus(self: *SCD4x) SCD4xError!u16 {
        const data: []const u8 = &.{0xE4, 0xB8};
        if (!self.i2c_write(data))
            return SCD4xError.I2CErrorWrite;
        system_timer.delayms(2);
        if (!self.i2c_read(self.raw_data[0..3]))
            return SCD4xError.I2CErrorReadStatus;
        try self.validateRawDataItem(0);
        return std.mem.readInt(u16, self.raw_data[0..2], .big);
    }

    pub fn readMeasurement(self: *SCD4x) SCD4xError!SCD4xResult {
        while (true) {
            const status = try self.getStatus();
            if (status & 0x7FF != 0)
                break;
            system_timer.delayms(1000);
        }
        const data: []const u8 = &.{0xEC, 0x05};
        if (!self.i2c_write(data))
            return SCD4xError.I2CErrorWrite;
        system_timer.delayms(2);
        if (!self.i2c_read(&self.raw_data))
            return SCD4xError.I2CErrorReadMeasurement;
        try self.validateRawData();
        return self.computeValues();
    }

    pub fn get(self: *SCD4x) SCD4xError!SCD4xResult {
        self.wakeUp() catch {};
        try self.startMeasurement();
        system_timer.delayms(6000);
        const result = try self.readMeasurement();
        try self.powerDown();
        return result;
    }
};
