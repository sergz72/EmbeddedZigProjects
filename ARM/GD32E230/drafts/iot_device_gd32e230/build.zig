const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m23 }
    });

    const optimize = b.standardOptimizeOption(.{});

    const rcu = b.addModule("rcu", .{
        .root_source_file = b.path("../lib/rcu.zig"),
        .target = target,
        .optimize = optimize
    });

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../../lib/cpu2.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const timer = b.addModule("timer", .{
        .root_source_file = b.path("../lib/timer.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart = b.addModule("usart", .{
        .root_source_file = b.path("../lib/usart.zig"),
        .target = target,
        .optimize = optimize
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../lib/i2c.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        },
    });

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../lib/spi.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
        .target = target,
        .optimize = optimize
    });

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic }
        },
    });

    const scd4x = b.addModule("scd4x", .{
        .root_source_file = b.path("../../../common_lib/sensor/scd4x.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = system_timer }
        }
    });

    const veml7700 = b.addModule("veml7700", .{
        .root_source_file = b.path("../../../common_lib/sensor/veml7700.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = system_timer }
        }
    });

    const cc1101 = b.addModule("cc1101", .{
        .root_source_file = b.path("../../../common_lib/rf/cc1101.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = system_timer }
        }
    });

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../../lib/fb_allocator.zig"),
        .target = target,
        .optimize = optimize
    });

    const shell = b.addModule("shell", .{
        .root_source_file = b.path("../../../common_lib/shell.zig"),
        .target = target,
        .optimize = optimize
    });

    const utils = b.addModule("utils", .{
        .root_source_file = b.path("../../../common_lib/utils.zig"),
        .target = target,
        .optimize = optimize
    });

    const i2c_commands = b.addModule("i2c_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/i2c_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell }
        }
    });

    const spi_commands = b.addModule("spi_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/spi_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "utils", .module = utils }
        }
    });

    const scd4x_commands = b.addModule("scd4x_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/scd4x_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "scd4x", .module = scd4x }
        }
    });

    const veml7700_commands = b.addModule("veml7700_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/veml7700_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "veml7700", .module = veml7700 }
        }
    });

    const cc1101_commands = b.addModule("cc1101_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/cc1101_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "cc1101", .module = cc1101 }
        }
    });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const hal_constants = b.addModule("hal_constants", .{
        .root_source_file = b.path("../../../iot_device_core/hal_constants.zig"),
        .target = target,
        .optimize = optimize
    });

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcu", .module = rcu },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "usart", .module = usart },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "usart_writer", .module = usart_writer },
            .{ .name = "shell", .module = shell },
            .{ .name = "timer", .module = timer },
            .{ .name = "i2c", .module = i2c },
            .{ .name = "spi", .module = spi },
            .{ .name = "hal_constants", .module = hal_constants }
        },
    });

    const hal_common = b.addModule("hal_common", .{
        .root_source_file = b.path("../../../iot_device_core/hal_common.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "hal", .module = hal },
            .{ .name = "scd4x", .module = scd4x },
            .{ .name = "veml7700", .module = veml7700 }
        }
    });

    const exe = b.addExecutable(.{
        .name = "iot_device_gd32e230.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("../../../iot_device_core/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "hal", .module = hal },
                .{ .name = "hal_common", .module = hal_common },
                .{ .name = "shell", .module = shell },
                .{ .name = "i2c_commands", .module = i2c_commands },
                .{ .name = "spi_commands", .module = spi_commands },
                .{ .name = "scd4x_commands", .module = scd4x_commands },
                .{ .name = "veml7700_commands", .module = veml7700_commands },
                .{ .name = "cc1101_commands", .module = cc1101_commands },
                .{ .name = "allocator", .module = allocator },
                .{ .name = "usart_writer", .module = usart_writer }
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_gd32e23x.S"));

    exe.setLinkerScript(b.path("../gd32e230x8_flash.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
