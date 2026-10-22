pub const GPIOA_BASE = 0x48000000;
pub const GPIOB_BASE = 0x48000400;
pub const GPIOC_BASE = 0x48000800;
pub const GPIOF_BASE = 0x48001400;

pub const GpioMode = enum(u2) {
    input = 0,
    output = 1,
    multiplexed = 2,
    analog = 3
};

pub const GpioPull = enum(u2) {
    none = 0,
    up = 1,
    down = 2,
};

pub const GpioMux = enum(u4) {
    mux0 = 0,
    mux1 = 1,
    mux2 = 2,
    mux3 = 3,
    mux4 = 4,
    mux5 = 5,
    mux6 = 6,
    mux7 = 7
};

pub const GpioInit = struct {
    mode: GpioMode,
    mux: GpioMux = .mux0,
    open_drain: bool = false,
    large_drive: bool = false,
    high_drive: bool = false,
    pull: GpioPull = .none,
};

pub const GpioScr = packed struct(u32) {
    iosb: u16 = 0,
    iocb: u16 = 0
};

pub const Gpio = extern struct {
    cfgr: u32,
    omode: u32,
    odrvr: u32,
    pull: u32,
    idt: u32,
    odt: u32,
    scr: GpioScr,
    wpr: u32,
    mux: [2]u32,
    clr: u32,
    togr: u32,
    reserved1: [3]u32,
    hdrv: u32,

    pub fn init(self: *volatile Gpio, pins_mask: u16, init_data: GpioInit) void {
        var pins = pins_mask;
        var cfgr = self.cfgr;
        var omode = self.omode;
        var odrvr = self.odrvr;
        var pull = self.pull;
        var mux = self.mux;
        var mask2: u32 = 3;
        var mask1: u32 = 1;
        var mask4: u32 = 0x0F;
        var shift1: u5 = 0;
        var shift2: u5 = 0;
        var shift4: u5 = 0;
        var muxidx: usize = 0;
        while (pins != 0) {
            if (pins & 1 != 0) {
                cfgr = (cfgr & ~mask2) | (@as(u32, @intFromEnum(init_data.mode)) << shift2);
                omode &= ~mask1;
                if (init_data.open_drain) {
                    omode |= @as(u32, 1) << shift1;
                }
                odrvr &= ~mask2;
                if (init_data.large_drive) {
                    odrvr |= @as(u32, 1) << shift2;
                }
                pull = (pull & ~mask2) | (@as(u32, @intFromEnum(init_data.pull)) << shift2);
                mux[muxidx] = (mux[muxidx] & ~mask4) | (@as(u32, @intFromEnum(init_data.mux)) << shift4);
            }
            if (shift4 == 28) {
                shift4 = 0;
                muxidx += 1;
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
        self.mux = mux;
        self.pull = pull;
        self.odrvr = odrvr;
        self.omode = omode;
        self.cfgr = cfgr;
    }

    pub fn setPins(self: *volatile Gpio, pins_mask: u16) void {
        self.scr = .{.iosb = pins_mask};
    }

    pub fn togglePins(self: *volatile Gpio, pins_mask: u16) void {
        self.togr = pins_mask;
    }

    pub fn clearPins(self: *volatile Gpio, pins_mask: u16) void {
        self.clr = pins_mask;
    }
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpiob: *volatile Gpio = @ptrFromInt(GPIOB_BASE);
pub const gpioc: *volatile Gpio = @ptrFromInt(GPIOC_BASE);
pub const gpiof: *volatile Gpio = @ptrFromInt(GPIOF_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x40, @sizeOf(Gpio));
}
