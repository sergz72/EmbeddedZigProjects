pub const Cpu = struct {
    current_frequency: usize,
    apb1_frequency: usize,
    apb2_frequency: usize,

    pub fn setAll(self: *Cpu, frequency: usize) void {
        self.current_frequency = frequency;
        self.apb1_frequency = frequency;
        self.apb2_frequency = frequency;
    }
};

pub var cpu = Cpu{
    .current_frequency = 16000000,
    .apb1_frequency = 16000000,
    .apb2_frequency = 16000000
};
