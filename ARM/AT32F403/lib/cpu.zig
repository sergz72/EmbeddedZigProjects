pub const LICK_FREQUENCY = 40000;
pub const HICK_FREQUENCY = 48000000;

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
    .current_frequency = 48000000,
    .apb1_frequency = 48000000,
    .apb2_frequency = 48000000
};
