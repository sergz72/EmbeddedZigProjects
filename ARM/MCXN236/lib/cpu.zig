pub const Cpu = struct {
    current_frequency: usize
};

pub var cpu = Cpu{.current_frequency = 48000000};

pub extern fn SystemPreInit() callconv(.c) void;
