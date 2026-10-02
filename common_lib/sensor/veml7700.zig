const system_timer = @import("system_timer");

pub const VEML7700_I2C_ADDRESS = 0x10;

const VEML7700_REG_CONFIG         = 0;
const VEML7700_REG_HIGH_THRESHOLD = 1;
const VEML7700_REG_LOW_THRESHOLD  = 2;
const VEML7700_REG_POWER_SAVE     = 3;
const VEML7700_REG_ALS            = 4;
const VEML7700_REG_WHITE          = 5;
const VEML7700_REG_IT_STATUS      = 6;
const VEML7700_REG_ID             = 7;

pub const VEML7700Persistence = enum(u2) {
    _1 = 0,
    _2 = 1,
    _4 = 2,
    _8 = 3
};

pub const VEML7700IT = enum(u4) {
    _25ms = 0x0C,
    _50ms = 8,
    _100ms = 0,
    _200ms = 1,
    _400ms = 2,
    _800ms = 3
};

pub const VEML7700Gain = enum(u2) {
    _1 = 0,
    _2 = 1,
    _0p125 = 2,
    _0p25 = 3
};

pub const VEML7700Config = packed struct(u16) {
    shutdown: bool = false,
    interrupt_enable: bool = false,
    reserved: u2 = 0,
    persistence: VEML7700Persistence = ._1,
    integration_time: VEML7700IT = ._100ms,
    reserved2: u1 = 0,
    gain: VEML7700Gain = ._1,
    reserved3: u3 = 0,
};

pub const VEML7700PowerSave = packed struct(u16) {
    psm_en: bool = false,
    psm_mode: u2 = 0,
    reserved: u13 = 0
};

pub const VEML7700Error = error {
    InvalidId,
    I2CErrorWriteRegConfig,
    I2CErrorWriteRegPowerSave,
    I2CErrorReadId,
    I2CErrorReadRegAls
};

pub const VEML7700Result = struct {
    lux: f32,
    gain: VEML7700Gain,
    tries: usize,
    raw: u16
};

pub const VEML7700 = struct {
    i2c_read: *const fn(u8) ?u16,
    i2c_write: *const fn(u8, u16) bool,
    i2c_error_name: []const u8 = &.{},

    fn checkId(self: *volatile VEML7700) VEML7700Error!void {
        const id = self.i2c_read(VEML7700_REG_ID);
        if (id == null)
            return VEML7700Error.I2CErrorReadId;
        if (id.? != 0xC481)
            return VEML7700Error.InvalidId;
    }

    fn setConfig(self: *volatile VEML7700, gain: VEML7700Gain) VEML7700Error!void {
        const config: VEML7700Config = .{.gain = gain, .integration_time = ._800ms};
        if (!self.i2c_write(VEML7700_REG_CONFIG, @bitCast(config))) {
            return VEML7700Error.I2CErrorWriteRegConfig;
        }
    }

    pub fn init(self: *volatile VEML7700) VEML7700Error!void {
        try self.checkId();
        try self.setConfig(._0p125);
        if (!self.i2c_write(VEML7700_REG_POWER_SAVE, 0)) {
            return VEML7700Error.I2CErrorWriteRegPowerSave;
        }
    }

    pub fn exInit(self: *volatile VEML7700, config: VEML7700Config, power_save: VEML7700PowerSave) VEML7700Error!void {
        try self.checkId();
        if (!self.i2c_write(VEML7700_REG_CONFIG, @bitCast(config))) {
            return VEML7700Error.I2CErrorWriteRegConfig;
        }
        if (!self.i2c_write(VEML7700_REG_POWER_SAVE, @bitCast(power_save))) {
            return VEML7700Error.I2CErrorWriteRegPowerSave;
        }
    }

    fn calculateLux(value: u16, gain: VEML7700Gain) f32 {
        return switch (gain) {
            ._0p125 => //gain is 1/8
                @as(f32, @floatFromInt(value)) * 0.0672,
            ._0p25 => //gain is 1/4
                @as(f32, @floatFromInt(value)) * 0.0366,
            ._1 => //gain is 1
                @as(f32, @floatFromInt(value)) * 0.0084,
            else => // gain is 2
                @as(f32, @floatFromInt(value)) * 0.0042
        };
    }

    pub fn measure(self: *volatile VEML7700, result: *VEML7700Result, wait: bool) VEML7700Error!void {
        result.gain = ._0p125;
        result.tries = 1;
        if (wait)
            system_timer.delayms(1500);
        while (true) {
            var raw = self.i2c_read(VEML7700_REG_ALS);
            if (raw == null) {
                return VEML7700Error.I2CErrorReadRegAls;
            }
            var value = raw.?;
            if (value >= 0x7000) {
                result.lux = calculateLux(value, ._0p125);
                result.raw = value;
                break;
            }
            result.tries += 1;
            if (value >= 0x1000) {
                result.gain = ._0p25;
            } else if (value >= 0x500) {
                result.gain = ._1;
            } else {
                result.gain = ._2;
            }
            try self.setConfig(result.gain);
            system_timer.delayms(1500);
            raw = self.i2c_read(VEML7700_REG_ALS);
            if (raw == null) {
                return VEML7700Error.I2CErrorReadRegAls;
            }
            value = raw.?;
            try self.setConfig(._0p125);
            if (value == 0xFFFF) { // overflow
                result.gain = ._0p125;
                result.tries += 1;
                system_timer.delayms(1500);
            } else {
                result.lux = calculateLux(value, result.gain);
                result.raw = value;
                break;
            }
        }
    }
};
