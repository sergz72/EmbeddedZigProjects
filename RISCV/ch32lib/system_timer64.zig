const cpu = @import("cpu");
const pfic = @import("pfic");

const SYSTICK_BASE: usize = 0xE000F000;

var p_us: u64 = undefined;
var p_ms: u64 = undefined;
var systick_counter: usize = undefined;

const SystickCtlr = packed struct(u32) {
    ste: bool = false,
    stie: bool = false,
    stclk_hclk: bool = false,
    stre: bool = false,
    count_down: bool = false,
    init: bool = false,
    reserved: u25 = 0,
    swie: bool = false
};

const Systick = extern struct {
    ctlr: SystickCtlr,
    sr: u32,
    cntr: u64,
    cmpr: u64
};

const systick: *volatile Systick = @ptrFromInt(SYSTICK_BASE);

pub fn delayInit() void {
    p_ms = cpu.cpu.current_frequency / 1000;
    p_us = p_ms / 1000;
    pfic.pfic.interruptEnable(pfic.Interrupt.SysTick.toU8());
}

export fn SysTick_Handler() callconv(.naked) void {
    systick_counter += 1;
    systick.sr = 0;
    asm volatile("mret");
}

fn delay(n: u64) void {
    systick.ctlr = SystickCtlr{};
    systick_counter = 0;
    systick.cntr = 0;
    systick.cmpr = n;
    systick.ctlr = SystickCtlr{.init = true};
    systick.ctlr = SystickCtlr{.ste = true, .stie = true, .stclk_hclk = true};
    while (systick_counter == 0) {
        asm volatile ("wfi");
    }
    systick.ctlr = SystickCtlr{};
}

pub fn delayms(ms: usize) void {
    delay(ms * p_ms);
}

pub fn delayus(us: usize) void {
    delay(us * p_us);
}

pub fn start1us() void {
    systick.ctlr = SystickCtlr{};
    systick_counter = 0;
    systick.cntr = 0;
    systick.cmpr = p_us;
    systick.ctlr = SystickCtlr{.init = true};
    systick.ctlr = SystickCtlr{.ste = true, .stie = true, .stclk_hclk = true};
}

pub fn start1ms() void {
    systick.ctlr = SystickCtlr{};
    systick_counter = 0;
    systick.cntr = 0;
    systick.cmpr = p_ms;
    systick.ctlr = SystickCtlr{.init = true};
    systick.ctlr = SystickCtlr{.ste = true, .stie = true, .stclk_hclk = true};
}

pub fn stop() usize {
    systick.ctlr = SystickCtlr{};
    return systick_counter;
}
