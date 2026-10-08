pub const Cpu = struct {
    current_frequency: usize,
    ahb1_frequency: usize,
    ahb2_frequency: usize,
    ahb3_frequency: usize,
    abp1_frequency: usize,
    apb2_frequency: usize
};

pub var cpu = Cpu{
    .current_frequency = 16000000,
    .ahb1_frequency = 16000000,
    .ahb2_frequency = 16000000,
    .ahb3_frequency = 16000000,
    .abp1_frequency = 16000000,
    .apb2_frequency = 16000000
};
