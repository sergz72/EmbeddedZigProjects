const std = @import("std");
const common = @import("build_common.zig");

pub fn build(b: *std.Build) !void {
    var riscv_features_add = std.Target.Cpu.Feature.Set.empty;
    const riscv_features = std.Target.riscv.Feature;

    riscv_features_add.addFeature(@intFromEnum(riscv_features.i));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.m));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.a));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.c));     // Compressed Instructions
    riscv_features_add.addFeature(@intFromEnum(riscv_features.zicsr));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.relax));

    var riscv_features_sub = std.Target.Cpu.Feature.Set.empty;
    riscv_features_sub.addFeature(@intFromEnum(riscv_features.f));
    riscv_features_sub.addFeature(@intFromEnum(riscv_features.d));
    riscv_features_sub.addFeature(@intFromEnum(riscv_features.zcf));

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .ilp32,
        .cpu_features_add = riscv_features_add,
        .cpu_features_sub = riscv_features_sub
    });

    const optimize = b.standardOptimizeOption(.{});

    const rcc = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target,
        .optimize = optimize
    });

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../../ch32lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio_common = b.addModule("gpio_common", .{
        .root_source_file = b.path("../../ch32lib/gpio_common.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "gpio_common", .module = gpio_common }
        },
    });

    const afio = b.addModule("afio", .{
        .root_source_file = b.path("../lib/afio.zig"),
        .target = target,
        .optimize = optimize
    });

    const pfic = b.addModule("pfic", .{
        .root_source_file = b.path("../../ch32lib/pfic.zig"),
        .target = target,
        .optimize = optimize
    });

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../ch32lib/system_timer64.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "pfic", .module = pfic }
        },
    });

    const usart = b.addModule("usart", .{
        .root_source_file = b.path("../lib/usart.zig"),
        .target = target,
        .optimize = optimize
    });

    const timer = b.addModule("timer", .{
        .root_source_file = b.path("../lib/timer.zig"),
        .target = target,
        .optimize = optimize
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../lib/i2c.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        }
    });

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../lib/spi.zig"),
        .target = target,
        .optimize = optimize
    });

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../../ch32lib/fb_allocator.zig"),
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
            .{ .name = "rcc", .module = rcc },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "afio", .module = afio },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "usart", .module = usart },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "pfic", .module = pfic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "usart_writer", .module = build_parameters.usart_writer },
            .{ .name = "shell", .module = build_parameters.shell },
            .{ .name = "timer", .module = timer },
            .{ .name = "i2c", .module = i2c },
            .{ .name = "spi", .module = spi }
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
    exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_ch32v20x_D6.S"));

    exe.setLinkerScript(b.path("../Link_203C8.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
