/++
    Authentication middleware

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.mvc.middleware.auth;

import linedubbed.controller.database;
import linedubbed.controller.mvc.models.runner;
import oceandrift.http.microframework.routing.middleware;
import oceandrift.http.microframework.httpauth;
import linedubbed.controller.sodium;
import linedubbed.controller.apitoken;

@safe:

final class RunnerAPIAuthMiddleware
{
    public this(
        DatabasePool db,
    )
    {
        _db = db;
    }

    private
    {
        DatabasePool _db;
    }

    public MiddlewareRequestHandler requestHandler()
    {
        return basicAuthMiddleware!"Runner API"(&this.checkCredentials);
    }

    private bool checkCredentials(Credentials cred)
    {
        enum bq = EntityManager.find!Runner().where("api_token_name", '=').select();
        PreparedCollection!Runner pc = bq.prepareCollection(_db.connection());
        pc.bind(0, cred.username.idup);
        auto runners = pc.execute();

        // not found?
        if (runners.empty)
            return false;

        Runner r = runners.front;
        scope (exit)
            runners.popFront();

        if (!apiTokenVerify(cred.password.idup, r.apiTokenHash))
            return false;

        return true;
    }
}
