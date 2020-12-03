-module(day3).
-compile(export_all).

-import('tools', [readlines/1]).

readlines()->
    Fname="example",
    tools:readlines(Fname).

    

