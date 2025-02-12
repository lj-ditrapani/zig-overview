const std = @import("std");
const item = @import("./item.zig");
const result = @import("./result.zig");

const Command = enum { help, add, done, quit, list };

pub fn todo(todoList: *std.ArrayList(item.Item), maybeLine: ?[]u8, allocator: std.mem.Allocator) std.mem.Allocator.Error!result.Result {
    const line = maybeLine orelse return .{ .unknownCommand = {} };
    var parts = std.mem.tokenizeAny(u8, line, " \t\r");
    const cmdStr = parts.next() orelse return .{ .unknownCommand = {} };
    const rawArg = parts.rest();
    const arg = std.mem.trim(u8, rawArg, " \t\r");
    const cmd = std.meta.stringToEnum(Command, cmdStr) orelse return .{ .unknownCommand = {} };
    return switch (cmd) {
        Command.quit => .{ .quit = {} },
        Command.help => .{ .help = {} },
        Command.list => processList(todoList),
        Command.add => try processAdd(todoList, arg, allocator),
        Command.done => processDone(todoList, arg),
    };
}

pub fn processList(todoList: *std.ArrayList(item.Item)) result.Result {
    return switch (todoList.items.len) {
        0 => .{ .emptyListHint = {} },
        else => .{ .list = {} },
    };
}

pub fn processAdd(todoList: *std.ArrayList(item.Item), arg: []const u8, allocator: std.mem.Allocator) std.mem.Allocator.Error!result.Result {
    const argCopy = try allocator.dupe(u8, arg);
    try todoList.append(.{ .state = item.State.todo, .description = argCopy });
    return .{ .list = {} };
}

pub fn processDone(todoList: *std.ArrayList(item.Item), arg: []const u8) result.Result {
    const index = std.fmt.parseInt(u16, arg, 10) catch return .{ .doneIndexError = {} };

    if (index > 0 and index <= todoList.items.len) {
        var i = &todoList.items[index - 1];
        i.state = item.State.done;
        return .{ .list = {} };
    } else {
        return .{ .doneIndexError = {} };
    }
}
