const std = @import("std");

pub const setColor = "\u{001B}[{s}m{s}";
pub const resetColor = "\u{001B}[0m";
const withColor = setColor ++ resetColor ++ "\n";
const withColor2 = setColor ++ " {s}" ++ resetColor ++ "\n";

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

    pub fn print2(self: ColoredWriter, arg1: []const u8, arg2: []const u8) !void {
        try self.writer.print(withColor2, .{ Color.red.toCode(), arg1, arg2 });
    }
};

test "Color.toCode returns the ANSI color code" {
    try std.testing.expectEqualStrings("31", Color.red.toCode());
    try std.testing.expectEqualStrings("32", Color.green.toCode());
    try std.testing.expectEqualStrings("33", Color.yellow.toCode());
    try std.testing.expectEqualStrings("34", Color.blue.toCode());
}
