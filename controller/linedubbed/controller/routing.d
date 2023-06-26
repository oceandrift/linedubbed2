/++
    lineDUBbed controller – HTTP routes definition

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.routing;

import linedubbed.controller.mvc.controllers;
import linedubbed.controller.mvc.middleware;
import oceandrift.http.microframework.app;

@safe:

final class Routing
{
    public this(
        RunnerAPIAuthMiddleware runnerAPIAuthMiddleware,
        RunnerAPIController runnerAPIController,
    )
    {
        _runnerAPIAuthMiddleware = runnerAPIAuthMiddleware;
        _runnerAPIController = runnerAPIController;
    }

    private
    {
        RunnerAPIAuthMiddleware _runnerAPIAuthMiddleware;
        RunnerAPIController _runnerAPIController;
    }

    void registerRoutes(Router router) @safe
    {
        router.get("/", delegate(Request request, Response response) {
            response.body.write("Hello world :)");
            return response;
        });

        router.group("/runner-api", delegate(Router group) @safe {
            group.get("/", &_runnerAPIController.getIndex);
        }).add(_runnerAPIAuthMiddleware.requestHandler);
    }
}
