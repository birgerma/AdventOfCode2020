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
    
    
%% Correct: 
sol1()->
    Fname="input",
    Data = tools:as_ints(tools:readlines(Fname)),
    Max = lists:max(Data),
    Sorted =  lists:sort([0,Max+3|Data]),
    %% io:fwrite("Data:~p~n",[Data]),
    %% io:fwrite("Data:~p~n",[Sorted]),
    Diff1 = countDiffs(Sorted,1),
    Diff3 = countDiffs(Sorted,3),
    io:fwrite("Answear:~p~n",[Diff1*Diff3]).

%% Correct: 
sol2()->
    Fname="input",
    Data = tools:as_ints(tools:readlines(Fname)),
    Max = lists:max(Data),
    Sorted =  lists:sort([0,Max+3|Data]),
    Memory = dict:new(),
    Start = os:timestamp(),
    io:fwrite("Data:~p~n",[Sorted]),
    {Res, M} = computeCombinationsMem(Sorted, Memory),
    End = os:timestamp(),
    Time = timer:now_diff(End,Start)/1000000,
    io:fwrite("Result ~p in ~f s",[Res, Time]).



computeCombinationsMem([A,B|T],Mem) when B-A>3 ->
    {0,Mem};
computeCombinationsMem([A,B],Mem) -> 
    {1,Mem};
computeCombinationsMem([A,B,C|T],Memory) when C-A=<3 -> 
    %% io:fwrite("Splitting computation ~n"),
    {V1,M1} = fetchCombinationsMem([B,C|T],Memory),
    {V2,M2} = fetchCombinationsMem([A,C|T],M1),
    {V1+V2,M2};
computeCombinationsMem([A|T],Memory) ->
    %% io:fwrite("Pop head:~w~n",[[A|T]]),
    {V,M} = fetchCombinationsMem(T,Memory),
    {V,M}.
%% computeCombinations([A,B,C|T],Memory) ->
fetchCombinationsMem(T,Memory) ->
    %% io:fwrite("Fetching combinations~n"),
    %% Key=lists:sum(T),
    Key = lists:join(" ", [integer_to_list(I) || I <- T]),
    Exists = dict:is_key(Key, Memory),
    if
	Exists->
	    Mem=Memory,
	    Value=dict:fetch(Key, Memory),
	    %% {Computed,M} = computeCombinationsMem(T, Memory),
	    io:fwrite("Fetching existing value ~p Key:~p~n",[Value,Key]);
	true  ->
	    io:fwrite("Compute new:~p~n",[Key]),
	    {Value,M} = computeCombinationsMem(T, Memory),
	    Mem = dict:store(Key, Value, M),
	    io:fwrite("Is stored:~p~n",[dict:is_key(Key, Mem)])
    end,

    if
	Key==813->
	    io:fwrite("Here we are~n"),
	    io:fwrite("List:~w~n",[T]),
	    io:fwrite("Key=~p Value=~p~n",[Key,Value]);
	true -> ok
    end,

    {Value, Mem}.

%% computeCombinations(Front,[A|T],Count,0) -> Count;
%% computeCombinations([],[A|T],Count,It) -> computeCombinations([A],T,Count,It);
computeCombinations([A,B|T],_) when B-A>3 ->
    0;
computeCombinations([A,B],_) -> 
    1;

%% [ 4, 6, 7, 10, 11, 12, 15, 16, 19, 22 ]
%% [ 4, 7, 10, 11, 12, 15, 16, 19, 22 ]
%% [ 10, 12, 15, 16, 19, 22 ]
%% [ 10, 12, 15, 16, 19, 22 ]
%% [ 5, 7, 10, 11, 12, 15, 16, 19, 22 ]
%% [ 10, 12, 15, 16, 19, 22 ]
%% [ 10, 12, 15, 16, 19, 22 ]
computeCombinations([A,B,C|T],Memory) when C-A=<3 -> 
    %% io:fwrite("Array check ~n:~w~n~w~n--------",[[A,B|T],[A,B|T]]),
    %% computeCombinations([A,C|T],Memory)+computeCombinations([B,C|T],Memory);
    {V1,M1} = fetchCombinations([A,C|T],Memory),
    {V2,M2} = fetchCombinations([B,C|T],M1),
    V1+V2;
computeCombinations([A|T],Memory) ->
    %% io:fwrite("Pop head:~w~n",[[A|T]]),
    {V,M} = fetchCombinations(T,Memory),
    V.
%% computeCombinations([A,B,C|T],Memory) ->
fetchCombinations(T,Memory) ->
    %% Key=lists:sum(T),
    Key = lists:join(" ", [integer_to_list(I) || I <- T]),
	    

    Exists = dict:is_key(Key, Memory),
    if
	Exists->
	    Mem=Memory,
	    Value=dict:fetch(Key, Memory),
	    Computed = computeCombinations(T, Memory),
	    io:fwrite("Fetching existing value ~p Computed:~p Key:~p~n",[Value, Computed,Key]);
	true  ->
	    %% io:fwrite("Compute new:~p~n",[Key]),
	    Value = computeCombinations(T, Memory),
	    Mem = dict:store(Key, Value, Memory)
    end,

    if
	Key==813->
	    io:fwrite("Here we are~n"),
	    io:fwrite("List:~w~n",[T]),
	    io:fwrite("Key=~p Value=~p~n",[Key,Value]);
	true -> ok
    end,
    %% io:fwrite("Sum:~p~n",[Key]),
    %% Computed = computeCombinations(T, Memory),
    %% dict:store(Key, Computed, Memory),
    %% io:fwrite("Key:~p Computed:~p Saved:~p~n",[Key, Computed, Value]),

    %% {Computed, Memory}.
    {Value, Mem}.
    %% computeCombinations(T,Memory).
    %% K2 = lists:flatten(io_lib:format("~p",[[B,C|T]])),
    %% {V1,M1} = getValue([A,C|T],Memory),
    %% {V2,M2} = getValue([B,C|T],M1),
    %% V1+V2.
    %% computeCombinations([A,C|T],Memory)+computeCombinations([B,C|T],Memory).
    
getValue(List, Memory)->
    Key = lists:sum(List),
    Exists = dict:is_key(Key, Memory),
    if
	Exists->
	    Mem=Memory,
	    Value=dict:fetch(Key, Memory),
	    io:fwrite("Fetching existing value~n");
	true  ->
	    io:fwrite("Compute new:~p~n",[Key]),
	    Value = computeCombinations(List, Memory),
	    Mem = dict:store(Key, Value, Memory)
    end,
    {Value, Mem}.

nComb(List) when length(List)<3 -> 
    io:fwrite("List too short:~w~n",[List]),
    1;
nComb([A,B,C]) when C-A=<3 -> 
    io:fwrite("Two combinations:~w~n",[[A,B,C]]),
    2;
nComb([A,B,C,D]) when D-A==3 -> 
    io:fwrite("Four combinations:~w~n",[[A,B,C,D]]),
    4;
nComb([A,B,C,D]) -> 
    io:fwrite("Two combinations:~w~n",[[A,B,C,D]]),
    2;
nComb(List) ->
    io:fwrite("Computing n combinations for:~w~n",[List]),
    1.

%% computeCombinationsFast(List,I,J,Comb,Current) when J>length(List)-> Comb+(J-I-1)*2;
computeCombinationsFast([_],Current,Comb) -> Comb;
computeCombinationsFast([A,B|T],Current,Comb) when B-A<3-> 
    %% io:fwrite("A=~p B=~p~n",[A,B]),
    computeCombinationsFast([A|T],[B|Current],Comb);
computeCombinationsFast([A,B|T],Current,Comb) ->
    C = nComb(lists:sort([A,B|Current])),
    io:fwrite("Compute combinations for:~w N=~p~n",[lists:sort([A,B|Current]),C]),
    io:fwrite("Total combinations:~p~n",[Comb*C]),
    computeCombinationsFast([B|T],[],Comb*C);

computeCombinationsFast(List,Current,Comb) ->
    io:fwrite("Current:~p~n",[Current]),
    io:fwrite("List:~p~n",[List]).

countDiffs(Data,Diff)-> 
    countDiffs(Data, Diff, 0).

countDiffs([_],_,Count) -> Count;
countDiffs([A,B|T],Diff,Count) when B-A==Diff-> 
    %% io:fwrite("Counting diff: ~p-~p~n",[B,A]),
    countDiffs([B|T],Diff,Count+1);
countDiffs([A|T],Diff,Count) -> 
    %% io:fwrite("Skipping: ~p~n",[A]),
    countDiffs(T,Diff,Count).
