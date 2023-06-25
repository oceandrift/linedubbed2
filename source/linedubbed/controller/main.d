/++
    lineDUBbed controller – app entry point

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.main;

import linedubbed.controller.app;

int main(string[] args)
{
    return runController(args);
}
