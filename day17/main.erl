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
    
%% Correct: 1380
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

%% Correct: 269
sol1()->
    Fname="input",
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
	      
countActiveNodes([],Count)-> Count;
countActiveNodes([{N,active}|T],Count)-> 
    countActiveNodes(T,Count+1);
countActiveNodes([{_,_}|T],Count)-> countActiveNodes(T,Count).
	      
runIteration(Map)-> runIteration(dict:to_list(Map), Map, []).
    
runIteration([], Map, Result)->
    NewMap = updateStates(Result,Map),
    Active = getActive(dict:to_list(NewMap),[]),
    addMissingNeigbours(Active,NewMap);

runIteration([{Coor,Status}|T], Map, Result)->
    Neighbours = getNeighbours(Coor),
    Count = countActive(Neighbours,Map,0),
    NewStatus = getNextStatus(Status, Count),
    if
	NewStatus==Status->
	    runIteration(T, Map, Result);
	true ->
	    runIteration(T, Map, [{Coor, NewStatus}|Result])
    end.
    

updateStates([],Map)->Map;
updateStates([{Coor, State}|T],Map)->
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
    getActive(T,Result).

filterCoor([],_,Result)->
    lists:reverse(Result);
filterCoor([Coor|T],Coor,Result) -> filterCoor(T,Coor,Result);
filterCoor([Coor1|T],Coor,Result) -> filterCoor(T,Coor,[Coor1|Result]).

getNeighbours(Coor)->
    filterCoor(getNeighbours(Coor,[],[]), Coor,[]).
getNeighbours([Coor],Prev,Result)->
    Coordinates = [lists:reverse([Coor-1|Prev]),lists:reverse([Coor|Prev]),lists:reverse([Coor+1|Prev])],
    lists:append(Result, Coordinates);
getNeighbours([Coor|T],Prev,Result)->
    lists:append([Result, getNeighbours(T, [Coor-1|Prev], Result),getNeighbours(T, [Coor|Prev], Result),getNeighbours(T, [Coor+1|Prev], Result)]).

createCoorMap([],Result)->
    dict:from_list(Result);
createCoorMap([{Status, Coor}|T], Result) ->
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
    Coor = extractXCoordinates(Row, 0, Y, Suffix, []),
    formatMapData(T, Y+1, Suffix, [Coor|Result]).
    

extractXCoordinates([], X, Y, Z, Result) -> lists:reverse(Result);
extractXCoordinates([H|T], X, Y, Suffix, Result) when H==$# ->
    Coor = lists:append([X,Y],Suffix),
    extractXCoordinates(T, X+1, Y, Suffix, [{active, Coor}|Result]);
extractXCoordinates([H|T], X, Y, Suffix, Result) ->
    Coor = lists:append([X,Y],Suffix),
    extractXCoordinates(T, X+1, Y, Suffix, [{inactive, Coor}|Result]).
