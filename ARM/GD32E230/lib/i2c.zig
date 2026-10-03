const cpu = @import("cpu");

const I2C0_BASE: usize = 0x40005400;
const I2C1_BASE: usize = 0x40005800;

pub const I2cError = error {
    TimeoutWaitNotBusy,
    TimeoutWaitMasterModeSelect,
    TimeoutWaitMasterTransmitterModeSelected,
    TimeoutWaitMasterReceiverModeSelected,
    TimeoutWaitTxe,
    TimeoutWaitRxne,
    TimeoutWaitMasterByteTransitted
};

pub const I2cCtl0 = packed struct(u32) {
    i2cen: bool = false,
    smben: bool = false,
    reserved: u1 = 0,
    smbsel: bool = false,
    arpen: bool = false,
    pecen: bool = false,
    gcen: bool = false,
    ss: bool = false,
    start: bool = false,
    stop: bool = false,
    acken: bool = false,
    poap: bool = false,
    pectrans: bool = false,
    salt: bool = false,
    reserved2: u1 = 0,
    sreset: bool = false,
    reserved3: u16 = 0
};

pub const I2cCtl1 = packed struct(u32) {
    i2cclk: u7 = 0,
    reserved: u1 = 0,
    errie: bool = false,
    evie: bool = false,
    bufie: bool = false,
    dmaon: bool = false,
    dmalst: bool = false,
    reserved2: u2 = 0,
    rbnecm: bool = false,
    reserved3: u16 = 0
};

pub const I2cSaddr0 = packed struct(u32) {
    address: u10 = 0,
    reserved: u5 = 0,
    addformat_10bit: bool = false,
    reserved2: u16 = 0
};

pub const I2cSaddr1 = packed struct(u32) {
    duaden: bool = false,
    address2: u7 = 0,
    reserved: u24 = 0
};

pub const I2cStat0 = packed struct(u32) {
    sbsend: bool,
    addsend: bool,
    btc: bool,
    add10send: bool,
    stpdet: bool,
    reserved: u1,
    rbne: bool,
    tbe: bool,
    berr: bool,
    lostarb: bool,
    aerr: bool,
    ouerr: bool,
    pecerr: bool,
    reserved2: u1,
    smbto: bool,
    smbalt: bool,
    reserved3: u16
};

pub const I2cStat1 = packed struct(u32) {
    master: bool,
    i2cbsy: bool,
    tr: bool,
    reserved: u1,
    rxgc: bool,
    defsmb: bool,
    hstsmb: bool,
    dumodf: bool,
    pecv: u8,
    reserved2: u16
};

pub const I2cCkCfg = packed struct(u32) {
    clkc: u12 = 0,
    reserved: u2 = 0,
    dtcy: bool = false,
    fast: bool = false,
    reserved2: u16 = 0
};

pub const I2cRt = packed struct(u32) {
    risetime: u7 = 2,
    reserved: u25 = 0
};

pub const I2c = extern struct {
    ctl0: I2cCtl0,
    ctl1: I2cCtl1,
    saddr0:  I2cSaddr0,
    saddr1: I2cSaddr1,
    data: u32,
    stat0: I2cStat0,
    stat1: I2cStat1,
    ckcfg: I2cCkCfg,
    rt: I2cRt,
    reserved: [23]u32,
    //0x80
    samcs: u32,
    reserved2: [3]u32,
    //0x90
    fmpcfg: u32,

    pub fn initMaster(self: *volatile I2c, speed: usize) void {
        self.ctl0 = .{};
        var freq = cpu.cpu.pclk1_frequency / 1000000;
        if (freq < 2) {
            freq = 2;
        } else if (freq > 72) {
            freq = 72;
        }
        self.ctl1 = .{.i2cclk = @truncate(freq)};
        if (speed <= 100000) {
            self.rt = .{.risetime = @truncate(freq+1)};
            var ccr = cpu.cpu.pclk1_frequency / (speed << 1);
            if (ccr < 4)
                ccr = 4;
            self.ckcfg = .{.clkc = @truncate(ccr)};
        } else {
            var ccr = cpu.cpu.pclk1_frequency / (speed * 3);
            if (ccr == 0)
                ccr = 1;
            self.rt = .{.risetime = @truncate(freq * 3 / 10 + 1)};
            self.ckcfg = .{.clkc = @truncate(ccr), .fast = true};
        }
        self.ctl0 = .{.i2cen = true};
    }

    fn checkNotBusy(self: *volatile I2c) bool {
        return !self.stat1.i2cbsy;
    }

    fn checkTxe(self: *volatile I2c) bool {
        return self.stat0.tbe;
    }

    fn checkRxne(self: *volatile I2c) bool {
        return self.stat0.rbne;
    }

    fn checkMasterModeSelect(self: *volatile I2c) bool {
        const s1 = self.stat0;
        const s2 = self.stat1;
        return s1.sbsend and s2.i2cbsy and s2.master;
    }

    fn checkMasterTransmitterModeSelected(self: *volatile I2c) bool {
        const s1 = self.stat0;
        const s2 = self.stat1;
        return s1.addsend and s1.tbe and s2.i2cbsy and s2.master and s2.tr;
    }

    fn checkMasterReceiverModeSelected(self: *volatile I2c) bool {
        const s1 = self.stat0;
        const s2 = self.stat1;
        return s1.addsend and s2.i2cbsy and s2.master;
    }

    fn checkMasterByteTransmitted(self: *volatile I2c) bool {
        const s1 = self.stat0;
        const s2 = self.stat1;
        return s1.btc and s1.tbe and s2.i2cbsy and s2.master and s2.tr;
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
            self.ctl0.stop = true;
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
        self.ctl0.start = true;


        if (!self.waitEvent(checkMasterModeSelect, timeout))
            return I2cError.TimeoutWaitMasterModeSelect;

        // sending address
        var addr = address << 1;
        if (!transmitter_mode)
            addr |= 1;
        self.data = addr;

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
            self.data = d;
            if (!self.waitEventOrStop(checkMasterByteTransmitted, timeout))
                return I2cError.TimeoutWaitMasterByteTransitted;
        }
    }

    fn receiveData(self: *volatile I2c, data: []u8, timeout: usize) I2cError!void {
        for (0..data.len) |idx| {
            if (idx == data.len - 1)
                self.ctl0.acken = false;
            if (!self.waitEventOrStop(checkRxne, timeout))
                return I2cError.TimeoutWaitRxne;
            data[idx] = @truncate(self.data);
        }
    }

    pub fn write(self: *volatile I2c, address: u10, data: []const u8, timeout: usize) I2cError!void {
        try self.sendAddress(address, timeout, true, true);
        try self.sendData(data, timeout);
        self.ctl0.stop = true;
    }

    pub fn transfer(self: *volatile I2c, address: u10, wdata: []const u8, rdata: []u8, timeout: usize) I2cError!void {
        self.ctl0.acken = true;
        try self.sendAddress(address, timeout, true, true);
        try self.sendData(wdata, timeout);
        try self.sendAddress(address, timeout, false, false);
        try self.receiveData(rdata, timeout);
        self.ctl0.stop = true;
    }

    pub fn scan(self: *volatile I2c, address: u10, timeout: usize) I2cError!void {
        try self.sendAddress(address, timeout, true, true);
        self.ctl0.stop = true;
    }

    pub fn read(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        self.ctl0.acken = true;
        try self.sendAddress(address, timeout, false, true);
        try self.receiveData(data, timeout);
        self.ctl0.stop = true;
    }
};

pub const i2c0: *volatile I2c = @ptrFromInt(I2C0_BASE);
pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x94, @sizeOf(I2c));
}
