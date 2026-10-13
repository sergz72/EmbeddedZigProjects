const sercom = @import("sercom");

const I2cMasterState = enum(usize) {
    idle, write_data, repeated_start, read_data, done, err
};

pub const I2cError = error {
    nack
};

pub const I2cMaster = struct {
    instance: *volatile sercom.Sercom,
    sclsm: bool,
    state: I2cMasterState = .idle,
    slave_address: u10 = undefined,
    current_tx_buffer: usize = undefined,
    tx_buffer: []const u8 = undefined,
    tx_index: usize = undefined,
    rx_buffer: []u8 = undefined,
    rx_index: usize = undefined,

    pub fn mbHandler(self: *I2cMaster) void {
        _ = self;
    }

    pub fn sbHandler(self: *I2cMaster) void {
        _ = self;
    }

    pub fn errorHandler(self: *I2cMaster) void {
        _ = self;
    }

    pub fn write(self: *volatile I2cMaster, address: u10, data: []const u8) I2cError!void {
        _ = self;
        _ = address;
        _ = data;
    }

    pub fn transfer(self: *volatile I2cMaster, address: u10, wdata: []const u8, rdata: []u8) I2cError!void {
        _ = self;
        _ = address;
        _ = wdata;
        _ = rdata;
    }

    pub fn scan(self: *volatile I2cMaster, address: u10) I2cError!void {
        _ = self;
        _ = address;
    }

    pub fn read(self: *volatile I2cMaster, address: u10, data: []u8) I2cError!void {
        _ = self;
        _ = address;
        _ = data;
    }
};
