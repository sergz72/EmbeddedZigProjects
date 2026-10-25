const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");

const I2C0_BASE: usize = 0x400F0000 + 0x800;
const I2C1_BASE: usize = 0x400F2000 + 0x800;

pub const I2cError = error {
    TimeoutWaitIdle,
    TimeoutWaitBusyBus,
    TimeoutWaitIdleWithStop,
    ErrorStatus,
    Nack,
    ArbitrationLost,
    DataIsTooLarge
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
    ris: I2cIntIMask,
    reserved2: u32,
    mis: I2cIntIMask,
    reserved3: u32,
    iset: I2cIntIMask,
    reserved4: u32,
    iclr: I2cIntIMask,
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

const ControllerStatus = enum(usize) {
    idle, tx_started, tx_in_progress, tx_complete, rx_started, rx_in_progress, rx_complete,
    arbitration_lost, nack
};

const ControllerData = struct {
    status: ControllerStatus,
    tx_buffer: []const u8 = undefined,
    tx_index: usize = undefined,
    rx_buffer: []u8 = undefined,
    rx_index: usize = undefined
};

var controller_data: [2]ControllerData = undefined;

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
        const v = common.GprcmPwren{.enable = true};
        self.gprcm.pwren = v;
    }

    pub inline fn reset(self: *volatile I2c) void {
        const v = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
        self.gprcm.rstctl = v;
    }

    pub inline fn disableAnalogGlitchFilter(self: *volatile I2c) void {
        self.gfctl.agfen = false;
    }

    pub inline fn resetControllerTransfer(self: *volatile I2c) void {
        self.master.mctr = .{};
    }

    pub inline fn setSpeed(self: *volatile I2c, speed: usize, i2c_clock_speed: usize) void {
        var mtpr = i2c_clock_speed / speed / 10 - 1;
        if (mtpr > 0x7F) {
            mtpr = 0x7F;
        }
        self.master.mtpr = @truncate(mtpr);
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

    pub inline fn disableController(self: *volatile I2c) void {
        self.master.mcr.active = false;
    }

    pub inline fn isControllerTXFIFOFull(self: *volatile I2c) bool {
        return self.master.mfifosr.txfifocnt == 0;
    }

    pub fn flushControllerTXFIFO(self: *volatile I2c) void {
        self.master.mfifoctl.txflush = true;
        while (self.master.mfifosr.txfifocnt != 8) {
            asm volatile("nop");
        }
        self.master.mfifoctl.txflush = false;
    }

    pub fn flushControllerRXFIFO(self: *volatile I2c) void {
        self.master.mfifoctl.rxflush = true;
        while (self.master.mfifosr.rxfifocnt != 0) {
            asm volatile("nop");
        }
        self.master.mfifoctl.rxflush = false;
    }

    pub fn fillControllerTXFIFO(self: *volatile I2c, data: []const u8, index: usize) usize {
        var idx = index;
        while (idx < data.len) {
            if (self.isControllerTXFIFOFull())
                return idx;
            self.master.mtxdata = data[idx];
            idx += 1;
        }
        return idx;
    }

    pub fn startControllerTransfer(self: *volatile I2c, address: u10, dir_receive: bool, length: u12, ack: bool) void {
        const v = I2cMsa{.dir_receive = dir_receive, .taddr = address};
        self.master.msa = v;
        const v2 = I2cMctr{.start = true, .stop = true, .burstrun = true, .cblen = length, .ack = ack};
        self.master.mctr = v2;
    }

    pub fn startControllerTransmitTransferNoStop(self: *volatile I2c, address: u10, length: u12) void {
        const v = I2cMsa{.dir_receive = false, .taddr = address};
        self.master.msa = v;
        const v2 = I2cMctr{.start = true, .burstrun = true, .cblen = length};
        self.master.mctr = v2;
    }

    pub fn startControllerReceiveTransferRepeatedStart(self: *volatile I2c, address: u10, length: u12) void {
        const v = I2cMsa{.dir_receive = true, .taddr = address};
        self.master.msa = v;
        const v2 = I2cMctr{.start = true, .stop = true, .burstrun = true, .cblen = length};//, .ack = true};
        self.master.mctr = v2;
    }

    pub fn stop(self: *volatile I2c) void {
        const v = I2cMctr{.stop = true, .burstrun = true};
        self.master.mctr = v;
    }

    pub fn isControllerRXFIFOEmpty(self: *volatile I2c) bool {
        return self.master.mfifosr.rxfifocnt == 0;
    }

    pub fn getControllerData(self: *volatile I2c) *ControllerData {
        if (self == i2c0) {
            return &controller_data[0];
        } else {
            return &controller_data[1];
        }
    }

    pub fn irqHandler(self: *volatile I2c) void {
        @setRuntimeSafety(false);
        const data = self.getControllerData();
        switch (self.cpu_int.iidx) {
            .data_received => {
                data.status = .rx_complete;
            },
            .data_transmitted => {
                self.cpu_int.imask.ctxfifotrg = false;
                data.status = .tx_complete;
            },
            .receive_fifo_trigger => {
                data.status = .rx_in_progress;
                while (!self.isControllerRXFIFOEmpty()) {
                    if (data.rx_index < data.rx_buffer.len) {
                        data.rx_buffer[data.rx_index] = @truncate(self.master.mrxdata);
                        data.rx_index += 1;
                    } else {
                        _ = self.master.mrxdata;
                    }
                }
            },
            .transmit_fifo_trigger => {
                data.status = .tx_in_progress;
                data.tx_index = self.fillControllerTXFIFO(data.tx_buffer, data.tx_index);
            },
            .arbitration_lost => {
                if (data.status == .rx_started or data.status == .tx_started) {
                    data.status = .arbitration_lost;
                }
            },
            .nack => {
                if (data.status == .rx_started or data.status == .tx_started) {
                    data.status = .nack;
                }
            },
            else => {}
        }
    }

    pub fn waitIdle(self: *volatile I2c, timeout: usize, error_check: bool) I2cError!void {
        var t = timeout;
        while (t != 0)
        {
            if (error_check and self.master.msr.err) {
                self.stop();
                return I2cError.ErrorStatus;
            }
            if (self.master.msr.idle)
                break;
            t -= 1;
        }
        if (t == 0)
            return I2cError.TimeoutWaitIdle;
    }

    pub fn waitIdleWithStop(self: *volatile I2c, timeout: usize, error_check: bool) I2cError!void {
        var t = timeout;
        while (t != 0)
        {
            if (error_check and self.master.msr.err) {
                self.stop();
                return I2cError.ErrorStatus;
            }
            if (self.master.msr.idle)
                break;
            t -= 1;
        }
        if (t == 0) {
            self.stop();
            return I2cError.TimeoutWaitIdleWithStop;
        }
    }

    pub fn waitBusyBus(self: *volatile I2c, timeout: usize, error_check: bool) I2cError!void {
        var t = timeout;
        while (t != 0)
        {
            if (error_check and self.master.msr.err) {
                self.stop();
                return I2cError.ErrorStatus;
            }
            if (!self.master.msr.busbsy)
                break;
            t -= 1;
        }
        if (t == 0) {
            self.stop();
            return I2cError.TimeoutWaitBusyBus;
        }
    }

    fn startTx(self: *volatile I2c, data: []const u8, timeout: usize) I2cError!*ControllerData {
        self.flushControllerTXFIFO();
        try self.waitIdle(timeout, false);
        const cdata = self.getControllerData();
        cdata.tx_buffer = data;
        cdata.tx_index = self.fillControllerTXFIFO(data, 0);
        if (cdata.tx_index < cdata.tx_buffer.len) {
            self.cpu_int.imask.ctxfifotrg = true;
        }
        cdata.status = .tx_started;
        return cdata;
    }

    pub fn write(self: *volatile I2c, address: u10, data: []const u8, timeout: usize) I2cError!void {
        if (data.len >= 4096)
            return I2cError.DataIsTooLarge;
        try self.waitBusyBus(timeout, false);
        const cdata = try self.startTx(data, timeout);
        self.startControllerTransfer(address, false, @truncate(data.len), false);
        try finishTx(cdata);
    }

    pub fn transfer(self: *volatile I2c, address: u10, wdata: []const u8, rdata: []u8, timeout: usize) I2cError!void {
        if (wdata.len >= 4096 or rdata.len >= 4096)
            return I2cError.DataIsTooLarge;
        try self.waitBusyBus(timeout, false);
        self.flushControllerRXFIFO();
        const cdata = try self.startTx(wdata, timeout);
        self.startControllerTransmitTransferNoStop(address, @truncate(wdata.len));
        try finishTx(cdata);
        cdata.rx_buffer = rdata;
        cdata.rx_index = 0;
        cdata.status = .rx_started;
        self.startControllerReceiveTransferRepeatedStart(address, @truncate(rdata.len));
        try finishRx(cdata);
    }

    fn clearInterruptFlags(self: *volatile I2c) void {
        self.cpu_int.iclr = @bitCast(@as(u32, 0xFFFFFFFF));
    }

    pub fn scan(self: *volatile I2c, address: u10, timeout: usize) I2cError!void {
        try self.waitBusyBus(timeout, false);
        const cdata = try self.startTx(&.{}, timeout);
        self.startControllerTransfer(address, false, 0, false);
        try finishTx(cdata);
        if (self.master.msr.err) {
            return I2cError.ErrorStatus;
        }
    }

    pub fn read(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        if (data.len >= 4096)
            return I2cError.DataIsTooLarge;
        self.flushControllerRXFIFO();
        try self.waitIdle(timeout, false);
        const cdata = self.getControllerData();
        cdata.rx_buffer = data;
        cdata.rx_index = 0;
        cdata.status = .rx_started;
        self.startControllerTransfer(address, true, @truncate(data.len), false);
        try finishRx(cdata);
    }

    pub fn init(self: *volatile I2c, speed: usize) void {
        self.disableAnalogGlitchFilter();
        self.resetControllerTransfer();
        self.setSpeed(speed, cpu.cpu.current_frequency / 8);
        self.setControllerTXFIFOThreshold(0);
        self.setControllerRXFIFOThreshold(0);
        self.enableControllerClockStretching();
        self.enableController();
        const v = I2cIntIMask{
            .carblost = true,
            .cnack = true,
            .crxfifotrg = true,
            .crxdone = true,
            .ctxdone = true
        };
        self.cpu_int.imask = v;
        if (self == i2c0) {
            nvic.nvic.enableInterrupt(interrupts.Interrupt.I2C0.toU8());
        } else {
            nvic.nvic.enableInterrupt(interrupts.Interrupt.I2C1.toU8());
        }
    }
};

fn finishTx(cdata: *ControllerData) I2cError!void {
    while (true) {
        switch (cdata.status) {
            .tx_complete => return,
            .nack => return I2cError.Nack,
            .arbitration_lost => return I2cError.ArbitrationLost,
            else => {
                asm volatile("wfi");
            }
        }
    }
}

fn finishRx(cdata: *ControllerData) I2cError!void {
    while (true) {
        switch (cdata.status) {
            .rx_complete => return,
            else => {
                asm volatile("wfi");
            }
        }
    }
}

export fn I2C1_IRQHandler() callconv(.c) void {
    i2c1.irqHandler();
}

export fn I2C0_IRQHandler() callconv(.c) void {
    i2c0.irqHandler();
}

pub const i2c0: *volatile I2c = @ptrFromInt(I2C0_BASE);
pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x127C-0x800, @sizeOf(I2c));
}
