/++
    lineDUBbed controller – runner API implementation

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.mvc.controllers.runnerapi;

import oceandrift.http.message;

@safe:

Response sendJSON(T)(Response response, T data)
{
    import asdf : serializeToJson;

    const string json = (function(T data) @trusted => serializeToJson(data))(data);
    response.body.write(json);
    response.withHeader!"Content-Type"("application/json");
    return response;
}

final class RunnerAPIController
{
    Response getIndex(Request, Response response)
    {
        return response.sendJSON("OK");
    }

    Response getJob(Request, Response response)
    {
        response.body.write("dings");
        return response;
    }
}
