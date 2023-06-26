/++
    lineDUBbed controller – database integration

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.database;

import oceandrift.db.mariadb;
import oceandrift.db.orm;
import linedubbed.controller.config;

@safe:

alias EntityMgr = EntityManager!MariaDB;
alias Database = MariaDB;

Database setupDB(const Config config)
{
    return new Database(
        config.database.host,
        config.database.username,
        config.database.password,
        config.database.database,
        config.database.port,
    );
}

Database getDatabase() @safe nothrow @nogc
{
    // TODO
    return db;
}

// thread-local
private static Database db;
