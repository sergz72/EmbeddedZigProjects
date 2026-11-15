const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus }
    });

    const optimize = b.standardOptimizeOption(.{});

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        },
    });

    const syscon = b.addModule("syscon", .{
        .root_source_file = b.path("../lib/syscon.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
        .target = target,
        .optimize = optimize
    });

    const port = b.addModule("port", .{
        .root_source_file = b.path("../lib/port.zig"),
        .target = target,
        .optimize = optimize
    });

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const ctimer = b.addModule("ctimer", .{
        .root_source_file = b.path("../lib/ctimer.zig"),
        .target = target,
        .optimize = optimize
    });

    const lpuart = b.addModule("lpuart", .{
        .root_source_file = b.path("../lib/lpuart.zig"),
        .target = target,
        .optimize = optimize
    });

    const scg = b.addModule("scg", .{
        .root_source_file = b.path("../lib/scg.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "syscon", .module = syscon }
        },
    });

    const vbat = b.addModule("vbat", .{
        .root_source_file = b.path("../lib/vbat.zig"),
        .target = target,
        .optimize = optimize
    });

    const lp_flexcomm = b.addModule("lp_flexcomm", .{
        .root_source_file = b.path("../lib/lp_flexcomm.zig"),
        .target = target,
        .optimize = optimize
    });

    const fmu = b.addModule("fmu", .{
        .root_source_file = b.path("../lib/fmu.zig"),
        .target = target,
        .optimize = optimize
    });

    const lpi2c = b.addModule("lpi2c", .{
        .root_source_file = b.path("../lib/lpi2c.zig"),
        .target = target,
        .optimize = optimize
    });

    const lpspi = b.addModule("lpspi", .{
        .root_source_file = b.path("../lib/lpspi.zig"),
        .target = target,
        .optimize = optimize
    });

    const scb = b.addModule("scb", .{
        .root_source_file = b.path("../../lib/scb.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
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

    const board = b.addModule("board", .{
        .root_source_file = b.path("../lib/FRDM_MCXN236.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "syscon", .module = syscon },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "port", .module = port },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "lpuart", .module = lpuart },
            .{ .name = "lpi2c", .module = lpi2c },
            .{ .name = "lpspi", .module = lpspi },
            .{ .name = "scg", .module = scg },
            .{ .name = "vbat", .module = vbat },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "lp_flexcomm", .module = lp_flexcomm },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "usart_writer", .module = usart_writer },
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

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "syscon", .module = syscon },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "ctimer", .module = ctimer },
            .{ .name = "board", .module = board },
            .{ .name = "scb", .module = scb },
            .{ .name = "shell", .module = shell },
            .{ .name = "fmu", .module = fmu },
            .{ .name = "scd4x", .module = scd4x },
            .{ .name = "veml7700", .module = veml7700 },
        }
    });

    const system_commands = b.addModule("system_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/system_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "allocator", .module = allocator },
            .{ .name = "hal", .module = hal },
            .{ .name = "system_timer", .module = system_timer },
        }
    });

    const flash_commands = b.addModule("flash_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/flash_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "hal", .module = hal },
            .{ .name = "utils", .module = utils },
        }
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

    const veml7700_commands = b.addModule("veml7700_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/veml7700_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "veml7700", .module = veml7700 }
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

    const exe = b.addExecutable(.{
        .name = "mcxn236_tests.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "hal", .module = hal },
                .{ .name = "board", .module = board },
                .{ .name = "shell", .module = shell },
                .{ .name = "allocator", .module = allocator },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "system_commands", .module = system_commands },
                .{ .name = "flash_commands", .module = flash_commands },
                .{ .name = "i2c_commands", .module = i2c_commands },
                .{ .name = "spi_commands", .module = spi_commands },
                .{ .name = "scd4x_commands", .module = scd4x_commands },
                .{ .name = "veml7700_commands", .module = veml7700_commands },
            }
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.function_sections = true;
    exe.data_sections = true;
    exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_MCXN236.S"));

    exe.root_module.addCSourceFile(.{
        .file = b.path("../system_MCXN236.c"),
        .flags = &[_][]const u8{ "-I../include", "-std=c23", "-Wall", "-DCPU_MCXN236VDF" }
    });

    exe.setLinkerScript(b.path("../MCXN236_flash.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
