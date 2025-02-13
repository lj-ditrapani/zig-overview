const std = @import("std");
const item = @import("./item.zig");
const Item = @import("./item.zig").Item;
const output = @import("./output.zig");
const result = @import("./result.zig");
const Result = @import("./result.zig").Result;
const todo = @import("./todo.zig").todo;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const writer = std.io.getStdOut().writer();
    const reader = std.io.getStdIn().reader();

    try writer.print("\nTodo\n", .{});
    var todoList = std.ArrayList(Item).init(allocator);
    var r: Result = Result{ .help = {} };
    const buf = try allocator.alloc(u8, 256);
    while (r != Result.quit) {
        try writer.print("\nEnter a command. Enter help to list available commands: ", .{});
        const line = try reader.readUntilDelimiterOrEof(buf, '\n');
        r = try todo(&todoList, line, allocator);
        switch (r) {
            Result.quit => try writer.print("bye!\n", .{}),
            Result.help => try writer.print(result.help, .{}),
            Result.emptyListHint => try writer.print(result.emptyListHint, .{}),
            Result.list => {
                for (todoList.items, 1..) |todoItem, index| {
                    try writer.print(
                        "{d}: {s} {?s}\n",
                        .{ index, todoItem.description, std.enums.tagName(
                            item.State,
                            todoItem.state,
                        ) },
                    );
                }
            },
            Result.unknownCommand => try writer.print(
                result.unknownCommand,
                .{},
            ),
            Result.doneIndexError => try writer.print(result.doneIndexError, .{}),
            else => try writer.print("not implemented yet", .{}),
        }
    }
}
