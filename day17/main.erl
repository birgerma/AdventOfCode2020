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
    Raw = tools:readlines(Fname),
    Data = formatMapData(Raw,[0,0]),
    CoorMap = createCoorMap(Data,[]),
    Active = getActive(dict:to_list(CoorMap),[]),
    Map = addMissingNeigbours(Active,CoorMap),
    Map1 = runIteration(Map),
    Map2 = runIteration(Map1),
    Map3 = runIteration(Map2),
    Map4 = runIteration(Map3),
    Map5 = runIteration(Map4),
    Map6 = runIteration(Map5),
    countActiveNodes(dict:to_list(Map6),0).

    %% dict:fetch([0,0,0],CoorMap),
    %% getNeighbours([0,0,0],[])==[[-1,-1,-1],[-1,-1,0],[-1,-1,1],[-1,0,-1],[-1,0,0],[-1,0,1],[-1,1,-1],[-1,1,0],[-1,1,1],[0,-1,-1],[0,-1,0],[0,-1,1],[0,0,-1],[0,0,1],[0,1,-1],[0,1,0],[0,1,1],[1,-1,-1],[1,-1,0],[1,-1,1],[1,0,-1],[1,0,0],[1,0,1],[1,1,-1],[1,1,0],[1,1,1]],

    %% getNeighbours([0,0,0])==[[-1,-1,-1],[-1,-1,0],[-1,-1,1],[-1,0,-1],[-1,0,0],[-1,0,1],[-1,1,-1],[-1,1,0],[-1,1,1],[0,-1,-1],[0,-1,0],[0,-1,1],[0,0,-1],[0,0,1],[0,1,-1],[0,1,0],[0,1,1],[1,-1,-1],[1,-1,0],[1,-1,1],[1,0,-1],[1,0,0],[1,0,1],[1,1,-1],[1,1,0],[1,1,1]],
    %% L1 = length(getNeighbours([0,0,0],[])),
    %% L2 = length(getNeighbours([0,0,0])),
    %% L3 = length(getNeighbours([0,0,0,0])),
    %% io:fwrite("~p ~p ~p ~n",[L1, L2, L3]).
    %% getNeighbours([0,1,1]),
    %% Data.




%% Correct: 
sol1()->
    Fname="example",
    Raw = tools:readlines(Fname),
    Data = formatMapData(Raw,[0]),
    CoorMap = createCoorMap(Data,[]),
    Active = getActive(dict:to_list(CoorMap),[]),
    Map = addMissingNeigbours(Active,CoorMap),
    Map1 = runIteration(Map),
    Map2 = runIteration(Map1),
    Map3 = runIteration(Map2),
    Map4 = runIteration(Map3),
    Map5 = runIteration(Map4),
    Map6 = runIteration(Map5),
    countActiveNodes(dict:to_list(Map6),0).
	      
    %% dict:fetch([0,0,0],CoorMap),
    %% getNeighbours([0,0,0],[]).

countActiveNodes([],Count)-> Count;
countActiveNodes([{N,active}|T],Count)-> 
    %% io:fwrite("Node ~p is active~n",[N]),
    countActiveNodes(T,Count+1);
countActiveNodes([{_,_}|T],Count)-> countActiveNodes(T,Count).
	      
runIteration(Map)-> runIteration(dict:to_list(Map), Map, []).
    
runIteration([], Map, Result)->
    %% io:fwrite("Status updates:~p~n",[Result]),
    NewMap = updateStates(Result,Map),
    Active = getActive(dict:to_list(NewMap),[]),
    addMissingNeigbours(Active,NewMap);

runIteration([{Coor,Status}|T], Map, Result)->
    %% Neighbours = getNeighbours(Coor,[]),
    Neighbours = getNeighbours(Coor),
    %% io:fwrite("Get neigbours for ~p:~p~n",[Coor, Neighbours]),
    Count = countActive(Neighbours,Map,0),
    %% io:fwrite("Counting active for ~p = ~p~n",[Coor, Count]),
    NewStatus = getNextStatus(Status, Count),
    %% io:fwrite("Old status: ~p New status: ~p~n",[Status,NewStatus]),
    if
	NewStatus==Status->
	    runIteration(T, Map, Result);
	true ->
	    runIteration(T, Map, [{Coor, NewStatus}|Result])
    end.
    

updateStates([],Map)->Map;
updateStates([{Coor, State}|T],Map)->
    %% io:fwrite("Update ~p with ~p~n",[Coor, State]),
    %% if
    %% 	State==active ->
	    
    updateStates(T, dict:store(Coor, State, Map)).
    

getNextStatus(Status, Count)->
    if
	Status==active->
	    if
		(Count==2) or (Count==3)->
		    active;
		true  ->
		    inactive
	    end;
	true ->
	    if
		Count==3->
		    active;
		true ->
		    inactive
	    end
    end.
	    
	    
countActive([],Map,Count)->Count;
countActive([H|T],Map,Count)->
    IsActive = (getStatus(H,Map)==active),
    if
	IsActive->
	    countActive(T,Map,Count+1);
	true ->
	    countActive(T,Map,Count)
    end.

getStatus(H,Map)->
    IsKey = dict:is_key(H,Map),
    %% io:fwrite("Get status for ~p",[H]),
    if
	IsKey ->
	    %% io:fwrite(" Status:~p~n",[dict:fetch(H,Map)]),
	    dict:fetch(H,Map);
	true ->
	    %% io:fwrite(" Status: inactive~n"),
	    inactive
    end.
addMissingNeigbours([],Result)-> Result;
addMissingNeigbours([Active|T],Result) -> 
    %% NewMem = addMissing(getNeighbours(Active,[]),Result),
    NewMem = addMissing(getNeighbours(Active),Result),
    addMissingNeigbours(T,NewMem).

addMissing([],Result)->Result;
addMissing([Coor|T],Result)->
    Exists = dict:is_key(Coor, Result),
    if
	Exists->
	    addMissing(T,Result);
	true ->
	    addMissing(T, dict:store(Coor,inactive,Result))
    end.

getActive([],Result)->
    lists:reverse(Result);
getActive([{Key, active}|T],Result) -> getActive(T,[Key|Result]);
getActive([{Key, Value}|T],Result) ->
    %% io:fwrite("Key:~p Status: ~p~n",[Key, Value]),
    getActive(T,Result).
    


filterCoor([],_,Result)->
    lists:reverse(Result);
filterCoor([Coor|T],Coor,Result) -> filterCoor(T,Coor,Result);
filterCoor([Coor1|T],Coor,Result) -> filterCoor(T,Coor,[Coor1|Result]).

getNeighbours(Coor)->
    %% io:fwrite("Get neighbours for~p~n",[Coor]),
    filterCoor(getNeighbours(Coor,[],[]), Coor,[]).
getNeighbours([Coor],Prev,Result)->
    Coordinates = [lists:reverse([Coor-1|Prev]),lists:reverse([Coor|Prev]),lists:reverse([Coor+1|Prev])],
    %% io:fwrite("Iterate:~p~n",[Coor]),
    %% io:fwrite("Final coordinates:~p~n",[Coordinates]),
    lists:append(Result, Coordinates);
getNeighbours([Coor|T],Prev,Result)->
    %% io:fwrite("Iterate:~p~n",[Coor]),
    lists:append([Result, getNeighbours(T, [Coor-1|Prev], Result),getNeighbours(T, [Coor|Prev], Result),getNeighbours(T, [Coor+1|Prev], Result)]).

%% getNeighbours([X,Y,Z],Result)->
%%     filterCoor(lists:append([getYNeigbours(X-1,Y,Z),getYNeigbours(X,Y,Z),getYNeigbours(X+1,Y,Z)]),[X,Y,Z],[]).

%% getYNeigbours(X,Y,Z)->
%%     lists:append([getZNeigbours(X,Y-1,Z),getZNeigbours(X,Y,Z),getZNeigbours(X,Y+1,Z)]).

%% getZNeigbours(X,Y,Z)->
%%     [[X,Y,Z-1],[X,Y,Z],[X,Y,Z+1]].

createCoorMap([],Result)->
    dict:from_list(Result);
createCoorMap([{Status, Coor}|T], Result) ->
    %% io:fwrite("Status:~p (X,Y,Z)=(~p,)~n",[Status, Coor]),
    Key = Coor,
    Value = Status,
    createCoorMap(T, [{Key, Value}|Result]);
createCoorMap([H|T], Result) ->
    io:fwrite("Entry:~p~n",[H]),
    io:fwrite("No match~n").

formatMapData(Raw, Suffix)->
    formatMapData(Raw, 0, Suffix,[]).
formatMapData([], Y, Suffix, Results)-> lists:flatten(lists:reverse(Results));
formatMapData([Row|T], Y, Suffix, Result) -> 
    %% Z=0,
    Coor = extractXCoordinates(Row, 0, Y, Suffix, []),
    formatMapData(T, Y+1, Suffix, [Coor|Result]).
    

extractXCoordinates([], X, Y, Z, Result) -> lists:reverse(Result);
extractXCoordinates([H|T], X, Y, Suffix, Result) when H==$# ->
    Coor = lists:append([X,Y],Suffix),
    %% io:fwrite("Reading active node at ~p~n",[Coor]),
    extractXCoordinates(T, X+1, Y, Suffix, [{active, Coor}|Result]);
extractXCoordinates([H|T], X, Y, Suffix, Result) ->
    Coor = lists:append([X,Y],Suffix),
    %% io:fwrite("Reading inactive node at ~p~n",[Coor]),
    extractXCoordinates(T, X+1, Y, Suffix, [{inactive, Coor}|Result]).
