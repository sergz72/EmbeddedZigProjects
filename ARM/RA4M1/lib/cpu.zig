const PRCR_BASE: usize = 0x4001E3FE;

pub const Cpu = struct {
    current_frequency: usize
};

pub const Prcr = packed struct(u16) {
    prc0: bool = false,
    prc1: bool = false,
    reserved: u1 = 0,
    prc3: bool = false,
    reserved2: u4 = 0,
    prkey: u8 = 0xA5
};

pub var prcr: *volatile Prcr = @ptrFromInt(PRCR_BASE);

pub var cpu = Cpu{.current_frequency = 8000000};
