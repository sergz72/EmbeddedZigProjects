pub const TSL2591_I2C_ADDRESS = 0x29;

const REG_ENABLE  = 0;
const REG_CONTROL = 1;
const REG_AILTL   = 4;
const REG_AILTH   = 5;
const REG_AIHTL   = 6;
const REG_AIHTH   = 7;
const REG_NPAILTL = 8;
const REG_NPAILTH = 9;
const REG_NPAIHTL = 10;
const REG_NPAIHTH = 11;
const REG_PERSIST = 12;
const REG_PID     = 0x11;
const REG_ID      = 0x12;
const REG_STATUS  = 0x13;
const REG_C0DATAL = 0x14;
const REG_C0DATAH = 0x15;
const REG_C1DATAL = 0x16;
const REG_C1DATAH = 0x17;

const PACKAGE_ID = 0;
const DEVICE_ID = 0x50;

pub const TSL2591Thresholds = struct {
    low: u16 = 0,
    high: u16 = 65535
};

pub const TSL2591Config = struct {
    no_persist_interrupt_enable: bool = false,
    sleep_after_interrupt: bool = false,
    als_interrupt_enable: bool = false,
    integration_time: TSL2591ATime = ._600ms,
    als_thresholds: TSL2591Thresholds = .{},
    no_persist_als_thresholds: TSL2591Thresholds = .{},
    persistence_filter: TSL2591Persist = .AnyOutOfRange
};

pub const TSL2591Result = struct {
    lux: f32,
    gain: TSL2591Gain,
    tries: usize,
    rawch0: u16,
    rawch1: u16
};

const TSL2591_LUX_DF = 816.0;   // Lux coefficient

const gain_scaling: [4]f32 = .{1.0, 25.0, 428.0, 9876.0};

const Transaction = enum(u2) {
    normal_operation = 1,
    special_function = 3
};

const SpecialFunction = enum(u5) {
    interrupt_set = 4,
    clear_als_interrupt = 6,
    clear_als_and_no_persist_interrupts = 7,
    clear_no_persist_interrupt = 10
};

const Command = packed struct(u8) {
    addr_sf: u5,
    transaction: Transaction,
    cmd: bool = true,

    fn registerAccess(register: u5) u8 {
        return @backingInt(Command{
            .addr_sf = register,
            .transaction = Transaction.normal_operation
        });
    }

    fn specialFunction(f: SpecialFunction) u8 {
        return @backingInt(Command{
            .addr_sf = @backingInt(f),
            .transaction = Transaction.special_function
        });
    }
};

pub const TSL2591Enable = packed struct(u8) {
    pon: bool,
    aen: bool,
    reserved: u2 = 0,
    aien: bool,
    reserved2: u1 = 0,
    sai: bool,
    npien: bool
};

pub const TSL2591ATime = enum(u3) {
    _100ms = 0,
    _200ms = 1,
    _300ms = 2,
    _400ms = 3,
    _500ms = 4,
    _600ms = 5,

    fn ms(self: TSL2591ATime) f32 {
        return switch (self) {
            ._100ms => 100.0,
            ._200ms => 200.0,
            ._300ms => 300.0,
            ._400ms => 400.0,
            ._500ms => 500.0,
            ._600ms => 600.0
        };
    }
};

pub const TSL2591Gain = enum(u2) {
    low = 0,
    medium = 1,
    high = 2,
    maximum = 3,

    fn prev(self: TSL2591Gain) TSL2591Gain {
        switch (self) {
            .low => return .low,
            .medium => return .low,
            .high => return .medium,
            .maximum => return .high
        }
    }

    fn next(self: TSL2591Gain) TSL2591Gain {
        switch (self) {
            .low => return .medium,
            .medium => return .high,
            .high => return .maximum,
            .maximum => return .maximum
        }
    }

    fn getScaling(self: TSL2591Gain) f32 {
        return gain_scaling[@backingInt(self)];
    }
};

const Control = packed struct(u8) {
    atime: TSL2591ATime,
    reserved: u1 = 0,
    again: TSL2591Gain = .low,
    reserved2: u1 = 0,
    sreset: bool = false
};

pub const TSL2591Persist = enum(u8) {
    EveryCycle = 0,
    AnyOutOfRange = 1,
    _2OutOfRange = 2,
    _3OutOfRange = 3,
    _5OutOfRange = 4,
    _10OutOfRange = 5,
    _15OutOfRange = 6,
    _20OutOfRange = 7,
    _25OutOfRange = 8,
    _30OutOfRange = 9,
    _35OutOfRange = 10,
    _40OutOfRange = 11,
    _45OutOfRange = 12,
    _50OutOfRange = 13,
    _55OutOfRange = 14,
    _60OutOfRange = 15
};

const PID = packed struct(u8) {
    reserved: u4,
    pid: u2,
    reserved2: u2
};

const TSL2591Status = packed struct(u8) {
    avalid: bool,
    reserved: u3,
    aint: bool,
    npintr: bool,
    reserved2: u2
};

pub const TSL2591Error = error {
    I2CErrorWrite,
    I2CErrorRead8,
    I2CErrorRead16,
    I2CErrorCommand,
    InvalidDeviceId,
    InvalidPackageId
};

pub const TSL2591Init = struct {
    i2c_read8: *const fn(u8) ?u8,
    i2c_read16: *const fn(u8) ?u16,
    i2c_write: *const fn(u8, u8) bool,
    i2c_command: *const fn(u8) bool,
    delayms: *const fn(usize) void,
    config: TSL2591Config
};

pub const TSL2591 = struct {
    init_data: *const TSL2591Init,
    i2c_error_name: []const u8 = &.{},
    control: Control = undefined,

    pub fn setGain(self: *TSL2591, gain: TSL2591Gain) TSL2591Error!void {
        self.control.again = gain;
        if (!self.init_data.i2c_write(Command.registerAccess(REG_CONTROL), @backingInt(self.control)))
            return TSL2591Error.I2CErrorWrite;
    }

    pub fn setAlsThresholds(self: *const TSL2591, thresholds: TSL2591Thresholds) TSL2591Error!void {
        if (!self.init_data.i2c_write(Command.registerAccess(REG_AILTL), @truncate(thresholds.low)))
            return TSL2591Error.I2CErrorWrite;
        if (!self.init_data.i2c_write(Command.registerAccess(REG_AILTH), @truncate(thresholds.low >> 8)))
            return TSL2591Error.I2CErrorWrite;
        if (!self.init_data.i2c_write(Command.registerAccess(REG_AIHTL), @truncate(thresholds.high)))
            return TSL2591Error.I2CErrorWrite;
        if (!self.init_data.i2c_write(Command.registerAccess(REG_AIHTH), @truncate(thresholds.high >> 8)))
            return TSL2591Error.I2CErrorWrite;
    }

    pub fn setNoPersistAlsThresholds(self: *const TSL2591, thresholds: TSL2591Thresholds) TSL2591Error!void {
        if (!self.init_data.i2c_write(Command.registerAccess(REG_NPAILTL), @truncate(thresholds.low)))
            return TSL2591Error.I2CErrorWrite;
        if (!self.init_data.i2c_write(Command.registerAccess(REG_NPAILTH), @truncate(thresholds.low >> 8)))
            return TSL2591Error.I2CErrorWrite;
        if (!self.init_data.i2c_write(Command.registerAccess(REG_NPAIHTL), @truncate(thresholds.high)))
            return TSL2591Error.I2CErrorWrite;
        if (!self.init_data.i2c_write(Command.registerAccess(REG_NPAIHTH), @truncate(thresholds.high >> 8)))
            return TSL2591Error.I2CErrorWrite;
    }

    pub fn setPersistenceFilter(self: *const TSL2591, filter: TSL2591Persist) TSL2591Error!void {
        if (!self.init_data.i2c_write(Command.registerAccess(REG_PERSIST), @backingInt(filter)))
            return TSL2591Error.I2CErrorWrite;
    }

    pub fn enable(self: *const TSL2591, en: TSL2591Enable) TSL2591Error!void {
        if (!self.init_data.i2c_write(Command.registerAccess(REG_ENABLE), @backingInt(en)))
            return TSL2591Error.I2CErrorWrite;
    }

    pub fn init(self: *TSL2591) TSL2591Error!void {
        const id = self.init_data.i2c_read8(Command.registerAccess(REG_ID)) orelse return TSL2591Error.I2CErrorRead8;
        if (id != DEVICE_ID)
            return TSL2591Error.InvalidDeviceId;
        const p = self.init_data.i2c_read8(Command.registerAccess(REG_PID)) orelse return TSL2591Error.I2CErrorRead8;
        const pid: PID = @bitCast(p);
        if (pid.pid != 0)
            return TSL2591Error.InvalidPackageId;
        try self.enable(.{
            .pon = true,
            .aen = true,
            .aien = self.init_data.config.als_interrupt_enable,
            .sai = self.init_data.config.sleep_after_interrupt,
            .npien = self.init_data.config.no_persist_interrupt_enable});
        self.control = .{.atime = self.init_data.config.integration_time};
        try self.setGain(.low);
        try self.setAlsThresholds(self.init_data.config.als_thresholds);
        try self.setNoPersistAlsThresholds(self.init_data.config.no_persist_als_thresholds);
        try self.setPersistenceFilter(self.init_data.config.persistence_filter);
    }

    pub fn clearInterrupts(self: *const TSL2591) TSL2591Error!void {
        if (!self.init_data.i2c_command(Command.specialFunction(SpecialFunction.clear_als_and_no_persist_interrupts)))
            return TSL2591Error.I2CErrorCommand;
    }

    pub fn getStatus(self: *const TSL2591) TSL2591Error!TSL2591Status {
        return self.init_data.i2c_read8(Command.registerAccess(REG_STATUS));
    }

    pub fn measure(self: *TSL2591, result: *TSL2591Result) TSL2591Error!void {
        result.gain = .low;
        result.tries = 1;

        while (true) {
            const ch0 = self.init_data.i2c_read16(Command.registerAccess(REG_C0DATAL)) orelse return TSL2591Error.I2CErrorRead16;
            const ch1 = self.init_data.i2c_read16(Command.registerAccess(REG_C1DATAL)) orelse return TSL2591Error.I2CErrorRead16;
            if ((ch0 == 0xFFFF or ch1 == 0xFFFF) and result.gain != .low) {
                result.gain = result.gain.prev();
                try self.setGain(result.gain);
                self.init_data.delayms(2000);
                result.tries += 1;
                continue;
            }
            if (result.gain != .low or ch0 > 65535/30 or ch1 > 65535/30) {
                try self.calculateResult(ch0, ch1, result);
                return;
            }
            if (ch0 > 65535/450 or ch1 > 65535/450) {
                result.gain = .medium;
            }
            else if (ch0 > 65535/10000 or ch1 > 65535/10000) {
                result.gain = .high;
            }
            else {
                result.gain = .maximum;
            }
            try self.setGain(result.gain);
            result.tries += 1;
            self.init_data.delayms(2000);
        }
    }

    fn calculateResult(self: *TSL2591, ch0: u16, ch1: u16, result: *TSL2591Result) TSL2591Error!void {
        if (result.gain != .low) {
            try self.setGain(.low);
        }
        const ch0f = @as(f32, ch0);
        const ch1f = @as(f32, ch1);
        const cpl = self.init_data.config.integration_time.ms() * result.gain.getScaling() / TSL2591_LUX_DF;
        // Alternate lux calculation 1
        // See: https://github.com/adafruit/Adafruit_TSL2591_Library/issues/14
        result.lux = (ch0f - ch1f) * (1.0 - ch1f / ch0f) / cpl;
        result.rawch0 = ch0;
        result.rawch1 = ch1;
    }
};
