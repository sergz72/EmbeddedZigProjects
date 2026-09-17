const cpu = @import("cpu");
const clock = @import("clock");
const gpio = @import("gpio");
const gpt = @import("gpt");
const lpm = @import("lpm");
const nvic = @import("nvic");
const icu = @import("icu");
const agt = @import("agt");
const backup = @import("backup");
const system_timer = @import("system_timer");

const LED_PIN = 12;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = 0;

var timer_interrupt: bool = undefined;

export fn ApplicationInterrupt0Handler() callconv(.c) void {
    timer_interrupt = true;
    agt.agt[0].agtcr.tundf = false;
    icu.icu.ielsr[0].ir = false;
}

fn clock_init() void {
    cpu.prcr.* = cpu.Prcr{.prc0 = true}; // Enable write access to the clock registers
    // 16 mhz crystal oscillator onboard
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
    cpu.prcr.* = cpu.Prcr{}; // Disable write access to the clock registers
}

fn gpt_init() void {
    lpm.mstpcrd.* = lpm.Mstpcrd{.gpt32 = false};
    timer_interrupt = false;
    gpt.gpt32[0].gtpr = cpu.cpu.pckd_frequency / 10 - 1;
    icu.icu.ielsr[0] = icu.IcuIelsr{.iels = .GPT0_COUNTER_OVERFLOW};
    nvic.nvic.interrupt_enable(0);
    gpt.gpt32[0].gtcr = gpt.GptCr{.cst = true}; // start timer
}

fn agt_init() void {
    backup.backup.vbtcr1 = 1; // Stop battery power supply switch.
    lpm.mstpcrd.* = lpm.Mstpcrd{.agt0 = false};
    timer_interrupt = false;
    agt.agt[0].agt = 32768 / 10 - 1;
    agt.agt[0].agtmr1 = agt.AgtMr1{.tck = .agtlclk};
    icu.icu.ielsr[0] = icu.IcuIelsr{.iels = .AGT0_INT};
    nvic.nvic.interrupt_enable(0);
    agt.agt[0].agtcr = agt.AgtCr{.tstart = true};
}

export fn SystemInit() callconv(.c) void {
    clock_init();
    system_timer.delay_init(system_timer.init_div1);
    gpio.port[LED_PORT].pdr = LED_PIN_MASK;
    //gpt_init();
    agt_init();
}

export fn main() callconv(.c) noreturn {
    var led_state = false;
    while (true) {
        asm volatile ("wfi");
        if (!timer_interrupt)
            continue;
        led_state = !led_state;
        if (led_state) {
            gpio.port[LED_PORT].posr = LED_PIN_MASK;
        } else {
            gpio.port[LED_PORT].porr = LED_PIN_MASK;
        }
    }
}
