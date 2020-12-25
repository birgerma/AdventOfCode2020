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
    ok.
%% sol2()->
%%     Input="394618527",
%%     List = formatInput(Input),
%%     AdvancedList = createAdvancedList(List,1000000),
%%     Final = playGame(AdvancedList, 10000000),
%%     Score = advancedScore(Final),
%%     io:fwrite("Final score:~p~n",[Score]),
%%     io:fwrite("Is correct:~p~n",[Score==67384529]).

%% Correct: 
sol1()->
    Input="394618527".
    %% List = formatInput(Input),
    %% Final = playGame(List, 100),
    %% io:fwrite("--final--~nCups:~p~n",[Final]),
    %% getFinalScore(Final,[]).


%% Correct: 
test1()->
    Input="389125467",
    TableName = cups,
    initCupsTable(TableName),
    List = formatInput(Input),
    addListToCupsTable(List,-1),
    %% Final = playGame(List, 1).
    playGame(3, lists:min(List), lists:max(List),100),
    Score = getFinalScore(1,[]).
    %% io:fwrite("--final--~nCups:~p~n",[Final]),
    %% Score = getFinalScore(Final,[]),
    %% io:fwrite("Final score:~p~n",[Score]),
    %% io:fwrite("Is correct:~p~n",[Score==67384529]).
    %% Data = tools:readlines(Fname).

%% test2()->
%%     Input="389125467",
%%     List = formatInput(Input),
%%     AdvancedList = createAdvancedList(List,100000), %%10 000 works, not higher
%%     %% length(AdvancedList).
%%     Final = playGame(AdvancedList, 100),
%%     %% Final = playGame(List, 10000),
%%     Score = advancedScore(Final),
%%     %% io:fwrite("--final--~nCups:~p~n",[Final]),
%%     %% Score = getFinalScore(Final,[]),
%%     io:fwrite("Final score:~p~n",[Score]),
%%     io:fwrite("Is correct:~p~n",[Score==67384529]).
%%     %% Data = tools:readlines(Fname).
    

initCupsTable(TableName)->
    ets:new(TableName,[set, named_table]).

setNextCup(Cup, Next)->
    Debug = false,
    Name = cups,
    tools:print("Set ~p->~p~n",[Cup,Next],Debug),
    ets:insert(Name, {Cup, Next}).

getNextCup(Cup)->
    Name = cups,
    ets:lookup(Name, Cup).

advancedScore([A,B,C|T]) when A==1->
    B*C;
advancedScore([H|T]) -> advancedScore(T).

createAdvancedList(List,Max)->
    CurrentMax = lists:max(List),
    List++createIntegerList(CurrentMax+1, Max,[]).
    
createIntegerList(Next, Max, Result) when Next=<Max ->
    createIntegerList(Next+1, Max, [Next|Result]);
createIntegerList(Next, Max, Result) -> lists:reverse(Result).
    %% io:fwrite("Create list between ~p and ~p", [Min,Max]).
    
    

int_list_to_int([],Val)->Val;
int_list_to_int([H|T],Val)->
    int_list_to_int(T,Val*10+H).

%% getFinalScore([H|T],Rest) when H==1->
%%     Final = T++lists:reverse(Rest),
%%     %% io:fwrite("Found 1, final list=~p~n",[Final]),
%%     int_list_to_int(Final,0);
getFinalScore(1,[]) ->
    Next = getNext(1),
    getFinalScore(Next,[]);
getFinalScore(1,Result) ->
    Final = lists:reverse(Result),
    int_list_to_int(Final,0);
getFinalScore(Current,Result) ->
    Next = getNext(Current),
    getFinalScore(Next,[Current|Result]).

getNext(Current) -> 
    [Next] = getNext(Current, 1, []),
    Next.
getNext(Current, N) -> getNext(Current, N, []).
getNext(Current, 0, Result) -> lists:reverse(Result);
getNext(Current, N, Result) ->
    %% io:fwrite("Current:~w, N=~p~n",[Current, N]),
    Res = getNextCup(Current),
    %% io:fwrite("Next:~p~n",[Res]),
    [{_, Next}] = Res,
    getNext(Next, N-1, [Next|Result]).

printGame(Current)->
    Next = getNext(Current),
    io:fwrite("cups: (~p),",[Current]),
    %% io:fwrite("Next:~w~n",[Next]),
    printGame(Next, Current).
printGame(Current,true)->
    printGame(Current);
printGame(Current,false)->
    ok;
printGame(Last, Last)->
    io:fwrite("~n");
printGame(Current, Last)->
    Next = getNext(Current),
    io:fwrite("~p,",[Current]),
    printGame(Next, Last).

playGame(Current, MinVal, MaxVal, MaxRounds) ->
    playGame(Current,1, MinVal, MaxVal, MaxRounds).
playGame(Current, Round, MinVal, MaxVal, MaxRounds) when Round>MaxRounds->
    io:fwrite("-- final --~n"),
    printGame(Current);
playGame(Current, Round,MinVal, MaxVal, MaxRounds)->
    Debug = false,
    %% io:fwrite("Current: ~p~n",[Current]),
    [A,B,C] = getNext(Current, 3, []),
    %% Next = getNext(C),
    Dest = getNextDest(Current-1,[A,B,C],MinVal,MaxVal),

    tools:print("-- move ~p --~n",[Round],Debug),
    printGame(Current,Debug),
    tools:print("pick up: ~p~n",[[A,B,C]],Debug),
    tools:print("destination: ~p~n~n",[Dest],Debug),

    move(Current,[A,B,C], Dest),
    Next = getNext(Current),
    playGame(Next, Round+1,MinVal, MaxVal, MaxRounds).
    %% io:fwrite("Next cup:~p~n",[Next]),
    %% printGame(Next).


move(Current,[A,B,C], Dest)-> 
    Debug = false,
    tools:print("Move [~p ~p ~p]~n",[A,B,C],Debug),
    tools:print("From:~p~n",[Current],Debug),
    tools:print("To:~p~n",[Dest],Debug),
    %% Connect Current with cup after C:
    Next = getNext(C),
    setNextCup(Current,Next),
    
    %Find what Dest is pointing to:
    Tmp = getNext(Dest),

    %% Connect C with Tmp
    setNextCup(C, Tmp),
    
    %% Connect Dest with A
    setNextCup(Dest,A).

    
    
%% playGame(List,NRounds)->
%%     playGame(List, dict:new(), 1, lists:min(List), lists:max(List),NRounds).


playGame(List,  Mem, Move, MinVal,MaxVal, MaxMove) when Move>MaxMove->
    io:fwrite("Game is done~n"),
    List;
%% playGame([], Move, MinVal,MaxVal,MaxMove) ->
%%     io:fwrite("Wrap around~n"),
%%     playGame(lists:reverse(Stack),[], Move, MinVal,MaxVal, MaxMove);
playGame([H,A,B,C|T], Mem, Move, MinVal, MaxVal, MaxMove) ->
    Debug = false,
    Key = getFinalScore([H,A,B,C|T],[]),
    Exists = dict:is_key(Key,Mem),
    %% tools:print("Key:~p~n",[Key]),
    if
	Exists ->
	    tools:print("USING MEMORY!!!~n",true),
	    Dest = -1,
	    NewList = dict:fetch(Key, Mem),
	    NewMem = Mem;	
	true ->
	    %% tools:print("Computing new!!!~n",true),
	    Dest = getNextDest(H-1,[A,B,C],MinVal,MaxVal),
	    NewList = insertList([A,B,C],Dest,[H|T],[]),
	    NewMem = dict:store(Key, NewList, Mem)
    end,
    tools:print("-- move ~p --~n",[Move],true),
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
    %% New = Front++List++T++[Current],
    NewTail = Front++List++T,
    New = lists:reverse([Current|lists:reverse(NewTail)]),

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

addListToCupsTable([A],First)->
    setNextCup(A,First);
addListToCupsTable([A,B|T],-1)->
    setNextCup(A,B),
    addListToCupsTable([B|T],A);
addListToCupsTable([A,B|T],First)->
    setNextCup(A,B),
    addListToCupsTable([B|T],First).
    
formatInput(Input)->
    List = tools:split(Input,""),
    tools:as_ints(List).

