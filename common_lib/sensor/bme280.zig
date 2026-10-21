const std = @import("std");

pub const BME280_ADDRESS = 0x76;

const REGISTER_ID = 0xD0;
const REGISTER_RESET = 0xE0;
const REGISTER_CTRL_HUM = 0xF2;
const REGISTER_STATUS = 0xF3;
const REGISTER_CTRL = 0xF4;
const REGISTER_CONFIG = 0xF5;
const REGISTER_PRES = 0xF7;
const REGISTER_TEMP = 0xFA;
const REGISTER_HUM = 0xFD;
const REGISTER_CALIB = 0x88;
const REGISTER_H1 = 0xA1;
const REGISTER_H2 = 0xE1;

const DEVICE_RESET = 0xB6;
const CHIP_ID = 0x60;

const Oversampling = enum(u3) {
    skipped = 0,
    x1 = 1,
    x2 = 2,
    x4 = 3,
    x8 = 4,
    x16 = 5
};

const CtrlHum = packed struct(u8) {
    osrs_h: Oversampling,
    reserved: u5 = 0
};

const Status = packed struct(u8) {
    im_update: bool,
    reserved: u2,
    measuring: bool,
    reserved2: u4
};

const Mode = enum(u2) {
    sleep = 0,
    forced = 1,
    normal = 3
};

const Ctrl = packed struct(u8) {
    mode: Mode,
    osrs_p: Oversampling,
    osrs_t: Oversampling
};

const Standby = enum(u3) {
    _p5ms = 0,
    _62p5ms = 1,
    _125ms = 2,
    _250ms = 3,
    _500ms = 4,
    _1000ms = 5,
    _10ms = 6,
    _20ms = 7
};

const Filter = enum(u3) {
    off = 0,
    x2 = 1,
    x4 = 2,
    x8 = 3,
    x16 = 4
};

const Config = packed struct(u8) {
    spi3w_en: bool,
    filter: Filter,
    t_sb: Standby
};

pub const BME280Result = struct {
    pressure: u24,
    temperature: u16,
    humidity: u16
};

pub const BME280Error = error {
    I2CErrorRead, I2CErrorWrite, InvalidChipId
};

const Calibration1 = extern struct {
    t1: u16,
    t2: i16,
    t3: i16,
    p1: u16,
    p2: i16,
    p3: i16,
    p4: i16,
    p5: i16,
    p6: i16,
    p7: i16,
    p8: i16,
    p9: i16
};

const Calibration2 = extern struct {
    h2_lo: u8,
    h2_hi: u8,
    h3: u8,
    h4_hi: u8,
    h4_h5_lo: u8,
    h5_hi: u8,
    h6: i8,

    fn getH2(self: *Calibration2) i16 {
        @setRuntimeSafety(false);
        return (@as(i16, self.h2_hi) << 8) | @as(i16, self.h2_lo);
    }

    fn getH4(self: *Calibration2) i16 {
        @setRuntimeSafety(false);
        var h4: u16 = (@as(u16, self.h4_hi) << 4) | (self.h4_h5_lo & 0x0F);
        if (h4 & 0x800 != 0) {
            h4 |= 0xF000;
        }
        return @bitCast(h4);
    }

    fn getH5(self: *Calibration2) i16 {
        @setRuntimeSafety(false);
        var h5: u16 = (@as(u16, self.h5_hi) << 4) | ((self.h4_h5_lo & 0xF0) >> 4);
        if (h5 & 0x800 != 0) {
            h5 |= 0xF000;
        }
        return @bitCast(h5);
    }
};

const Calibration = extern struct {
    c1: Calibration1,
    c2: Calibration2,
    h1: u8,
};

const RawData = extern struct {
    // pressure = 3 bytes, temperature = 3 bytes, humidity = 2 bytes
    d: [8]u8,

    fn getPressure(self: *RawData) i64 {
        const v: u24 = std.mem.readInt(u24, self.d[0..3], .big);
        return v >> 4;
    }

    fn getTemperature(self: *RawData) isize {
        const v: u24 = std.mem.readInt(u24, self.d[3..6], .big);
        return v >> 4;
    }

    fn getHumidity(self: *RawData) isize {
        const v: u16 = std.mem.readInt(u16, self.d[6..], .big);
        return @intCast(v);
    }
};

pub const BME280 = struct {
    i2c_read: *const fn(u8, []u8) bool,
    i2c_write: *const fn([]const u8) bool,
    delayms: *const fn(usize) void,
    i2c_error_name: []const u8 = &.{},
    cal: Calibration = undefined,
    raw_data: RawData = undefined,
    has_humidity_sensor: bool = undefined,

    fn getTemperatureCalibration(self: *BME280) isize {
        const t = self.raw_data.getTemperature();
        const t1 = @as(isize, self.cal.c1.t1);
        const var1 = (((t>>3) - (t1 << 1)) * @as(isize, self.cal.c1.t2)) >> 11;
        const x = (t>>4) - t1;
        const  var2  = (((x * x) >> 12) * @as(isize, self.cal.c1.t3)) >> 14;
        return var1 + var2;
    }

    fn compensatePressure(self: *BME280,t_fine: isize) usize {
        const adc_p = self.raw_data.getPressure();

        var var1 = @as(i64, t_fine) - 128000;
        var var2 = var1 * var1 * @as(i64, self.cal.c1.p6);
        var2 += (var1*@as(i64, self.cal.c1.p5))<<17;
        var2 += @as(i64, self.cal.c1.p4)<<35;
        var1 = ((var1 * var1 * @as(i64, self.cal.c1.p3))>>8) + ((var1 * @as(i64, self.cal.c1.p2))<<12);
        var1 = ((1<<47)+var1)*@as(i64, self.cal.c1.p1)>>33;

        if (var1 == 0) {
            return 0;  // avoid exception caused by division by zero
        }

        var p: i64 = 1048576 - adc_p;
        p = @divTrunc((((p<<31) - var2)*3125), var1);
        const p13 = p >> 13;
        var1 = (@as(i64, self.cal.c1.p9) * p13 * p13) >> 25;
        var2 = (@as(i64, self.cal.c1.p8) * p) >> 19;
        p = ((p + var1 + var2) >> 8) + (@as(i64, self.cal.c1.p7)<<4);

        return @intCast(p >> 8);
    }

    fn compensateHumidity(self: *BME280, t_fine: isize) usize {
        const adc_h = self.raw_data.getHumidity();
        var v_x1_u32r = t_fine - 76800;

        v_x1_u32r = ((((adc_h << 14) - ((@as(isize, self.cal.c2.getH4())) << 20) -
            (@as(isize, self.cal.c2.getH5()) * v_x1_u32r)) + 16384) >> 15) *
            ((((((v_x1_u32r * ((@as(isize, self.cal.c2.h6))) >> 10) *
            ((v_x1_u32r * @as(isize, self.cal.c2.h3) >> 11) + 32768)) >> 10) +
            2097152) * @as(isize, self.cal.c2.getH2()) + 8192) >> 14);

        const v15 = v_x1_u32r >> 15;
        v_x1_u32r -= (((v15 * v15 >> 7) * @as(isize, self.cal.h1)) >> 4);

        if (v_x1_u32r < 0)
            v_x1_u32r = 0;
        if (v_x1_u32r > 419430400)
            v_x1_u32r = 419430400;

        return @intCast(@divTrunc((v_x1_u32r>>12) * 100, 1024));
    }

    pub fn init(self: *BME280) BME280Error!void {
        var id: [1]u8 = undefined;
        if (!self.i2c_read(REGISTER_ID, &id)) {
            return BME280Error.I2CErrorRead;
        }
        switch (id[0]) {
            0x58 => self.has_humidity_sensor = false,
            0x60 => self.has_humidity_sensor = true,
            else => return BME280Error.InvalidChipId
        }
        if (!self.i2c_write(&.{REGISTER_CTRL_HUM, @backingInt(CtrlHum{.osrs_h = Oversampling.x1})}))
            return BME280Error.I2CErrorWrite;
        const c1: []u8 = std.mem.asBytes(&self.cal.c1);
        if (!self.i2c_read(REGISTER_CALIB, c1)) {
            return BME280Error.I2CErrorRead;
        }
        var h1: [1]u8 = undefined;
        if (!self.i2c_read(REGISTER_H1, &h1)) {
            return BME280Error.I2CErrorRead;
        }
        self.cal.h1 = h1[0];
        const c2: []u8 = std.mem.asBytes(&self.cal.c2);
        if (!self.i2c_read(REGISTER_H2, c2)) {
            return BME280Error.I2CErrorRead;
        }
    }

    pub fn startMeasurement(self: *BME280) BME280Error!void {
        if (!self.i2c_write(&.{REGISTER_CTRL, @backingInt(Ctrl{
                .mode = Mode.forced,
                .osrs_p = Oversampling.x1,
                .osrs_t = Oversampling.x1})}))
            return BME280Error.I2CErrorWrite;
    }

    pub fn isMeasurementReady(self: *BME280) BME280Error!bool {
        var c: [1]u8 = undefined;
        if (!self.i2c_read(REGISTER_STATUS, &c)) {
            return BME280Error.I2CErrorRead;
        }
        const status: Status = @bitCast(c[0]);
        return !status.measuring;
    }

    fn getRawData(self: *BME280) BME280Error!void {
        while (true) {
            if (try self.isMeasurementReady()) {
                break;
            }
            self.delayms(100);
        }
        if (!self.i2c_read(REGISTER_PRES, &self.raw_data.d)) {
            return BME280Error.I2CErrorRead;
        }
    }

    pub fn get(self: *BME280) BME280Error!BME280Result {
        try self.startMeasurement();
        try self.getRawData();
        const t_fine = self.getTemperatureCalibration();
        const result: BME280Result = .{
            .temperature = @intCast(compensateTemperature(t_fine)),
            .humidity = if (self.has_humidity_sensor) @truncate(self.compensateHumidity(t_fine)) else 0,
            .pressure = @truncate(self.compensatePressure(t_fine))
        };
        return result;
    }
};

fn compensateTemperature(t_fine: isize) isize {
    return (t_fine * 5 + 128) >> 8;
}

test "sizeof test" {
    try std.testing.expectEqual(24, @sizeOf(Calibration1));
    try std.testing.expectEqual(7, @sizeOf(Calibration2));
}

fn testI2cRead(reg: u8, data: []u8) bool {
    switch (reg) {
        REGISTER_CALIB => {
            @memcpy(data, &[_]u8{
                0x70, 0x6B, 0x43, 0x67, 0x18, 0xFC, 0x7D, 0x8E,
                0x43, 0xD6, 0xD0, 0x0B, 0x27, 0x0B, 0x8C, 0x00,
                0xF9, 0xFF, 0x8C, 0x3C, 0xF8, 0xC6, 0x70, 0x17});
            return true;
        },
        REGISTER_H1 => {
            data[0] = 0x4B;
            return true;
        },
        REGISTER_H2 => {
            @memcpy(data, &[_]u8{
                0x6E, 0x01, 0x00, 0x13, 0x2B, 0x03, 0x1E});
            return true;
        },
        REGISTER_STATUS => {
          data[0] = 0;
          return true;
        },
        REGISTER_PRES => {
            @memcpy(data, &[_]u8{
                0x65, 0x5A, 0xC0, 0x7E, 0xED, 0x00, 0x7B, 0x0C});
            return true;
        },
        else => return false
    }
}

fn testI2cWrite(data: []const u8) bool {
    _ = data;
    return true;
}

fn testDelayms(ms: usize) void {
    _ = ms;
}

test "calculations test" {
    var bme: BME280 = .{
        .i2c_read = testI2cRead,
        .i2c_write = testI2cWrite,
        .delayms = testDelayms
    };
    try bme.init();
    const result = try bme.get();
    try std.testing.expectEqual(2508, result.temperature);
    try std.testing.expectEqual(6330, result.humidity);
    try std.testing.expectEqual(100653, result.pressure);
}