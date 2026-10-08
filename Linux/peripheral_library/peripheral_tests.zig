pub const std = @import("std");
pub const gpio = @import("gpio");
pub const spi = @import("spi");
pub const i2c = @import("i2c");
pub const cc1101_device = @import("cc1101_device");

const ArgumentsError = error{
    CommandExpected,
    InvalidSpiBusAndDeviceNumber,
    InvalidSwitch,
    ConfigFileNameExpected,
    I2CBusNumberExpected,
    SpiBusNumberExpected,
    ParametersExpected,
    UnknownParameter
};

const Command = enum(usize) {
    None,
    TestScd41,
    TestCC1101,
    I2CScan,
    SPITest,
    GPIOTest,
    _
};

const SwitchFn = *const fn () void;

const switches = std.StaticStringMap(SwitchFn).initComptime(.{
    .{ "--test-cc1101", testCC1101Switch },
    .{ "--i2c-scan", i2cScanSwitch },
    .{ "--test-spi", testSpiSwitch },
    .{ "--test-gpio", testGpioSwitch },
});

fn testCC1101Switch() void {
    command = Command.TestCC1101;
    config_file_name_expected = true;
    parameters_expected = true;
}

fn i2cScanSwitch() void {
    command = Command.I2CScan;
    i2c_bus_number_expected = true;
}

fn testSpiSwitch() void {
    command = Command.SPITest;
    spi_bus_number_expected = true;
}

fn testGpioSwitch() void {
    command = Command.GPIOTest;
    parameters_expected = true;
}

var config_file_name: []const u8 = &.{};
var parameters: []const u8 = &.{};
var config_file_name_expected = false;
var i2c_bus_number_expected = false;
var spi_bus_number_expected = false;
var parameters_expected = false;
var bus_number: usize = 0;
var device_number: usize = 0;
var command = Command.None;

pub fn main(init: std.process.Init) !u8 {
    const allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(allocator);
    defer allocator.free(args);

    processArguments(args[1..], init.io, allocator) catch |err| {
        std.debug.print("Error processing arguments: {}\n", .{err});
        return 1;
    };
    return 0;
}

fn processArguments(args: []const [:0]const u8, io: std.Io, allocator: std.mem.Allocator) !void {
    for (args) |arg| {
        if (config_file_name_expected) {
            config_file_name = arg;
            config_file_name_expected = false;
            continue;
        }
        if (parameters_expected) {
            parameters = arg;
            parameters_expected = false;
            continue;
        }
        if (i2c_bus_number_expected) {
            bus_number = try std.fmt.parseInt(usize, arg, 10);
            i2c_bus_number_expected = false;
            continue;
        }
        if (spi_bus_number_expected) {
            var it = std.mem.splitScalar(u8, arg, ',');
            const part1 = it.next();
            const part2 = it.next();
            if (part1 == null or part2 == null) {
                return ArgumentsError.InvalidSpiBusAndDeviceNumber;
            }
            bus_number = try std.fmt.parseInt(usize, part1.?, 10);
            device_number = try std.fmt.parseInt(usize, part2.?, 10);
            spi_bus_number_expected = false;
            continue;
        }
        const switch_fn = switches.get(arg) orelse return ArgumentsError.InvalidSwitch;
        switch_fn();
    }
    if (config_file_name_expected or (command == Command.TestCC1101 and config_file_name.len == 0)) {
        return ArgumentsError.ConfigFileNameExpected;
    }
    if (i2c_bus_number_expected) {
        return ArgumentsError.I2CBusNumberExpected;
    }
    if (spi_bus_number_expected) {
        return ArgumentsError.SpiBusNumberExpected;
    }
    if (parameters_expected) {
        return ArgumentsError.ParametersExpected;
    }
    switch (command) {
        .I2CScan => i2cScan(io, allocator),
        .SPITest => testSpi(io, allocator),
        .GPIOTest => testGpio(io, allocator),
        .TestCC1101 => testCC1101(io, allocator),
        else => return ArgumentsError.CommandExpected
    }
}

fn i2cScan(io: std.Io, allocator: std.mem.Allocator) void {
    _ = io;
    _ = allocator;
}

fn testSpi(io: std.Io, allocator: std.mem.Allocator) void {
    var spi_master = spi.SPIMaster{.bits_per_word = 8, .speed_hz = 1000000};
    spi_master.init(io, allocator, bus_number, device_number) catch |err| {
        std.debug.print("SPI init failed: {}\n", .{err});
        return;
    };
    defer spi_master.close(io);
    spi_master.testTransfer() catch |err| {
        std.debug.print("SPI transfer failed: {}\n", .{err});
        return;
    };
}

fn testCC1101(io: std.Io, allocator: std.mem.Allocator) void {
    var device: cc1101_device.CC1101Device = .{};
    device.init(io, allocator, config_file_name) catch |err| {
        std.debug.print("CC1101 init failed: {} error_name={s} error_location={s} linux_errno={}\n", .{
            err, device.spi_error_name, device.spi_error_location, device.getLinuxErrno()
        });
        return;
    };
    defer device.close(io);
    device.runTests(io, allocator, parameters) catch |err| {
        std.debug.print("CC1101 runTests failed: {} error_name={s} error_location={s} linux_errno={}\n", .{
            err, device.spi_error_name, device.spi_error_location, device.getLinuxErrno()
        });
    };
}

fn testGpio(io: std.Io, allocator: std.mem.Allocator) void {
    gpio.GPIO.testGpio(io, allocator, parameters) catch |err| {
        std.debug.print("GPIO test failed: {}\n", .{err});
    };
}
