const std = @import("std");
const ArrayList = std.ArrayList;
const Writer = std.fs.File.Writer;
const Item = @import("./item.zig").Item;
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
    const buf = try allocator.alloc(u8, 256);
    const cWriter = ColoredWriter{ .writer = writer };
    while (true) {
        try writer.print("Enter a command. Enter help to list available commands: ", .{});
        const maybeLine = reader.readUntilDelimiterOrEof(buf, '\n');
        const r = try todo(&todoList, maybeLine, allocator);
        try r.printResult(todoList, cWriter, reader);
        if (r == Result.quit) break;
    }
}
