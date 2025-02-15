const Color = @import("./output.zig").Color;

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
};
