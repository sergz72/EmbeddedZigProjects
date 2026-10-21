pub const I2cError = error{
    ReadTimeout,
    WriteTimeout,
    Nack,
};

pub const I2cSoft = struct {
    set_scl: *const fn(value: bool) void,
    set_sda: *const fn(value: bool) void,
    get_scl: *const fn() bool,
    get_sda: *const fn() bool,
    delayus: *const fn(us: usize) void,
    timeout: usize,
    delay: usize = 5, // 100 khz baud

    inline fn i2cDelay(self: *const I2cSoft) void {
        self.delayus(self.delay);
    }

    pub fn init(self: *const I2cSoft) void {
        self.set_scl(true);
        self.set_sda(true);
    }

    fn start(self: *const I2cSoft) void {
        self.set_sda(true);
        self.i2cDelay();
        self.set_scl(true);
        self.i2cDelay();
        self.set_sda(false);
        self.i2cDelay();
        self.set_scl(false);
        self.i2cDelay();
    }

    fn stop(self: *const I2cSoft) void {
        self.set_sda(false);
        self.i2cDelay();
        self.set_scl(true);
        self.i2cDelay();
        self.set_sda(true);
        self.i2cDelay();
    }

    fn rx(self: *const I2cSoft, ack: bool) I2cError!u8 {
        var d: u8 = 0;

        self.set_sda(true);
        for(0..8) |_| {
            d <<= 1;
            self.i2cDelay();
            self.set_scl(true);
            self.i2cDelay();
            if (self.get_sda()) d |= 1;
            self.set_scl(false);
        }
        self.set_sda(!ack);
        self.i2cDelay();
        self.set_scl(true);
        //waiting for device to release SCL
        var timeout = self.timeout;
        while (timeout != 0) {
            if (self.get_scl())
                break;
            timeout -= 1;
        }
        if (timeout == 0) {
            self.stop();
            return I2cError.ReadTimeout;
        }
        self.i2cDelay();
        self.set_scl(false);
        self.set_sda(true);
        return d;
    }

    fn tx(self: *const I2cSoft, data: u8) I2cError!void {
        var d = data;
        for (0..8) |_| {
            self.set_sda(d & 0x80 != 0);
            self.i2cDelay();
            self.set_scl(true);
            self.i2cDelay();
            self.set_scl(false);
            d <<= 1;
        }
        self.set_sda(true);
        self.i2cDelay();
        self.set_scl(true);
        //waiting for device to release SCL
        var timeout = self.timeout;
        while (timeout != 0) {
            if (self.get_scl())
                break;
            timeout -= 1;
        }
        if (timeout == 0) {
            self.stop();
            return I2cError.WriteTimeout;
        }
        self.i2cDelay();
        const b = self.get_sda(); // possible ACK bit
        self.set_scl(false);
        if (b) { // nack
            self.stop();
            return I2cError.Nack;
        }
    }

    pub fn write(self: *const I2cSoft, address: u10, data: []const u8) I2cError!void {
        self.start();
        try self.tx(@truncate((address << 1)));
        for (data) |d| {
            try self.tx(d);
        }
        self.stop();
    }

    pub fn transfer(self: *const I2cSoft, address: u10, wdata: []const u8, rdata: []u8) I2cError!void {
        self.start();
        try self.tx(@truncate((address << 1)));
        for (wdata) |d| {
            try self.tx(d);
        }
        self.start();
        try self.tx(@truncate((address << 1) | 1));
        for (0..rdata.len) |idx| {
            rdata[idx] = try self.rx(idx != rdata.len - 1);
        }
        self.stop();
    }

    pub fn scan(self: *const I2cSoft, address: u10) I2cError!void {
        self.start();
        try self.tx(@truncate((address << 1)));
        self.stop();
    }

    pub fn read(self: *const I2cSoft, address: u10, data: []u8) I2cError!void {
        self.start();
        try self.tx(@truncate((address << 1) | 1));
        self.i2cDelay();
        for (0..data.len) |idx| {
            data[idx] = try self.rx(idx != data.len - 1);
        }
        self.stop();
    }
};

