pub const GPIOA_BASE = 0x40010800;
pub const GPIOB_BASE = 0x40010C00;
pub const GPIOC_BASE = 0x40011000;
pub const GPIOD_BASE = 0x40011400;
pub const GPIOE_BASE = 0x40011800;

pub const GpioFunction = enum(u32) {
    analog = 0,
    input_floating = 4,
    input_pupd = 8,
    alternate_opendrain = 0x0C,
    pub const push_pull = .analog;
    pub const open_drain = .input_floating;
    pub const alternate_push_pull = .input_pupd;
};

pub const GpioMode = enum(u32) {
    input = 0,
    output_high_drive = 1,
    output = 2
};

pub const GpioInit = struct {
    mode: GpioMode,
    function: GpioFunction
};

pub const GpioScr = packed struct(u32) {
    iosb: u16 = 0,
    iocb: u16 = 0
};

pub const Gpio = extern struct {
    cfgr: [2]u32,
    idt: u32,
    odt: u32,
    scr: GpioScr,
    clr: u32,
    wpr: u32,
    reserved2: u32,
    srctr: u32,
    reserved1: [6]u32,
    hdrv: u32,

    pub fn init(self: *volatile Gpio, pins_mask: u16, init_data: GpioInit) void {
        var pins = pins_mask;
        var cfgr = self.cfgr;
        var mask4: u32 = 0x0F;
        var shift4: u5 = 0;
        var cfgridx: usize = 0;
        while (pins != 0) {
            if (pins & 1 != 0) {
                cfgr[cfgridx] = (cfgr[cfgridx] & ~mask4) | ((@backingInt(init_data.mode) | @backingInt(init_data.function)) << shift4);
            }
            if (shift4 == 28) {
                shift4 = 0;
                cfgridx += 1;
                mask4 = 0x0F;
            } else {
                shift4 += 4;
                mask4 <<= 4;
            }
            pins >>= 1;
        }
        self.cfgr = cfgr;
    }

    pub fn setPins(self: *volatile Gpio, pins_mask: u16) void {
        const v: GpioScr = .{.iosb = pins_mask};
        self.scr = v;
    }

    pub fn clearPins(self: *volatile Gpio, pins_mask: u16) void {
        self.clr = pins_mask;
    }
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpiob: *volatile Gpio = @ptrFromInt(GPIOB_BASE);
pub const gpioc: *volatile Gpio = @ptrFromInt(GPIOC_BASE);
pub const gpiod: *volatile Gpio = @ptrFromInt(GPIOD_BASE);
pub const gpioe: *volatile Gpio = @ptrFromInt(GPIOE_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x40, @sizeOf(Gpio));
}
