const system_timer = @import("system_timer");
const board = @import("board");
const rcc = @import("rcc");
const tim = @import("tim");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const flash = @import("flash");
const scb = @import("scb");
const shell = @import("shell");

const TIMER_INSTANCE = tim.tim7;

var led_status: bool = undefined;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

export fn TIM7_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.sr.u) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.sr = tim.Timr{};
    }
}

fn usartCallback(data: u8) void {
    sh.processChar(data);
}

inline fn initTimer() void {
    rcc.rcc.hpenr.apb1l.tim7en = true;
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.pclk1_frequency / 10000 - 1);
    TIMER_INSTANCE.arr = 10000 - 1; //1 second interval
    TIMER_INSTANCE.dier = .{.u = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIM7.toU8());
    timer_interrupt = false;
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.cr1 = .{.cen = true, .arpe = true};
}

export fn SystemInit() callconv(.c) void {
    led_status = false;
    board.init(false, 48000000, rcc.PllCharacteristicsH563);
    board.initUsart(115200, &usartCallback, true);
    initTimer();
}

pub fn ledToggle() void {
    led_status = !led_status;
    if (led_status) {
        board.ledRedOn();
    } else {
        board.ledRedOff();
    }
}

pub fn flashWrite(address: usize, data: []u8) flash.FlashError!void {
    _ = address;
    _ = data;
    return flash.FlashError.Timeout;
}

pub fn flashSectorErase(address: usize) flash.FlashError!void {
    _ = address;
    return flash.FlashError.Timeout;
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    //todo
}

pub fn getResetCause() []const u8 {
    return rcc.rcc.getResetCause();
}
