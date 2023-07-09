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
                "CREATE TABLE IF NOT EXISTS `schema_migration` ("
                    ~ " `id` BIGINT AUTO_INCREMENT PRIMARY KEY"
                    ~ ", `level` INTEGER NOT NULL"
                    ~ ", `executed_at` DATETIME NOT NULL"
                    ~ ")"
            );
        }

        int getMigrationLevel()
        {
            Statement stmt = _db.prepare(
                "SELECT `level` FROM `schema_migration` ORDER BY `id` DESC LIMIT 1"
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

            if (currentLvl > appMigrations.length)
            {
                logInfo("Database schema beyond known migrations. Application outdated?");
                return;
            }

            if (currentLvl == appMigrations.length)
            {
                logInfo("Database schema is up-to-date.");
                return;
            }

            foreach (migration; appMigrations[currentLvl .. $])
            {
                immutable int target = currentLvl + 1;

                logInfo("Applying migration #", target);
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
                "INSERT INTO `schema_migration` (`level`, `executed_at`) VALUES (?, CURRENT_TIMESTAMP)"
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
    Migration(
        "CREATE TABLE `operator` ("
            ~ "`id` BIGINT AUTO_INCREMENT PRIMARY KEY"
            ~ ", `name` VARCHAR(64) NOT NULL"
            ~ ")",
        "DROP TABLE `operator`",
    ),
    Migration(
        "CREATE TABLE `runner` ("
            ~ "`id` BIGINT AUTO_INCREMENT PRIMARY KEY"
            ~ ", `name` VARCHAR(24) NOT NULL"
            ~ ", `operator_id` BIGINT NOT NULL"
            ~ ", `description` TEXT NOT NULL"
            ~ ", `api_token_name` VARCHAR(24)"
            ~ ", `api_token_hash` CHAR(128)"
            ~ ", FOREIGN KEY (`operator_id`) REFERENCES `operator`(`id`)"
            ~ ")",
        "DROP TABLE `runner`",
    ),
];
