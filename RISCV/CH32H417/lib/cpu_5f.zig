pub const LSI_FREQUENCY = 40000;

pub const Cpu = struct {
    current_frequency: usize,
    pclk1_frequency: usize,
    pclk2_frequency: usize,

    pub fn setAll(self: *Cpu, frequency: usize) void {
        self.current_frequency = frequency;
        self.pclk1_frequency = frequency;
        self.pclk2_frequency = frequency;
    }
};

pub const core_3f: bool = false;

pub var cpu = Cpu{
    .current_frequency = 25000000,
    .pclk1_frequency = 25000000,
    .pclk2_frequency = 25000000
};
