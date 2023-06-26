/++
    lineDUBbed controller – app configurations

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.config;

import linedubbed.common.path;
import mir.serde : serdeOptional;

struct Config
{
    DatabaseConfig database;
}

struct DatabaseConfig
{
    string host;
    string username;
    string password;
    string database;
    @serdeOptional ushort port = 3306;
}

final class AppConfig
{
@safe pure nothrow @nogc:

    const(Config) get()
    {
        return _cfg;
    }

    public this(Config config)
    {
        _cfg = config;
    }

    private Config _cfg;
}

Config loadConfig()
{
    import std.file;
    import asdf : deserialize;

    return readText(configPath).deserialize!Config();
}

private:

static immutable string configPath;

shared static this()
{
    import std.path : buildNormalizedPath;

    configPath = thisExeDir.buildNormalizedPath("../etc/linedubbed-controller.conf");
}
