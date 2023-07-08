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

///
public import oceandrift.db.orm : prepareCollection, PreparedCollection;

@safe:

alias EntityManager = oceandrift.db.orm.EntityManager!MariaDB;
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

final class DatabasePool
{
    public this(AppConfig config)
    {
        _config = config.get();
    }

    private
    {
        const Config _config;

        // thread-local
        static Database _database = null;
    }

    public Database connection()
    {
        if (_database is null)
            _database = setupDB(_config);

        return _database;
    }

    public EntityManager entityManager()
    {
        return EntityManager(this.connection);
    }

    alias em = entityManager;
}
