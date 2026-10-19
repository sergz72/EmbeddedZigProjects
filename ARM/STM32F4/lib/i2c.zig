const cpu = @import("cpu");

const I2C1_BASE: usize = 0x40005400;
const I2C2_BASE: usize = 0x40005800;
const I2C3_BASE: usize = 0x40005C00;

pub const I2cCr1 = packed struct(u16) {
    pe: bool = false,
    smbus: bool = false,
    reserved: bool = false,
    smbtype: bool = false,
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
    reserved2: bool = false,
    swrst: bool = false
};

pub const I2cCr2 = packed struct(u16) {
    freq: u6 = 0,
    reserved: u2 = 0,
    iterren: bool = false,
    itevten: bool = false,
    itbufen: bool = false,
    dmaen: bool = false,
    last: bool = false,
    reserved2: u3 = 0
};

pub const I2cOar1 = packed struct(u16) {
    add: u10 = 0,
    reserved: u5 = 0,
    addmode: bool = false
};

pub const I2cOar2 = packed struct(u16) {
    endual: bool = false,
    add: u7 = 0,
    reserved: u8 = 0
};

pub const I2cSr1 = packed struct(u16) {
    sb: bool,
    addr: bool,
    btf: bool,
    add10: bool,
    stopf: bool,
    reserved: u1 = 0,
    rxne: bool,
    txe: bool,
    berr: bool,
    arlo: bool,
    af: bool,
    ovr: bool,
    pecerr: bool,
    reserved2: u1 = 0,
    timeout: bool = false,
    smbalert: bool = false
};

pub const I2cSr2 = packed struct(u16) {
    msl: bool = false,
    busy: bool = false,
    tra: bool = false,
    reserved: u1 = 0,
    gencall: bool = false,
    smbdefault: bool = false,
    smbhost: bool = false,
    dualf: bool = false,
    pec: u8 = 0
};

pub const I2cCcr = packed struct(u16) {
    ccr: u12 = 0,
    reserved: u2 = 0,
    duty: bool = false,
    f_s: bool = false
};

pub const I2cFltr = packed struct(u16) {
    dnf: u4 = 0,
    anoff: bool = false,
    reserved: u11 = 0
};

pub const I2cError = error {
    TimeoutWaitSb,
    TimeoutWaitAddrAf,
    AcknowledgeFailure,
    TimeoutWaitTxe,
    TimeoutWaitBtfAf,
    TimeoutWaitNotBusy,
    TimeoutWaitRxne
};

pub const I2c = extern struct {
    cr1: I2cCr1,
    reserved: u16,
    cr2: I2cCr2,
    reserved2: u16,
    oar1: I2cOar1,
    reserved3: u16,
    oar2: I2cOar2,
    reserved4: u16,
    dr: u16,
    reserved5: u16,
    sr1: I2cSr1,
    reserved6: u16,
    sr2: I2cSr2,
    reserved7: u16,
    ccr: I2cCcr,
    reserved8: u16,
    trise: u16,
    reserved9: u16,
    fltr: I2cFltr,

    pub fn enable(self: *I2c) void {
        self.cr1.pe = true;
    }

    pub fn disable(self: *I2c) void {
        self.cr1.pe = false;
    }

    pub fn initMaster(self: *I2c, speed: usize) void {
        self.cr2 = .{ .freq = @truncate(cpu.cpu.pclk1_frequency / 1000000) };
        if (speed > 100000) {
            var ccr: u6 = @truncate(cpu.cpu.pclk1_frequency / (speed * 3));
            if (ccr < 4) {
                ccr = 4;
            }
            self.ccr = .{ .ccr = ccr, .f_s = true };
        } else {
            var ccr: u6 = @truncate(cpu.cpu.pclk1_frequency / (speed * 2));
            if (ccr < 4) {
                ccr = 4;
            }
            self.ccr = .{ .ccr = ccr };
        }
        self.trise = @truncate((cpu.cpu.pclk1_frequency / 1000000) + 1);
    }

    pub fn generateStop(self: *I2c) void {
        self.cr1.stop = true;
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

    fn sendAddress(self: *volatile I2c, address: u16, timeout: usize) I2cError!void {
        try self.waitNotBusy(timeout);
        self.sr1 = @bitCast(@as(u16, 0)); // clear all error flags
        self.cr1.start = true;
        try self.waitSb(timeout);
        self.dr = address;
        try self.waitAddrAf(timeout);
    }

    fn send(self: *volatile I2c, data: []const u8, timeout: usize) I2cError!void {
        for (data) |d| {
            try self.waitTxe(timeout);
            self.dr = d;
            try self.waitBtfAf(timeout);
        }
    }

    pub fn waitTxe(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEvent(self, &checkTxe, timeout)) {
            return I2cError.TimeoutWaitTxe;
        }
    }

    fn checkTxe(self: *volatile I2c) bool {
        return self.sr1.txe;
    }

    fn receive(self: *volatile I2c, data: []u8, timeout: usize) I2cError!void {
        for (0..data.len) |idx| {
            if (idx == data.len - 1) {
                self.cr1.ack = false;
            }
            try self.waitRxne(timeout);
            data[idx] = self.dr;
        }
    }

    pub fn waitRxne(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEvent(self, &checkRxne, timeout)) {
            return I2cError.TimeoutWaitRxne;
        }
    }

    fn checkRxne(self: *volatile I2c) bool {
        return self.sr1.rxne;
    }

    pub fn write(self: *volatile I2c, address: u10, data: []const u8, timeout: usize) I2cError!void {
        try self.sendAddress(@as(u16, address) << 1, timeout);
        try self.send(data, timeout);
        self.generateStop();
    }

    pub fn transfer(self: *volatile I2c, address: u10, wdata: []const u8, rdata: []u8, timeout: usize) I2cError!void {
        self.sendAddress(@as(u16, address) << 1, timeout);
        try self.send(wdata, timeout);
        self.cr1.ack = true;
        try self.sendAddress((@as(u16, address) << 1) | 1, timeout);
        try self.receive(rdata, timeout);
        self.generateStop();
    }

    pub fn scan(self: *volatile I2c, address: u10, timeout: usize) I2cError!void {
        try self.sendAddress(@as(u16, address) << 1, timeout);
        self.generateStop();
    }

    pub fn read(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        self.cr1.ack = true;
        try self.sendAddress((@as(u16, address) << 1) | 1, timeout);
        try self.receive(data, timeout);
        self.generateStop();
    }

    pub fn waitSb(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEvent(self, &checkSb, timeout)) {
            return I2cError.TimeoutWaitSb;
        }
    }

    pub fn waitNotBusy(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEvent(self, &checkNotBusy, timeout)) {
            return I2cError.TimeoutWaitNotBusy;
        }
    }

    pub fn waitAddrAf(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEventOrStop(self, &checkAddrAf, timeout)) {
            return I2cError.TimeoutWaitAddrAf;
        }
        if (self.sr1.af) {
            return I2cError.AcknowledgeFailure;
        }
        _ = self.sr2; // read SR2 to clear ADDR flag
    }

    pub fn waitBtfAf(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!waitEventOrStop(self, &checkBtfAf, timeout)) {
            return I2cError.TimeoutWaitBtfAf;
        }
        if (self.sr1.af) {
            return I2cError.AcknowledgeFailure;
        }
    }

    fn checkNotBusy(self: *volatile I2c) bool {
        return !self.sr2.busy;
    }

    fn checkSb(self: *volatile I2c) bool {
        return self.sr1.sb;
    }

    fn checkAddrAf(self: *volatile I2c) bool {
        return self.sr1.addr or self.sr1.af;
    }

    fn checkBtfAf(self: *volatile I2c) bool {
        return self.sr1.btf or self.sr1.af;
    }
};

pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);
pub const i2c2: *volatile I2c = @ptrFromInt(I2C2_BASE);
pub const i2c3: *volatile I2c = @ptrFromInt(I2C3_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x26, @sizeOf(I2c));
}
