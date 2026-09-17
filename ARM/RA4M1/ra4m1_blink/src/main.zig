const cpu = @import("cpu");
const clock = @import("clock");
const gpio = @import("gpio");
const flash = @import("flash");
const system_timer = @import("system_timer");

const LED_PIN = 12;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = 0;

fn clock_init() void {
    cpu.prcr.* = cpu.Prcr{.prc0 = true}; // Enable write access to the clock registers
    clock.clock.mosccr = clock.ClockStop{.stop = false};
    while (!clock.clock.oscsf.moscsf) {
        asm volatile ("nop");
    }
    clock.clock.sckscr = .mosc;
    clock.clock.sckdivcr.ick = .div2;
    clock.clock.sckdivcr.fck = .div2;
    clock.clock.sckdivcr.pcka = .div2;
    clock.clock.sckdivcr.pckb = .div2;
    clock.clock.sckdivcr.pckc = .div2;
    clock.clock.sckdivcr.pckd = .div2;
    _ = clock.clock.sckdivcr;
    //flash.flash.fcacheiv = 1;
    //while ((flash.flash.fcacheiv & 1) != 0)  {
    //    asm volatile ("nop");
    //}
    //flash.flash.fcachee = 1;
    cpu.prcr.* = cpu.Prcr{}; // Disable write access to the clock registers
}

export fn SystemInit() callconv(.c) void {
    clock_init();
    system_timer.delay_init(system_timer.init_div1);
    gpio.port[LED_PORT].pdr = LED_PIN_MASK;
}

export fn main() callconv(.c) noreturn {
    while (true) {
        gpio.port[LED_PORT].posr = LED_PIN_MASK;
        system_timer.delayms(1000);
        gpio.port[LED_PORT].porr = LED_PIN_MASK;
        system_timer.delayms(1000);
    }
}
