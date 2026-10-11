const std = @import("std");
const common = @import("build_common.zig");

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

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../../lib/fb_allocator.zig"),
        .target = target,
        .optimize = optimize
    });

    var build_parameters = common.preCreateModules(b, .{
        .target = target,
        .optimize = optimize,
        .system_timer = system_timer
    });
    build_parameters.allocator = allocator;

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
            .{ .name = "usart_writer", .module = build_parameters.usart_writer },
            .{ .name = "shell", .module = build_parameters.shell },
            .{ .name = "timer", .module = timer },
            .{ .name = "i2c", .module = i2c },
            .{ .name = "spi", .module = spi },
            .{ .name = "hal_constants", .module = build_parameters.hal_constants }
        },
    });
    build_parameters.hal = hal;

    const config = b.addModule("config", .{
        .root_source_file = b.path("../../../iot_device_core/hal_config_one_cc1101.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cc1101", .module = build_parameters.cc1101 }
        }
    });
    build_parameters.config = config;

    var exe = common.buildExe(b, build_parameters);
    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_gd32e23x.S"));

    exe.setLinkerScript(b.path("../gd32e230x8_flash.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
