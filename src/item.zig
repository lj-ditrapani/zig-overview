const std = @import("std");
const ArrayList = std.ArrayList;
const output = @import("./output.zig");
const Color = output.Color;

const itemTemplate = "{d}: " ++ output.setColor ++ output.resetColor ++ "{s}\n";

pub const State = enum {
    todo,
    done,

    pub fn toString(self: State) []const u8 {
        return switch (self) {
            .todo => "",
            .done => " (done)",
        };
    }

    pub fn toColor(self: State) Color {
        return switch (self) {
            .todo => Color.green,
            .done => Color.blue,
        };
    }
};

pub const Item = struct {
    description: []const u8,
    state: State = State.todo,

    pub fn print(self: Item, writer: anytype, index: usize) !void {
        const state = self.state.toString();
        const descColor = self.state.toColor();
        try writer.print(
            itemTemplate,
            .{ index, descColor.toCode(), self.description, state },
        );
    }
};

pub fn printList(list: ArrayList(Item), writer: anytype) !void {
    for (list.items, 1..) |todoItem, index| {
        try todoItem.print(writer, index);
    }
}

test "State.toString" {
    try std.testing.expectEqualStrings("", State.todo.toString());
    try std.testing.expectEqualStrings(" (done)", State.done.toString());
}

test "State.toColor" {
    try std.testing.expectEqual(Color.green, State.todo.toColor());
    try std.testing.expectEqual(Color.blue, State.done.toColor());
}
