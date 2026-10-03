pub const Cpu = struct {
    current_frequency: usize,
    pclk1_frequency: usize,
    pclk2_frequency: usize
};

pub var cpu = Cpu{
    .current_frequency = 8000000,
    .pclk1_frequency = 8000000,
    .pclk2_frequency = 8000000
};
