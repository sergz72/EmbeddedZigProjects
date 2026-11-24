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

pub var cpu = Cpu{
    .current_frequency = 8000000,
    .pclk1_frequency = 8000000,
    .pclk2_frequency = 8000000
};
