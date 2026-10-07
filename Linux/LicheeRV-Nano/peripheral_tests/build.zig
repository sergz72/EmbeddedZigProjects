const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv64,
        .os_tag = .linux,
        .abi = .musl,
        .cpu_features_add = std.Target.riscv.featureSet(&.{
            .m,
            .a,
            .f,
            .d,
            .c,
        }),
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../../peripheral_library/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../../peripheral_library/spi.zig"),
        .target = target,
        .optimize = optimize
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../../peripheral_library/i2c.zig"),
        .target = target,
        .optimize = optimize
    });

    const cc1101 = b.addModule("cc1101", .{
        .root_source_file = b.path("../../../common_lib/rf/cc1101.zig"),
        .target = target,
        .optimize = optimize
    });

    const cc1101_device = b.addModule("cc1101_device", .{
        .root_source_file = b.path("../../peripheral_library/cc1101_device.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "gpio", .module = gpio },
            .{ .name = "spi", .module = spi },
            .{ .name = "cc1101", .module = cc1101 }
        },
    });

    const exe = b.addExecutable(.{
        .name = "peripheral_tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("../../peripheral_library/peripheral_tests.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "gpio", .module = gpio },
                .{ .name = "spi", .module = spi },
                .{ .name = "i2c", .module = i2c },
                .{ .name = "cc1101_device", .module = cc1101_device }
            },
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
}
