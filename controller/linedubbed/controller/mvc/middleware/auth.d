/++
    Authentication middleware

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.mvc.middleware.auth;

import oceandrift.http.microframework.routing.middleware;
import oceandrift.http.microframework.httpauth;
import std.digest.sha;

@safe:

final class RunnerAPIAuthMiddleware
{
    public MiddlewareRequestHandler requestHandler()
    {
        return basicAuthMiddleware!"Runner API"(&this.checkCredentials);
    }

    private bool checkCredentials(Credentials cred)
    {
        return false;
    }
}
