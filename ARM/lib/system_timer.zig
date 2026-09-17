const cpu = @import("cpu");

const SYSTICK_BASE: usize = 0xE000E010;

var p_us: usize = undefined;
var systick_interrupt: bool = undefined;

const SystickCsr = packed struct(u32) {
    enable: bool = false,
    tickint: bool = false,
    clksource: bool = false,
    reserved: u13 = 0,
    countflag: bool = false,
    reserved2: u15 = 0,
};

const Systick = extern struct {
    csr: SystickCsr,
    rvr: u32,
    cvr: u32,
    calib: u32
};

const SystickInit = struct {
    clksource: bool,
    divider: usize
};

const systick: *volatile Systick = @ptrFromInt(SYSTICK_BASE);

pub const init_div8 = SystickInit{.clksource = false, .divider = 8000000};
pub const init_div1 = SystickInit{.clksource = true, .divider = 1000000};

pub fn delay_init(init: SystickInit) void {
    p_us = cpu.cpu.current_frequency / init.divider;
    systick.csr = SystickCsr{.tickint = true, .clksource = init.clksource};
}

export fn SysTick_Handler() callconv(.c) void {
    systick_interrupt = true;
}

fn delay(n: u24) void {
    systick_interrupt = false;
    systick.rvr = n;
    systick.csr.enable = true;
    while (!systick_interrupt) {
        asm volatile ("wfi");
    }
    systick.csr.enable = false;
}

pub fn delayms(ms: usize) void {
    for (0..ms) |_| {
        delayus(1000);
    }
}

pub fn delayus(us: usize) void {
    delay(@truncate(us * p_us));
}
