-module(main).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    Start1 = os:timestamp(),
    Sol1 = sol1(),
    Start2 = os:timestamp(),
    Sol2 = sol2(),
    EndTime = os:timestamp(),
    Time1 = timer:now_diff(Start2, Start1)/1000000,
    Time2 = timer:now_diff(EndTime, Start2)/1000000,
    Total = timer:now_diff(EndTime, Start1)/1000000,

    io:fwrite("Solution part1 (Time:~f sec): ~p~n", [Time1, Sol1]),
    io:fwrite("Solution part2 (Time:~f sec): ~p~n", [Time2, Sol2]),
    io:fwrite("Total execution time: ~f sec~n", [Total]),
    Test = os:timestamp(),
    MeanETime1 = tools:etimeMs(fun()-> sol1()end, 1000),
    MeanETime2 = tools:etimeMs(fun()-> sol2()end, 1000),
    io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime1]),
    io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime2]).
    
%% Correct: 245848639
sol2()->
    Fname="input",
    Data =tools:readlines(Fname).
    
%% Correct: 2089807806 
sol1()->
    Fname="input",
    Data = tools:as_ints(tools:readlines(Fname)),
    Max = lists:max(Data),
    Sorted =  lists:sort([0,Max+3|Data]),
    %% io:fwrite("Data:~p~n",[Data]),
    %% io:fwrite("Data:~p~n",[Sorted]),
    Diff1 = countDiffs(Sorted,1),
    Diff3 = countDiffs(Sorted,3),
    io:fwrite("Answear:~p~n",[Diff1*Diff3]).


countDiffs(Data,Diff)-> 
    countDiffs(Data, Diff, 0).

countDiffs([_],_,Count) -> Count;
countDiffs([A,B|T],Diff,Count) when B-A==Diff-> 
    %% io:fwrite("Counting diff: ~p-~p~n",[B,A]),
    countDiffs([B|T],Diff,Count+1);
countDiffs([A|T],Diff,Count) -> 
    %% io:fwrite("Skipping: ~p~n",[A]),
    countDiffs(T,Diff,Count).
