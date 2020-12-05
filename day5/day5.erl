-module(day5).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    

%% Correct: 892
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    getMax(getSeatIds(Data),0).

sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    Ids = getSeatIds(Data),
    findMissingIds(Ids).

findMissingIds(Ids)->
    findMissingId(lists:sort(Ids)).
findMissingId([A,B|T]) when A==B-1 -> findMissingId([B|T]);
findMissingId([A,B|_]) -> 
    A+1.



    

getSeatIds(Data)->
    SeatData = getAllSeatData(Data, []),
    extractListIndexes(SeatData, 3, []).

getMax([], Max)-> Max;
getMax([H|T],Max) when H>Max-> getMax(T,H);
getMax([H|T],Max) -> getMax(T,Max).

getAllSeatData([],Result)->
    lists:reverse(Result);
getAllSeatData([H|T], Result) ->
    getAllSeatData(T, [getSeatData(H)|Result]).


getSeatData(SeatStr)->
    Row = getSeatRow(SeatStr, 0, 127),
    Col = getSeatCol(SeatStr, 0, 7),
    Id = (Row*8)+Col,
    %% io:fwrite("Seat: ~p,~p,~p~n",[Row, Col, Id]),
    [Row, Col, Id].

extractListIndexes([],_,Result)->
    lists:reverse(Result);
extractListIndexes([H|T], Index, Result) -> 
    extractListIndexes(T, Index, [lists:nth(Index,H)|Result]).


getSeatRow([], Min, Max)-> Min;
getSeatRow([$F|T], Min, Max)->
    NewMax=Min+((Max-Min) div 2),
    %% io:fwrite("Match F old=[~p ~p] new=[~p ~p] ~n",[Min, Max, Min, NewMax]),
    getSeatRow(T,Min,NewMax);
getSeatRow([$B|T], Min, Max)->
    NewMin=Min+((Max+1-Min) div 2),
    %% io:fwrite("Match B old=[~p ~p] new=[~p ~p] ~n",[Min, Max, NewMin,  Max]),
    getSeatRow(T,NewMin,Max);
getSeatRow([H|T], Min, Max)->
    %% io:fwrite("Check head=~c~n",[H]),
    getSeatRow(T,Min,Max).

getSeatCol([], Min, Max)-> Min;
getSeatCol([$L|T], Min, Max)->
    NewMax=Min+((Max-Min) div 2),
    %% io:fwrite("Match R old=[~p ~p] new=[~p ~p] ~n",[Min, Max, Min, NewMax]),
    getSeatCol(T,Min,NewMax);
getSeatCol([$R|T], Min, Max)->
    NewMin=Min+((Max+1-Min) div 2),
    %% io:fwrite("Match L old=[~p ~p] new=[~p ~p] ~n",[Min, Max, NewMin,  Max]),
    getSeatCol(T,NewMin,Max);
getSeatCol([H|T], Min, Max)->
    %% io:fwrite("Check head=~c~n",[H]),
    getSeatCol(T,Min,Max).
    
