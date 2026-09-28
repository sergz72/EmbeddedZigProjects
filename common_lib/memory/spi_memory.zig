const std = @import("std");

pub const SpiMemoryType = enum {
    flash,
    psram,
    fram,
    eeprom
};

pub const SpiMemoryAddressSize = enum(usize) {
    _2bytes = 2,
    _3bytes = 3,
    _4bytes = 4
};

pub const SpiMemoryEraseCommand = enum {
    sector, block32, block64, chip
};

pub const SpiMemoryInit = struct {
    memory_type: SpiMemoryType,
    address_size: SpiMemoryAddressSize,
    qspi: bool,

    write_command: u8 = 2,
    read_command: u8 = 3,
    wren_command: u8 = 6,
    fast_read_command: u8 = 0x0B,
    read_id_command: u8 = 0x9F,
    reset_enable_command: u8 = 0x66,
    reset_command: u8 = 0x99,
    enter_qspi_mode_command: u8 = 0x35,
    exit_qspi_mode_command: u8 = 0xF5,
    qspi_fast_read_command: u8 = 0xEB,
    qspi_write_command: u8 = 0x38,
    sector_erase_command: u8 = 0x20,
    block32_erase_command: u8 = 0x52,
    block64_erase_command: u8 = 0xD8,
    chip_erase_command: u8 = 0xC7,

    spi_transfer: *const fn(write_data: []const u8, read_data: ?[]u8) bool
};

pub const SpiMemory = struct {
    memory_init: *const SpiMemoryInit,
    current_mode_qspi: bool = false,

    pub fn init(self: *SpiMemory, chip_init: *const SpiMemoryInit) void {
        self.memory_init = chip_init;
        self.current_mode_qspi = false;
    }

    pub fn readId(self: *const SpiMemory) ?u32 {
        if (self.current_mode_qspi)
            return null;
        var data: [5]u8 = .{self.memory_init.read_id_command, 0, 0, 0, 0};
        if (!self.memory_init.spi_transfer(data[0..1], data[0..3]))
            return null;
        data[3] = 0;
        return std.mem.readInt(u32, data[0..4], .little);
    }

    pub fn reset(self: *const SpiMemory) bool {
        if (!self.memory_init.spi_transfer(&.{self.memory_init.reset_enable_command}, null))
            return false;
        return self.memory_init.spi_transfer(&.{self.memory_init.reset_command}, null);
    }
};
