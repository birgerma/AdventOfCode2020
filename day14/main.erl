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
sol2()->
    Fname="input",
    Data = tools:readlines(Fname).

%% Correct: 
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    %% io:fwrite("Data:~p~n",[Data]),
    Prog = formatProgData(Data,[]),
    Mem = runProgram(Prog,"", dict:new()),
    Sum = getMemorySum(Mem),
    %% io:fwrite("Memory: ~p~n~p~n",[dict:fetch(8,Mem), dict:fetch(7,Mem)]).
    Sum.


getMemorySum(Mem)->
    BinValues = getMemValue(dict:to_list(Mem),[]),
    %% io:fwrite("Memory:~p~n",[BinValues]),
    Values = as_dec(BinValues,[]),
    %% io:fwrite("Decimal values:~w~n",[Values]),
    lists:sum(Values).
    
getMemValue([],Result)-> lists:reverse(Result);
getMemValue([{Pos, Val}|T],Result)->
    getMemValue(T, [Val|Result]).

runProgram([],Mask,Mem)->Mem;
runProgram([[M,V]|T],Mask,Mem)->
    %% io:fwrite("Memory assignment~n"),
    NewMem = assign(M, V, Mask, Mem),
    %% io:fwrite("New memory:~p~n",[dict:fetch(M,NewMem)]),
    runProgram(T,Mask,NewMem);
runProgram([M|T],Mask, Mem) ->
    %% io:fwrite("Mask change~n"),
    runProgram(T,M,Mem).

assign(Pos, Val, Mask, Mem)->
    %% io:fwrite("Assigning: Mask=~p~n",[Mask]),
    %% io:fwrite("Assign Mem[~p]=~p (Mask=~p)~n",[Pos,Val,Mask]),
    Value = maskValue(Val, Mask,[]),
    %% io:fwrite("Final value:~p~n",[Value]),
    dict:store(Pos, Value,Mem).

maskValue([], [],Result) -> lists:reverse(Result);
maskValue([V|T1], [M|T2],Result) when M/=$X->
    %% io:fwrite("Use mask:~c~n",[M]),
    maskValue(T1,T2, [M|Result]);
maskValue([V|T1], [M|T2],Result) ->
    %% io:fwrite("Skip mask:~c~n",[M]),
    maskValue(T1,T2, [V|Result]).

formatProgData([],Result) -> lists:reverse(Result);
formatProgData([[$m,$a,$s,$k|Tail]|T],Result) ->
    Mask = string:trim(lists:nth(2,tools:split(Tail,"="))),
    %% BinMask = re:replace(Mask, "X", "1", [global, {return, list}]),
    %% io:fwrite("Found mask:~p New Mask~p~n",[Mask, BinMask]),
    formatProgData(T,[Mask|Result]);
formatProgData([H|T],Result) ->
    %% io:fwrite("Memory assignment:~p~n",[H]),
    {Mem, Val} = formatMemAss(H),
    BinVal = as_binary(Val, 36),
    %% io:fwrite("Bin value:~p~n",[BinVal]),
    %% io:fwrite("Match:~p L=~p~n",[{Mem, Val},length([Mem, Val])]),
    formatProgData(T,[[Mem, BinVal]|Result]).


formatMemAss(A)->
    Lst = tools:split(A,"="),
    Mem = string:trim(re:replace(lists:nth(1,Lst), "[a-zA-Z|\\[|\\]]", "", [global, {return, list}])),
    Val = string:trim(re:replace(lists:nth(2,Lst), "[a-zA-Z|\\[|\\]]", "", [global, {return, list}])),
    {list_to_integer(Mem),list_to_integer(Val)}.
    

as_dec([],Result)-> lists:reverse(Result);
as_dec([H|T],Result)->
    %% io:fwrite("Converting: ~p to ~p~n",[H, list_to_integer(H,2)]),
    as_dec(T, [list_to_integer(H,2)|Result]).

as_binary(Val, Nbits)->
    Bin = integer_to_list(Val, 2),
    padd_zeros(Bin, Nbits).

padd_zeros(Val, Len) when length(Val)<Len ->
    padd_zeros([$0|Val],Len);
padd_zeros(Val,_) -> Val.
