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
    
    
%% Correct: 
sol2()->
    Fname="example",
    Data = tools:readlines(Fname).

%% Correct: 
sol1()->
    Fname="input",
    [StringTime|IdList] = tools:readlines(Fname),
    Time = list_to_integer(StringTime),
    %% TimeTable = tools:split(IdList,","),
    TimeTable = tools:as_ints(lists:filter(fun(E) -> E/="x"end, tools:split(IdList,","))),
    ClosestTime = getClosestTime(Time, TimeTable, []),
    MinIndex = findMinIndex(ClosestTime),
    MinElement = lists:nth(MinIndex,ClosestTime),
    Id = lists:nth(MinIndex,TimeTable),
    io:fwrite("MinIndex~p Value:~p Id:~p ~n",[MinIndex,MinElement,Id]),
    Res = (MinElement-Time)*Id,
    io:fwrite("Time: ~p List:~p Result:~p~n",[Time, TimeTable, Res]).


findMinIndex([H|T]) -> findMinIndex(T, 2, H, 1).
findMinIndex([], Index, MinValue, MinIndex)-> MinIndex; 
findMinIndex([H|T], Index, MinValue, MinIndex) ->
    IsLess = (H<MinValue),
    io:fwrite("Compare ~p < ~p = ~p ~n",[H,MinValue,IsLess]),
    if
	IsLess->
	    findMinIndex(T, Index+1, H, Index);
	true  ->
	    findMinIndex(T, Index+1, MinValue, MinIndex)
    end.
getClosestTime(_, [], Result)-> lists:reverse(Result);
getClosestTime(Time, [H|T], Result) ->
    Res = ((Time div H)+1)*H,
    io:fwrite("Time:~p~n",[Res]),
    getClosestTime(Time, T, [Res|Result]).
