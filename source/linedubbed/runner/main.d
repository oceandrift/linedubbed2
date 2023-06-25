/++
    lineDUBbed runner app entry point

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.runner.main;

import linedubbed.runner.app;

int main(string[] args)
{
    import std.stdio;

    return runRunner(args, stdout, stderr);
}
