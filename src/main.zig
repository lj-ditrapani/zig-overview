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
const Color = output.Color;
const ColoredWriter = output.ColoredWriter;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const writer = std.io.getStdOut().writer();
    const reader = std.io.getStdIn().reader();

    try writer.print("\nTodo\n\n", .{});
    var todoList = ArrayList(Item).init(allocator);
    var r: Result = Result{ .help = {} };
    const buf = try allocator.alloc(u8, 256);
    const cWriter = ColoredWriter{ .writer = writer };
    while (r != Result.quit) {
        try writer.print("Enter a command. Enter help to list available commands: ", .{});
        const line = try reader.readUntilDelimiterOrEof(buf, '\n');
        r = todo(&todoList, line, allocator);
        switch (r) {
            .quit => try cWriter.print(Color.blue, "bye!"),
            .help => try cWriter.print(Color.yellow, result.help),
            .emptyListHint => try cWriter.print(Color.yellow, result.emptyListHint),
            .list => try printList(todoList, cWriter),
            .unknownCommand => try cWriter.print(Color.red, result.unknownCommand),
            .missingArg => |cmd| try cWriter.printMissingArg(cmd),
            .doneIndexError => try cWriter.print(Color.red, result.doneIndexError),
        }
    }
}

fn printList(list: ArrayList(Item), writer: ColoredWriter) !void {
    for (list.items, 1..) |todoItem, index| {
        try writer.printItem(index, todoItem);
    }
}
