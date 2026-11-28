const LPSPI0_BASE = 0x40092000;
const LPSPI1_BASE = 0x40093000;
const LPSPI2_BASE = 0x40094000;
const LPSPI3_BASE = 0x40095000;
const LPSPI4_BASE = 0x400B4000;
const LPSPI5_BASE = 0x400B5000;
const LPSPI6_BASE = 0x400B6000;
const LPSPI7_BASE = 0x400B7000;

pub const Verid = bitpack struct(u32) {
    feature: u16,
    minor: u8,
    major: u8,
};

pub const Param = bitpack struct(u32) {
    txfifo: u8,
    rxfifo: u8,
    pcsnum: u8,
    reserved0: u8,
};

pub const Cr = bitpack struct(u32) {
    men: bool = false,
    rst: bool = false,
    reserved0: u1 = 0,
    dbgen: bool = false,
    reserved1: u4 = 0,
    rtf: bool = false,
    rrf: bool = false,
    reserved2: u22 = 0,
};

pub const Sr = bitpack struct(u32) {
    tdf: bool = true,
    rdf: bool = false,
    reserved0: u6 = 0,
    wcf: bool = false,
    fcf: bool = false,
    tcf: bool = false,
    tef: bool = false,
    ref: bool = false,
    dmf: bool = false,
    reserved1: u10 = 0,
    mbf: bool = false,
    reserved2: u7 = 0,
};

pub const Ier = bitpack struct(u32) {
    tdie: bool = false,
    rdie: bool = false,
    reserved0: u6 = 0,
    wcie: bool = false,
    fcie: bool = false,
    tcie: bool = false,
    teie: bool = false,
    reie: bool = false,
    dmie: bool = false,
    reserved1: u18 = 0,
};

pub const Der = bitpack struct(u32) {
    tdde: bool = false,
    rdde: bool = false,
    reserved0: u7 = 0,
    fcde: bool = false,
    reserved1: u22 = 0,
};

pub const Cfgr0 = bitpack struct(u32) {
    hren: bool = false,
    hrpol: bool = false,
    hrsel: bool = false,
    hrdir: bool = false,
    reserved0: u4 = 0,
    cirfifo: bool = false,
    rdmo: bool = false,
    reserved1: u22 = 0,
};

pub const Pcspol = enum(u4) {
    discarded = 0,
    stored = 1,
};

pub const Matcfg = enum(u3) {
    disabled = 0,
    enabled_firstdatamatch = 2,
    enabled_anydatamatch = 3,
    enabled_datamatch_100 = 4,
    enabled_datamatch_101 = 5,
    enabled_datamatch_110 = 6,
    enabled_datamatch_111 = 7,
};

pub const Pincfg = enum(u2) {
    sin_in_sout_out = 0,
    sin_both_in_out = 1,
    sout_both_in_out = 2,
    sout_in_sin_out = 3,
};

pub const Cfgr1 = bitpack struct(u32) {
    master: bool = false,
    sample: bool = false,
    autopcs: bool = false,
    nostall: bool = false,
    partial: bool = false,
    reserved0: u3 = 0,
    pcspol: Pcspol = .discarded,
    reserved1: u4 = 0,
    matcfg: Matcfg = .disabled,
    reserved2: u5 = 0,
    pincfg: Pincfg = .sin_in_sout_out,
    outcfg: bool = false,
    pcscfg: bool = false,
    reserved3: u4 = 0,
};

pub const Ccr = bitpack struct(u32) {
    sckdiv: u8 = 0,
    dbt: u8 = 0,
    pcssck: u8 = 0,
    sckpcs: u8 = 0,
};

pub const Ccr1 = bitpack struct(u32) {
    sckset: u8 = 0,
    sckhld: u8 = 0,
    pcspcs: u8 = 0,
    scksck: u8 = 0,
};

pub const Fcr = bitpack struct(u32) {
    txwater: u3 = 0,
    reserved0: u13 = 0,
    rxwater: u3 = 0,
    reserved1: u13 = 0,
};

pub const Fsr = bitpack struct(u32) {
    txcount: u4,
    reserved0: u12,
    rxcount: u4,
    reserved1: u12,
};

pub const Width = enum(u2) {
    onebit = 0,
    twobit = 1,
    fourbit = 2,
};

pub const Prescale = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7,
};

pub const Tcr = bitpack struct(u32) {
    framesz: u12 = 31,
    reserved0: u4 = 0,
    width: Width = .onebit,
    txmsk: bool = false,
    rxmsk: bool = false,
    contc: bool = false,
    cont: bool = false,
    bysw: bool = false,
    lsbf: bool = false,
    pcs: u2 = 0,
    reserved1: u1 = 0,
    prescale: Prescale = .div1,
    cpha: bool = false,
    cpol: bool = false,
};

pub const Rsr = bitpack struct(u32) {
    sof: bool,
    rxempty: bool,
    reserved0: u30,
};

pub const Dr = extern union {
    b: u8,
    h: u16,
    w: u32,
};

pub const Lpspi = extern struct {
    verid: Verid,
    param: Param,
    reserved0: [2]u32,
    cr: Cr,
    sr: Sr,
    ier: Ier,
    der: Der,
    cfgr0: Cfgr0,
    cfgr1: Cfgr1,
    reserved1: [2]u32,
    dmr0: u32,
    dmr1: u32,
    reserved2: [2]u32,
    ccr: Ccr,
    ccr1: Ccr1,
    reserved3: [4]u32,
    fcr: Fcr,
    fsr: Fsr,
    tcr: Tcr,
    tdr: Dr,
    reserved4: [2]u32,
    rsr: Rsr,
    rdr: Dr,
    rdror: u32,
    reserved5: [224]u32,
    tcbr: u32,
    tdbr: [128]u32,
    rdbr: [128]u32,

    pub fn initMaster(self: *volatile Lpspi, baud: usize, spi_clock: usize) void {
        self.cfgr1 = Cfgr1{.master = true};
        var divider = spi_clock / baud;
        if (divider > 257) {
            divider = 257;
        } else if (divider < 2) {
            divider = 2;
        }
        const divider2: u8 = @truncate(divider / 2);
        self.ccr = Ccr{.sckdiv = @truncate(divider - 2), .dbt = divider2, .pcssck = divider2, .sckpcs = divider2};
        const txwater: u3 = @truncate(@min((@as(usize, 1) << @truncate(self.param.txfifo)) - 1, 7));
        self.fcr = Fcr{.txwater = txwater};
        self.tcr = Tcr{.framesz = 7};
        self.cr = Cr{.men = true};
    }

    pub fn flushFifos(self: *volatile Lpspi) void {
        self.cr.rtf = true;
        self.cr.rrf = true;
    }

    pub fn waitForTransferComplete(self: *volatile Lpspi) void {
        while (self.sr.mbf) {
            asm volatile ("nop");
        }
    }

    pub fn sendPoll8(self: *volatile Lpspi, data: []const u8) void {
        var tx_idx: usize = 0;
        var rx_idx: usize = 0;
        while (tx_idx < data.len or rx_idx < data.len) {
            while (tx_idx < data.len and self.sr.tdf) {
                self.tdr.b = data[tx_idx];
                tx_idx += 1;
            }
            while (self.sr.rdf) {
                _ = self.rdr.b;
                rx_idx += 1;
            }
        }
        self.waitForTransferComplete();
    }

    pub fn receivePoll8(self: *volatile Lpspi, data: []u8) void {
        var tx_idx: usize = 0;
        var rx_idx: usize = 0;
        while (tx_idx < data.len or rx_idx < data.len) {
            while (tx_idx < data.len and self.sr.tdf) {
                self.tdr.b = 0;
                tx_idx += 1;
            }
            while (self.sr.rdf) {
                data[rx_idx] = self.rdr.b;
                rx_idx += 1;
            }
        }
        self.waitForTransferComplete();
    }

    pub fn sendReceivePoll8(self: *volatile Lpspi, data_in: []const u8, data_out: []u8) void {
        var tx_idx: usize = 0;
        var rx_idx: usize = 0;
        while (tx_idx < data_in.len or rx_idx < data_out.len) {
            while (tx_idx < data_in.len and self.sr.tdf) {
                self.tdr.b = data_in[tx_idx];
                tx_idx += 1;
            }
            while (self.sr.rdf) {
                data_out[rx_idx] = self.rdr.b;
                rx_idx += 1;
            }
        }
        self.waitForTransferComplete();
    }

    pub fn transferPoll8(self: *volatile Lpspi, write_data: []const u8, read_data: ?[]u8) void {
        self.sendPoll8(write_data);
        if (read_data != null)
            self.receivePoll8(read_data.?);
    }
};

pub const lpspi0: *volatile Lpspi = @ptrFromInt(LPSPI0_BASE);
pub const lpspi1: *volatile Lpspi = @ptrFromInt(LPSPI1_BASE);
pub const lpspi2: *volatile Lpspi = @ptrFromInt(LPSPI2_BASE);
pub const lpspi3: *volatile Lpspi = @ptrFromInt(LPSPI3_BASE);
pub const lpspi4: *volatile Lpspi = @ptrFromInt(LPSPI4_BASE);
pub const lpspi5: *volatile Lpspi = @ptrFromInt(LPSPI5_BASE);
pub const lpspi6: *volatile Lpspi = @ptrFromInt(LPSPI6_BASE);
pub const lpspi7: *volatile Lpspi = @ptrFromInt(LPSPI7_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x800, @sizeOf(Lpspi));
}
