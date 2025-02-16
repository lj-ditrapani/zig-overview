const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = @import("std").mem.Allocator;
const item = @import("./item.zig");
const Item = item.Item;
const result = @import("./result.zig");
const Result = result.Result;
const help = result.help;
const emptyListHint = result.emptyListHint;
const doneIndexError = result.doneIndexError;
const unknownCommand = result.unknownCommand;

const Command = enum { help, add, done, quit, list };

pub fn todo(
    todoList: *ArrayList(Item),
    maybeEitherLine: anyerror!?[]u8,
    allocator: Allocator,
) anyerror!Result {
    const maybeLine = maybeEitherLine catch |e| {
        if (e == error.StreamTooLong) return .{ .tooMuchInput = {} };
        return e;
    };
    const line = maybeLine orelse return unknownCommand;
    var parts = std.mem.tokenizeAny(u8, line, " \t\r");
    const cmdStr = parts.next() orelse return unknownCommand;
    const rawArg = parts.rest();
    const arg = std.mem.trim(u8, rawArg, " \t\r");
    const cmd = std.meta.stringToEnum(Command, cmdStr) orelse return unknownCommand;
    return switch (cmd) {
        .quit => .{ .quit = {} },
        .help => help,
        .list => processList(todoList.*),
        .add => processAdd(todoList, arg, allocator),
        .done => processDone(todoList, arg),
    };
}

pub fn processList(todoList: ArrayList(Item)) Result {
    return switch (todoList.items.len) {
        0 => emptyListHint,
        else => .{ .list = {} },
    };
}

pub fn processAdd(todoList: *ArrayList(Item), arg: []const u8, allocator: Allocator) Result {
    if (arg.len == 0) {
        return .{ .missingArg = .add };
    }
    const argCopy = allocator.dupe(u8, arg) catch unreachable;
    todoList.append(.{ .state = item.State.todo, .description = argCopy }) catch unreachable;
    return .{ .list = {} };
}

pub fn processDone(todoList: *ArrayList(Item), arg: []const u8) Result {
    if (arg.len == 0) {
        return .{ .missingArg = .done };
    }
    const index = std.fmt.parseInt(u16, arg, 10) catch return doneIndexError;

    if (index > 0 and index <= todoList.items.len) {
        var todoItem = &todoList.items[index - 1];
        todoItem.state = item.State.done;
        return .{ .list = {} };
    } else {
        return doneIndexError;
    }
}
