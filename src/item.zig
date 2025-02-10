pub const State = enum {
    todo,
    done,
};

pub const Item = struct {
    description: []u8,
    state: State = State.todo,

    pub fn toLine(self: Item, index: u16) []u8 {
        const _ = index;
        return self.description;
    }
};
