/++
    Path utilities

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.common.path;

/++
    Returns: folder where the program's executable is located in
 +/
string thisExeDir() @safe
{
    import std.path : dirName;
    import std.file : thisExePath;

    return thisExePath.dirName;
}