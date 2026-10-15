const hal = @import("hal");
const cc1101_commands = @import("cc1101_commands");
const cc1101 = @import("cc1101");
const config = @import("config");

const cfg1: cc1101.CC1101Cfg = .{
    .mode = .gfsk1200,
    .freq = 433800,
    .packet_length = 64,
    .address = 2,
    .mcsm1 = .{.txoff_mode = .rx, .rxoff_mode = .idle, .cca_mode = .always},
    .pktctrl0 = .{
        .crc_en = true, .white_data = true, .length_config = .variable,
        .pkt_format = .normal_mode
    },
    .tx_power = ._0
};

pub const cc1101_init: [config.NUMBER_OF_CC1101_DEVICES]cc1101.CC1101Init = if (config.NUMBER_OF_CC1101_DEVICES == 2) .{
    .{
        .timeout = hal.CC1101_TIMEOUT,
        .spi_write = hal.spi1Write,
        .spi_read_write = hal.spi1ReadWrite,
        .spi_transfer = hal.spi1Transfer,
        .spi_cs_set = hal.spi1CsSet,
        .get_gdo0 = hal.getGdo01,
        .get_gdo2 = hal.getGdo21
    },
    .{
        .timeout = hal.CC1101_TIMEOUT,
        .spi_write = hal.spi2Write,
        .spi_read_write = hal.spi2ReadWrite,
        .spi_transfer = hal.spi2Transfer,
        .spi_cs_set = hal.spi2CsSet,
        .get_gdo0 = hal.getGdo02,
        .get_gdo2 = hal.getGdo22
    }
} else .{
    .{
        .timeout = hal.CC1101_TIMEOUT,
        .spi_write = hal.spi1Write,
        .spi_read_write = hal.spi1ReadWrite,
        .spi_transfer = hal.spi1Transfer,
        .spi_cs_set = hal.spi1CsSet,
        .get_gdo0 = hal.getGdo01,
        .get_gdo2 = hal.getGdo21
    }
};

pub const cc1101_cfg: [config.NUMBER_OF_CC1101_DEVICES]cc1101.CC1101Cfg = if (config.NUMBER_OF_CC1101_DEVICES == 2) .{
    cfg1, config.cfg2
} else .{ cfg1 };

pub var cc1101_devices: [config.NUMBER_OF_CC1101_DEVICES]cc1101.CC1101 = if (config.NUMBER_OF_CC1101_DEVICES == 2) .{
    .{.context = @ptrFromInt(1), .init_data = &cc1101_init[0] },
    .{.context = @ptrFromInt(1), .init_data = &cc1101_init[1] },
} else .{
    .{.context = @ptrFromInt(1), .init_data = &cc1101_init[0] }
};

pub fn init() void {
    if (hal.INIT_DEVICES) {
        for (0..config.NUMBER_OF_CC1101_DEVICES) |n| {
            cc1101_devices[n].validateAndInit(&cc1101_cfg[n]) catch { while (true){} };
        }
    }
    cc1101_commands.registerCommands(hal.sh, &cc1101_cfg, &cc1101_devices) catch { while (true){} };
}