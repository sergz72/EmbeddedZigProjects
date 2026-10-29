pub const Cpu = struct {
    current_frequency: usize
};

pub var cpu = Cpu{.current_frequency = 1000000};
