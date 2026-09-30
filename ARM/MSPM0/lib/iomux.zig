const IOMUX_BASE: usize = 0x40428000;

pub const IomuxPf = enum(u6) {
    unconnected = 0,
    gpio = 1,
    function2 = 2,
    function3 = 3,
    function4 = 4,
    function5 = 5,
    function6 = 6,
    function7 = 7,
    function8 = 8,
    function9 = 9
};

pub const IomuxPinCm = packed struct(u32) {
    pf: IomuxPf = .unconnected,
    reserved: u1 = 0,
    pc: bool = false,
    reserved5: u5 = 0,
    wakestat: bool = false,
    reserved2: u2 = 0,
    pipd: bool = false,
    pipu: bool = false,
    inena: bool = false,
    hysten: bool = false,
    drv: bool = false,
    reserved3: u4 = 0,
    hiz1: bool = false,
    inv: bool = false,
    wuen: bool = false,
    wcomp: bool = false,
    reserved4: u3 = 0
};

pub const Iomux = extern struct {
    reserved0: u32,
    pincm: [251]IomuxPinCm,

    pub fn initDigitalOutput(self: *volatile Iomux, pin: u8) void {
        @setRuntimeSafety(false);
        if (pin == 0 or pin >= self.pincm.len)
            return;
        self.pincm[pin - 1] = .{.pf = .gpio, .pc = true};
    }

    pub fn initPeripheralOutputFunction(self: *volatile Iomux, pin: u8, function: IomuxPf) void {
        @setRuntimeSafety(false);
        if (pin == 0 or pin >= self.pincm.len)
            return;
        self.pincm[pin - 1] = .{.pf = function, .pc = true};
    }

    pub fn initPeripheralFunction(self: *volatile Iomux, pin: u8, function: IomuxPinCm) void {
        @setRuntimeSafety(false);
        if (pin == 0 or pin >= self.pincm.len)
            return;
        self.pincm[pin - 1] = function;
    }

    pub fn initPeripheralInputFunction(self: *volatile Iomux, pin: u8, function: IomuxPf) void {
        @setRuntimeSafety(false);
        if (pin == 0 or pin >= self.pincm.len)
            return;
        self.pincm[pin - 1] = .{.pf = function, .pc = true, .inena = true};
    }
};

pub const iomux: *volatile Iomux = @ptrFromInt(IOMUX_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1524-0x400, @sizeOf(Iomux));
}
