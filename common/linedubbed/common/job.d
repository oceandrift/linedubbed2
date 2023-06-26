/++
    Studies, jobs and tasks abstraction

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.common.job;

struct Job
{
    long id;
    Task[] tasks;
}

struct Task
{
    string command;
    Prerequisites prerequisites;
}

struct Prerequisites
{
    Compiler compiler;
}

struct Compiler
{
    string name;
    string version_;
}
