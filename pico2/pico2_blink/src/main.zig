const std = @import("std");
const sio = @import("sio");
const resets = @import("resets");
const interrupts = @import("interrupts");
const uart = @import("uart");
const xosc = @import("xosc");
const cpu = @import("cpu");
const system_timer = @import("system_timer");

const LED2_PIN: u32 = 21;
const LED2_PIN_MASK: u32 = 1 << LED2_PIN;

extern var __CORE1_STACK_TOP: anyopaque;
extern fn _VectoredInterruptVectorTable() callconv(.c) void;
extern fn cpu1_reset_handler() callconv(.c) void;

export fn main_cpu0() callconv(.c) noreturn {
    xosc.xosc.init(xosc.XoscStatusFreqRange.one_to_15_mhz);

    resets.unreset(resets.ResetFields{.io_bank0=true, .pads_bank0=true});
    sio.sio.gpioLowOutputEnable(sio.DEFAULT_LED_PIN_MASK);
    sio.io_bank0.gpioFunctionSet(sio.DEFAULT_LED_PIN, sio.GpioFunc.sio_0);
    sio.pads_bank0.gpioIsolationRemove(sio.DEFAULT_LED_PIN);

    sio.sio.gpioLowOutputEnable(LED2_PIN_MASK);
    sio.io_bank0.gpioFunctionSet(LED2_PIN, sio.GpioFunc.sio_0);
    sio.pads_bank0.gpioIsolationRemove(LED2_PIN);

    system_timer.init_system_timer();
    system_timer.start_system_timer();

    cpu.Cpu.interrupts_enable();

    uart.uart_writer.print("Hello from Embedded Zig!\n", .{}) catch {};

    sio.sio.launch_core1(@intFromPtr(&_VectoredInterruptVectorTable), @intFromPtr(&__CORE1_STACK_TOP), @intFromPtr(&cpu1_reset_handler));

    while (true) {
        sio.sio.gpioLowToggle(sio.DEFAULT_LED_PIN_MASK);
        system_timer.delay(250);
    }
}

export fn main_cpu1() callconv(.c) noreturn {
    cpu.Cpu.interrupts_enable();

    system_timer.start_system_timer();

    while (true) {
        sio.sio.gpioLowToggle(LED2_PIN_MASK);
        system_timer.delay(1000);
    }
}

// pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
//     _ = msg;
//     _ = error_return_trace;
//     _ = ret_addr;
//     // For embedded, loop infinitely or trigger a hardware reset
//     while (true) {}
// }