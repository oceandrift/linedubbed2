/++
    lineDUBbed controller – app entry point

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.app;

import asdf : AsdfSerdeException;
import linedubbed.controller.config;
import linedubbed.controller.di;
import linedubbed.controller.routing;
import oceandrift.http.microframework.app;
import std.stdio : File, stderr;

int runController(string[] args)
{
    DI container = setupDI();

    // load config
    Config config;
    try
        config = loadConfig();
    catch (AsdfSerdeException ex)
        return writeError!1("Config file error:\n\t", ex.message, "\n\t@offset ", ex.location);
    catch (Exception ex)
        return writeError!1("Config file error:\n\t", ex.message);

    container.register!AppConfig().existingInstance(new AppConfig(config));

    // test DB connection
    try
    {
        import linedubbed.controller.database;

        Database db = setupDB(config);
        db.connect();
        db.close();
    }
    catch (Exception ex)
    {
        return writeError!1(
            "Database connection error:\n\t",
            ex.message,
            "\nDatabase:\n\tmariadb://",
            config.database.host, ':', config.database.port, '/', config.database.database,
        );
    }

    // retrieve routing setup callback
    Routing routing = container.resolve!Routing();
    RouterConfigDelegate routerConfig = &routing.registerRoutes;

    // bootstrap oceandrift
    return quickstart("linedubbed2:controller", args, routerConfig);
}

private:

int writeError(int returnValue = 1, S...)(S args)
{
    pragma(inline, true);

    stderr.writeln(args);
    return returnValue;
}
