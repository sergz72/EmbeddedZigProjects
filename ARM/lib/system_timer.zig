const cpu = @import("cpu");

const SYSTICK_BASE: usize = 0xE000E010;

var p_us: usize = undefined;
var p_ms: usize = undefined;
var systick_counter: usize = undefined;

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

pub const init_div8 = SystickInit{.clksource = false, .divider = 8000};
pub const init_div1 = SystickInit{.clksource = true, .divider = 1000};

pub fn delay_init(init: SystickInit) void {
    p_ms = cpu.cpu.current_frequency / init.divider;
    p_us = p_ms / 1000;
    systick.csr = SystickCsr{.tickint = true, .clksource = init.clksource};
}

export fn SysTick_Handler() callconv(.c) void {
    systick_counter += 1;
}

fn delay(n: u24, count: usize) void {
    systick_counter = 0;
    systick.cvr = 0;
    systick.rvr = n;
    systick.csr.enable = true;
    while (systick_counter < count) {
        asm volatile ("wfi");
    }
    systick.csr.enable = false;
}

pub fn start1us() void {
    systick_counter = 0;
    systick.cvr = 0;
    systick.rvr = @truncate(p_us);
    systick.csr.enable = true;
}

pub fn start1ms() void {
    systick_counter = 0;
    systick.cvr = 0;
    systick.rvr = @truncate(p_ms);
    systick.csr.enable = true;
}

pub fn stop() usize {
    systick.csr.enable = false;
    return systick_counter;
}

pub fn delayms(ms: usize) void {
    delay(@truncate(p_ms), ms);
}

pub fn delayus(us: usize) void {
    delay(@truncate(us * p_us), 1);
}
