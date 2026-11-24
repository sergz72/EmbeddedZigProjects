const IOMUXC_SNVS_GPR_BASE = 0x400A4000;
    
pub const IomuxGpr3 = bitpack struct(u32) {
    lpsr_mode_enable: bool = false,
    dcdc_status_capt_clr: bool = false,
    por_pull_type: u2 = 0,
    reserved0: u12 = 0,
    dcdc_in_low_vol: bool = false,
    dcdc_over_cur: bool = false,
    dcdc_over_vol: bool = false,
    dcdc_sts_dc_ok: bool = false,
    reserved1: u12 = 0,
};

pub const IomuxSnvsGpr = extern struct {
    gpr0: u32,
    gpr1: u32,
    gpr2: u32,
    gpr3: IomuxGpr3,
};

pub const iomuxc_snvs_gpr: *volatile IomuxSnvsGpr = @ptrFromInt(IOMUXC_SNVS_GPR_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10, @sizeOf(IomuxSnvsGpr));
}
