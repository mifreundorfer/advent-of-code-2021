const std = @import("std");
const math = std.math;

const Allocator = std.mem.Allocator;
pub const GPAllocator = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 16 });

pub fn main() anyerror!void {
    var gp_allocator: GPAllocator  = .{};
    defer _ = gp_allocator.deinit();
    var allocator: *Allocator = &gp_allocator.allocator;

    const input: []u8 = try std.fs.cwd().readFileAlloc(allocator, "Day3/input.txt", math.maxInt(usize));
    defer allocator.free(input);

    var values = std.ArrayList(i32).init(allocator);
    defer values.deinit();

    var reader = std.io.fixedBufferStream(input).reader();
    var buffer: [128]u8 = undefined;

    var max_bit: i32 = 0;
    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        const value: i32 = try std.fmt.parseInt(i32, line, 2);
        max_bit = std.math.max(max_bit, @intCast(i32, line.len));
        try values.append(value);
    }


    {
        var gamma: i32 = 0;
        var epsilon: i32 = 0;
        var bit: u5 = 0;
        while (bit < max_bit) : (bit += 1) {
            var one_bits: i32 = 0;
            var zero_bits: i32 = 0;
            for (values.items) |value| {
                if (((value >> bit) & 1) == 1) {
                    one_bits += 1;
                } else {
                    zero_bits += 1;
                }
            }

            if (one_bits > zero_bits) {
                gamma |= @as(i32, 1) << bit;
            } else {
                epsilon |= @as(i32, 1) << bit;
            }
        }

        const power_consumption = gamma * epsilon;

        std.log.info("Power consumption is {d}", .{ power_consumption });
    }

    {
        var oxygen_candidates = std.ArrayList(i32).init(allocator);
        defer oxygen_candidates.deinit();
        try oxygen_candidates.appendSlice(values.items);

        var bit: i32 = max_bit - 1;
        while (oxygen_candidates.items.len > 1 and bit >= 0) : (bit -= 1) {
            var one_bits: i32 = 0;
            var zero_bits: i32 = 0;
            for (oxygen_candidates.items) |value| {
                if (((value >> @intCast(u5, bit)) & 1) == 1) {
                    one_bits += 1;
                } else {
                    zero_bits += 1;
                }
            }

            const valid_bit: i32 = if (one_bits >= zero_bits) 1 else 0;

            var i: usize = 0;
            while (i < oxygen_candidates.items.len) {
                if (((oxygen_candidates.items[i] >> @intCast(u5, bit)) & 1) != valid_bit) {
                    _ = oxygen_candidates.swapRemove(i);
                } else {
                    i += 1;
                }
            }
        }

        var co2_candidates = std.ArrayList(i32).init(allocator);
        defer co2_candidates.deinit();
        try co2_candidates.appendSlice(values.items);

        bit = max_bit - 1;
        while (co2_candidates.items.len > 1 and bit >= 0) : (bit -= 1) {
            var one_bits: i32 = 0;
            var zero_bits: i32 = 0;
            for (co2_candidates.items) |value| {
                if (((value >> @intCast(u5, bit)) & 1) == 1) {
                    one_bits += 1;
                } else {
                    zero_bits += 1;
                }
            }

            const valid_bit: i32 = if (zero_bits <= one_bits) 0 else 1;

            var i: usize = 0;
            while (i < co2_candidates.items.len) {
                if (((co2_candidates.items[i] >> @intCast(u5, bit)) & 1) != valid_bit) {
                    _ = co2_candidates.swapRemove(i);
                } else {
                    i += 1;
                }
            }
        }

        std.debug.assert(oxygen_candidates.items.len == 1);
        const oxygen_generator_rating = oxygen_candidates.items[0];

        std.debug.assert(co2_candidates.items.len == 1);
        const co2_scrubber_rating = co2_candidates.items[0];

        const life_support_rating = oxygen_generator_rating * co2_scrubber_rating;

        std.log.info("Oxygen generator rating is {d}", .{ oxygen_generator_rating });
        std.log.info("CO2 scrubber rating is {d}", .{ co2_scrubber_rating });
        std.log.info("Life support rating is {d}", .{ life_support_rating });
    }
}