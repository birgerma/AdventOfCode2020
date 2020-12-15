-module(main).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    Start1 = os:timestamp(),
    Sol1 = sol1(),
    Start2 = os:timestamp(),
    Sol2 = sol2(),
    EndTime = os:timestamp(),
    Time1 = timer:now_diff(Start2, Start1)/1000,
    Time2 = timer:now_diff(EndTime, Start2)/1000,
    Total = timer:now_diff(EndTime, Start1)/1000,

    io:fwrite("Solution part1 (Time:~f ms): ~p~n", [Time1, Sol1]),
    io:fwrite("Solution part2 (Time:~f ms): ~p~n", [Time2, Sol2]),
    io:fwrite("Total execution time: ~f ms~n", [Total]).


%% main()->
%%     io:fwrite("Solution part1: ~p~n",[sol1()]),
%%     io:fwrite("Solution part2: ~p~n",[sol2()]).
    

%% Correct: 892
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    getMax(getSeatIds(Data),0).

%% Correct: 
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    Ids = getSeatIds(Data),
    findMissingIds(Ids).

findMissingIds(Ids)->
    findMissingId(lists:sort(Ids)).
findMissingId([A,B|T]) when A==B-1 -> findMissingId([B|T]);
findMissingId([A,_|_]) -> 
    A+1.

getSeatIds(Data)->
    SeatData = getAllSeatData(Data, []),
    extractListIndexes(SeatData, 3, []).

getMax([], Max)-> Max;
getMax([H|T],Max) when H>Max-> getMax(T,H);
getMax([_|T],Max) -> getMax(T,Max).

getAllSeatData([],Result)->
    lists:reverse(Result);
getAllSeatData([H|T], Result) ->
    getAllSeatData(T, [getSeatData(H)|Result]).


getSeatData(SeatStr)->
    Row = getSeatRow(SeatStr, 0, 127),
    Col = getSeatCol(SeatStr, 0, 7),
    Id = (Row*8)+Col,
    [Row, Col, Id].

extractListIndexes([],_,Result)->
    lists:reverse(Result);
extractListIndexes([H|T], Index, Result) -> 
    extractListIndexes(T, Index, [lists:nth(Index,H)|Result]).

getSeatRow([], Min, _)-> Min;
getSeatRow([$F|T], Min, Max)->
    NewMax=Min+((Max-Min) div 2),
    getSeatRow(T,Min,NewMax);
getSeatRow([$B|T], Min, Max)->
    NewMin=Min+((Max+1-Min) div 2),
    getSeatRow(T,NewMin,Max);
getSeatRow([_|T], Min, Max)->
    getSeatRow(T,Min,Max).

getSeatCol([], Min, _)-> Min;
getSeatCol([$L|T], Min, Max)->
    NewMax=Min+((Max-Min) div 2),
    getSeatCol(T,Min,NewMax);
getSeatCol([$R|T], Min, Max)->
    NewMin=Min+((Max+1-Min) div 2),
    getSeatCol(T,NewMin,Max);
getSeatCol([_|T], Min, Max)->
    getSeatCol(T,Min,Max).
    
