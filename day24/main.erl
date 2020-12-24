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
    %% Test = os:timestamp(),
    %% MeanETime1 = tools:etimeMs(fun()-> sol1()end, 1000),
    %% MeanETime2 = tools:etimeMs(fun()-> sol2()end, 1000),
    %% io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime1]),
    %% io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime2]).
    
    
%% Correct: 
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    Coor = getCoordinates(Data,[]),
    Floor = flip(Coor,dict:new()),
    NewFloor = createWhiteNeigbours(Floor),
    Final = doFlipMoves(NewFloor, 100),
    countBlack(dict:to_list(Final),0).


%% Correct: 
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    Coor = getCoordinates(Data,[]),
    Floor = flip(Coor,dict:new()),
    length(dict:to_list(Floor)).


test1()->
    Fname="example",
    Data = tools:readlines(Fname),
    Coor = getCoordinates(Data,[]),
    Floor = flip(Coor,dict:new()),
    length(dict:to_list(Floor)).

test2()->
    Fname="example",
    Data = tools:readlines(Fname),
    Coor = getCoordinates(Data,[]),
    Floor = flip(Coor,dict:new()),
    NewFloor = createWhiteNeigbours(Floor),
    Final = doFlipMoves(NewFloor, 100),
    countBlack(dict:to_list(Final),0).
    %% Day1 = flipTiles(NewFloor),
    %% Day2 = flipTiles(Day1),
    %% countBlack(dict:to_list(Day2),0).


doFlipMoves(Floor, 0)-> Floor;
doFlipMoves(Floor, Move)->
    doFlipMoves(flipTiles(createWhiteNeigbours(Floor)),Move-1).

countBlack([],Count)-> Count;
countBlack([{C,black}|T],Count)-> countBlack(T,Count+1);
countBlack([{C,V}|T],Count)->
    countBlack(T,Count).
    

flipTiles(Floor)->
    flipTiles(dict:to_list(Floor), Floor,[]).

flipTiles([],Floor, Result)-> dict:from_list(Result);
flipTiles([{C,V}|T],Floor, Result)->
    %% io:fwrite("check tile:~p~n",[C]),
    Debug = false,
    N = getNeighbours(C),
    {Black, White} = countNeigbours(N, Floor,{0,0}),
    tools:print("Pos:~p Color:~p Neigbour: Black=~p White=~p~n",[C, V, Black, White],Debug),
    if
	((V==black) and ((Black==0) or (Black>2))) ->
	    tools:print("Flip to white~n~n",Debug),
	    flipTiles(T,Floor, [{C,white}|Result]);
	(V==white) and (Black==2)->
	    tools:print("Flip to black~n~n",Debug),
	    flipTiles(T,Floor, [{C,black}|Result]);
	true ->
	    tools:print("Dont flip~n~n",Debug),
	    flipTiles(T,Floor, [{C,V}|Result])
    end.


countNeigbours([], Floor, Result)-> Result;
countNeigbours([Tile|T], Floor, {Black, White})->
    IsBlack = (getValue(Tile,Floor)==black),
    if
	IsBlack ->
	    countNeigbours(T, Floor, {Black+1, White});
	true ->
	    countNeigbours(T, Floor, {Black, White+1})
    end.
		       

createWhiteNeigbours(Floor)->
    %% io:fwrite("Original:~p~n",[dict:to_list(Floor)]),
    createWhiteNeigbours(dict:to_list(Floor),Floor,[]).

createWhiteNeigbours([],Floor,Result)->
    addToDict(Result,white,Floor);
createWhiteNeigbours([{C,V}|T],Floor,Result)->
    Debug = false,
    tools:print("Find neigbours for ~p~n",[C],Debug),
    N = getNeighbours(C),
    White = filterBlack(N,Floor,[]),
    tools:print("Neigbours:~p White:~p~n",[N,White],Debug),
    createWhiteNeigbours(T,Floor,White++Result).

addToDict([],Value,Dict)->Dict;
addToDict([Key|T],Value,Dict)->
    addToDict(T,Value,dict:store(Key,Value,Dict)).
    
filterBlack([],Floor,Result)-> lists:reverse(Result);
filterBlack([H|T],Floor,Result)->
    %% IsBlack = dict:is_key(H,Floor),
    IsBlack = (getValue(H,Floor)==black),
    %% io:fwrite("Neigbour:~p=~p~n",[H,IsBlack]),
    if 
	IsBlack->
	    filterBlack(T,Floor, Result);
	true ->
	    filterBlack(T,Floor, [H|Result])
    end.
    
getValue(H,Floor)->
    Exists = dict:is_key(H,Floor),
    if
	Exists->
	    dict:fetch(H,Floor);
	true ->
	    white
    end.

test()->
    I1 = "esenee",
    I2 = "esew",
    I3 = "nwwswee",
    R1 = getCoor(I1),
    R2 = getCoor(I2),
    R3 = getCoor(I3),
    io:fwrite("Result: ~p ~p ~p ~n",[R1,R2,R3]).

getNeighbours({X,Y})->
    Diff = [{+1, 0},{-1, 0},{+0.5, 1},{-0.5, 1},{+0.5, -1},{-0.5, -1}],
    getNeighbours({X,Y}, Diff, []).
    
getNeighbours({X,Y}, [], Result)-> lists:reverse(Result);
getNeighbours({X,Y}, [{DX, DY}|T], Result)->
    %% getNeighbours({X,Y}, T, [{roundInt(X+DX), roundInt(Y+DY)}|Result]).
    %% io:fwrite("Neigbour for ~p:~p~n",[])
    getNeighbours({X,Y}, T, [{roundInt(X+DX), roundInt(Y+DY)}|Result]).
    

flip([], Floor)-> Floor;
flip([H|T], Floor)->
    Debug =false,
    IsWhite = dict:is_key(H,Floor),
    if
	IsWhite ->
	    tools:print("Tile value:~p~n",[dict:fetch(H, Floor)],Debug),
	    NewMem = dict:erase(H,Floor),
	    flip(T,NewMem);
	true ->
	    NewMem = dict:store(H,black, Floor),
	    flip(T, NewMem)
    end.
	    
    


getCoordinates([],Result) ->
    lists:reverse(Result);
getCoordinates([H|T],Result) ->
    getCoordinates(T,[getCoor(H)|Result]).

getCoor(I1)->
    getCoor(I1,0,0).

getCoor([],X,Y) ->
    {roundInt(X),roundInt(Y)};
getCoor([$e|T],X,Y) -> getCoor(T,X+1, Y);
getCoor([$w|T],X,Y) -> getCoor(T,X-1, Y);
getCoor([$s,$w|T],X,Y) -> getCoor(T,X-0.5, Y+1);
getCoor([$s,$e|T],X,Y) -> getCoor(T,X+0.5, Y+1);
getCoor([$n,$w|T],X,Y) -> getCoor(T,X-0.5, Y-1);
getCoor([$n,$e|T],X,Y) -> getCoor(T,X+0.5, Y-1).


roundInt(Float) when round(Float)-Float == 0->
    %% io:fwrite("Float ~p has no decimals (~p)~n",[Float,round(Float)]),
    round(Float);
roundInt(Float) ->
    %% io:fwrite("Float ~p has decimals (~p)~n",[Float, round(Float)]),
    Float.
