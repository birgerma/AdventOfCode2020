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
    Data = tools:readlines(Fname).
    

%% Correct: 
sol1()->
    Input="394618527",
    List = formatInput(Input),
    Final = playGame(List, 100),
    io:fwrite("--final--~nCups:~p~n",[Final]),
    getFinalScore(Final,[]).


%% Correct: 
test1()->
    Input="389125467",
    List = formatInput(Input),
    Final = playGame(List, 100),
    io:fwrite("--final--~nCups:~p~n",[Final]),
    Score = getFinalScore(Final,[]),
    io:fwrite("Final score:~p~n",[Score]),
    io:fwrite("Is correct:~p~n",[Score==67384529]).
    %% Data = tools:readlines(Fname).

test2()->
    Input="389125467",
    List = formatInput(Input),
    Final = playGame(List, 100000),
    io:fwrite("--final--~nCups:~p~n",[Final]),
    Score = getFinalScore(Final,[]),
    io:fwrite("Final score:~p~n",[Score]),
    io:fwrite("Is correct:~p~n",[Score==67384529]).
    %% Data = tools:readlines(Fname).
    

int_list_to_int([],Val)->Val;
int_list_to_int([H|T],Val)->
    int_list_to_int(T,Val*10+H).

getFinalScore([H|T],Rest) when H==1->
    Final = T++lists:reverse(Rest),
    io:fwrite("Found 1, final list=~p~n",[Final]),
    int_list_to_int(Final,0);
getFinalScore([H|T],Rest) ->
    getFinalScore(T,[H|Rest]).

playGame(List,NRounds)->
    playGame(List, dict:new(), 1, lists:min(List), lists:max(List),NRounds).


playGame(List,  Mem, Move, MinVal,MaxVal, MaxMove) when Move>MaxMove->
    io:fwrite("Game is done~n"),
    List;
%% playGame([], Move, MinVal,MaxVal,MaxMove) ->
%%     io:fwrite("Wrap around~n"),
%%     playGame(lists:reverse(Stack),[], Move, MinVal,MaxVal, MaxMove);
playGame([H,A,B,C|T], Mem, Move, MinVal, MaxVal, MaxMove) ->
    Debug = false,
    Key = [H,A,B,C|T],
    Exists = dict:is_key(Key,Mem),
    if
	Exists ->
	    tools:print("USING MEMORY!!!~n",Debug),
	    Dest = -1,
	    NewList = dict:fetch(Key, Mem),
	    NewMem = Mem;	
	true ->
	    Dest = getNextDest(H-1,[A,B,C],MinVal,MaxVal),
	    NewList = insertList([A,B,C],Dest,[H|T],[]),
	    NewMem = dict:store(Key, NewList, Mem)
    end,
    tools:print("-- move ~p --~n",[Move],Debug),
    tools:print("cups: (~p) ~p ~p ~p ~p~n",[H,A,B,C,T],Debug),
    tools:print("pick up: ~p,~p,~p~n",[A,B,C],Debug),
    tools:print("destination: ~p~n",[Dest],Debug),

    playGame(NewList, NewMem, Move+1, MinVal, MaxVal, MaxMove).


%% insertList(List, Dest, [],Result) ->
%%     io:fwrite("Wrap around~n");
insertList(List, Dest, [H|T],Result) when H==Dest->
    %% io:fwrite("We should insert here!~n"),
    %% io:fwrite("Result:~p~n",[Result]),
    %% io:fwrite("Head:~p~n",[H]),
    %% io:fwrite("Tail:~p~n",[T]),
    %% io:fwrite("Stack:~p~n",[Stack]),
    [Current|Front] = lists:reverse([H|Result]),
    New = Front++List++T++[Current],
    %% io:fwrite("New list:~p~n",[New]),
    New;
insertList(List, Dest, [H|T],Result) ->
    %% io:fwrite("Continue looking for ~p~n",[Dest]),
    insertList(List, Dest, T,[H|Result]).

    
getNextDest(Next, Taken, MinVal,MaxVal) when Next<MinVal->
    getNextDest(MaxVal, Taken, MinVal,MaxVal);
getNextDest(Next, Taken, MinVal,MaxVal)->
    %% io:fwrite("Compute dest:~p ~p ~p ~n",[H,MinVal, MaxVal]),
    IsOk = (not lists:member(Next, Taken)),
    if
	IsOk->
	    Next;
	true ->
	    %% io:fwrite("Subtract, return ~p~n",[H-1]),
	    getNextDest(Next-1, Taken, MinVal, MaxVal)
    end.

formatInput(Input)->
    List = tools:split(Input,""),
    tools:as_ints(List).
