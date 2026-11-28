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
    block32k_erase_command: u8 = 0x52,
    block64k_erase_command: u8 = 0xD8,
    chip_erase_command: u8 = 0xC7,

    spi_transfer: *const fn(write_data: []const u8, read_data: ?[]u8, set_cs: bool) bool
};

pub const SpiAddress = struct {
    size: SpiMemoryAddressSize,
    command_and_address: [6]u8 = undefined,
    bytes: []u8 = undefined,

    pub fn set(self: *SpiAddress, command: u8, address: u32, nop_bytes: usize) void {
        self.command_and_address[0] = command;
        switch (self.size) {
            ._2bytes => {
                self.command_and_address[1] = @truncate(address >> 8);
                self.command_and_address[2] = @truncate(address);
                self.command_and_address[3] = 0;
                self.bytes = self.command_and_address[0..3+nop_bytes];
            },
            ._3bytes => {
                self.command_and_address[1] = @truncate(address >> 16);
                self.command_and_address[2] = @truncate(address >> 8);
                self.command_and_address[3] = @truncate(address);
                self.command_and_address[4] = 0;
                self.bytes = self.command_and_address[0..4+nop_bytes];
            },
            ._4bytes => {
                self.command_and_address[1] = @truncate(address >> 24);
                self.command_and_address[2] = @truncate(address >> 16);
                self.command_and_address[3] = @truncate(address >> 8);
                self.command_and_address[4] = @truncate(address);
                self.command_and_address[5] = 0;
                self.bytes = self.command_and_address[0..5+nop_bytes];
            },
        }
    }
};

pub const SpiMemory = struct {
    memory_init: *const SpiMemoryInit,
    address: SpiAddress,

    pub fn init(self: *SpiMemory, chip_init: *const SpiMemoryInit) void {
        self.memory_init = chip_init;
        self.address.size = chip_init.address_size;
    }

    pub fn readId(self: *const SpiMemory) ?u32 {
        var data: [5]u8 = .{self.memory_init.read_id_command, 0, 0, 0, 0};
        if (!self.memory_init.spi_transfer(data[0..1], data[0..3], true))
            return null;
        data[3] = 0;
        return std.mem.readInt(u32, data[0..4], .little);
    }

    pub fn reset(self: *const SpiMemory) bool {
        if (!self.memory_init.spi_transfer(&.{self.memory_init.reset_enable_command}, null, true))
            return false;
        return self.memory_init.spi_transfer(&.{self.memory_init.reset_command}, null, true);
    }

    pub fn wren(self: *const SpiMemory) bool {
        return self.memory_init.spi_transfer(&.{self.memory_init.wren_command}, null, true);
    }

    pub fn eraseChip(self: *const SpiMemory) bool {
        return self.memory_init.spi_transfer(&.{self.memory_init.chip_erase_command}, null, true);
    }

    pub fn eraseSector(self: *SpiMemory, address: u32) bool {
        self.address.set(self.memory_init.sector_erase_command, address, 0);
        return self.memory_init.spi_transfer(self.address.bytes, null, true);
    }

    pub fn eraseBlock32k(self: *SpiMemory, address: u32) bool {
        self.address.set(self.memory_init.block32k_erase_command, address, 0);
        return self.memory_init.spi_transfer(self.address.bytes, null, true);
    }

    pub fn eraseBlock64k(self: *SpiMemory, address: u32) bool {
        self.address.set(self.memory_init.block64k_erase_command, address, 0);
        return self.memory_init.spi_transfer(self.address.bytes, null, true);
    }

    pub fn write(self: *SpiMemory, address: u32, data: []const u8) bool {
        self.address.set(self.memory_init.write_command, address, 0);
        if (!self.memory_init.spi_transfer(self.address.bytes, null, false))
            return false;
        return self.memory_init.spi_transfer(data, null, true);
    }

    fn readCommon(self: *SpiMemory, command: u8, nop_bytes: usize, address: u32, data: []u8) bool {
        self.address.set(command, address, nop_bytes);
        return self.memory_init.spi_transfer(self.address.bytes, data, true);
    }

    pub fn read(self: *SpiMemory, address: u32, data: []u8) bool {
        return self.readCommon(self.memory_init.read_command, 0, address, data);
    }

    pub fn fastRead(self: *SpiMemory, address: u32, data: []u8) bool {
        return self.readCommon(self.memory_init.read_command, 1, address, data);
    }
};
