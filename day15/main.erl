-module(main).
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
    
    
%% Correct: 129262
sol2()->
    %% Fname = "0,3,6",
    Fname = "0,20,7,16,1,18,15",
    %% Fname=Input,
    MaxRounds = 30000000,
    Data = tools:as_ints(tools:split(Fname,",")),
    [First|InitRev] = lists:reverse(Data),
    %% Init = lists:reverse(InitRev),
    Init = InitRev,
    %% io:fwrite("First:~p Init:~p~n",[First, Init]),
    %% io:fwrite("Data:~p~n",[Data]),
    Mem = initMemory(lists:reverse(Init), 1, dict:new()),
    %% io:fwrite("Memory:~p~n",[dict:to_list(Mem)]),
    Start1 = os:timestamp(),
    %% Last= playGame2(First, length(Data)+1, Init, MaxRounds),
    Start2 = os:timestamp(),
    {Last2, FinalMem} = playGame(Mem, First, length(Data)+1, MaxRounds),
    EndTime = os:timestamp(),
    Time1 = timer:now_diff(Start2, Start1)/1000000,
    Time2 = timer:now_diff(EndTime, Start2)/1000000,
    %% io:fwrite("Solution ~p in ~f sec~n",[Last, Time1]),
    io:fwrite("Solution ~p in ~f sec~n",[Last2, Time2]).

    %% Example = "0,3,6",
    %% Input = "0,20,7,16,1,18,15",
    %% Fname=Input,
    %% MaxRounds = 2020,
    %%          %% 30000000
    %% Data = tools:as_ints(tools:split(Fname,",")),
    %% io:fwrite("Data:~p~n",[Data]),
    %% Mem = initMemory(Data, 1, dict:new()),
    %% %% io:fwrite("Memory:~p~n",[dict:to_list(Mem)]),
    %% %% {Last, FinalMem} = playGameMemoize(Mem, lists:nth(length(Data),Data), length(Data)+1, MaxRounds, Data, dict:new()),
    %% %% io:fwrite("Last number ~p in ~p rounds~n",[Last, MaxRounds]).
    %% ok.

%% Correct: 
sol1()->
    Example = "0,3,6",
    Input = "0,20,7,16,1,18,15",
    Fname=Input,
    MaxRounds = 2020,
    Data = tools:as_ints(tools:split(Fname,",")),
    [First|InitRev] = lists:reverse(Data),
    Init = lists:reverse(InitRev),
    %% Init = InitRev,
    %% io:fwrite("First:~p Init:~p~n",[First, Init]),
    %% io:fwrite("Data:~p~n",[Data]),
    Mem = initMemory(Init, 1, dict:new()),
    %% io:fwrite("Memory:~p~n",[dict:to_list(Mem)]),
    {Last, FinalMem} = playGame(Mem, First, length(Data)+1, MaxRounds),
    Last.
    
    


getNextNumber(LastNum, Round, Mem)->
    Exists = dict:is_key(LastNum,Mem),
    if
	Exists ->
	    %% io:fwrite("Prev ~p exists Round:~p Last Round:~p~n",[LastNum,Round,dict:fetch(LastNum,Mem)]),
	    Round-1-dict:fetch(LastNum,Mem);
	true ->
	    %% io:fwrite("Number was first, return 0~n"),
	    0
    end.

getNextNumber([N])->
    0;
getNextNumber(List) ->
    %% io:fwrite("Last numbers:~p~n",[List]),
    Rev = lists:reverse(List),
    Diff = lists:nth(1,Rev)-lists:nth(2,Rev).
    %% -1.

addToMemory(Next, Round,Mem)->
    dict:store(Next, Round,Mem).
    %% Exists = dict:is_key(Next,Mem),
    %% if
    %% 	Exists ->
    %% 	    dict:append(Next, Round, Mem);
    %% 	true  ->
    %% 	    dict:store(Next, [Round],Mem)
    %% end.

playGame(Mem, Last, Round, MaxRounds) when Round>MaxRounds->{Last, Mem};
playGame(Mem, Last, Round, MaxRounds)->
    %% M = dict:fetch(Last,Mem),
    Next = getNextNumber(Last, Round, Mem),
    NewMem = addToMemory(Last, Round-1, Mem),
    %% io:fwrite("Round: ~p. Last spoken:~p Next:~p~n",[Round, Last, Next]),
    %% io:fwrite("Memory: ~p (~p)~n",[M, length(M)]),
    playGame(NewMem, Next, Round+1, MaxRounds).

findIndex(E, [], Index)-> not_found;
findIndex(E, [E|T], Index)-> Index;
findIndex(E, [H|T], Index)-> 
    %% io:fwrite("Not found, increase index~n"),
    findIndex(E, T, Index+1).

playGame2(Last, Round, History, MaxRounds) when Round>MaxRounds->Last;
playGame2(Last, Round, History, MaxRounds)->
    Exists = lists:member(Last, History),
    if
	Exists->
	    %% io:fwrite("Look for ~p in ~p~n",[Last, History]),
	    Index = findIndex(Last, History, 1),
	    Next = Index;
	    %% io:fwrite("Found index ~p for element ~p~n",[Index, Last]);
	true ->
	    Next = 0
    end,
    %% Next = getNextNumber(Last, Round, Mem),
    %% NewMem = addToMemory(Last, Round-1, Mem),
    %% io:fwrite("Round: ~p. Last spoken:~p Next:~p~n",[Round, Last, Next]),
    %% io:fwrite("Memory: ~p (~p)~n",[M, length(M)]),
    playGame2(Next, Round+1, [Last|History], MaxRounds).

%% playGameMemoize(Mem, Last, Round, MaxRounds, History, Cycles) when Round>MaxRounds->{Last, Mem};
%% playGameMemoize(Mem, Last, Round, MaxRounds, History, Cycles)->
%%     %% Key = lists:join(",",)
%%     PrevRound = dict:fetch(Last,Mem),
%%     Next = getNextNumber(Last,Mem),
%%     %% Next = (Round-1-getNextNumber(Round,M)),%%getNextNumber(Round,M),
%%     NewMem = addToMemory(Next, Round,Mem),
%%     io:fwrite("History:~p~n",[History]),
%%     %% io:fwrite("Round: ~p. Last spoken:~p Next:~p~n",[Round, Last, Next]),
%%     %% io:fwrite("Memory: ~p (~p)~n",[M, length(M)]),
%%     Hist = [Next|History],
%%     %% Key = tools:list_to_string(Hist,","),
%%     %% Key = string:join( [[X + ""] || X<-Hist], "," ),
%%     Key = lists:sum(Hist)*length(Hist),
%%     FoundCycle = dict:is_key(Key, Cycles),
%%     if
%% 	FoundCycle->
%% 	    io:fwrite("Cycle found:~p~n",[Hist]);
%% 	true->
%% 	    io:fwrite("Key:~p~n",[Key]),
%% 	    NewCycles = dict:append_list(Key, Hist, Cycles),
%% 	    playGameMemoize(NewMem, Next, Round+1, MaxRounds, Hist, NewCycles)
%%     end.


initMemory([],_,Mem)->
    Mem;
initMemory([H|T],Index,Mem) ->
    initMemory(T,Index+1,dict:store(H,Index,Mem)).


