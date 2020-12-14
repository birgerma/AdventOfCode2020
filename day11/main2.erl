-module(main2).
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
    Fname="input",
    Data = tools:readlines(Fname),
    %% printList(Data),
    SteadyState = findSteadyState(Data,1000),
    countOccupied(SteadyState, 0).

%% Correct: 
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    SteadyState = findSteadyState(Data,100000),
    countOccupied(SteadyState, 0).


countOccupied([],Count) -> Count;
countOccupied([Row|T],Count) ->
    countOccupied(T, Count+countOccupiedRow(Row,0)).

countOccupiedRow([],Count)-> Count;
countOccupiedRow([S|T],Count) when S==$# -> countOccupiedRow(T,Count+1);
countOccupiedRow([_|T],Count) -> countOccupiedRow(T,Count).

isEqual([],[])-> true;
isEqual([H|T1],[H|T2])->
    isEqual(T1,T2);
isEqual([H1|T1],[H2|T2])-> false.

printList([])->
    io:fwrite("-------------~n");
printList([Row|T])->
    io:fwrite("~p~n",[Row]),
    printList(T).

findSteadyState(State, 0)-> false;
findSteadyState(State, It)->
    NextState = updateSeatStates(State,1,1,[],[]),
    IsEqual = isEqual(State, NextState),
    %% io:fwrite("Round ~p:~n",[It]),
    %% printList(NextState),
    %% io:fwrite("Is equal:~p~n",[IsEqual]),
    if
	IsEqual->
	    State;
	true->
	    findSteadyState(NextState, It-1)
    end.

getNextEntry(Seats, X,Y)->
    Entry = getRoomPosition(Seats, X,Y),
    getNextEntry(Seats, X,Y, Entry).
getNextEntry(Seats, X,Y, $L) ->
    Occupy = shouldBeOccupied(Seats, X, Y),
    if 
	Occupy->
	    Entry = $#; %% Add occupy sym
	true ->
	    Entry = $L%%getRoomPosition(Seats, X,Y) %% Use current state
    end,
    Entry;

getNextEntry(Seats, X,Y, $#) ->
    %% io:fwrite("Check occupied if should be free~n"),
    %% Souround = getSourundings(Seats,X,Y, $#),
    Free = shouldBeFree(Seats, X, Y),
    %% io:fwrite("Should be free ~p~n", [Free]),
    %% io:fwrite("Souroundings:~p ~p~n",[getSourundings(Seats,X,Y, $#), boolSum(getSourundings(Seats,X,Y, $#))]),
    if 
	Free->
	    Entry = $L; %% Add occupy sym
	true ->
	    Entry = $#%%getRoomPosition(Seats, X,Y) %% Use current state
    end,
    Entry;
getNextEntry(_, _,_, _)->$..

boolSum([])-> 0;
boolSum([true|T]) -> 1+boolSum(T);
boolSum([_|T])-> boolSum(T).

    
shouldBeFree(Seats, X, Y)->
    Sight = getSights(Seats, X,Y),
    %% io:fwrite("(~p,~p) - Sights:~p N Occupied:~p~n",[X,Y,Sight, tools:countChar(Sight,$#)]),
    %% boolSum(getFreeSights(Seats, X,Y))>=5.
    tools:countChar(Sight,$#)>=5.
    %% boolSum(getSourundings(Seats,X,Y, $#))>=5.

updateSeatStates(Seats, X, Y, Row, Col) when Y>length(Seats)-> lists:reverse(Col);
updateSeatStates(Seats, X, Y, Row, Col)->
    %% io:fwrite("~c",[lists:nth(X,lists:nth(Y,Seats))]),
    MaxX = length(lists:nth(1,Seats)),
    %% Occupy = shouldBeOccupied(Seats, X, Y),
    %% io:fwrite("Should occupy:~p~n",[Occupy]),
    NextEntry = getNextEntry(Seats, X,Y),
    %% if 
    %% 	Occupy->
    %% 	    Entry = $#; %% Add occupy sym
    %% 	true ->
    %% 	    Entry = getRoomPosition(Seats, X,Y) %% Use current state
    %% end,

    if
	X<MaxX->
	    NextRow = [NextEntry|Row],
	    NextCol = Col,
	    NextX=X+1,
	    NextY=Y;
	true ->
	    %% io:fwrite("~n"),
	    NextRow = [],
	    NextCol = [lists:reverse([NextEntry|Row])|Col],
	    NextX=1,
	    NextY=Y+1
    end,
    %% ok.
    updateSeatStates(Seats, NextX, NextY, NextRow, NextCol).



isFreeSight(Seats, X,Y, _, _, Xmax, Ymax) when X<1;Y<1 -> true;
isFreeSight(Seats, X,Y, _, _, Xmax, Ymax) when X>Xmax;Y>Ymax -> true;
isFreeSight(Seats, X,Y, Xdir, Ydir, Xmax, Ymax)->
    IsFloor = (getRoomPosition(Seats, X,Y)==$.),
    IsFree = (getRoomPosition(Seats, X,Y)==$L),
    if
	IsFloor->
	    isFreeSight(Seats, X+Xdir,Y+Ydir, Xdir, Ydir, Xmax, Ymax);
	IsFree ->
	    true;
	true ->
	    false
    end.
    
    
isFree(Seats, X, Y)->
    Entry = getRoomPosition(Seats, X,Y),
    %% io:fwrite("Check avaliablity for ~p ~p ~c ~n",[X,Y, Entry]),
    isFree(Entry).
isFree(Entry) when Entry/=$#->
    %% io:fwrite("Here we are~n"),
    true;
isFree(_) -> 
    %% io:fwrite("Here should not be ~p ~p~n",[Entry, Entry/=$#]),
    false.


getFreeSights(Seats, X,Y)->
%% (Seats, X,Y, Xdir, Ydir, Xmax, Ymax)->
    Ymax = length(Seats),
    Xmax = length(lists:nth(1,Seats)),
    [
     (isFreeSight(Seats,X-1,Y, -1, 0, Xmax, Ymax)),
     (isFreeSight(Seats,X+1,Y, 1, 0, Xmax, Ymax)),
     (isFreeSight(Seats,X,Y-1, 0, -1, Xmax, Ymax)),
     (isFreeSight(Seats,X,Y+1, 0, 1, Xmax, Ymax)),
     (isFreeSight(Seats,X-1,Y-1, -1, -1, Xmax, Ymax)),
     (isFreeSight(Seats,X-1,Y+1, -1, 1, Xmax, Ymax)),
     (isFreeSight(Seats,X+1,Y-1, 1, -1, Xmax, Ymax)),
     (isFreeSight(Seats,X+1,Y+1, 1, 1, Xmax, Ymax))
    ].
    

shouldBeOccupied(Seats, X, Y)->
    Entry = getRoomPosition(Seats, X,Y),
    IsSeat = isSeat(Entry),
    
    %% io:fwrite("Is seat:~c:~p~n",[Entry,IsSeat]),
    E2 = getRoomPosition(Seats, X-1,Y),
    FreeSight = getFreeSights(Seats, X,Y),
    %% io:fwrite("Is free sight:~p ()~n",[isSeat(Entry) and (boolSum(FreeSight)>=5)]),
    %% io:fwrite("Is free::~p (~c)~n",[isFree(Seats, X-1,Y), E2]),
    isSeat(Entry) and (boolSum(FreeSight)==length(FreeSight)).
    %% isSeat(Entry) and isFreeSouroundings(Seats,X,Y).

isFreeSouroundings(S, X,Y)->
    isFree(S, X-1,Y) and isFree(S, X+1,Y) and isFree(S, X,Y-1) and isFree(S,X,Y+1) and isFree(S,X-1,Y-1) and isFree(S, X+1, Y-1) and isFree(S, X+1, Y+1) and isFree(S, X-1, Y+1).

getSight(Seats, X,Y, _, _, Xmax, Ymax) when X<1;Y<1 -> $.;
getSight(Seats, X,Y, _, _, Xmax, Ymax) when X>Xmax;Y>Ymax -> $.;
getSight(Seats, X, Y, Xdir, Ydir, Xmax, Ymax)->
    Entry = getRoomPosition(Seats, X,Y),
    IsFloor = (Entry==$.),
    if
	IsFloor->
	    getSight(Seats, X+Xdir, Y+Ydir, Xdir, Ydir, Xmax, Ymax);
	true ->
	    %% io:fwrite("Found element ~c at ~p,~p~n",[Entry, X,Y]),
	    Entry
    end.

getSights(Seats, X, Y)->
    Ymax = length(Seats),
    Xmax = length(lists:nth(1,Seats)),
    [
     (getSight(Seats,X-1,Y,  -1,  0, Xmax, Ymax)),
     (getSight(Seats,X+1,Y,   1,  0, Xmax, Ymax)),
     (getSight(Seats,X,Y-1,   0, -1, Xmax, Ymax)),
     (getSight(Seats,X,Y+1,   0,  1, Xmax, Ymax)),
     (getSight(Seats,X-1,Y-1,-1, -1, Xmax, Ymax)),
     (getSight(Seats,X-1,Y+1,-1,  1, Xmax, Ymax)),
     (getSight(Seats,X+1,Y-1, 1, -1, Xmax, Ymax)),
     (getSight(Seats,X+1,Y+1, 1,  1, Xmax, Ymax))
    ].

getSourundings(S, X,Y, Element)->
    [
     (getRoomPosition(S,X-1,Y)==Element),
     (getRoomPosition(S,X+1,Y)==Element),
     (getRoomPosition(S,X,Y-1)==Element),
     (getRoomPosition(S,X,Y+1)==Element),
     (getRoomPosition(S,X-1,Y-1)==Element),
     (getRoomPosition(S,X-1,Y+1)==Element),
     (getRoomPosition(S,X+1,Y-1)==Element),
     (getRoomPosition(S,X+1,Y+1)==Element)
    ].

isSeat($L)->
    true;
isSeat(_) -> false.



getRoomPosition(Seats, X,Y) when X<1;Y<1 -> $.;
getRoomPosition(Seats, X,Y)->
    MaxX = length(lists:nth(1,Seats)),
    MaxY = length(Seats),
    getRoomPosition(Seats, X, Y, MaxX, MaxY).
getRoomPosition(Seats, X, Y, MaxX, MaxY) when X>MaxX;Y>MaxY -> $.;
getRoomPosition(Seats, X, Y, MaxX, MaxY) ->
    lists:nth(X,lists:nth(Y,Seats)).
