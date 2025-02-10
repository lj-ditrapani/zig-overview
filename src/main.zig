const std = @import("std");

pub fn main() !void {
    const arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const rawWriter = std.io.getStdOut().writer();
    var reader = std.io.getStdIn().reader();

    var bw = std.io.bufferedWriter(rawWriter);
    var writer = bw.writer();
    try writer.print("Here we go!\n", .{});
    try bw.flush(); // Don't forget to flush!
    const b = try reader.readByte();
    try writer.print("da char = {c}.\n", .{b});
    try writer.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush(); // Don't forget to flush!
}
