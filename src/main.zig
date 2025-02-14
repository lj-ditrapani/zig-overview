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
    var todoList = ArrayList(Item).init(allocator);
    var r: Result = Result{ .help = {} };
    const buf = try allocator.alloc(u8, 256);
    while (r != Result.quit) {
        try writer.print("\nEnter a command. Enter help to list available commands: ", .{});
        const line = try reader.readUntilDelimiterOrEof(buf, '\n');
        r = todo(&todoList, line, allocator);
        switch (r) {
            .quit => try writer.print(colorTemplate(Color.blue), .{"bye!\n"}),
            .help => try writer.print(colorTemplate(Color.yellow), .{result.help}),
            .emptyListHint => try writer.print(colorTemplate(Color.yellow), .{result.emptyListHint}),
            .list => try printList(todoList, writer, buf),
            .unknownCommand => try writer.print(colorTemplate(Color.red), .{result.unknownCommand}),
            .missingArg => |cmd| try writer.print(colorTemplate2(Color.red, "{s} {s}"), .{ cmd.tagName(), result.missingArg }),
            .doneIndexError => try writer.print(colorTemplate(Color.red), .{result.doneIndexError}),
        }
    }
}

fn printList(list: ArrayList(Item), writer: std.fs.File.Writer, buf: []u8) !void {
    for (list.items, 1..) |todoItem, index| {
        try printItem(index, todoItem, writer, buf);
    }
}

fn printItem(index: usize, todoItem: Item, writer: std.fs.File.Writer, buf: []u8) !void {
    const state = todoItem.state.toString();
    const descColor = switch (todoItem.state) {
        .todo => Color.green,
        .done => Color.blue,
    };
    const msg = try std.fmt.bufPrint(buf, "{d}: \u{001B}[{s}m{s}\u{001B}[0m{s}", .{ index, descColor.toCode(), todoItem.description, state });
    try writer.print("{s}\n", .{msg});
}

inline fn colorTemplate(color: Color) []const u8 {
    return colorTemplate2(color, "{s}");
}

inline fn colorTemplate2(color: Color, body: []const u8) []const u8 {
    return "\u{001B}[" ++ color.toCode() ++ "m" ++ body ++ "\u{001B}[0m";
}
