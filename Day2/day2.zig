const std = @import("std");
const math = std.math;

const Allocator = std.mem.Allocator;
pub const GPAllocator = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 16 });

pub fn main() anyerror!void {
    var gp_allocator: GPAllocator  = .{};
    defer _ = gp_allocator.deinit();
    var allocator: *Allocator = &gp_allocator.allocator;

    const input: []u8 = try std.fs.cwd().readFileAlloc(allocator, "Day2/input.txt", math.maxInt(usize));
    defer allocator.free(input);

    {
        var reader = std.io.fixedBufferStream(input).reader();
        var buffer: [128]u8 = undefined;

        var forward: i32 = 0;
        var depth: i32 = 0;
        while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
            if (std.mem.startsWith(u8, line, "forward")) {
                const value = try std.fmt.parseInt(i32, line[8..], 10);
                forward += value;
            } else if (std.mem.startsWith(u8, line, "down")) {
                const value = try std.fmt.parseInt(i32, line[5..], 10);
                depth += value;
            } else if (std.mem.startsWith(u8, line, "up")) {
                const value = try std.fmt.parseInt(i32, line[3..], 10);
                depth -= value;
            }
        }

        std.log.info("Forward is {d}, Depth is {d}, mulitplied is {d}", .{ forward, depth, forward * depth });
    }

    {
        var reader = std.io.fixedBufferStream(input).reader();
        var buffer: [128]u8 = undefined;

        var forward: i32 = 0;
        var depth: i32 = 0;
        var aim: i32 = 0;
        while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
            if (std.mem.startsWith(u8, line, "forward")) {
                const value = try std.fmt.parseInt(i32, line[8..], 10);
                forward += value;
                depth += value * aim;
            } else if (std.mem.startsWith(u8, line, "down")) {
                const value = try std.fmt.parseInt(i32, line[5..], 10);
                aim += value;
            } else if (std.mem.startsWith(u8, line, "up")) {
                const value = try std.fmt.parseInt(i32, line[3..], 10);
                aim -= value;
            }
        }

        std.log.info("Corrected Forward is {d}, Depth is {d}, mulitplied is {d}", .{ forward, depth, forward * depth });
    }
}