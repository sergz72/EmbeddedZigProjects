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

    write_command: u8 = 2,
    read_command: u8 = 3,
    wren_command: u8 = 6,
    fast_read_command: u8 = 0x0B,
    read_id_command: u8 = 0x9F,
    reset_enable_command: u8 = 0x66,
    reset_command: u8 = 0x99,
    sector_erase_command: u8 = 0x20,
    block32_erase_command: u8 = 0x52,
    block64_erase_command: u8 = 0xD8,
    chip_erase_command: u8 = 0xC7,

    spi_transfer: *const fn(write_data: []const u8, read_data: ?[]u8) bool
};

pub const SpiMemory = struct {
    memory_init: *const SpiMemoryInit,

    pub fn init(self: *SpiMemory, chip_init: *const SpiMemoryInit) void {
        self.memory_init = chip_init;
    }

    pub fn readId(self: *const SpiMemory) ?u32 {
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

    pub fn wren(self: *const SpiMemory) bool {
        _ = self;
        return false;
    }

    pub fn write(self: *const SpiMemory, address: u32, data: []u8) bool {
        _ = self;
        _ = address;
        _ = data;
        return false;
    }

    fn readCommon(self: *const SpiMemory, command: u8, nop_cycles: usize, address: u32, data: []u8) bool {
        _ = self;
        _ = command;
        _ = nop_cycles;
        _ = address;
        _ = data;
        return false;
    }

    pub fn read(self: *const SpiMemory, address: u32, data: []u8) bool {
        _ = self;
        _ = address;
        _ = data;
        return false;
    }

    pub fn fastRead(self: *const SpiMemory, address: u32, data: []u8) bool {
        _ = self;
        _ = address;
        _ = data;
        return false;
    }
};
