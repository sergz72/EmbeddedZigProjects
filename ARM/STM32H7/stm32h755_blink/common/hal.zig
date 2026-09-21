const nucleo = @import("nucleo");
const rcc = @import("rcc");
const system_timer = @import("system_timer");

pub fn init_core0() void {
    rcc.rcc.enr[0].hp.ahb4.hsem = true;
    system_timer.delay_init(system_timer.init_div8);
    nucleo.init_leds(false);
}

pub fn init_core1() void {
    //rcc.rcc.enr[0].hp.ahb4.hsem = true;
    system_timer.delay_init(system_timer.init_div8);
}