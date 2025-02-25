const std = @import("std");
const ArrayList = std.ArrayList;
const item = @import("./item.zig");
const Item = item.Item;
const printList = item.printList;
const output = @import("output.zig");
const ColoredWriter = output.ColoredWriter;
const Color = output.Color;

const helpMsg =
    \\Available commands:
    \\help                              Displays this help
    \\list                              Display the todo list
    \\add <todo item description>       Adds the item to the todo list
    \\done <todo item number>           Marks the item as done
    \\quit                              Exit the program
;
const emptyListHintMsg = "List is empty.  Try adding some items";
const unknownCommandMsg = "I do not understand your command.  " ++
    "Enter help to display available commands.";
pub const missingArg = "command requires an argument";
const doneIndexErrorMsg = "Done command must have a valid item index";
const tooMuchInput = "You typed too many characters in.  Limit your command to 256 characters.";

pub const Result = union(enum) {
    quit,
    list,
    warn: Warn,
    err: Err,
    missingArg: MissingArgCommand,
    tooMuchInput,

    pub fn printResult(self: Result, todoList: ArrayList(Item), writer: ColoredWriter, reader: anytype) !void {
        switch (self) {
            .quit => try writer.print(Color.blue, "bye!"),
            .list => try printList(todoList, writer.writer),
            .warn => |w| try writer.print(Color.yellow, w.msg),
            .err => |e| try writer.print(Color.red, e.msg),
            .missingArg => |cmd| try writer.print2(cmd.tagName(), missingArg),
            .tooMuchInput => try handleTooMuchInput(writer, reader),
        }
    }
};

const Warn = struct {
    msg: []const u8,
};

const Err = struct {
    msg: []const u8,
};

const MissingArgCommand = enum {
    add,
    done,

    pub fn tagName(self: MissingArgCommand) []const u8 {
        return switch (self) {
            .add => "Add",
            .done => "Done",
        };
    }
};

pub const help = Result{ .warn = Warn{ .msg = helpMsg } };
pub const emptyListHint = Result{ .warn = Warn{ .msg = emptyListHintMsg } };
pub const unknownCommand = Result{ .err = Err{ .msg = unknownCommandMsg } };
pub const doneIndexError = Result{ .err = Err{ .msg = doneIndexErrorMsg } };

fn handleTooMuchInput(writer: ColoredWriter, reader: anytype) !void {
    try writer.print(Color.red, tooMuchInput);
    try reader.skipUntilDelimiterOrEof('\n');
}

test "MissingArgCommand.tagName returns string description of command" {
    try std.testing.expectEqualStrings("Add", MissingArgCommand.add.tagName());
    try std.testing.expectEqualStrings("Done", MissingArgCommand.done.tagName());
}
