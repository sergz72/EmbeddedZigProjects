pub fn init_reg(pins: u8, mode_and_speed: u32, reg: *volatile u32) void {
    if (pins == 0)
        return;
    var pin_mask = pins;
    var cfgr_mask: u32 = 0x0F;
    var cfgr = reg.*;
    var shift: u5 = 0;
    while (pin_mask != 0) {
        if (pin_mask & 1 != 0) {
            cfgr &= ~cfgr_mask;
            cfgr |= mode_and_speed << shift;
        }
        pin_mask >>= 1;
        if (pin_mask == 0)
            break;
        cfgr_mask <<= 4;
        shift += 4;
    }
    reg.* = cfgr;
}
