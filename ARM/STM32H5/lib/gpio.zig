const GPIOA_BASE = 0x42020000;
const GPIOB_BASE = 0x42020400;
const GPIOC_BASE = 0x42020800;
const GPIOD_BASE = 0x42020C00;
const GPIOE_BASE = 0x42021000;
const GPIOF_BASE = 0x42021400;
const GPIOG_BASE = 0x42021800;
const GPIOH_BASE = 0x42021C00;
const GPIOI_BASE = 0x42022000;

pub const GpioMode = enum(u2) {
    input = 0,
    output = 1,
    alternate = 2,
    analog = 3
};

pub const GpioSpeed = enum(u2) {
    low = 0,
    medium = 1,
    high = 2,
    very_high = 3
};

pub const GpioPull = enum(u2) {
    floating = 0,
    pullup = 1,
    pulldown = 2,
};

pub const GpioInit = struct {
    mode: GpioMode,
    alternate: u4 = 0,
    open_drain: bool = false,
    speed: GpioSpeed = .low,
    pull: GpioPull = .floating,
    hslv: bool = false
};

pub const GpioBsrr = packed struct(u32) {
    bs: u16 = 0,
    br: u16 = 0
};

pub const Gpio = extern struct {
    moder: u32,
    otyper: u32,
    ospeedr: u32,
    pupdr: u32,
    idr: u32,
    odr: u32,
    bsrr: GpioBsrr,
    lckr: u32,
    afr: [2]u32,
    brr: u32,
    hslvr: u32,
    seccfgr: u32,

    pub fn init(self: *volatile Gpio, pins_mask: u16, init_data: GpioInit) void {
        var pins = pins_mask;
        var moder = self.moder;
        var otype = self.otyper;
        var ospeedr = self.ospeedr;
        var pupdr = self.pupdr;
        var afr = self.afr;
        var hslvr = self.hslvr;
        var mask2: u32 = 3;
        var mask1: u32 = 1;
        var mask4: u32 = 0x0F;
        var shift1: u5 = 0;
        var shift2: u5 = 0;
        var shift4: u5 = 0;
        var afridx: usize = 0;
        while (pins != 0) {
            if (pins & 1 != 0) {
                moder = (moder & ~mask2) | (@as(u32, @backingInt(init_data.mode)) << shift2);
                otype &= ~mask1;
                if (init_data.open_drain) {
                    otype |= @as(u32, 1) << shift1;
                }
                ospeedr = (ospeedr & ~mask2) | (@as(u32, @backingInt(init_data.speed)) << shift2);
                pupdr = (pupdr & ~mask2) | (@as(u32, @backingInt(init_data.pull)) << shift2);
                afr[afridx] = (afr[afridx] & ~mask4) | (@as(u32, init_data.alternate) << shift4);
                hslvr &= ~mask1;
                if (init_data.hslv) {
                    hslvr |= @as(u32, 1) << shift1;
                }
            }
            if (shift4 == 28) {
                shift4 = 0;
                afridx += 1;
                mask4 = 0x0F;
            } else {
                shift4 += 4;
                mask4 <<= 4;
            }
            mask2 <<= 2;
            mask1 <<= 1;
            shift1 += 1;
            shift2 += 2;
            pins >>= 1;
        }
        self.moder = moder;
        self.otyper = otype;
        self.ospeedr = ospeedr;
        self.pupdr = pupdr;
        self.afr = afr;
        self.hslvr = hslvr;
    }

    pub fn setPins(self: *volatile Gpio, pins_mask: u16) void {
        self.bsrr = GpioBsrr{ .bs = pins_mask };
    }

    pub fn clearPins(self: *volatile Gpio, pins_mask: u16) void {
        self.brr = pins_mask;
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

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x400, @sizeOf(Gpio));

}
