const std = @import("std");

pub const BuildParameters = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.Optimize,
    hal: *std.Build.Module,
    config: *std.Build.Module,
    system_timer: *std.Build.Module,
    cc1101: *std.Build.Module,
    shell: *std.Build.Module,
    allocator: *std.Build.Module,
    usart_writer: *std.Build.Module,
    hal_constants: *std.Build.Module
};

pub const PreCreateParameters = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.Optimize,
    system_timer: *std.Build.Module
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
        .hal_constants = hal_constants
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

    const hal_common = b.addModule("hal_common", .{
        .root_source_file = b.path("../../../iot_device_core/hal_common.zig"),
        .target = parameters.target,
        .optimize = parameters.optimize,
        .imports = &.{
            .{ .name = "hal", .module = parameters.hal },
            .{ .name = "scd4x", .module = scd4x },
            .{ .name = "veml7700", .module = veml7700 },
            .{ .name = "cc1101", .module = parameters.cc1101 },
            .{ .name = "config", .module = parameters.config }
        }
    });

    const exe = b.addExecutable(.{
        .name = "iot_device_gd32e230.elf",
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
                .{ .name = "scd4x_commands", .module = scd4x_commands },
                .{ .name = "veml7700_commands", .module = veml7700_commands },
                .{ .name = "cc1101_commands", .module = cc1101_commands },
                .{ .name = "allocator", .module = parameters.allocator },
                .{ .name = "usart_writer", .module = parameters.usart_writer }
            },
        }),
    });

    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;

    return exe;
}
