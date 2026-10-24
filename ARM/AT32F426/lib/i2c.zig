const cpu = @import("cpu");

pub const I2C1_BASE = 0x40005400;
pub const I2C2_BASE = 0x40005800;

pub const I2cCtrl1 = packed struct(u16) {
    i2cen: bool = false,
    permode: bool = false,
    reserved1: u1 = 0,
    smbmode: bool = false,
    arpen: bool = false,
    pecen: bool = false,
    gcaen: bool = false,
    stretch: bool = false,
    genstart: bool = false,
    genstop: bool = false,
    acken: bool = false,
    mackctrl: bool = false,
    pecten: bool = false,
    smbalert: bool = false,
    reserved2: u1 = 0,
    reset: bool = false
};

pub const I2cCtrl2 = packed struct(u16) {
    clkfreq: u8 = 0,
    errien: bool = false,
    evtien: bool = false,
    dataien: bool = false,
    dmaen: bool = false,
    dmaend: bool = false,
    reserved1: u3 = 0
};

pub const I2cOaddr1 = packed struct(u16) {
    addr1: u10,
    reserved1: u5 = 0,
    addr1mode: bool = false
};

pub const I2cOaddr2 = packed struct(u16) {
    addr2en: bool = false,
    addr2: u7,
    reserved1: u8 = 0
};

pub const I2cSts1 = packed struct(u16) {
    startf: bool = false,
    addr7f: bool = false,
    tdc: bool = false,
    addrhf: bool = false,
    stopf: bool = false,
    reserved1: u1 = 0,
    rdbf: bool = false,
    tdbe: bool = false,
    buserr: bool = false,
    arlost: bool = false,
    ackfail: bool = false,
    ouf: bool = false,
    pecerr: bool = false,
    reserved2: u1 = 0,
    tmout: bool = false,
    alertf: bool = false
};

pub const I2cSts2 = packed struct(u16) {
    trmode: bool,
    busyf: bool,
    dirf: bool,
    reserved1: u1,
    gcaddrf: bool,
    devaddrf: bool,
    hostaddrf: bool,
    addr2f: bool,
    pecval: u8
};

pub const I2cClkctrl = packed struct(u16) {
    speed: u12 = 0,
    reserved1: u2 = 0,
    dutymode: bool = false,
    speedmode: bool = false
};

pub const I2cError = error {
    TimeoutWaitStartf,
    TimeoutWaitAddrAf,
    AcknowledgeFailure,
    TimeoutWaitTxe,
    TimeoutWaitTdcAf,
    TimeoutWaitNotBusy,
    TimeoutWaitRxne
};

pub const I2c = extern struct {
    ctrl1: I2cCtrl1,
    reserved: u16,
    ctrl2: I2cCtrl2,
    reserved2: u16,
    oaddr1: I2cOaddr1,
    reserved3: u16,
    oaddr2: I2cOaddr2,
    reserved4: u16,
    dt: u16,
    reserved5: u16,
    sts1: I2cSts1,
    reserved6: u16,
    sts2: I2cSts2,
    reserved7: u16,
    clkctrl: I2cClkctrl,
    reserved8: u16,
    tmrise: u16,
    reserved9: u16,
    dnf: u16,

    pub fn enable(self: *volatile I2c) void {
        self.ctrl1.i2cen = true;
    }

    pub fn disable(self: *volatile I2c) void {
        self.ctrl1.i2cen = false;
    }

    pub fn initMaster(self: *volatile I2c, speed: usize) void {
        const v: I2cCtrl2 = .{ .clkfreq = @truncate(cpu.cpu.apb1_frequency / 1000000) };
        self.ctrl2 = v;
        if (speed > 100000) {
            var ccr: u12 = @truncate(cpu.cpu.apb1_frequency / (speed * 3));
            if (ccr < 4) {
                ccr = 4;
            }
            const v2: I2cClkctrl = .{ .speed = ccr, .speedmode = true };
            self.clkctrl = v2;
        } else {
            var ccr: u12 = @truncate(cpu.cpu.apb1_frequency / (speed * 2));
            if (ccr < 4) {
                ccr = 4;
            }
            const v2: I2cClkctrl = .{ .speed = ccr };
            self.clkctrl = v2;
        }
        self.tmrise = @truncate((cpu.cpu.apb1_frequency / 1000000) + 1);
    }

    fn generateStop(self: *volatile I2c) void {
        self.ctrl1.genstop = true;
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
            self.generateStop();
        }
        return t != 0;
    }

    fn sendAddress(self: *volatile I2c, address: u16, timeout: usize) I2cError!void {
        self.ctrl1.genstart = true;
        try self.waitStartf(timeout);
        self.dt = address;
        try self.waitAddrAf(timeout);
    }

    fn send(self: *volatile I2c, data: []const u8, timeout: usize) I2cError!void {
        for (data) |d| {
            try self.waitTxe(timeout);
            self.dt = d;
            try self.waitTdcAf(timeout);
        }
    }

    fn waitTxe(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEventOrStop(self, &checkTxe, timeout)) {
            return I2cError.TimeoutWaitTxe;
        }
    }

    fn checkTxe(self: *volatile I2c) bool {
        return self.sts1.tdbe;
    }

    fn receive(self: *volatile I2c, data: []u8, timeout: usize) I2cError!void {
        for (0..data.len) |idx| {
            if (idx == data.len - 1) {
                self.ctrl1.acken = false;
            }
            try self.waitRxne(timeout);
            data[idx] = @truncate(self.dt);
        }
    }

    fn waitRxne(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEventOrStop(self, &checkRxne, timeout)) {
            return I2cError.TimeoutWaitRxne;
        }
    }

    fn checkRxne(self: *volatile I2c) bool {
        return self.sts1.rdbf;
    }

    pub fn write(self: *volatile I2c, address: u10, data: []const u8, timeout: usize) I2cError!void {
        try self.waitNotBusy(timeout);
        self.sts1 = @bitCast(@as(u16, 0)); // clear all error flags
        try self.sendAddress(@as(u16, address) << 1, timeout);
        try self.send(data, timeout);
        self.generateStop();
    }

    pub fn transfer(self: *volatile I2c, address: u10, wdata: []const u8, rdata: []u8, timeout: usize) I2cError!void {
        try self.waitNotBusy(timeout);
        self.sts1 = @bitCast(@as(u16, 0)); // clear all error flags
        try self.sendAddress(@as(u16, address) << 1, timeout);
        try self.send(wdata, timeout);
        self.ctrl1.acken = true;
        try self.sendAddress((@as(u16, address) << 1) | 1, timeout);
        try self.receive(rdata, timeout);
        self.generateStop();
    }

    pub fn scan(self: *volatile I2c, address: u10, timeout: usize) I2cError!void {
        try self.waitNotBusy(timeout);
        self.sts1 = @bitCast(@as(u16, 0)); // clear all error flags
        try self.sendAddress(@as(u16, address) << 1, timeout);
        self.generateStop();
    }

    pub fn read(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        try self.waitNotBusy(timeout);
        self.sts1 = @bitCast(@as(u16, 0)); // clear all error flags
        self.ctrl1.acken = true;
        try self.sendAddress((@as(u16, address) << 1) | 1, timeout);
        try self.receive(data, timeout);
        self.generateStop();
    }

    fn waitStartf(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEvent(self, &checkStartf, timeout)) {
            return I2cError.TimeoutWaitStartf;
        }
    }

    fn waitNotBusy(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEvent(self, &checkNotBusy, timeout)) {
            return I2cError.TimeoutWaitNotBusy;
        }
    }

    fn waitAddrAf(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEventOrStop(self, &checkAddrAf, timeout)) {
            return I2cError.TimeoutWaitAddrAf;
        }
        if (self.sts1.ackfail) {
            self.generateStop();
            return I2cError.AcknowledgeFailure;
        }
        _ = self.sts2; // read STS2 to clear ADDR flag
    }

    fn waitTdcAf(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEventOrStop(self, &checkTdcAf, timeout)) {
            return I2cError.TimeoutWaitTdcAf;
        }
        if (self.sts1.ackfail) {
            self.generateStop();
            return I2cError.AcknowledgeFailure;
        }
    }

    fn checkNotBusy(self: *volatile I2c) bool {
        return !self.sts2.busyf;
    }

    fn checkStartf(self: *volatile I2c) bool {
        return self.sts1.startf;
    }

    fn checkAddrAf(self: *volatile I2c) bool {
        return self.sts1.addr7f or self.sts1.ackfail;
    }

    fn checkTdcAf(self: *volatile I2c) bool {
        return self.sts1.tdc or self.sts1.ackfail;
    }
};

pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);
pub const i2c2: *volatile I2c = @ptrFromInt(I2C2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x26, @sizeOf(I2c));
}
