pub const help =
    \\
    \\Available commands:
    \\help                              Displays this help
    \\list                              Display the todo list
    \\add <todo item description>       Adds the item to the todo list
    \\done <todo item number>           Marks the item as done
    \\quit                              Exit the program
;
pub const emptyListHint = "List is empty.  Try adding some items";
pub const unknownCommand = "I do not understand your command.  " ++
    "Enter help to display available commands.";
pub const missingArg = "command requires an argument";
pub const doneIndexError = "Done command must have a valid item index";

pub const Result = union(enum) {
    quit,
    help,
    list,
    unknownCommand,
    missingArg: MissingArgCommand,
    doneIndexError,
    emptyListHint,
};

pub const MissingArgCommand = enum {
    add,
    done,

    pub fn tagName(self: MissingArgCommand) []const u8 {
        return switch (self) {
            .add => "add",
            .done => "done",
        };
    }
};

const UnexpectedArgCommand = enum { help, list, quit };
