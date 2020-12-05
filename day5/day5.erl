-module(day5).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    

sol2()->
    Fname="input".

%% 30 not correct, 215 too low, 216 correct
sol1()->
    Fname="input".

getSeatData(SeatStr)->
    Row = getSeatRow(SeatStr, 0, 127),
    Col = getSeatCol(SeatStr, 0, 7),
    Id = (Row*8)+Col,
    io:fwrite("Seat: ~p,~p,~p~n",[Row, Col, Id]).

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
    io:fwrite("Match R old=[~p ~p] new=[~p ~p] ~n",[Min, Max, Min, NewMax]),
    getSeatCol(T,Min,NewMax);
getSeatCol([$R|T], Min, Max)->
    NewMin=Min+((Max+1-Min) div 2),
    io:fwrite("Match L old=[~p ~p] new=[~p ~p] ~n",[Min, Max, NewMin,  Max]),
    getSeatCol(T,NewMin,Max);
getSeatCol([H|T], Min, Max)->
    %% io:fwrite("Check head=~c~n",[H]),
    getSeatCol(T,Min,Max).
    
