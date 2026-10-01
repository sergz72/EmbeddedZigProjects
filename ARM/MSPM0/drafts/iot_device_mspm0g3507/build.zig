const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus }
    });

    const optimize = b.standardOptimizeOption(.{});

    const sysctl = b.addModule("sysctl", .{
        .root_source_file = b.path("../lib/sysctl.zig"),
        .target = target,
        .optimize = optimize
    });

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const common = b.addModule("common", .{
        .root_source_file = b.path("../lib/common.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
    });

    const iomux = b.addModule("iomux", .{
        .root_source_file = b.path("../lib/iomux.zig"),
        .target = target,
        .optimize = optimize
    });

    const uart = b.addModule("uart", .{
        .root_source_file = b.path("../lib/uart.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
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
            .{ .name = "cpu", .module = cpu }
        },
    });

    const gptimer = b.addModule("gptimer", .{
        .root_source_file = b.path("../lib/gptimer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../lib/i2c.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
    });

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../lib/spi.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
    });

    const mathacl = b.addModule("mathacl", .{
        .root_source_file = b.path("../lib/mathacl.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
    });

    const trng = b.addModule("trng", .{
        .root_source_file = b.path("../lib/trng.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
    });

    const wwdt = b.addModule("wwdt", .{
        .root_source_file = b.path("../lib/wwdt.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
        },
    });

    const aes = b.addModule("aes", .{
        .root_source_file = b.path("../lib/aes.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "common", .module = common }
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
        .optimize = optimize
    });

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../lib/fb_allocator.zig"),
        .target = target,
        .optimize = optimize
    });

    const shell = b.addModule("shell", .{
        .root_source_file = b.path("../../../common_lib/shell.zig"),
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

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sysctl", .module = sysctl },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "iomux", .module = iomux },
            .{ .name = "uart", .module = uart },
            .{ .name = "common", .module = common },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "shell", .module = shell },
            .{ .name = "gptimer", .module = gptimer },
            .{ .name = "i2c", .module = i2c },
            .{ .name = "spi", .module = spi },
            .{ .name = "mathacl", .module = mathacl },
            .{ .name = "trng", .module = trng },
            .{ .name = "wwdt", .module = wwdt },
            .{ .name = "aes", .module = aes },
            .{ .name = "usart_writer", .module = usart_writer },
            .{ .name = "scd4x", .module = scd4x },
            .{ .name = "veml7700", .module = veml7700 }
        },
    });

    const exe = b.addExecutable(.{
        .name = "iot_device_mspm0g3507.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "hal", .module = hal },
                .{ .name = "shell", .module = shell },
                .{ .name = "i2c_commands", .module = i2c_commands },
                .{ .name = "scd4x_commands", .module = scd4x_commands },
                .{ .name = "veml7700_commands", .module = veml7700_commands },
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

    exe.root_module.addCSourceFile(.{
        .file = b.path("../startup_mspm0g350x_gcc.c"),
        .flags = &[_][]const u8{"-O3"}, 
    });

    exe.setLinkerScript(b.path("../mspm0g3507.lds"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
