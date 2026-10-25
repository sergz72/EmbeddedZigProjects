const std = @import("std");
const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const AES_BASE: usize = 0x40442000 + 0x800;

pub const AesDma2IIdx = enum(u32) {
    no_interupt = 0,
    dma2 = 4
};

pub const AesDma2Int = packed struct(u32) {
    reserved: u3 = 0,
    dma2: bool = false,
    reserved2: u28 = 0
};

pub const AesDma2 = extern struct {
    iidx: AesDma2IIdx,
    reserved0: u32,
    imask: AesDma2Int,
    reserved1: u32,
    ris: AesDma2Int,
    reserved2: u32,
    mis: AesDma2Int,
    reserved3: u32,
    iset: AesDma2Int,
    reserved4: u32,
    iclr: AesDma2Int,
};

pub const AesDma1IIdx = enum(u32) {
    no_interupt = 0,
    dma1 = 3
};

pub const AesDma1Int = packed struct(u32) {
    reserved: u2 = 0,
    dma1: bool = false,
    reserved2: u29 = 0
};

pub const AesDma1 = extern struct {
    iidx: AesDma1IIdx,
    reserved0: u32,
    imask: AesDma1Int,
    reserved1: u32,
    ris: AesDma1Int,
    reserved2: u32,
    mis: AesDma1Int,
    reserved3: u32,
    iset: AesDma1Int,
    reserved4: u32,
    iclr: AesDma1Int,
};

pub const AesDma0IIdx = enum(u32) {
    no_interupt = 0,
    dma0 = 2
};

pub const AesDma0Int = packed struct(u32) {
    reserved: u1 = 0,
    dma0: bool = false,
    reserved2: u30 = 0
};

pub const AesDma0 = extern struct {
    iidx: AesDma0IIdx,
    reserved0: u32,
    imask: AesDma0Int,
    reserved1: u32,
    ris: AesDma0Int,
    reserved2: u32,
    mis: AesDma0Int,
    reserved3: u32,
    iset: AesDma0Int,
    reserved4: u32,
    iclr: AesDma0Int,
};

pub const AesIntIIdx = enum(u32) {
    no_interupt = 0,
    aes_ready = 1
};

pub const AesInt = extern struct {
    iidx: AesIntIIdx,
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

pub const AesGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const AesEvtMode = packed struct(u32) {
    int0_cfg: common.EvtCfg = .software_mode,
    evt1_cfg: common.EvtCfg = .hardware_mode,
    evt2_cfg: common.EvtCfg = .hardware_mode,
    evt3_cfg: common.EvtCfg = .hardware_mode,
    reserved: u24 = 0
};

pub const AesOpx = enum(u2) {
    encryption = 0,
    decryption = 1,
    generate_first_round_key = 2,
    decryption_with_first_round_key = 3
};

pub const AesKlx = enum(u2) {
    key_128_bit = 0,
    key_256_bit = 2
};

pub const AesCmx = enum(u2) {
    ecb = 0,
    cbc = 1,
    ofb = 2,
    cfb = 3
};

pub const AesActl0 = packed struct(u32) {
    opx: AesOpx = .encryption,
    klx: AesKlx = .key_128_bit,
    reserved: u1 = 0,
    cmx: AesCmx = .ecb,
    swrst: bool = false,
    reserved2: u3 = 0,
    errfg: bool = false,
    reserved3: u3 = 0,
    cmen: bool = false,
    reserved4: u16 = 0
};

pub const AesActl1 = packed struct(u32) {
    blkcntx: u8 = 0,
    reserved: u24 = 0
};

pub const AesAstat = packed struct(u32) {
    busy: bool = false,
    keywr: bool = false,
    dinwr: bool = false,
    doutrd: bool = false,
    keycntx: u4 = 0,
    dincntx: u4 = 0,
    doutcntx: u4 = 0,
    reserved: u16 = 0
};

pub const Aes = extern struct {
    gprcm: AesGprcm,
    reserved1: [512]u32,
    pdbgctl: common.PdbgCtl,
    reserved2: u32,
    cpu_int: AesInt,
    reserved3: u32,
    dma_trig0: AesDma0,
    reserved4: u32,
    dma_trig1: AesDma1,
    reserved5: u32,
    dma_trig2: AesDma2,
    reserved6: u32,
    evt_mode: AesEvtMode,
    reserved7: [7]u32,
    aesactl0: AesActl0,
    aesactl1: AesActl1,
    aesastat: AesAstat,
    aesakey: u32,
    aesadin: u32,
    aesadout: u32,
    aesaxdin: u32,
    aesaxin: u32,

    pub inline fn enablePower(self: *volatile Aes) void {
        const v = common.GprcmPwren{.enable = true};
        self.gprcm.pwren = v;
    }

    pub inline fn reset(self: *volatile Aes) void {
        const v = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
        self.gprcm.rstctl = v;
    }

    pub fn setKey(self: *volatile Aes, key: []const u8) bool {
        if (key.len != 16 and key.len != 32) {
            return false;
        }
        var idx: usize = 0;
        while (idx < key.len) : (idx += 4) {
            const k = std.mem.readInt(u32, key[idx..][0..4], .little);
            self.aesakey = k;
        }
        return true;
    }

    pub fn setDataIn(self: *volatile Aes, data: []const u8) bool {
        if (data.len < 16) {
            return false;
        }
        var idx: usize = 0;
        while (idx < 16) : (idx += 4) {
            const d = std.mem.readInt(u32, data[idx..][0..4], .little);
            self.aesadin = d;
        }
        return true;
    }

    pub fn setXoredDataIn(self: *volatile Aes, data: []const u8) bool {
        if (data.len < 16) {
            return false;
        }
        var idx: usize = 0;
        while (idx < 16) : (idx += 4) {
            const d = std.mem.readInt(u32, data[idx..][0..4], .little);
            self.aesaxdin = d;
        }
        return true;
    }

    pub fn setXoredDataInNoTrigger(self: *volatile Aes, data: []const u32) bool {
        if (data.len < 16) {
            return false;
        }
        var idx: usize = 0;
        while (idx < 16) : (idx += 4) {
            const d = std.mem.readInt(u32, data[idx..][0..4], .little);
            self.aesaxin = d;
        }
        return true;
    }

    pub fn getDataOut(self: *volatile Aes, data: []u8) bool {
        if (data.len < 16) {
            return false;
        }
        var idx: usize = 0;
        while (idx < 16) : (idx += 4) {
            const d = self.aesadout;
            std.mem.writeInt(u32, data[idx..][0..4], d, .little);
        }
        return true;
    }

    pub fn init(self: *volatile Aes, opx: AesOpx, klx: AesKlx) void {
        self.aesactl0 = AesActl0{.opx = opx, .klx = klx};
    }

    pub fn initWithKey(self: *volatile Aes, opx: AesOpx, key: []const u8) bool {
        if (key.len == 16) {
            self.aesactl0 = AesActl0{.opx = opx, .klx = .key_128_bit};
        } else if (key.len == 32) {
            self.aesactl0 = AesActl0{.opx = opx, .klx = .key_256_bit};
        } else {
            return false;
        }
        return self.setKey(key);
    }

    pub fn process(self: *volatile Aes, in: []const u8, out: []u8) bool {
        if (in.len < 16 or out.len < 16) {
            return false;
        }
        if (!self.setDataIn(in)) {
            return false;
        }
        while (self.aesastat.busy) {
            asm volatile ("nop");
        }
        return self.getDataOut(out);
    }
};

pub const aes: *volatile Aes = @ptrFromInt(AES_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x1120-0x800, @sizeOf(Aes));
}
