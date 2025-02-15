const std = @import("std");
const result = @import("./result.zig");
const MissingArgCommand = result.MissingArgCommand;
const item = @import("./item.zig");
const Item = item.Item;

const setColor = "\u{001B}[{s}m{s}";
const resetColor = "\u{001B}[0m";
const withColor = setColor ++ resetColor ++ "\n";
const withColor2 = setColor ++ " {s}" ++ resetColor ++ "\n";
const itemTemplate = "{d}: " ++ setColor ++ resetColor ++ "{s}\n";

pub const Color = enum {
    red,
    green,
    yellow,
    blue,

    pub fn toCode(self: Color) []const u8 {
        return switch (self) {
            .red => "31",
            .green => "32",
            .yellow => "33",
            .blue => "34",
        };
    }
};

pub const ColoredWriter = struct {
    writer: std.fs.File.Writer,

    pub fn print(self: ColoredWriter, color: Color, msg: []const u8) !void {
        try self.writer.print(withColor, .{ color.toCode(), msg });
    }

    pub fn printMissingArg(self: ColoredWriter, cmd: MissingArgCommand) !void {
        try self.writer.print(withColor2, .{ Color.red.toCode(), cmd.tagName(), result.missingArg });
    }

    pub fn printItem(self: ColoredWriter, index: usize, todoItem: Item) !void {
        const state = todoItem.state.toString();
        const descColor = todoItem.state.toColor();
        try self.writer.print(
            itemTemplate,
            .{ index, descColor.toCode(), todoItem.description, state },
        );
    }
};
