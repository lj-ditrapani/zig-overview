const outputzig = @import("./output.zig");

const help =
    \\
    \\Available commands:
    \\help                              Displays this help
    \\list                              Display the todo list
    \\add <todo item description>       Adds the item to the todo list
    \\done <todo item number>           Marks the item as done
    \\quit                              Exit the program
;
const emptyListHint = "List is empty.  Try adding some items";
const unknownCommand = "I do not understand your command.  " ++
    "Enter help to display available commands.";
const unexpectedArg = " command does not take any arguments";
const missingArg = " command requires an argument";
const doneIndexError = "Done command must have a valid item index";

pub const Result = union(enum) {
    exit,
    help,
    list,
    unknownCommand,
    missingArg: MissingArgCommand,
    unexpectedArg: UnexpectedArgCommand,
    doneIndexError,
    emptyListHint,
};

const MissingArgCommand = enum { add, done };

const UnexpectedArgCommand = enum { help, list, quit };
