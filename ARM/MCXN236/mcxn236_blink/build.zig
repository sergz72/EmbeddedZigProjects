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
            .{ .name = "scg", .module = scg },
            .{ .name = "vbat", .module = vbat },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "lp_flexcomm", .module = lp_flexcomm },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "cpu", .module = cpu }
        },
    });

    const exe = b.addExecutable(.{
        .name = "mcxn236_blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "board", .module = board },
                .{ .name = "ctimer", .module = ctimer },
            },
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
