const cpu = @import("cpu");

const I2C1_BASE: usize = 0x40005400;
const I2C2_BASE: usize = 0x40005800;

pub const I2cError = error {
    TimeoutWaitNotBusy,
    TimeoutWaitMasterModeSelect,
    TimeoutWaitMasterTransmitterModeSelected,
    TimeoutWaitMasterReceiverModeSelected,
    TimeoutWaitTxe,
    TimeoutWaitRxne,
    TimeoutWaitMasterByteTransitted
};

pub const I2cCtlr1 = packed struct(u16) {
    pe: bool = false,
    smbus: bool = false,
    reserved: u1 = 0,
    smbtype_master: bool = false,
    enarp: bool = false,
    enpec: bool = false,
    engc: bool = false,
    nostretch: bool = false,
    start: bool = false,
    stop: bool = false,
    ack: bool = false,
    pos: bool = false,
    pec: bool = false,
    alert: bool = false,
    reserved2: u1 = 0,
    swrst: bool = false
};

pub const I2cCtlr2 = packed struct(u16) {
    freq: u6 = 0,
    reserved: u2 = 0,
    iterren: bool = false,
    iteven: bool = false,
    itbufen: bool = false,
    dmaen: bool = false,
    last: bool = false,
    reserved2: u3 = 0
};

pub const I2cOaddr1 = packed struct(u16) {
    address: u10 = 0,
    reserved: u5 = 0,
    addmode_10bit: bool = false
};

pub const I2cOaddr2 = packed struct(u16) {
    endual: bool = false,
    address2: u7 = 0,
    reserved: u8 = 0
};

pub const I2cStar1 = packed struct(u16) {
    sb: bool,
    addr: bool,
    btf: bool,
    add10: bool,
    stopf: bool,
    reserved: u1,
    rxne: bool,
    txe: bool,
    verr: bool,
    arrlo: bool,
    af: bool,
    ovr: bool,
    pecerr: bool,
    reserved2: u1,
    timeout: bool,
    smbalert: bool
};

pub const I2cStar2 = packed struct(u16) {
    msl: bool,
    busy: bool,
    tra: bool,
    reserved: u1,
    gencall: bool,
    smbdefault: bool,
    smbhost: bool,
    dualf: bool,
    pec: u8
};

pub const I2cCkCfgr = packed struct(u16) {
    ccr: u12 = 0,
    reserved: u2 = 0,
    duty_16_9: bool = false,
    fast_mode: bool = false
};

pub const I2cCkRtr = packed struct(u16) {
    trise: u6 = 2,
    reserved: u10 = 0
};

pub const I2c = extern struct {
    ctlr1: I2cCtlr1,
    reserved0: u16,
    ctlr2: I2cCtlr2,
    reserved1: u16,
    oaddr1:  I2cOaddr1,
    reserved2: u16,
    oaddr2: I2cOaddr2,
    reserved3: u16,
    datar: u16,
    reserved4: u16,
    star1: I2cStar1,
    reserved5: u16,
    star2: I2cStar2,
    reserved6: u16,
    ckcfgr: I2cCkCfgr,
    reserved7: u16,
    rtr: I2cCkRtr,

    pub fn initMaster(self: *volatile I2c, speed: usize) void {
        self.ctlr1 = .{};
        var freq = cpu.cpu.pclk1_frequency / 1000000;
        if (freq < 4) {
            freq = 4;
        } else if (freq > 60) {
            freq = 60;
        }
        self.ctlr2 = .{.freq = @truncate(freq)};
        if (speed <= 100000) {
            self.rtr = .{.trise = @truncate(freq+1)};
            var ccr = cpu.cpu.pclk1_frequency / (speed << 1);
            if (ccr < 4)
                ccr = 4;
            self.ckcfgr = .{.ccr = @truncate(ccr)};
        } else {
            var ccr = cpu.cpu.pclk1_frequency / (speed * 3);
            if (ccr == 0)
                ccr = 1;
            self.rtr = .{.trise = @truncate(freq * 3 / 10 + 1)};
            self.ckcfgr = .{.ccr = @truncate(ccr), .fast_mode = true};
        }
        self.ctlr1 = .{.pe = true};
    }

    fn checkNotBusy(self: *volatile I2c) bool {
        return !self.star2.busy;
    }

    fn checkTxe(self: *volatile I2c) bool {
        return self.star1.txe;
    }

    fn checkRxne(self: *volatile I2c) bool {
        return self.star1.rxne;
    }

    fn checkMasterModeSelect(self: *volatile I2c) bool {
        return self.star2.busy and self.star2.msl and self.star1.sb;
    }

    fn checkMasterTransmitterModeSelected(self: *volatile I2c) bool {
        return self.star2.busy and self.star2.msl and self.star2.tra and self.star1.addr and self.star1.txe;
    }

    fn checkMasterReceiverModeSelected(self: *volatile I2c) bool {
        return self.star2.busy and self.star2.msl and self.star1.addr;
    }

    fn checkMasterByteTransmitted(self: *volatile I2c) bool {
        return self.star2.busy and self.star2.msl and self.star2.tra and self.star1.btf and self.star1.txe;
    }

    fn waitEvent(self: *volatile I2c, event_fn: *const fn(*volatile I2c) bool, timeout: usize) bool {
        var t = timeout;
        while (t != 0) {
            if (event_fn(self))
                break;
            t -= 1;
        }
        return t != 0;
    }

    fn waitEventOrStop(self: *volatile I2c, event_fn: *const fn(*volatile I2c) bool, timeout: usize) bool {
        var t = timeout;
        while (t != 0) {
            if (event_fn(self))
                break;
            t -= 1;
        }
        if (t == 0) {
            self.ctlr1.stop = true;
        }
        return t != 0;
    }

    fn sendAddress(self: *volatile I2c, address: u10, timeout: usize, transmitter_mode: bool, check_not_busy: bool) I2cError!void {
        if (check_not_busy) {
            // wait until bus is free
            if (!self.waitEvent(checkNotBusy, timeout))
                return I2cError.TimeoutWaitNotBusy;
        }

        // generating start
        self.ctlr1.start = true;


        if (!self.waitEvent(checkMasterModeSelect, timeout))
            return I2cError.TimeoutWaitMasterModeSelect;

        // sending address
        var addr = address << 1;
        if (!transmitter_mode)
            addr |= 1;
        self.datar = addr;

        // waiting until transmitter/receiver flag is set
        if (transmitter_mode) {
            if (!self.waitEventOrStop(checkMasterTransmitterModeSelected, timeout))
                return I2cError.TimeoutWaitMasterTransmitterModeSelected;
        } else {
            if (!self.waitEventOrStop(checkMasterReceiverModeSelected, timeout))
                return I2cError.TimeoutWaitMasterReceiverModeSelected;
        }
    }

    fn sendData(self: *volatile I2c, data: []const u8, timeout: usize) I2cError!void {
        for (data) |d| {
            if (!self.waitEventOrStop(checkTxe, timeout))
                return I2cError.TimeoutWaitTxe;
            self.datar = d;
            if (!self.waitEventOrStop(checkMasterByteTransmitted, timeout))
                return I2cError.TimeoutWaitMasterByteTransitted;
        }
    }

    fn receiveData(self: *volatile I2c, data: []u8, timeout: usize) I2cError!void {
        for (0..data.len) |idx| {
            if (idx == data.len - 1)
                self.ctlr1.ack = false;
            if (!self.waitEventOrStop(checkRxne, timeout))
                return I2cError.TimeoutWaitRxne;
            data[idx] = @truncate(self.datar);
        }
    }

    pub fn write(self: *volatile I2c, address: u10, data: []const u8, timeout: usize) I2cError!void {
        try self.sendAddress(address, timeout, true, true);
        try self.sendData(data, timeout);
        self.ctlr1.stop = true;
    }

    pub fn transfer(self: *volatile I2c, address: u10, wdata: []const u8, rdata: []u8, timeout: usize) I2cError!void {
        self.ctlr1.ack = true;
        try self.sendAddress(address, timeout, true, true);
        try self.sendData(wdata, timeout);
        try self.sendAddress(address, timeout, false, false);
        try self.receiveData(rdata, timeout);
        self.ctlr1.stop = true;
    }

    pub fn scan(self: *volatile I2c, address: u10, timeout: usize) I2cError!void {
        try self.sendAddress(address, timeout, true, true);
        self.ctlr1.stop = true;
    }

    pub fn read(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        self.ctlr1.ack = true;
        try self.sendAddress(address, timeout, false, true);
        try self.receiveData(data, timeout);
        self.ctlr1.stop = true;
    }
};

pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);
pub const i2c2: *volatile I2c = @ptrFromInt(I2C2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x22, @sizeOf(I2c));
}
