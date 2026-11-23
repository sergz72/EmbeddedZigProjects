const cpu = @import("cpu");
const pfic = @import("pfic");

const SYSTICK_BASE: usize = 0xE000F000;

var p_us: u32 = undefined;
var p_ms: u32 = undefined;
var systick_counter: usize = undefined;

const SystickCtlr = bitpack struct(u32) {
    en: bool = false,
    ie: bool = false,
    clk_hclk: bool = false,
    auto_reload: bool = false,
    count_down: bool = false,
    reserved: u1 = 0,
    cid: bool = false,
    reserved2: u25 = 0,
};

const SystickIsr = bitpack struct(u32) {
    isr0: bool = false,
    isr1: bool = false,
    reserved: u30 = 0,
};

const Systick = extern struct {
    ctlr0: SystickCtlr,
    isr: SystickIsr,
    cnt0: u32,
    reserved: u32,
    cmp0: u32,
    reserved1: [27]u32,
    ctlr1: SystickCtlr,
    reserved2: u32,
    cnt1: u32,
    reserved3: u32,
    cmp1: u32,
};

const systick: *volatile Systick = @ptrFromInt(SYSTICK_BASE);

export fn SysTick0_Handler() callconv(.naked) void {
    asm volatile(
        \\ la    t0, %[counter]
        \\ lw    t1, 0(t0)
        \\ addi  t1, t1, 1
        \\ sw    t1, 0(t0)
        \\
        \\ li    t0, 0xE000F000
        \\ lw    t1, 4(t0)
        \\ andi  t1, t1, 0xFFFFFFFE
        \\ sw    t1, 4(t0)
        \\ mret
        :
        : [counter] "i" (&systick_counter),
    );
}

export fn SysTick1_Handler() callconv(.naked) void {
    asm volatile(
        \\ la    t0, %[counter]
        \\ lw    t1, 0(t0)
        \\ addi  t1, t1, 1
        \\ sw    t1, 0(t0)
        \\
        \\ li    t0, 0xE000F000
        \\ lw    t1, 4(t0)
        \\ andi  t1, t1, 0xFFFFFFFD
        \\ sw    t1, 4(t0)
        \\ mret
        :
        : [counter] "i" (&systick_counter),
    );
}

pub fn delayInit() void {
    p_ms = cpu.cpu.current_frequency / 1000;
    p_us = p_ms / 1000;
    if (cpu.core_3f) {
        pfic.pfic.interruptEnable(pfic.Interrupt.SysTick.toU8());
    } else {
        pfic.pfic.interruptEnable(pfic.Interrupt.SysTick1.toU8());
    }
}

pub fn delayLoopus(us: usize) void {
    const n: u32 = @truncate(p_us * us);
    for (0..n) |_| {
        asm volatile("nop");
    }
}

fn delay(n: u32) void {
    if (cpu.core_3f) {
        systick.isr.isr0 = false;
        systick.ctlr0 = SystickCtlr{};
        systick_counter = 0;
        systick.cnt0 = 0;
        systick.cmp0 = n;
        systick.ctlr0 = SystickCtlr{.en = true, .ie = true, .clk_hclk = true};
        while (systick_counter == 0) {
            asm volatile ("wfi");
        }
        systick.ctlr0 = SystickCtlr{};
    } else {
        systick.isr.isr1 = false;
        systick.ctlr1 = SystickCtlr{};
        systick_counter = 0;
        systick.cnt1 = 0;
        systick.cmp1 = n;
        systick.ctlr1 = SystickCtlr{.en = true, .ie = true, .clk_hclk = true};
        while (systick_counter == 0) {
            asm volatile ("wfi");
        }
        systick.ctlr1 = SystickCtlr{};
    }
}

pub fn delayms(ms: usize) void {
    delay(ms * p_ms);
}

pub fn delayus(us: usize) void {
    delay(us * p_us);
}

pub fn start1us() void {
    if (cpu.core_3f) {
        systick.isr.isr0 = false;
        systick.ctlr0 = SystickCtlr{};
        systick_counter = 0;
        systick.cnt0 = 0;
        systick.cmp0 = p_us;
        systick.ctlr0 = SystickCtlr{.en = true, .ie = true, .clk_hclk = true};
    } else {
        systick.isr.isr1 = false;
        systick.ctlr1 = SystickCtlr{};
        systick_counter = 0;
        systick.cnt1 = 0;
        systick.cmp1 = p_us;
        systick.ctlr1 = SystickCtlr{.en = true, .ie = true, .clk_hclk = true};
    }
}

pub fn start1ms() void {
    if (cpu.core_3f) {
        systick.isr.isr0 = false;
        systick.ctlr0 = SystickCtlr{};
        systick_counter = 0;
        systick.cnt0 = 0;
        systick.cmp0 = p_ms;
        systick.ctlr0 = SystickCtlr{.en = true, .ie = true, .clk_hclk = true};
    } else {
        systick.isr.isr1 = false;
        systick.ctlr1 = SystickCtlr{};
        systick_counter = 0;
        systick.cnt1 = 0;
        systick.cmp1 = p_ms;
        systick.ctlr1 = SystickCtlr{.en = true, .ie = true, .clk_hclk = true};
    }
}

pub fn stop() usize {
    if (cpu.core_3f) {
        systick.ctlr0 = SystickCtlr{};
    } else {
        systick.ctlr1 = SystickCtlr{};
    }
    return systick_counter;
}

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x94, @sizeOf(Systick));
}
