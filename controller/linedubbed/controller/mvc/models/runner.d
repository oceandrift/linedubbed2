/++
    Models and repositories representing

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.mvc.models.runner;

import oceandrift.db.orm;

struct Runner
{
    mixin EntityID;
    string name;
    string operator;
    string description;
    string authTokenHash;
}
