pub const std = @import("std");
pub const gpio = @import("gpio");

const ArgumentsError = error{
    CommandExpected,
    InvalidSpiBusAndDeviceNumber,
    InvalidSwitch,
    ConfigFileNameExpected,
    I2CBusNumberExpected,
    SpiBusNumberExpected,
    GpioParametersExpected,
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
    gpio_parameters_expected = true;
}

var config_file_name: []const u8 = &.{};
var gpio_parameters: []const u8 = &.{};
var config_file_name_expected = false;
var i2c_bus_number_expected = false;
var spi_bus_number_expected = false;
var gpio_parameters_expected = false;
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
        if (gpio_parameters_expected) {
            gpio_parameters = arg;
            gpio_parameters_expected = false;
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
        if (std.mem.startsWith(u8, arg, "--")) {
            std.debug.print("Processing switch: {s}\n", .{arg});
            const switch_fn = switches.get(arg);
            if (switch_fn == null) {
                return ArgumentsError.InvalidSwitch;
            }
            switch_fn.?();
        } else {
            std.debug.print("Processing parameter: {s}\n", .{arg});
            return ArgumentsError.UnknownParameter;
        }
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
    if (gpio_parameters_expected) {
        return ArgumentsError.GpioParametersExpected;
    }
    switch (command) {
        .I2CScan => try i2cScan(io, allocator),
        .SPITest => try testSpi(io, allocator),
        .GPIOTest => try testGpio(io, allocator),
        .TestCC1101 => try testCC1101(io, allocator),
        else => return ArgumentsError.CommandExpected
    }
}

fn i2cScan(io: std.Io, allocator: std.mem.Allocator) !void {
    _ = io;
    _ = allocator;
}

fn testSpi(io: std.Io, allocator: std.mem.Allocator) !void {
    _ = io;
    _ = allocator;
}

fn testCC1101(io: std.Io, allocator: std.mem.Allocator) !void {
    _ = io;
    _ = allocator;
}

fn testGpio(io: std.Io, allocator: std.mem.Allocator) !void {
    gpio.GPIO.testGpio(io, allocator, gpio_parameters) catch |err| {
        std.debug.print("GPIO test failed: {}\n", .{err});
    };
}
