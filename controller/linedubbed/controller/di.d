/++
    lineDUBbed controller – DI setup

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.di;

import poodinis;
public import poodinis : existingInstance;

alias DI = shared(DependencyContainer);

DI setupDI()
{
    auto container = new shared DependencyContainer();
    container.setPersistentResolveOptions(ResolveOption.registerBeforeResolving);

    return container;
}
