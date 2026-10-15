const std = @import("std");

pub const BuildParameters = struct {
    target: std.Build.ResolvedTarget,
    optimize: ?std.builtin.Optimize,
    hal: *std.Build.Module,
    config: *std.Build.Module,
    system_timer: *std.Build.Module,
    cc1101: *std.Build.Module,
    shell: *std.Build.Module,
    allocator: *std.Build.Module,
    usart_writer: *std.Build.Module,
    hal_constants: *std.Build.Module,
    name: []const u8,
    lux_sensor_module: []const u8,
    co2_sensor_module: []const u8,
    rf_modem_module: []const u8
};

pub const PreCreateParameters = struct {
    target: std.Build.ResolvedTarget,
    optimize: ?std.builtin.Optimize,
    system_timer: *std.Build.Module,
    name: []const u8,
    lux_sensor_module: []const u8,
    co2_sensor_module: []const u8,
    rf_modem_module: []const u8
};

pub fn preCreateModules(b: *std.Build, parameters: PreCreateParameters) BuildParameters {
    const shell = b.addModule("shell", .{
        .root_source_file = b.path("../../../common_lib/shell.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize
    });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize
    });

    const cc1101 = b.addModule("cc1101", .{
        .root_source_file = b.path("../../../common_lib/rf/cc1101.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = parameters.system_timer }
        }
    });

    const hal_constants = b.addModule("hal_constants", .{
        .root_source_file = b.path("../../../iot_device_core/hal_constants.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize
    });
    return BuildParameters{
        .target = parameters.target,
        .optimize = parameters.optimize,
        .hal = undefined,
        .config = undefined,
        .system_timer = parameters.system_timer,
        .cc1101 = cc1101,
        .shell = shell,
        .allocator = undefined,
        .usart_writer = usart_writer,
        .hal_constants = hal_constants,
        .name = parameters.name,
        .lux_sensor_module = parameters.lux_sensor_module,
        .co2_sensor_module = parameters.co2_sensor_module,
        .rf_modem_module = parameters.rf_modem_module
    };
}

pub fn buildExe(b: *std.Build, parameters: BuildParameters) *std.Build.Step.Compile {
    const scd4x = b.addModule("scd4x", .{
        .root_source_file = b.path("../../../common_lib/sensor/scd4x.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = parameters.system_timer }
        }
    });

    const veml7700 = b.addModule("veml7700", .{
        .root_source_file = b.path("../../../common_lib/sensor/veml7700.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = parameters.system_timer }
        }
    });

    const utils = b.addModule("utils", .{
        .root_source_file = b.path("../../../common_lib/utils.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize
    });

    const cc1101_commands = b.addModule("cc1101_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/cc1101_commands.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "shell", .module = parameters.shell },
            .{ .name = "cc1101", .module = parameters.cc1101 },
            .{ .name = "utils", .module = utils }
        }
    });

    const i2c_commands = b.addModule("i2c_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/i2c_commands.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "shell", .module = parameters.shell }
        }
    });

    const spi_commands = b.addModule("spi_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/spi_commands.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "shell", .module = parameters.shell },
            .{ .name = "utils", .module = utils }
        }
    });

    const scd4x_commands = b.addModule("scd4x_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/scd4x_commands.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "shell", .module = parameters.shell },
            .{ .name = "scd4x", .module = scd4x }
        }
    });

    const veml7700_commands = b.addModule("veml7700_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/veml7700_commands.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "shell", .module = parameters.shell },
            .{ .name = "veml7700", .module = veml7700 }
        }
    });

    const font = b.addModule("font", .{
        .root_source_file = b.path("../../../common_lib/display/font.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize
    });

    const font8 = b.addModule("font8", .{
        .root_source_file = b.path("../../../common_lib/display/fonts/font8.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "font", .module = font }
        }
    });

    const lcd_bw = b.addModule("lcd_bw", .{
        .root_source_file = b.path("../../../common_lib/display/lcd_bw.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "font", .module = font }
        }
    });

    const lcd = b.addModule("lcd", .{
        .root_source_file = b.path("../../../common_lib/display/lcd_ks0108.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "font", .module = font },
            .{ .name = "lcd_bw", .module = lcd_bw },
        }
    });

    const hal_common = b.addModule("hal_common", .{
        .root_source_file = b.path("../../../iot_device_core/hal_common.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "hal", .module = parameters.hal },
            .{ .name = "scd4x", .module = scd4x },
            .{ .name = "veml7700", .module = veml7700 },
            .{ .name = "cc1101", .module = parameters.cc1101 },
            .{ .name = "lcd", .module = lcd },
            .{ .name = "config", .module = parameters.config }
        }
    });

    const ui = b.addModule("ui", .{
        .root_source_file = b.path("../../../iot_device_core/ui.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "lcd", .module = lcd },
            .{ .name = "hal_common", .module = hal_common },
            .{ .name = "font8", .module = font8 }
        }
    });

    const lux_sensor = b.addModule("lux_sensor", .{
        .root_source_file = b.path(parameters.lux_sensor_module),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "veml7700", .module = veml7700 },
            .{ .name = "veml7700_commands", .module = veml7700_commands },
            .{ .name = "shell", .module = parameters.shell },
            .{ .name = "hal", .module = parameters.hal },
        }
    });

    const co2_sensor = b.addModule("co2_sensor", .{
        .root_source_file = b.path(parameters.co2_sensor_module),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "scd4x", .module = scd4x },
            .{ .name = "scd4x_commands", .module = scd4x_commands },
            .{ .name = "shell", .module = parameters.shell },
            .{ .name = "hal", .module = parameters.hal },
        }
    });

    const rf_modem = b.addModule("rf_modem", .{
        .root_source_file = b.path(parameters.rf_modem_module),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "cc1101", .module = parameters.cc1101 },
            .{ .name = "cc1101_commands", .module = cc1101_commands },
            .{ .name = "shell", .module = parameters.shell },
            .{ .name = "hal", .module = parameters.hal },
            .{ .name = "config", .module = parameters.config }
        }
    });

    const exe = b.addExecutable(.{
        .name = parameters.name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("../../../iot_device_core/main.zig"),
            .target = parameters.target,
            .optimize = parameters.optimize,
            .imports = &.{
                .{ .name = "system_timer", .module = parameters.system_timer },
                .{ .name = "hal", .module = parameters.hal },
                .{ .name = "hal_common", .module = hal_common },
                .{ .name = "shell", .module = parameters.shell },
                .{ .name = "i2c_commands", .module = i2c_commands },
                .{ .name = "spi_commands", .module = spi_commands },
                .{ .name = "lux_sensor", .module = lux_sensor },
                .{ .name = "co2_sensor", .module = co2_sensor },
                .{ .name = "rf_modem", .module = rf_modem },
                .{ .name = "allocator", .module = parameters.allocator },
                .{ .name = "usart_writer", .module = parameters.usart_writer },
                .{ .name = "ui", .module = ui }
            },
        }),
    });

    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;

    return exe;
}
