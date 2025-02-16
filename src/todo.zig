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

test "todo returns tooMuchInput Result if line is a StreamTooLong error" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    const value = todo(&list, error.StreamTooLong, allocator);
    try std.testing.expectEqual(Result{ .tooMuchInput = {} }, value);
}

test "todo returns the error if line is any other error" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    const value = todo(&list, error.TestError, allocator);
    try std.testing.expectEqual(error.TestError, value);
}

test "todo returns unknownCommand if line is null" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    const value = todo(&list, null, allocator);
    try std.testing.expectEqual(unknownCommand, value);
}

test "todo returns unknownCommand if line is not a command" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    const cmd: []u8 = try allocator.dupe(u8, "clap");
    defer allocator.free(cmd);
    const value = todo(&list, cmd, allocator);
    try std.testing.expectEqual(unknownCommand, value);
}

test "todo returns quit if line is quit" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    const cmd: []u8 = try allocator.dupe(u8, "quit");
    defer allocator.free(cmd);
    const value = todo(&list, cmd, allocator);
    try std.testing.expectEqual(Result{ .quit = {} }, value);
}

test "todo returns help if line is help" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    const cmd: []u8 = try allocator.dupe(u8, "help");
    defer allocator.free(cmd);
    const value = todo(&list, cmd, allocator);
    try std.testing.expectEqual(help, value);
}

test "todo returns emptyListHint if line is list and list is empty" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    const cmd: []u8 = try allocator.dupe(u8, "list");
    defer allocator.free(cmd);
    const value = todo(&list, cmd, allocator);
    try std.testing.expectEqual(emptyListHint, value);
}

test "todo returns list if line is list and list is non-empty" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    _ = try list.addOne();
    defer list.deinit();
    const cmd: []u8 = try allocator.dupe(u8, "list");
    defer allocator.free(cmd);
    const value = todo(&list, cmd, allocator);
    try std.testing.expectEqual(Result{ .list = {} }, value);
}

test "todo returns missingArg if line is missing arg (add)" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    defer list.deinit();
    const cmd: []u8 = try allocator.dupe(u8, " add ");
    defer allocator.free(cmd);
    const value = todo(&list, cmd, allocator);
    try std.testing.expectEqual(Result{ .missingArg = .add }, value);
}

test "todo returns missingArg if line is missing arg (done)" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(Item).init(allocator);
    defer list.deinit();
    const cmd: []u8 = try allocator.dupe(u8, " done ");
    defer allocator.free(cmd);
    const value = todo(&list, cmd, allocator);
    try std.testing.expectEqual(Result{ .missingArg = .done }, value);
}
