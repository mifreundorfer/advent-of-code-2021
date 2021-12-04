const std = @import("std");

const Allocator = std.mem.Allocator;
pub const GPAllocator = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 16 });

pub fn main() anyerror!void {
    var gp_allocator: GPAllocator  = .{};
    defer _ = gp_allocator.deinit();
    var allocator: *Allocator = &gp_allocator.allocator;

    {
        var file = try std.fs.cwd().openFile("Day1/input.txt", .{ .read = true });
        defer file.close();

        var reader = file.reader();
        var buffer: [128]u8 = undefined;

        var last_value: ?i32 = null;
        var num_greater: i32 = 0;
        while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
            const value: i32 = try std.fmt.parseInt(i32, line, 10);

            if (last_value) |lv| {
                if (value > lv) {
                    num_greater += 1;
                }
            }

            last_value = value;
        }

        std.log.info("There {d} measurements greater than the last one", .{ num_greater });
    }

    {
        var file = try std.fs.cwd().openFile("Day1/input.txt", .{ .read = true });
        defer file.close();

        var reader = file.reader();
        var buffer: [128]u8 = undefined;

        var values = std.ArrayList(i32).init(allocator);
        defer values.deinit();

        while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
            const value: i32 = try std.fmt.parseInt(i32, line, 10);
            try values.append(value);
        }

        var last_window: ?i32 = null;
        var num_greater: i32 = 0;

        var i: usize = 0;
        while (i < values.items.len - 2) : ( i += 1) {
            var window: i32 = 0;
            for (values.items[i..i+3]) |value| {
                window += value;
            }

            if (last_window) |lw| {
                if (window > lw) {
                    num_greater += 1;
                }
            }

            last_window = window;
        }

        std.log.info("There {d} sliding window measurements greater than the last one", .{ num_greater });
    }

    // without intermediately allocating an array of all values
    {
        var file = try std.fs.cwd().openFile("Day1/input.txt", .{ .read = true });
        defer file.close();

        var reader = file.reader();
        var buffer: [128]u8 = undefined;

        var last_window: i32 = 0;
        var num_greater: i32 = 0;
        var window_buffer: [3]i32 = .{ 0, 0, 0 };
        var index: usize = 0;

        while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (index += 1) {
            const value: i32 = try std.fmt.parseInt(i32, line, 10);

            window_buffer[index % 3] = value;

            var window: i32 = 0;
            for (window_buffer) |window_value| {
                window += window_value;
            }

            if (index > 2) {
                if (window > last_window) {
                    num_greater += 1;
                }
            }

            last_window = window;
        }

        std.log.info("There {d} sliding window measurements greater than the last one", .{ num_greater });
    }
}
