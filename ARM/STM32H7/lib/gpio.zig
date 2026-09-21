const GPIOA_BASE: usize = 0x58020000;
const GPIOB_BASE: usize = 0x58020400;
const GPIOC_BASE: usize = 0x58020800;
const GPIOD_BASE: usize = 0x58020C00;
const GPIOE_BASE: usize = 0x58021000;
const GPIOF_BASE: usize = 0x58021400;
const GPIOG_BASE: usize = 0x58021800;
const GPIOH_BASE: usize = 0x58021C00;
const GPIOI_BASE: usize = 0x58022000;
const GPIOJ_BASE: usize = 0x58022400;
const GPIOK_BASE: usize = 0x58022800;

pub const GpioMode = enum(u32) {
    input = 0,
    output = 1,
    alternate = 2,
    analog = 3
};

pub const GpioSpeed = enum(u32) {
    low = 0,
    medium = 1,
    high = 2,
    very_high = 3
};

pub const GpioPupdr = enum(u32) {
    floating = 0,
    pullup = 1,
    pulldown = 2
};

pub const GpioInit = struct {
    pins: u16,
    mode: GpioMode,
    speed: GpioSpeed,
    pupdr: GpioPupdr = .floating,
    alternate_function: u4 = 0,
    open_drain: bool = false
};

pub const Gpio = extern struct {
    moder: u32,
    otyper: u32,
    ospeedr: u32,
    pupdr: u32,
    idr: u32,
    odr: u32,
    bsrr: u32,
    lckr: u32,
    afr: [2]u32,

    pub fn init(self: *volatile Gpio, init_data: *const GpioInit) void {
        var pin_mask = init_data.pins;
        var mask4: u32 = 0x0F;
        var mask2: u32 = 3;
        var mask1: u32 = 1;
        var moder = self.moder;
        var otyper = self.otyper;
        var ospeedr = self.ospeedr;
        var pupdr = self.pupdr;
        var afr = self.afr;
        var afr_idx: usize = 0;
        var shift1: u5 = 0;
        var shift2: u5 = 0;
        var shift4: u5 = 0;
        while (pin_mask != 0) {
            if (pin_mask & 1 != 0) {
                moder &= ~mask2;
                otyper &= ~mask1;
                ospeedr &= ~mask2;
                pupdr &= ~mask2;
                afr[afr_idx] &= mask4;
                moder |= @intFromEnum(init_data.mode) << shift2;
                if (init_data.open_drain)
                    otyper |= @as(u32, 1) << shift1;
                ospeedr |= @intFromEnum(init_data.speed) << shift2;
                pupdr |= @intFromEnum(init_data.pupdr) << shift2;
                afr[afr_idx] |= @as(u32, init_data.alternate_function) << shift4;
            }
            pin_mask >>= 1;
            if (pin_mask == 0)
                break;
            if (shift4 == 28) {
                mask4 = 0x0F;
                shift4 = 0;
                afr_idx += 1;
            } else {
                mask4 <<= 4;
                shift4 += 4;
            }
            mask2 <<= 2;
            shift2 += 2;
            mask1 <<= 1;
            shift1 += 1;
        }
        self.otyper = otyper;
        self.ospeedr = ospeedr;
        self.pupdr = pupdr;
        self.afr = afr;
        self.moder = moder;
    }
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpiob: *volatile Gpio = @ptrFromInt(GPIOB_BASE);
pub const gpioc: *volatile Gpio = @ptrFromInt(GPIOC_BASE);
pub const gpiod: *volatile Gpio = @ptrFromInt(GPIOD_BASE);
pub const gpioe: *volatile Gpio = @ptrFromInt(GPIOE_BASE);
pub const gpiof: *volatile Gpio = @ptrFromInt(GPIOF_BASE);
pub const gpiog: *volatile Gpio = @ptrFromInt(GPIOG_BASE);
pub const gpioh: *volatile Gpio = @ptrFromInt(GPIOH_BASE);
pub const gpioi: *volatile Gpio = @ptrFromInt(GPIOI_BASE);
pub const gpioj: *volatile Gpio = @ptrFromInt(GPIOJ_BASE);
pub const gpiok: *volatile Gpio = @ptrFromInt(GPIOK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x28, @sizeOf(Gpio));
}
