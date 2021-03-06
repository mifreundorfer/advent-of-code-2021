const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    addDay(b, target, mode, "Day1", "Day1/day1.zig");
    addDay(b, target, mode, "Day2", "Day2/day2.zig");
    addDay(b, target, mode, "Day3", "Day3/day3.zig");
    addDay(b, target, mode, "Day4", "Day4/day4.zig");
}

fn addDay(b: *std.build.Builder, target: std.zig.CrossTarget, mode: std.builtin.Mode,
    name: []const u8, main_file: []const u8) void {
    const exe = b.addExecutable(name, main_file);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(name, "Run this day");
    run_step.dependOn(&run_cmd.step);
}
