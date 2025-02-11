const std = @import("std");
const item = @import("./item.zig");
const output = @import("./output.zig");
const result = @import("./result.zig");
const todo = @import("./todo.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const rawWriter = std.io.getStdOut().writer();
    const reader = std.io.getStdIn().reader();

    // bw cannot be const because bw.writer wants a mutable reference (*Self)
    var bw = std.io.bufferedWriter(rawWriter);
    const writer = bw.writer();
    try writer.print("Here we go!\n", .{});
    try bw.flush();
    const text: []u8 = try allocator.alloc(u8, 5);
    std.mem.copyForwards(u8, text, "ctext");
    const cs = getCs(text, output.Color.blue);
    try writer.print("The CS: {s} {s}\n", .{ cs.msg, @tagName(cs.color) });
    try bw.flush();
    const b = try reader.readByte();
    try writer.print("da char = {c}.\n", .{b});
    try writer.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush();
    var todoList = std.ArrayList(item.Item).init(allocator);
    loop(&todoList);
}

pub fn loop(todoList: *std.ArrayList(item.Item)) void {
    var r: result.Result = result.Result{ .help = {} };
    while (r != result.Result.exit) {
        r = todo.todo(todoList);
    }
}

fn getCs(text: []u8, color: output.Color) output.ColoredString {
    return .{
        .color = color,
        .msg = text,
    };
}
