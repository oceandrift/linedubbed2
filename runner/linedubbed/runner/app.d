/++
    lineDUBbed runner app entry point

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.runner.app;

import std.getopt;
import std.stdio : File;

static immutable appInfo = `lineDUBbed runner
Copyright (c) 2023 Elias Batek
`;

@safe:

int runRunner(string[] args, File stdout, File stderr)
{
    if (args.length != 2)
    {
        stderr.writeln("Bad arguments");
        printHelp(args[0], stderr);
        return 1;
    }

    if ((args[1] == "--help") || (args[1] == "help"))
    {
        stderr.writeln(appInfo);
        printHelp(args[0], stdout);
        return 0;
    }

    assert(0);
}

private:

void printHelp(string arg0, File target)
{
    target.writeln("Usage:\n\t", arg0, " <controller URL>");
}
