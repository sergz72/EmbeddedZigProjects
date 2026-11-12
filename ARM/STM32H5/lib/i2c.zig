const struct_modify = @import("struct_modify");

const I2C1_BASE = 0x40005400;
const I2C2_BASE = 0x40005800;
const I2C3_BASE = 0x44002800;
const I2C4_BASE = 0x44002C00;

pub const I2cCr1 = bitpack struct(u32) {
    pe: bool = false,
    txie: bool = false,
    rxie: bool = false,
    addrie: bool = false,
    nackie: bool = false,
    stopie: bool = false,
    tcie: bool = false,
    errie: bool = false,
    dnf: u4 = 0,
    anfoff: bool = false,
    reserved0: u1 = 0,
    txdmaen: bool = false,
    rxdmaen: bool = false,
    sbc: bool = false,
    nostretch: bool = false,
    wupen: bool = false,
    gcen: bool = false,
    smbhen: bool = false,
    smbden: bool = false,
    alerten: bool = false,
    pecen: bool = false,
    fmp: bool = false,
    reserved1: u5 = 0,
    addraclr: bool = false,
    stopfaclr: bool = false,
};

pub const I2cCr2 = bitpack struct(u32) {
    sadd: u10 = 0,
    rd_wrn: bool = false,
    add10: bool = false,
    head10r: bool = false,
    start: bool = false,
    stop: bool = false,
    nack: bool = false,
    nbytes: u8 = 0,
    reload: bool = false,
    autoend: bool = false,
    pecbyte: bool = false,
    reserved0: u5 = 0,
};

pub const I2cOar1 = bitpack struct(u32) {
    oa1: u10 = 0,
    oa1mode: bool = false,
    reserved0: u4 = 0,
    oa1en: bool = false,
    reserved1: u16 = 0,
};

pub const I2cOar2 = bitpack struct(u32) {
    reserved0: u1 = 0,
    oa2: u7 = 0,
    oa2msk: u3 = 0,
    reserved1: u4 = 0,
    oa2en: bool = false,
    reserved2: u16 = 0,
};

pub const I2cTimingr = bitpack struct(u32) {
    scll: u8 = 0,
    sclh: u8 = 0,
    sdadel: u4 = 0,
    scldel: u4 = 0,
    reserved0: u4 = 0,
    presc: u4 = 0,
};

pub const I2cTimeoutr = bitpack struct(u32) {
    timeouta: u12 = 0,
    tidle: bool = false,
    reserved0: u2 = 0,
    timouten: bool = false,
    timeoutb: u12 = 0,
    reserved1: u3 = 0,
    texten: bool = false,
};

pub const I2cIsr = bitpack struct(u32) {
    txe: bool = true,
    txis: bool = false,
    rxne: bool = false,
    addr: bool = false,
    nackf: bool = false,
    stopf: bool = false,
    tc: bool = false,
    tcr: bool = false,
    berr: bool = false,
    arlo: bool = false,
    ovr: bool = false,
    pecerr: bool = false,
    timeout: bool = false,
    alert: bool = false,
    reserved0: u1 = 0,
    busy: bool = false,
    dir: bool = false,
    addcode: u7 = 0,
    reserved1: u8 = 0,
};

pub const I2cIcr = bitpack struct(u32) {
    reserved0: u3 = 0,
    addrcf: bool = false,
    nackcf: bool = false,
    stopcf: bool = false,
    reserved1: u2 = 0,
    berrcf: bool = false,
    arlocf: bool = false,
    ovrcf: bool = false,
    peccf: bool = false,
    timoutcf: bool = false,
    alertcf: bool = false,
    reserved2: u18 = 0,
};

pub const I2cPecr = bitpack struct(u32) {
    pec: u8 = 0,
    reserved0: u24 = 0,
};

pub const I2cError = error {
    TimeoutWaitStopf,
    TimeoutWaitTxis,
    TimeoutWaitRxne,
    TimeoutWaitNotBusy,
    TimeoutWaitTc,
    AcknowledgeFailure,
    UnsupportedSpeed,
    InvalidClock,
    NoValidTiming,
    DataIsTooLarge
};

pub const I2c = extern struct {
    cr1: I2cCr1,
    cr2: I2cCr2,
    oar1: I2cOar1,
    oar2: I2cOar2,
    timingr: I2cTimingr,
    timeoutr: I2cTimeoutr,
    isr: I2cIsr,
    icr: I2cIcr,
    pecr: I2cPecr,
    rxdr: u32,
    txdr: u32,

    pub inline fn enable(self: *volatile I2c) void {
        self.cr1.pe = true;
    }

    pub inline fn disable(self: *volatile I2c) void {
        self.cr1.pe = false;
    }

    pub fn initMaster(self: *volatile I2c, speed: usize, i2c_clock_frequency: usize) I2cError!void {
        self.timingr = try calcTimingr(speed,i2c_clock_frequency);
        self.cr2 = I2cCr2{.nack = true, .autoend = true};
        self.cr1 = I2cCr1{.pe = true};
    }

    fn waitEvent(self: *volatile I2c, event_fn: *const fn(*volatile I2c) bool, timeout: usize, check_af: bool) I2cError!bool {
        var t = timeout;
        while (t != 0) {
            if (check_af and self.isAcknowledgeFailed(timeout))
                return I2cError.AcknowledgeFailure;
            if (event_fn(self))
                break;
            t -= 1;
        }
        return t != 0;
    }

    fn flushTxdr(self: *volatile I2c) void {
        // If a pending TXIS flag is set
        // Write a dummy data in TXDR to clear it
        if(self.isr.txis)
            self.txdr = 0;

        // Flush TX register if not empty
        if (!self.isr.txe)
            self.isr.txe = true;
    }

    fn resetCr2(self: *volatile I2c) void {
        struct_modify.struct_modify(&self.cr2, .{
            .sadd = 0,
            .nbytes = 0,
            .rd_wrn = false,
            .reload = false,
            .head10r = false
        });
    }

    inline fn clearNackStopFlags(self: *volatile I2c) void {
        self.icr = I2cIcr{.nackcf = true, .stopcf = true};
    }

    fn isAcknowledgeFailed(self: *volatile I2c, timeout: usize) bool {
        if (self.isr.nackf) {
            var t = timeout;
            while (t != 0) {
                if (self.isr.stopf)
                    break;
                t -= 1;
            }
            if (t == 0) {
                return true;
            }
            self.clearNackStopFlags();
            self.flushTxdr();
            self.resetCr2();
            return true;
        }
        return false;
    }

    fn transferConfig(self: *volatile I2c, dev_address: u10, size: u8, rd_wrn: bool, autoend: bool, start: bool, reload: bool) void {
        var cr2 = self.cr2;
        cr2.sadd = dev_address << 1;
        cr2.nbytes = size;
        cr2.rd_wrn = rd_wrn;
        cr2.autoend = autoend;
        cr2.reload = reload;
        cr2.start = start;
        cr2.stop = false;
        self.cr2 = cr2;
    }

    fn waitNotBusy(self: *volatile I2c, timeout: usize) I2cError!void {
        if (!try self.waitEvent(checkNotBusy, timeout, false)) {
            return I2cError.TimeoutWaitNotBusy;
        }
    }

    pub fn write(self: *volatile I2c, address: u10, data: []const u8, timeout: usize) I2cError!void {
        if (data.len > 255) return I2cError.DataIsTooLarge;
        try self.waitNotBusy(timeout);
        self.transferConfig(address, @truncate(data.len), false, true, true, false);
        for (data) |byte| {
            if (!try self.waitEvent(checkTxis, timeout, true)) {
                return I2cError.TimeoutWaitTxis;
            }
            self.txdr = byte;
        }
        if (!try self.waitEvent(checkStopf, timeout, true)) {
            return I2cError.TimeoutWaitStopf;
        }
        self.clearNackStopFlags();
    }

    pub fn transfer(self: *volatile I2c, address: u10, wdata: []const u8, rdata: []u8, timeout: usize) I2cError!void {
        if (wdata.len > 255 or rdata.len > 255) return I2cError.DataIsTooLarge;
        try self.waitNotBusy(timeout);
        self.transferConfig(address, @truncate(wdata.len), false, false, true, false);
        for (wdata) |byte| {
            if (!try self.waitEvent(checkTxis, timeout, true)) {
                return I2cError.TimeoutWaitTxis;
            }
            self.txdr = byte;
        }
        if (!try self.waitEvent(checkTc, timeout, true)) {
            return I2cError.TimeoutWaitTc;
        }
        self.transferConfig(address, @truncate(rdata.len), true, true, true, false);
        for (rdata) |*byte| {
            if (!try self.waitEvent(checkRxne, timeout, false)) {
                return I2cError.TimeoutWaitRxne;
            }
            byte.* = @truncate(self.rxdr);
        }
        if (!try self.waitEvent(checkStopf, timeout, true)) {
            return I2cError.TimeoutWaitStopf;
        }
        self.clearNackStopFlags();
    }

    pub fn scan(self: *volatile I2c, address: u10, timeout: usize) I2cError!void {
        try self.waitNotBusy(timeout);
        self.transferConfig(address, 0, false, true, true, false);
        if (!try self.waitEvent(checkStopf, timeout, true)) {
            return I2cError.TimeoutWaitStopf;
        }
        self.clearNackStopFlags();
    }

    pub fn read(self: *volatile I2c, address: u10, data: []u8, timeout: usize) I2cError!void {
        if (data.len > 255) return I2cError.DataIsTooLarge;
        try self.waitNotBusy(timeout);
        self.transferConfig(address, @truncate(data.len), true, true, true, false);
        for (data) |*byte| {
            if (!try self.waitEvent(checkRxne, timeout, false)) {
                return I2cError.TimeoutWaitRxne;
            }
            byte.* = @truncate(self.rxdr);
        }
        if (!try self.waitEvent(checkStopf, timeout, true)) {
            return I2cError.TimeoutWaitStopf;
        }
        self.clearNackStopFlags();
    }

    fn checkTxis(self: *volatile I2c) bool {
        return self.isr.txis;
    }

    fn checkRxne(self: *volatile I2c) bool {
        return self.isr.rxne;
    }

    fn checkStopf(self: *volatile I2c) bool {
        return self.isr.stopf;
    }

    fn checkTc(self: *volatile I2c) bool {
        return self.isr.tc;
    }

    fn checkNotBusy(self: *volatile I2c) bool {
        return !self.isr.busy;
    }
};

pub const TimingConfig = struct {
    rise_ns: u64 = 100, // SCL/SDA rise time (real board value, not the spec max)
    fall_ns: u64 = 50, // SCL/SDA fall time
    analog_filter_ns: u64 = 50, // 0 if ANFOFF = 1
    dnf: u64 = 0, // digital filter length in I2CCLK cycles (0..15)
};

const DEFAULT_TIMING_CONFIG = TimingConfig{};

const Spec = struct {
    t_low_ns: u64,
    t_high_ns: u64,
    t_su_dat_ns: u64,
    t_hd_dat_ns: u64,
};

fn specFor(bus_hz: usize) ?Spec {
    if (bus_hz == 0) return null;
    if (bus_hz <= 100_000) return .{ .t_low_ns = 4700, .t_high_ns = 4000, .t_su_dat_ns = 250, .t_hd_dat_ns = 0 };
    if (bus_hz <= 400_000) return .{ .t_low_ns = 1300, .t_high_ns = 600, .t_su_dat_ns = 100, .t_hd_dat_ns = 0 };
    if (bus_hz <= 1_000_000) return .{ .t_low_ns = 500, .t_high_ns = 260, .t_su_dat_ns = 50, .t_hd_dat_ns = 0 };
    return null;
}

const ps_per_ns: u64 = 1000;
const ps_per_s: u64 = 1_000_000_000_000;

fn ceilDiv(a: u64, b: u64) u64 {
    return (a + b - 1) / b;
}

/// bus_hz: desired SCL frequency (e.g. 100_000, 400_000, 1_000_000)
/// i2cclk_hz: I2C kernel clock frequency
fn calcTimingr(bus_hz: usize, i2cclk_hz: usize) I2cError!I2cTimingr {
    return calcTimingrCfg(bus_hz, i2cclk_hz, &DEFAULT_TIMING_CONFIG);
}

fn calcTimingrCfg(bus_hz: usize, i2cclk_hz: usize, cfg: *const TimingConfig) I2cError!I2cTimingr {
    if (i2cclk_hz < bus_hz * 10) return I2cError.InvalidClock;
    const spec = specFor(bus_hz) orelse return I2cError.UnsupportedSpeed;

    const t_clk_ps = ps_per_s / i2cclk_hz;
    const t_scl_ps = ps_per_s / bus_hz;

    // t_sync1 + t_sync2 ~= tf + tr + 2*tI2CCLK + analog filter + DNF*tI2CCLK
    const sync_ps = (cfg.fall_ns + cfg.rise_ns + cfg.analog_filter_ns) * ps_per_ns + (2 + cfg.dnf) * t_clk_ps;
    if (t_scl_ps <= sync_ps) return I2cError.NoValidTiming;
    const avail_ps = t_scl_ps - sync_ps; // time available for (SCLL+1) + (SCLH+1)

    const low_min_ps = spec.t_low_ns * ps_per_ns;
    const high_min_ps = spec.t_high_ns * ps_per_ns;

    var presc: u64 = 0;
    while (presc < 16) : (presc += 1) {
        const t_presc = (presc + 1) * t_clk_ps;

        // Minimum number of steps for each phase.
        const low_min = ceilDiv(low_min_ps, t_presc);
        const high_min = ceilDiv(high_min_ps, t_presc);

        // Total steps available at the requested frequency.
        const total = avail_ps / t_presc;
        if (total < low_min + high_min) continue; // can't meet spec at this speed
        if (total > 512) continue; // doesn't fit 2 x 8 bit, use a bigger prescaler

        // Split proportionally to the spec's low/high ratio, then enforce minimums.
        var n_low = total * low_min_ps / (low_min_ps + high_min_ps);
        if (n_low < low_min) n_low = low_min;
        var n_high = total - n_low;
        if (n_high < high_min) {
            n_high = high_min;
            n_low = total - n_high;
        }
        if (n_low < 1 or n_high < 1 or n_low > 256 or n_high > 256) continue;

        // SCLDEL: (SCLDEL+1)*tPRESC >= tr + tSU;DAT
        const scldel_ps = (cfg.rise_ns + spec.t_su_dat_ns) * ps_per_ns;
        const scldel_steps = ceilDiv(scldel_ps, t_presc);
        if (scldel_steps < 1 or scldel_steps - 1 > 15) continue;

        // SDADEL: SDADEL*tPRESC >= tHD;DAT (min). Upper limit tVD;DAT(max) is easily met
        // for sane values, but check roughly against the data valid time budget.
        const sdadel_steps = ceilDiv(spec.t_hd_dat_ns * ps_per_ns, t_presc);
        if (sdadel_steps > 15) continue;

        return .{
            .scll = @truncate(n_low - 1),
            .sclh = @truncate(n_high - 1),
            .sdadel = @truncate(sdadel_steps),
            .scldel = @truncate(scldel_steps - 1),
            .presc = @truncate(presc),
        };
    }
    return I2cError.NoValidTiming;
}

pub const i2c1: *volatile I2c = @ptrFromInt(I2C1_BASE);
pub const i2c2: *volatile I2c = @ptrFromInt(I2C2_BASE);
pub const i2c3: *volatile I2c = @ptrFromInt(I2C3_BASE);
pub const i2c4: *volatile I2c = @ptrFromInt(I2C4_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2C, @sizeOf(I2c));
}

test "400 kHz @ 64 MHz" {
    const std = @import("std");

    const t = try calcTimingr(400_000, 64_000_000);
    const raw: u32 = @bitCast(t);
    std.debug.print("TIMINGR = 0x{X:0>8}\n", .{raw});
    try std.testing.expectEqual(0xC02D62, @backingInt(t));
}

test "100 kHz @ 48 MHz" {
    const std = @import("std");

    const t = try calcTimingr(100_000, 48_000_000);
    const raw: u32 = @bitCast(t);
    std.debug.print("TIMINGR = 0x{X:0>8}\n", .{raw});
    try std.testing.expectEqual(0x10806B7D, @backingInt(t));
}