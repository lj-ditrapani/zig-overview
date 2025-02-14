pub const State = enum {
    todo,
    done,

    pub fn toString(self: State) []const u8 {
        return switch (self) {
            .todo => "",
            .done => " (done)",
        };
    }
};

pub const Item = struct {
    description: []const u8,
    state: State = State.todo,
};
