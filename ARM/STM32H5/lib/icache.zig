pub const IcacheCr = packed struct(u32) {
    en: bool = false, // [0]  enable
    cacheinv: bool = false, // [1]  invalidate (self-clears)
    waysel: bool = true, // [2]  0: 1-way direct, 1: 2-way associative
    _r0: u13 = 0,
    hitmen: bool = false, // [16] hit monitor enable
    missmen: bool = false, // [17] miss monitor enable
    hitmrst: bool = false, // [18] hit monitor reset
    missmrst: bool = false, // [19] miss monitor reset
    _r1: u12 = 0,
};

pub const IcacheSr = packed struct(u32) {
    busyf: bool, // [0] busy
    bsyendf: bool, // [1] busy end flag
    errf: bool, // [2] error flag
    _r: u29,
};

pub const IcacheIer = packed struct(u32) {
    _r0: u1 = 0,
    bsyendie: bool = false, // [1]
    errie: bool = false, // [2]
    _r1: u29 = 0,
};

pub const IcacheFcr = packed struct(u32) {
    _r0: u1 = 0,
    cbsyendf: bool = false, // [1] write 1 to clear
    cerrf: bool = false, // [2] write 1 to clear
    _r1: u29 = 0,
};

pub const IcacheCrr = packed struct(u32) {
    baddr: u8 = 0, // [7:0]   base address bits [28:21]
    _r0: u1 = 0,
    rsize: u3 = 1, // [11:9]  region size
    _r1: u3 = 0,
    ren: bool = false, // [15]    region enable
    remapaddr: u11 = 0, // [26:16] remap address bits [31:21]
    _r2: u1 = 0,
    mstsel: bool = false, // [28]    AHB master select
    _r3: u2 = 0,
    hburst: bool = false, // [31]    output burst type
};

pub const Icache = extern struct {
    cr: IcacheCr,
    sr: IcacheSr,
    ier: IcacheIer,
    fcr: IcacheFcr,
    hmonr: u32,
    mmonr: u32,
    reserved1: [2]u32,
    crr: [4]IcacheCrr,

    pub fn enable(self: *volatile Icache) void {
        self.cr = IcacheCr{.cacheinv = true};
        while (!self.sr.busyendf) {
            asm volatile ("nop");
        }
        self.cr = IcacheCr{.en = true};
    }
};
