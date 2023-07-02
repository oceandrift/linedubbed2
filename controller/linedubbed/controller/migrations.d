/++
    lineDUBbed controller – (database) migrations

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.migrations;

import linedubbed.controller.config;
import linedubbed.controller.database;
import oceandrift.db.dbal : get, Statement;
import socketplate.log;

struct DatabaseMigrator
{
    public this(const Config config, Database database)
    {
        _config = config;
        _db = database;
    }

    private
    {
        const Config _config;
        Database _db;
    }

    public
    {
        void ensureMigrationsTableExists()
        {
            _db.execute(
                "CREATE TABLE IF NOT EXISTS `schema_migrations` ("
                    ~ " `id` BIGINT AUTO_INCREMENT PRIMARY KEY"
                    ~ ", `level` INTEGER NOT NULL"
                    ~ ", `executed_at` DATETIME NOT NULL"
                    ~ ")"
            );
        }

        int getMigrationLevel()
        {
            Statement stmt = _db.prepare(
                "SELECT `level` FROM `schema_migrations` ORDER BY `id` DESC LIMIT 1"
            );

            scope (exit)
                stmt.close();

            stmt.execute();
            if (stmt.empty)
                return 0;

            return stmt.front[0].get!int;
        }

        void migrate()
        {
            int currentLvl = this.getMigrationLevel();

            if (currentLvl == appMigrations.length)
            {
                logInfo("Database schema is up-to-date.");
                return;
            }

            foreach (idx, migration; appMigrations[currentLvl .. $])
            {
                assert(idx < size_t(int.max));
                immutable int target = cast(int) idx + 1;

                if (idx != currentLvl)
                    assert(false, "Migration level mismatch");

                this.applyUp(migration);
                this.saveMigrationLevel(target);
                currentLvl = target;
            }
        }
    }

    private
    {
        void saveMigrationLevel(int value)
        {
            Statement stmt = _db.prepare(
                "INSERT INTO `schema_migrations` (`level`, `executed_at`) VALUES (?, CURRENT_TIMESTAMP)"
            );

            scope (exit)
                stmt.close();

            stmt.bind(0, value);
            stmt.execute();
        }

        void applyUp(Migration m)
        {
            _db.execute(m.up);
        }
    }
}

private:

struct Migration
{
    string up;
    string down;
}

static immutable appMigrations = [
    Migration(""),
];
