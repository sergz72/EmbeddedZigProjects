const iomuxc = @import("iomuxc");

const IOMUXC_SNVS_BASE = 0x400A8000;

pub const IomuxSnvs = extern struct {
    pmic_mux: iomuxc.IomuxMuxCtl,
    test_mode_pad: iomuxc.IomuxPadCtl,
    por_b_pad: iomuxc.IomuxPadCtl,
    onoff_pad: iomuxc.IomuxPadCtl,
    pmic_on_req_pad: iomuxc.IomuxPadCtl
};

pub const iomuxc_snvs: *volatile IomuxSnvs = @ptrFromInt(IOMUXC_SNVS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(IomuxSnvs));
}
