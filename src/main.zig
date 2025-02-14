const std = @import("std");
const bufPrint = std.fmt.bufPrint;
const ArrayList = std.ArrayList;
const Writer = std.fs.File.Writer;
const item = @import("./item.zig");
const Item = item.Item;
const output = @import("./output.zig");
const result = @import("./result.zig");
const Result = result.Result;
const MissingArgCommand = result.MissingArgCommand;
const todo = @import("./todo.zig").todo;
const Color = @import("./output.zig").Color;

const setColor = "\u{001B}[{s}m{s}";
const resetColor = "\u{001B}[0m";
const withColor = setColor ++ resetColor ++ "\n";
const withColor2 = setColor ++ " {s}" ++ resetColor ++ "\n";
const itemTemplate = "{d}: " ++ setColor ++ resetColor ++ "{s}\n";

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
    const cWriter = ColoredWriter{ .writer = writer };
    while (r != Result.quit) {
        try writer.print("\nEnter a command. Enter help to list available commands: ", .{});
        const line = try reader.readUntilDelimiterOrEof(buf, '\n');
        r = todo(&todoList, line, allocator);
        switch (r) {
            .quit => try cWriter.print(Color.blue, "bye!"),
            .help => try cWriter.print(Color.yellow, result.help),
            .emptyListHint => try cWriter.print(Color.yellow, result.emptyListHint),
            .list => try printList(todoList, writer),
            .unknownCommand => try cWriter.print(Color.red, result.unknownCommand),
            .missingArg => |cmd| try writer.print(
                withColor2,
                .{ Color.red.toCode(), cmd.tagName(), result.missingArg },
            ),
            .doneIndexError => try cWriter.print(Color.red, result.doneIndexError),
        }
    }
}

fn printList(list: ArrayList(Item), writer: Writer) !void {
    for (list.items, 1..) |todoItem, index| {
        try printItem(index, todoItem, writer);
    }
}

fn printItem(index: usize, todoItem: Item, writer: Writer) !void {
    const state = todoItem.state.toString();
    const descColor = switch (todoItem.state) {
        .todo => Color.green,
        .done => Color.blue,
    };
    try writer.print(
        itemTemplate,
        .{ index, descColor.toCode(), todoItem.description, state },
    );
}
pub const ColoredWriter = struct {
    writer: std.fs.File.Writer,

    pub fn print(self: ColoredWriter, color: Color, msg: []const u8) !void {
        try self.writer.print(withColor, .{ color.toCode(), msg });
    }
};
