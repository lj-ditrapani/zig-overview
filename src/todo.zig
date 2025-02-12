const std = @import("std");
const item = @import("./item.zig");
const result = @import("./result.zig");

const Command = enum { help, add, done, quit, list };

pub fn todo(todoList: *std.ArrayList(item.Item), line: []u8) result.Result {
    std.debug.print("here {d}\n", .{todoList.capacity});
    var parts = std.mem.tokenizeAny(u8, line, " \t\r");
    const maybeCmdString = parts.next();
    if (maybeCmdString) |cmdStr| {
        std.debug.print("cmd {s}\n", .{cmdStr});
        const maybeCmd = std.meta.stringToEnum(Command, cmdStr);
        if (maybeCmd) |cmd| {
            return switch (cmd) {
                Command.quit => .{ .exit = {} },
                else => .{ .help = {} },
            };
        }
    }
    return .{ .help = {} };
}
