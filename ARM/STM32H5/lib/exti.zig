const EXTI_BASE = 0x44022000;

pub const Exti2 = packed struct(u32) {
    reserved0: u14 = 0,
    rt46: bool = false,
    reserved1: u3 = 0,
    rt50: bool = false,
    reserved2: u2 = 0,
    rt53: bool = false,
    reserved3: u10 = 0,
};

pub const ExtiLockr = packed struct(u32) {
    lock: bool = false,
    reserved0: u31 = 0,
};

pub const ExtiPort = enum(u8) {
    gpioa = 0,
    gpiob = 1,
    gpioc = 2,
    gpiod = 3,
    gpioe = 4,
    gpiof = 5,
    gpiog = 6,
    gpioh = 7
};

pub const Exti = extern struct {
    rtsr1: u32,
    ftsr1: u32,
    swier1: u32,
    rpr1: u32,
    fpr1: u32,
    seccfgr1: u32,
    privcfgr1: u32,
    reserved0: u32,
    rtsr2: Exti2,
    ftsr2: Exti2,
    swier2: Exti2,
    rpr2: Exti2,
    fpr2: Exti2,
    seccfgr2: u32,
    privcfgr2: u32,
    reserved1: [9]u32,
    cr: [4]u32,
    lockr: ExtiLockr,
    reserved2: [3]u32,
    imr1: u32,
    emr1: u32,
    reserved3: [2]u32,
    imr2: u32,
    emr2: u32,

    pub fn interruptEnable(self: *volatile Exti, line: u4, rising_edge: bool, falling_edge: bool) void {
        self.imr1 |= (1 << line);
        if (rising_edge) {
            self.rtsr1 |= (1 << line);
        }
        if (falling_edge) {
            self.ftsr1 |= (1 << line);
        }
    }

    pub fn setExtiPort(self: *volatile Exti, port: ExtiPort, line: u4) void {
        const shift = @as(u5, line & 3) << 3;
        const idx = line >> 2;
        const mask = 0xFF << shift;
        self.cr[idx] = (self.cr[idx] & ~mask) | (@as(u32, @backingInt(port)) << shift);
    }
};

pub const exti: *volatile Exti = @ptrFromInt(EXTI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x98, @sizeOf(Exti));

}
