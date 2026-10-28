const std = @import("std");
const generic_rtc = @import("generic_rtc");

pub const DS3231_I2C_ADDRESS = 0x68;

pub const InternalError = error {
    I2CErrorWriteControlRegister,
    I2CErrorWriteData,
    I2CErrorReadControlRegister,
    I2CErrorReadData,
    I2CErrorReadTemperature
};

pub const DS3231Error = InternalError || generic_rtc.RtcDataError;

pub const DS3231 = struct {
    i2c_write: *const fn (data: []const u8) bool,
    i2c_transfer: *const fn (reg: u8, rdata: []u8) bool,
    i2c_error_name: []const u8 = &.{},

    pub fn init(self: *const DS3231, enable_sqw: bool) DS3231Error!void {
        const data: [3]u8 = .{0x0E, if (enable_sqw) 0 else 4, 0x00};
        if (!self.i2c_write(&data)) {
            return DS3231Error.I2CErrorWriteControlRegister;
        }
    }

    pub fn get(self: *const DS3231, rtc: *generic_rtc.RtcData) DS3231Error!void {
        var data: [7]u8 = undefined;

        if (!self.i2c_transfer(0, &data)) {
            return DS3231Error.I2CErrorReadData;
        }
        rtc.seconds = generic_rtc.pack(data[0]);
        rtc.minutes = generic_rtc.pack(data[1]);
        rtc.hours   = generic_rtc.pack(data[2]);
        try rtc.setWeekDay(data[3]);
        rtc.day     = generic_rtc.pack(data[4]);
        try rtc.setMonth(generic_rtc.pack(data[5]));
        rtc.year    = 2000 + @as(usize, generic_rtc.pack(data[6]));
        rtc.buildYDay();
    }

    pub fn getTemperature(self: *const DS3231) DS3231Error!i16 {
        while (true) {
            const data: [1]u8 = undefined;
            if (!self.i2c_transfer(0x0E, data)) {
                return DS3231Error.I2CErrorReadControlRegister;
            }
            if (data[0] & 0x20 == 0) {
                break;
            }
        }
        const data: [2]u8 = undefined;
        if (!self.i2c_transfer(0x11, data)) {
            return DS3231Error.I2CErrorReadTemperature;
        }
        const t = std.mem.readInt(u16, &data, .big);
        return (t >> 6) * 25;
    }

    pub fn setDateTime(self: *const DS3231, rtc: *const generic_rtc.RtcData) DS3231Error!void {
        const data: [8]u8 = .{
            0x00,
            generic_rtc.unpack(rtc.seconds),
            generic_rtc.unpack(rtc.minutes),
            generic_rtc.unpack(rtc.hours),
            @backingInt(rtc.wday),
            generic_rtc.unpack(rtc.day),
            generic_rtc.unpack(@backingInt(rtc.month)),
            generic_rtc.unpack(@truncate(rtc.year - 2000))
        };
        if (!self.i2c_write(&data)) {
            return DS3231Error.I2CErrorWriteData;
        }
    }
};
