const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const I2C0_BASE: usize = 0x400F0000 + 0x800;
const I2C1_BASE: usize = 0x400F2000 + 0x800;

pub const I2cError = error {
    Timeout, ErrorStatus, TxFifoFull, DataIsTooLarge
};

pub const I2cSlave = extern struct {
    soar: u32,
    soar2: u32,
    sctr: u32,
    ssr: u32,
    srxdata: u32,
    stxdata: u32,
    sackctl: u32,
    sfifoctl: u32,
    sfifosr: u32,
    target_pecctl: u32,
    target_pecsr: u32,
};

pub const I2cMctr = packed struct(u32) {
    burstrun: bool = false,
    start: bool = false,
    stop: bool = false,
    ack: bool = false,
    cackoen: bool = false,
    rd_on_txempty: bool = false,
    reserved: u10 = 0,
    cblen: u12 = 0,
    reserved2: u4 = 0
};

pub const I2cMfifoCtl = packed struct(u32) {
    txtrig: u3 = 0,
    reserved: u4 = 0,
    txflush: bool = false,
    rxtrig: u3 = 0,
    reserved2: u4 = 0,
    rxflush: bool = false,
    reserved3: u16 = 0
};

pub const I2cMcr = packed struct(u32) {
    active: bool = false,
    mctl: bool = false,
    clkstretch: bool = false,
    reserved: u5 = 0,
    lpbk: bool = false,
    reserved2: u23 = 0
};

pub const I2cMsr = packed struct(u32) {
    busy: bool,
    err: bool,
    adrack: bool,
    dataack: bool,
    arblst: bool,
    idle: bool,
    busbsy: bool,
    reserved: u9,
    cbcnt: u12,
    reserved2: u4
};

pub const I2cMfifoSr = packed struct(u32) {
    rxfifocnt: u4,
    reserved: u3,
    rxflush: bool,
    txfifocnt: u4,
    reserved2: u3,
    txflush: bool,
    reserved3: u16 = 0
};

pub const I2cMsa = packed struct(u32) {
    dir_receive: bool = false,
    taddr: u10 = 0,
    reserved: u4 = 0,
    cmode_10bit: bool = false,
    reserved2: u16 = 0
};

pub const I2cMaster = extern struct {
    msa: I2cMsa,
    mctr: I2cMctr,
    msr: I2cMsr,
    mrxdata: u32,
    mtxdata: u32,
    mtpr: u32,
    mcr: I2cMcr,
    reserved0: [2]u32,
    mbmon: u32,
    mfifoctl: I2cMfifoCtl,
    mfifosr: I2cMfifoSr,
    controller_i2cpecctl: u32,
    controller_pecsr: u32,
};

pub const I2cDmaTrig = extern struct {
    iidx: u32,
    reserved0: u32,
    imask: u32,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const I2cIntIIdx = enum(u32) {
    no_interupt = 0,
    data_received = 1,
    data_transmitted = 2,
    receive_fifo_trigger = 3,
    transmit_fifo_trigger = 4,
    rx_fifo_full = 5,
    tx_fifo_empty = 6,
    nack = 8,
    start = 9,
    stop = 10,
    arbitration_lost = 11,
    dma_done_tx = 12,
    dma_done_rx = 13,
    pec = 14,
    timeout_a = 15,
    timeout_b = 16,
    target_data1 = 0x11,
    target_data2 = 0x12,
    target_receive_fifo_trigger = 0x13,
    target_transmit_fifo_trigger = 0x14,
    target_rx_fifo_full = 0x15,
    target_tx_fifo_empty = 0x16,
    target_start = 0x17,
    target_stop = 0x18,
    target_general_call = 0x19,
    target_dma_done_tx = 0x1A,
    target_dma_done_rx = 0x1B,
    target_pec = 0x1C,
    target_tx_fifo_underflow = 0x1D,
    target_rx_fifo_overflow = 0x1E,
    target_arbitration_lost = 0x1F,
    interrupt_overflow = 0x20
};

pub const I2cIntIMask = packed struct(u32) {
    crxdone: bool = false,
    ctxdone: bool = false,
    crxfifotrg: bool = false,
    ctxfifotrg: bool = false,
    crxfifofull: bool = false,
    ctxempty: bool = false,
    reserved: u1 = 0,
    cnack: bool = false,
    cstart: bool = false,
    cstop: bool = false,
    carblost: bool = false,
    cdma_done_tx: bool = false,
    cdma_done_rx: bool = false,
    cpec_rx_err: bool = false,
    timeouta: bool = false,
    timeoutb: bool = false,
    trxdone: bool = false,
    ttxdone: bool = false,
    trxfifotrg: bool = false,
    ttxfifotrg: bool = false,
    trxfifofull: bool = false,
    ttxempty: bool = false,
    tstart: bool = false,
    tstop: bool = false,
    tgencall: bool = false,
    tdma_done_tx: bool = false,
    tdma_done_rx: bool = false,
    tpec_rx_err: bool = false,
    ttx_unfl: bool = false,
    trx_ovfl: bool = false,
    tarblost: bool = false,
    intr_ovfl: bool = false
};

pub const I2cInt = extern struct {
    iidx: I2cIntIIdx,
    reserved0: u32,
    imask: I2cIntIMask,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const I2cGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    clkcfg: u32,
    reserved0: [2]u32,
    stat: u32,
};

pub const I2cGfctl = packed struct(u32) {
    dgfsel: u3 = 0,
    reserved: u5 = 0,
    agfen: bool = true,
    agfsel: u2 = 3,
    chain: bool = true,
    reserved2: u20 = 0
};

pub const I2c = extern struct {
    gprcm: I2cGprcm,
    reserved1: [506]u32,
    clkdiv: common.ClkDiv,
    clksel: common.Clksel2,
    reserved2: [4]u32,
    pdbgctl: u32,
    reserved3: u32,
    cpu_int: I2cInt,
    reserved4: u32,
    dma_trig1: I2cDmaTrig,
    reserved5: u32,
    dma_trig0: I2cDmaTrig,
    reserved6: [13]u32,
    evt_mode: u32,
    intctl: u32,
    reserved7: [5]u32,
    desc: u32,
    reserved8: [64]u32,
    gfctl: I2cGfctl,
    timeout_ctl: u32,
    timeout_cnt: u32,
    reserved9: u32,
    master: I2cMaster,
    reserved10: [2]u32,
    slave: I2cSlave,

    pub inline fn enablePower(self: *volatile I2c) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub inline fn reset(self: *volatile I2c) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }

    pub inline fn disableAnalogGlitchFilter(self: *volatile I2c) void {
        self.gfctl.agfen = false;
    }

    pub inline fn resetControllerTransfer(self: *volatile I2c) void {
        self.master.mctr = .{};
    }

    pub inline fn setSpeed(self: *volatile I2c, speed: usize, i2c_clock_speed: usize) void {
        const mtpr = i2c_clock_speed / speed / 10 - 1;
        self.master.mtpr = if (mtpr > 0x7F) 0x7F else @truncate(mtpr);
    }

    pub inline fn setControllerTXFIFOThreshold(self: *volatile I2c, threshold: u3) void {
        self.master.mfifoctl.txtrig = threshold;
    }

    pub inline fn setControllerRXFIFOThreshold(self: *volatile I2c, threshold: u3) void {
        self.master.mfifoctl.rxtrig = threshold;
    }

    pub inline fn enableControllerClockStretching(self: *volatile I2c) void {
        self.master.mcr.clkstretch = true;
    }

    pub inline fn enableController(self: *volatile I2c) void {
        self.master.mcr.active = true;
    }

    pub fn waitIdle(self: *volatile I2c, timeout: usize) I2cError!void {
        var t = timeout;
        while (t != 0)
        {
            if (self.master.msr.idle)
                break;
            t -= 1;
        }
        if (t == 0)
            return I2cError.Timeout;
    }

    pub fn waitIdleWithStop(self: *volatile I2c, timeout: usize) I2cError!void {
        var t = timeout;
        while (t != 0)
        {
            if (self.master.msr.idle)
                break;
            t -= 1;
        }
        if (t == 0) {
            self.enableStopCondition();
            return I2cError.Timeout;
        }
    }

    pub fn waitBusy(self: *volatile I2c, timeout: usize) I2cError!void {
        var t = timeout;
        while (t != 0)
        {
            if (self.master.msr.err) {
                self.enableStopCondition();
                return I2cError.ErrorStatus;
            }
            if (!self.master.msr.busy)
                break;
            t -= 1;
        }
        if (t == 0) {
            self.enableStopCondition();
            return I2cError.Timeout;
        }
    }

    pub fn waitBusyBus(self: *volatile I2c, timeout: usize) I2cError!void {
        var t = timeout;
        while (t != 0)
        {
            if (self.master.msr.err) {
                self.enableStopCondition();
                return I2cError.ErrorStatus;
            }
            if (!self.master.msr.busbsy)
                break;
            t -= 1;
        }
        if (t == 0) {
            self.enableStopCondition();
            return I2cError.Timeout;
        }
    }

    pub inline fn isControllerTXFIFOFull(self: *volatile I2c) bool {
        return self.master.mfifosr.txfifocnt == 0;
    }

    pub fn fillControllerTXFIFO(self: *volatile I2c, data: []u8) I2cError!void {
        for (data) |d| {
            if (self.isControllerTXFIFOFull())
                return I2cError.TxFifoFull;
            self.master.mtxdata = d;
        }
    }

    pub fn startControllerTransfer(self: *volatile I2c, address: u10, dir_receive: bool, length: u12) void {
        self.master.msa = .{.dir_receive = dir_receive, .taddr = address};
        self.master.mctr = .{.start = true, .stop = true, .burstrun = true, .cblen = length};
    }

    pub fn startControllerTransmitTransferNoStop(self: *volatile I2c, address: u10, length: u12) void {
        self.master.msa = .{.dir_receive = false, .taddr = address};
        self.master.mctr = .{.start = true, .burst_run = true, .cblen = length};
    }

    pub fn startControlleRreceiveTransferRepeatedStart(self: *volatile I2c, address: u10, length: u12) void {
        self.master.msa = .{.dir_receive = true, .taddr = address};
        self.master.mctr = .{.start = true, .stop = true, .burst_run = true, .cblen = length, .ack = true};
    }

    pub fn enableStopCondition(self: *volatile I2c) void {
        self.master.mctr.stop = true;
    }

    pub fn write(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        if (data.len >= 4096)
            return I2cError.DataIsTooLarge;
        try self.fillControllerTXFIFO(data);
        try self.waitIdle(timeout);
        self.startControllerTransfer(address, false, @truncate(data.len));
        try self.waitBusyBus(timeout);
        try self.waitIdleWithStop(timeout);
    }

    pub fn isControllerRXFIFOEmpty(self: *volatile I2c) bool {
        return self.master.mfifosr.rxfifocnt == 0;
    }

    pub fn transfer(self: *volatile I2c, address: u10, wdata: []u8, rdata: []u8, timeout: usize) I2cError!void {
        if (wdata.len >= 4096 or rdata.len >= 4096)
            return I2cError.DataIsTooLarge;
        try self.fillControllerTXFIFO(wdata);
        try self.waitIdle(timeout);
        self.startControllerTransmitTransferNoStop(address, @truncate(wdata.len));
        try self.waitBusy(timeout);
        self.startControllerReceiveTransferRepeatedStart(address, @truncate(rdata.len));
        try self.receive(rdata, timeout);
    }

    fn receive(self: *volatile I2c, rdata: []u8, timeout: usize) I2cError!void {
        for (0..rdata.len) |idx| {
            var t = timeout;
            while (t != 0) {
                if (!self.isControllerRXFIFOEmpty())
                    break;
                t -= 1;
            }
            if (t == 0) {
                self.enableStopCondition();
                return I2cError.Timeout;
            }
            rdata[idx] = @truncate(self.master.mrxdata);
        }
    }

    pub fn scan(self: *volatile I2c, address: u10, timeout: usize) I2cError!void {
        //self.startControllerTransfer(address, true, 0);
        //try self.waitBusyBus(timeout);
        //try self.waitIdleWithStop(timeout);
        var data: [1]u8 = undefined;
        return self.read(address, &data, timeout);
    }

    pub fn read(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        if (data.len >= 4096)
            return I2cError.DataIsTooLarge;
        try self.waitIdle(timeout);
        self.startControllerTransfer(address, true, @truncate(data.len));
        try self.receive(data, timeout);
    }
};

pub const i2c0: *volatile I2c = @ptrFromInt(I2C0_BASE);
pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x127C-0x800, @sizeOf(I2c));
}
