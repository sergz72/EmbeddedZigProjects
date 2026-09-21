const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target_cm4 = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 }
    });

    const target_cm7 = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m7 }
    });

    const optimize = b.standardOptimizeOption(.{});

    const flash = b.addModule("flash", .{
        .root_source_file = b.path("../lib/flash.zig"),
        .target = target_cm4,
        .optimize = optimize
    });

    const rcu = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target_cm4,
        .optimize = optimize
    });

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu.zig"),
        .target = target_cm4,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target_cm4,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target_cm4,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        },
    });

    const nucleo = b.addModule("nucleo", .{
        .root_source_file = b.path("../lib/nucleo.zig"),
        .target = target_cm4,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcu },
            .{ .name = "gpio", .module = gpio }
        },
    });

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("common/hal.zig"),
        .target = target_cm4,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "flash", .module = flash },
            .{ .name = "rcc", .module = rcu },
            .{ .name = "nucleo", .module = nucleo },
            .{ .name = "system_timer", .module = system_timer }
        },
    });

    const exe_cm4 = b.addExecutable(.{
        .name = "stm32h755_blink_cm4.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("cm4/main.zig"),
            .target = target_cm4,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "nucleo", .module = nucleo },
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "hal", .module = hal },
            },
        }),
    });

    const exe_cm7 = b.addExecutable(.{
        .name = "stm32h755_blink_cm7.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("cm7/main.zig"),
            .target = target_cm7,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "nucleo", .module = nucleo },
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "hal", .module = hal },
            },
        }),
    });

    exe_cm4.link_gc_sections = true;
    exe_cm4.link_function_sections = true;
    exe_cm4.link_data_sections = true;
    //exe_cm4.lto = .full;                     // Whole-program optimization & inlining

    exe_cm4.root_module.addAssemblyFile(b.path("../startup_stm32h755xx_CM4.s"));

    exe_cm4.setLinkerScript(b.path("../stm32h755xx_flash_CM4.ld"));

    exe_cm7.link_gc_sections = true;
    exe_cm7.link_function_sections = true;
    exe_cm7.link_data_sections = true;
    //exe_cm7.lto = .full;                     // Whole-program optimization & inlining

    exe_cm7.root_module.addAssemblyFile(b.path("../startup_stm32h755xx_CM7.s"));

    exe_cm7.setLinkerScript(b.path("../stm32h755xx_flash_CM7.ld"));

    b.installArtifact(exe_cm4);
    b.installArtifact(exe_cm7);

    const size_report_cm4 = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report_cm4.addArtifactArg(exe_cm4);

    const size_report_cm7 = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report_cm7.addArtifactArg(exe_cm7);

    b.getInstallStep().dependOn(&size_report_cm4.step);
    b.getInstallStep().dependOn(&size_report_cm7.step);
}
