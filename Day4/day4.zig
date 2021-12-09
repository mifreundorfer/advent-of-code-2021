const std = @import("std");
const math = std.math;

const Allocator = std.mem.Allocator;

const Board = struct {
    board_index: i32,
    numbers: [25]i32,
    checked: [25]bool,

    pub fn markNumber(self: *Board, number: i32) void {
        for (range(25)) |_, i| {
            if (self.numbers[i] == number) {
                self.checked[i] = true;
            }
        }
    }

    pub fn hasBingo(self: Board) bool {
        for (range(5)) |_, row| {
            var all_marked = true;
            for (range(5)) |_, col| {
                all_marked = all_marked and self.checked[row * 5 + col];
            }

            if (all_marked) {
                return true;
            }
        }

        for (range(5)) |_, col| {
            var all_marked = true;
            for (range(5)) |_, row| {
                all_marked = all_marked and self.checked[row * 5 + col];
            }

            if (all_marked) {
                return true;
            }
        }

        return false;
    }

    pub fn printBoard(self: Board) void {
        for (range(5)) |_, row| {
            std.log.info("{d} {d} {d} {d} {d}", .{
                if (!self.checked[row * 5 + 0]) self.numbers[row * 5 + 0] else -1,
                if (!self.checked[row * 5 + 1]) self.numbers[row * 5 + 1] else -1,
                if (!self.checked[row * 5 + 2]) self.numbers[row * 5 + 2] else -1,
                if (!self.checked[row * 5 + 3]) self.numbers[row * 5 + 3] else -1,
                if (!self.checked[row * 5 + 4]) self.numbers[row * 5 + 4] else -1,
            });
        }
    }

    pub fn calculateWinningScore(self: Board, number: i32) i32 {
        var result: i32 = 0;
        for (range(25)) |_, i| {
            if (!self.checked[i]) {
                result += self.numbers[i];
            }
        }

        return result * number;
    }
};

pub fn range(len: usize) []const u0 {
    return @as([*]u0, undefined)[0..len];
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = arena.deinit();
    var allocator: *Allocator = &arena.allocator;

    var input: []u8 = try std.fs.cwd().readFileAlloc(allocator, "Day4/input.txt", std.math.maxInt(usize));

    var reader = std.io.fixedBufferStream(input).reader();

    var randomNumbers = std.ArrayList(i32).init(allocator);
    {
        var line: []u8 = (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))).?;

        var it = std.mem.split(u8, line, ",");
        while (it.next()) |value| {
            try randomNumbers.append(try std.fmt.parseInt(i32, value, 10));
        }
    }

    var timer = try std.time.Timer.start();

    var board_index: i32 = 0;
    var boards = std.ArrayList(Board).init(allocator);
    while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |empty_line| {
        std.debug.assert(empty_line.len == 0);

        var board: Board = .{ .board_index = board_index, .numbers = .{ 0 }**25, .checked = .{ false }**25 };
        board_index += 1;

        var row: usize = 0;
        while (row < 5) : (row += 1) {
            var line = try reader.readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
            var col: usize = 0;
            while (col < 5) : (col += 1) {
                var value = line[col*3..col*3+2];
                if (value[0] == ' ') {
                    value = value[1..2];
                }

                board.numbers[row * 5 + col] = try std.fmt.parseInt(i32, value, 10);
            }

            std.debug.assert(col == 5);
        }

        std.debug.assert(row == 5);

        try boards.append(board);
    }

    std.log.info("Parsing boards took {d}ms", .{@intToFloat(f64, timer.lap()) / 1_000_000.0});

    var fistWinningScore: ?i32 = null;
    var lastWinningScore: ?i32 = null;
    for (randomNumbers.items) |number| {
        for (boards.items) |*board| {
            board.markNumber(number);
        }

        var i: usize = 0;
        while (i < boards.items.len) {
            var board = &boards.items[i];
            if (board.hasBingo()) {
                var score = board.calculateWinningScore(number);
                if (fistWinningScore == null) {
                    fistWinningScore = score;
                }

                lastWinningScore = score;

                _ = boards.swapRemove(i);
            } else {
                i += 1;
            }
        }
    }

    std.log.info("Playing game took {d}ms", .{@intToFloat(f64, timer.lap()) / 1_000_000.0});

    std.log.info("First Winning score will be {d}", .{ fistWinningScore.? });
    std.log.info("Last Winning score will be {d}", .{ lastWinningScore.? });
}