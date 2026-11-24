pub const LSI_FREQUENCY = 40000;

pub const Cpu = struct {
    current_frequency: usize,
    pclk1_frequency: usize,
    pclk2_frequency: usize,
};

pub fn setAll(frequency: usize) void {
    cpu.current_frequency = frequency;
    cpu.pclk1_frequency = frequency;
    cpu.pclk2_frequency = frequency;
}

pub extern const CORE_V5F_START_ADDRESS: usize;

pub var cpu = Cpu{
    .current_frequency = 25000000,
    .pclk1_frequency = 25000000,
    .pclk2_frequency = 25000000
};
