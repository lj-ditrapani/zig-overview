const std = @import("std");
const item = @import("./item.zig");
const output = @import("./output.zig");
const result = @import("./result.zig");
const todo = @import("./todo.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const writer = std.io.getStdOut().writer();
    const reader = std.io.getStdIn().reader();

    try writer.print("\nTodo\n", .{});
    var todoList = std.ArrayList(item.Item).init(allocator);
    var r: result.Result = result.Result{ .help = {} };
    const buf = try allocator.alloc(u8, 256);
    while (r != result.Result.exit) {
        try writer.print("\nEnter a command. Enter help to list available commands: ", .{});
        const maybeLine = try reader.readUntilDelimiterOrEof(buf, '\n');
        if (maybeLine) |line| {
            try writer.print("Got {s}", .{line});
            r = todo.todo(&todoList, line);
        }
    }
}
