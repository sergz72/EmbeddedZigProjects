const sercom = @import("sercom");

const I2cMasterState = enum(usize) {
    idle, write_data, repeated_start, read_data, done, err
};

pub const I2cError = error {
    rxnack, unexpected_mb_state, unexpected_sb_state, err
};

pub const I2cMaster = struct {
    instance: *volatile sercom.Sercom,
    sclsm: bool,
    state: I2cMasterState = .idle,
    err: I2cError = undefined,
    slave_address: u11 = undefined,
    tx_buffer: []const u8 = undefined,
    tx_index: usize = undefined,
    rx_buffer: []u8 = undefined,
    rx_index: usize = undefined,

    fn readByteSclsm0(self: *I2cMaster) void {
        if (self.rx_index == self.rx_buffer.len - 1) {
            self.instance.i2cm.ctrlb.ackact = true; // NACK
            self.instance.i2cm.ctrlb.cmd = .stop;
        } else {
            self.instance.i2cm.ctrlb.ackact = false; // ACK
            self.instance.i2cm.ctrlb.cmd = .byte_read;
        }
        self.rx_buffer[self.rx_index] = @truncate(self.instance.i2cm.data);
        self.rx_index += 1;
    }

    fn readByteSclsm1(self: *I2cMaster) void {
        self.rx_buffer[self.rx_index] = @truncate(self.instance.i2cm.data);
        self.rx_index += 1;
        if (self.rx_index == self.rx_buffer.len) {
            self.state = .done;
        } else if (self.rx_index == self.rx_buffer.len - 1) {
            self.instance.i2cm.ctrlb.ackact = true; // NACK
            self.instance.i2cm.ctrlb.cmd = .stop;
        } else {
            self.instance.i2cm.ctrlb.ackact = false; // ACK
            self.instance.i2cm.ctrlb.cmd = .byte_read;
        }
    }

    pub fn mbHandler(self: *I2cMaster) void {
        switch (self.state) {
            .write_data => {
                if (self.instance.i2cm.status.rxnack) {
                    self.instance.i2cm.ctrlb.cmd = .stop;
                    self.state = .err;
                    self.err = I2cError.rxnack;
                    return;
                }
                if (self.tx_index == self.tx_buffer.len) {
                    if (self.rx_buffer.len > 0) {
                        self.state = .repeated_start;
                    } else {
                        self.instance.i2cm.ctrlb.cmd = .stop;
                        self.state = .done;
                    }
                    return;
                }
                self.instance.i2cm.data = self.tx_buffer[self.tx_index];
                self.tx_index += 1;
            },
            .repeated_start => {
                self.instance.i2cm.ctrlb.cmd = .repeated_start;
                self.instance.i2cm.addr.addr = self.slave_address;
                self.state = .read_data;
                if (self.sclsm) {
                    if (self.rx_index == self.rx_buffer.len - 1) {
                        self.instance.i2cm.ctrlb.ackact = true; // NACK
                        self.instance.i2cm.ctrlb.cmd = .stop;
                    } else {
                        self.instance.i2cm.ctrlb.ackact = false; // ACK
                    }
                }
            },
            else => {
                self.instance.i2cm.ctrlb.cmd = .stop;
                self.state = .err;
                self.err = I2cError.unexpected_mb_state;
            }
        }
    }

    pub fn sbHandler(self: *I2cMaster) void {
        switch (self.state) {
            .read_data => {
                if (self.instance.i2cm.status.rxnack) {
                    self.instance.i2cm.ctrlb.cmd = .stop;
                    self.state = .err;
                    self.err = I2cError.rxnack;
                    return;
                }
                if (self.sclsm) {
                    self.readByteSclsm1();
                } else {
                    self.readByteSclsm0();
                }
            },
            else => {
                self.instance.i2cm.ctrlb.cmd = .stop;
                self.state = .err;
                self.err = I2cError.unexpected_sb_state;
            }
        }
    }

    pub fn errorHandler(self: *I2cMaster) void {
        self.instance.i2cm.ctrlb.cmd = .stop;
        self.state = .err;
        self.err = I2cError.err;
        self.instance.i2cm.intflag = .{.err = true};
    }

    pub fn write(self: *volatile I2cMaster, address: u10, data: []const u8) I2cError!void {
        self.tx_buffer = data;
        self.tx_index = 0;
        self.rx_buffer = &.{};
        self.rx_index = 0;
        self.state = .write_data;
        self.instance.i2cm.addr.addr = @as(u11, address) << 1;
        while (true) {
            if (self.state == .done)
                return;
            if (self.state == .err)
                return self.err;
            asm volatile("wfi");
        }
    }

    pub fn transfer(self: *volatile I2cMaster, address: u10, wdata: []const u8, rdata: []u8) I2cError!void {
        self.tx_buffer = wdata;
        self.tx_index = 0;
        self.rx_buffer = rdata;
        self.rx_index = 0;
        self.state = .write_data;
        self.slave_address = (@as(u11, address) << 1) | 1;
        self.instance.i2cm.addr.addr = @as(u11, address) << 1;
        while (true) {
            if (self.state == .done)
                return;
            if (self.state == .err)
                return self.err;
            asm volatile("wfi");
        }
    }

    pub fn scan(self: *volatile I2cMaster, address: u10) I2cError!void {
        return self.write(address, &.{});
    }

    pub fn read(self: *volatile I2cMaster, address: u10, data: []u8) I2cError!void {
        self.rx_buffer = data;
        self.rx_index = 0;
        self.instance.i2cm.addr.addr = (@as(u11, address) << 1) | 1;
        while (true) {
            if (self.state == .done)
                return;
            if (self.state == .err)
                return self.err;
            asm volatile("wfi");
        }
    }
};
