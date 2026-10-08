const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 }
    });

    const optimize = b.standardOptimizeOption(.{});

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const rcc = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
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

    const board = b.addModule("board", .{
        .root_source_file = b.path("../lib/f429i_discovery.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc },
            .{ .name = "gpio", .module = gpio }
        },
    });

    const exe = b.addExecutable(.{
        .name = "stm32f429_blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "cpu", .module = cpu },
                .{ .name = "board", .module = board },
                .{ .name = "rcc", .module = rcc },
                .{ .name = "gpio", .module = gpio },
                .{ .name = "nvic", .module = nvic }
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_stm32f429xx.s"));

    exe.setLinkerScript(b.path("../STM32F429xx_FLASH.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
