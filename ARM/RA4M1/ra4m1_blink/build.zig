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

    const clock = b.addModule("clock", .{
        .root_source_file = b.path("../lib/clock.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const icu = b.addModule("icu", .{
        .root_source_file = b.path("../lib/icu.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpt = b.addModule("gpt", .{
        .root_source_file = b.path("../lib/gpt.zig"),
        .target = target,
        .optimize = optimize
    });

    const lpm = b.addModule("lpm", .{
        .root_source_file = b.path("../lib/lpm.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
        .target = target,
        .optimize = optimize
    });

    const agt = b.addModule("agt", .{
        .root_source_file = b.path("../lib/agt.zig"),
        .target = target,
        .optimize = optimize
    });

    const backup = b.addModule("backup", .{
        .root_source_file = b.path("../lib/backup.zig"),
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

    const exe = b.addExecutable(.{
        .name = "ra4m1_blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "icu", .module = icu },
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "cpu", .module = cpu },
                .{ .name = "gpio", .module = gpio },
                .{ .name = "gpt", .module = gpt },
                .{ .name = "agt", .module = agt },
                .{ .name = "backup", .module = backup },
                .{ .name = "lpm", .module = lpm },
                .{ .name = "nvic", .module = nvic },
                .{ .name = "clock", .module = clock }
            },
        }),
    });

    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    //exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup.S"));

    exe.setLinkerScript(b.path("../Link.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
