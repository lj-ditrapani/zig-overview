const std = @import("std");
const tagName = std.enums.tagName;
const item = @import("./item.zig");
const Item = item.Item;
const output = @import("./output.zig");
const result = @import("./result.zig");
const Result = result.Result;
const MissingArgCommand = result.MissingArgCommand;
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
        r = todo(&todoList, line, allocator);
        switch (r) {
            .quit => try writer.print("bye!\n", .{}),
            .help => try writer.print(result.help, .{}),
            .emptyListHint => try writer.print(result.emptyListHint, .{}),
            .list => try printList(todoList, writer),
            .unknownCommand => try writer.print(
                result.unknownCommand,
                .{},
            ),
            .missingArg => |cmd| try writer.print("{?s} {s}", .{ tagName(MissingArgCommand, cmd), result.missingArg }),
            .doneIndexError => try writer.print(result.doneIndexError, .{}),
        }
    }
}

fn printList(list: std.ArrayList(Item), writer: anytype) !void {
    for (list.items, 1..) |todoItem, index| {
        const state = switch (todoItem.state) {
            .done => "(done)",
            .todo => "",
        };
        try writer.print("{d}: {s} {s}\n", .{ index, todoItem.description, state });
    }
}
