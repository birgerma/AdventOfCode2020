-module(day9).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    
%% Correct: 
sol1()->
    Fname="example",
    Data = tools:readlines(Fname),
    Numbers = tools:as_ints(Data).

%% Correct:
sol2()->
    Fname="input",
    Data = tools:readlines(Fname).
    
    
