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
    Fname="example",
    Raw = tools:readlines(Fname),
    Data = formatMapData(Raw),
    %% CoorMap = createCoorMap(Data,[]),
    %% Active = getActive(dict:to_list(CoorMap),[]),
    %% Map = addMissingNeigbours(Active,CoorMap),
    %% Map1 = runIteration(Map),
    %% Map2 = runIteration(Map1),
    %% Map3 = runIteration(Map2),
    %% Map4 = runIteration(Map3),
    %% Map5 = runIteration(Map4),
    %% Map6 = runIteration(Map5),
    %% countActiveNodes(dict:to_list(Map6),0).
	      
    %% dict:fetch([0,0,0],CoorMap),
    getNeighbours([0,0,0],[])==[[-1,-1,-1],[-1,-1,0],[-1,-1,1],[-1,0,-1],[-1,0,0],[-1,0,1],[-1,1,-1],[-1,1,0],[-1,1,1],[0,-1,-1],[0,-1,0],[0,-1,1],[0,0,-1],[0,0,1],[0,1,-1],[0,1,0],[0,1,1],[1,-1,-1],[1,-1,0],[1,-1,1],[1,0,-1],[1,0,0],[1,0,1],[1,1,-1],[1,1,0],[1,1,1]],
    
    getNeighbours([0,0,0,0],[]).
    




%% Correct: 
sol1()->
    Fname="input",
    Raw = tools:readlines(Fname),
    Data = formatMapData(Raw),
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
countActiveNodes([{_,active}|T],Count)-> countActiveNodes(T,Count+1);
countActiveNodes([{_,_}|T],Count)-> countActiveNodes(T,Count).
	      
runIteration(Map)-> runIteration(dict:to_list(Map), Map, []).
    
runIteration([], Map, Result)->
    io:fwrite("Status updates:~p~n",[Result]),
    NewMap = updateStates(Result,Map),
    Active = getActive(dict:to_list(NewMap),[]),
    addMissingNeigbours(Active,NewMap);

runIteration([{Coor,Status}|T], Map, Result)->
    Neighbours = getNeighbours(Coor,[]),
    Count = countActive(Neighbours,Map,0),
    io:fwrite("Counting active for ~p = ~p~n",[Coor, Count]),
    NewStatus = getNextStatus(Status, Count),
    io:fwrite("Old status: ~p New status: ~p~n",[Status,NewStatus]),
    if
	NewStatus==Status->
	    runIteration(T, Map, Result);
	true ->
	    runIteration(T, Map, [{Coor, NewStatus}|Result])
    end.
    

updateStates([],Map)->Map;
updateStates([{Coor, State}|T],Map)->
    io:fwrite("Update ~p with ~p~n",[Coor, State]),
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
    if
	IsKey ->
	    dict:fetch(H,Map);
	true ->
	    inactive
    end.
addMissingNeigbours([],Result)-> Result;
addMissingNeigbours([Active|T],Result) -> 
    NewMem = addMissing(getNeighbours(Active,[]),Result),
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
filterCoor([[X,Y,Z]|T],[X,Y,Z],Result) -> filterCoor(T,[X,Y,Z],Result);
filterCoor([[X1,Y1,Z1]|T],[X,Y,Z],Result) -> filterCoor(T,[X,Y,Z],[[X1,Y1,Z1]|Result]).


getNeighbours([X,Y,Z],Result)->
    filterCoor(lists:append([getYNeigbours(X-1,Y,Z),getYNeigbours(X,Y,Z),getYNeigbours(X+1,Y,Z)]),[X,Y,Z],[]).

getYNeigbours(X,Y,Z)->
    lists:append([getZNeigbours(X,Y-1,Z),getZNeigbours(X,Y,Z),getZNeigbours(X,Y+1,Z)]).

getZNeigbours(X,Y,Z)->
    [[X,Y,Z-1],[X,Y,Z],[X,Y,Z+1]].

createCoorMap([],Result)->
    dict:from_list(Result);
createCoorMap([{Status, X,Y,Z}|T], Result) ->
    io:fwrite("Status:~p (X,Y,Z)=(~p,~p,~p,)~n",[Status, X, Y, Z]),
    Key = [X,Y,Z],
    Value = Status,
    createCoorMap(T, [{Key, Value}|Result]);
createCoorMap([H|T], Result) ->
    io:fwrite("Entry:~p~n",[H]),
    io:fwrite("No match~n").

formatMapData(Raw)->
    formatMapData(Raw, 0, []).
formatMapData([], Y, Results)-> lists:flatten(lists:reverse(Results));
formatMapData([Row|T], Y, Result) -> 
    Z=0,
    Coor = extractXCoordinates(Row, 0, Y, Z, []),
    formatMapData(T, Y+1, [Coor|Result]).
    

extractXCoordinates([], X, Y, Z, Result) -> lists:reverse(Result);
extractXCoordinates([H|T], X, Y, Z, Result) when H==$# ->
    extractXCoordinates(T, X+1, Y, Z, [{active, X,Y,Z}|Result]);
extractXCoordinates([H|T], X, Y, Z, Result) ->
    extractXCoordinates(T, X+1, Y, Z, [{inactive, X,Y,Z}|Result]).
