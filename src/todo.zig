const std = @import("std");
const Allocator = @import("std").mem.Allocator;
const item = @import("./item.zig");
const Item = @import("./item.zig").Item;
const Result = @import("./result.zig").Result;

const Command = enum { help, add, done, quit, list };

pub fn todo(
    todoList: *std.ArrayList(Item),
    maybeLine: ?[]u8,
    allocator: Allocator,
) Allocator.Error!Result {
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

pub fn processList(todoList: *std.ArrayList(Item)) Result {
    return switch (todoList.items.len) {
        0 => .{ .emptyListHint = {} },
        else => .{ .list = {} },
    };
}

pub fn processAdd(
    todoList: *std.ArrayList(Item),
    arg: []const u8,
    allocator: Allocator,
) Allocator.Error!Result {
    const argCopy = try allocator.dupe(u8, arg);
    try todoList.append(.{ .state = item.State.todo, .description = argCopy });
    return .{ .list = {} };
}

pub fn processDone(todoList: *std.ArrayList(Item), arg: []const u8) Result {
    const index = std.fmt.parseInt(u16, arg, 10) catch return .{ .doneIndexError = {} };

    if (index > 0 and index <= todoList.items.len) {
        var todoItem = &todoList.items[index - 1];
        todoItem.state = item.State.done;
        return .{ .list = {} };
    } else {
        return .{ .doneIndexError = {} };
    }
}
