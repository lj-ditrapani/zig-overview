const std = @import("std");
const ArrayList = std.ArrayList;
const item = @import("./item.zig");
const Item = item.Item;
const output = @import("./output.zig");
const result = @import("./result.zig");
const Result = result.Result;
const MissingArgCommand = result.MissingArgCommand;
const todo = @import("./todo.zig").todo;
const Color = @import("./output.zig").Color;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const writer = std.io.getStdOut().writer();
    const reader = std.io.getStdIn().reader();

    try writer.print("\nTodo\n", .{});
    try writer.print(colorTemplate(Color.blue), .{"blue?"});
    var todoList = ArrayList(Item).init(allocator);
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
            .missingArg => |cmd| try writer.print("{s} {s}", .{ cmd.tagName(), result.missingArg }),
            .doneIndexError => try writer.print(result.doneIndexError, .{}),
        }
    }
}

fn printList(list: ArrayList(Item), writer: std.fs.File.Writer) !void {
    for (list.items, 1..) |todoItem, index| {
        const state = todoItem.state.toString();
        try writer.print("{d}: {s} {s}\n", .{ index, todoItem.description, state });
    }
}

inline fn colorTemplate(color: Color) []const u8 {
    return "\u{001B}[" ++ color.toCode() ++ "m{s}\u{001B}[0m";
}
