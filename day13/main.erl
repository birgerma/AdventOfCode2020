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
    [_|Ids] = tools:readlines(Fname),
    IdList = as_ints(tools:split(Ids,","),[]),
    %% TimeStamp = 1068781,
    Init = lists:nth(1, IdList)*1000000000000000,
    TimeStamp = findTimestampFast(IdList),
    IsOk=check_sol2(TimeStamp, IdList, 0),
    io:fwrite("Time:~p is ok:~p~n",[TimeStamp, IsOk]).

findTimestampFast(IdList)->
    Rem = computeNegIndex(IdList,0,[]),
    Num = lists:filter(fun(E) -> E/="x"end, IdList),
    %% Num=[3,4,5],
    %% Rem = [2,3,1],
    Prod = prod(Num,1),
    PP = computePP(Num, Prod, []),
    %% Inv = computeInv(20, 3,1),
    Inv = computeInvList(PP, Num,[]),
    PS = computeProdSum(Rem, PP, Inv, 0),
    X=modulo(PS,Prod),
    io:fwrite("List:~p~n Rem:~p~n Prod:~p~n PP:~p~n Inv:~p~n ProdSum:~p~n X=~p~n",[Num,Rem,Prod, PP, Inv, PS, X]).

modulo(X,Y) when X > 0 ->   
   X rem Y;

modulo(X,Y) when X < 0 ->   
    K = (-X div Y)+1,
    PositiveX = X + K*Y,
    PositiveX rem Y;

modulo(0,_Y) -> 
    0.

computeProdSum([], [], [], Sum)-> Sum;
computeProdSum([H1|T1], [H2|T2], [H3|T3], Sum)->
    io:fwrite("~p ~p ~p ~n",[H1, H2, H3]),
    computeProdSum(T1, T2, T3, Sum+H1*H2*H3).
    
computeInvList([], [], Result) -> lists:reverse(Result);
computeInvList([PPH|PPT], [NumH|NumT], Result)->
    computeInvList(PPT, NumT, [computeInv(PPH, NumH, 1)|Result]).

computeInv(PP, Num, InvTest) when ((PP*InvTest) rem Num==1)-> InvTest;
computeInv(PP, Num, InvTest) -> 
    computeInv(PP, Num, InvTest+1).
    

computePP([], _, Result)->lists:reverse(Result);
computePP([H|T], Prod, Result) -> computePP(T, Prod, [Prod div H|Result]).
    
prod([],Res) ->
    Res;
prod([H|T],Res) ->prod(T,Res*H).


computeNegIndex([],_,Result)-> lists:reverse(Result);
computeNegIndex(["x"|T],Index,Result) -> computeNegIndex(T,Index+1, Result);
computeNegIndex([H|T],Index,Result)-> computeNegIndex(T,Index+1, [-Index|Result]).
    
findTimestamp(TS, IdList, 0)-> -1;
findTimestamp(TS, IdList, MaxIt)->
    IsFound = check_sol2(TS, IdList, 0),
    if
	IsFound->
	    TS;
	true  ->
	    Diff = lists:nth(1,IdList),
	    findTimestamp(TS+Diff, IdList, MaxIt-1)
    end.
    

check_sol2(TS, [],Index)->
    true;
check_sol2(TS, ["x"|T], Index) -> check_sol2(TS, T, Index+1);
check_sol2(TS, [H|T], Index) ->
    Next = getClosestNext(TS, H),
    IsOk = ((Next-Index)==0),
    %% io:fwrite("Bus:~p TS rem H:~p Next:~p Index:~p~n",[H,(TS rem H), Next, Index]),
    %% io:fwrite("TS:~p, H:~p Index:~p isOk:~p~n",[TS, H, Index, IsOk]),
    if 
	IsOk ->
	    check_sol2(TS, T, Index+1);
	true  ->
	    false
    end.



as_ints([],Result)->
    lists:reverse(Result);
as_ints(["x"|T], Result) -> as_ints(T, ["x"|Result]);
as_ints([H|T], Result) -> as_ints(T, [list_to_integer(H)|Result]).

%% Correct: 
sol1()->
    Fname="input",
    [StringTime|IdList] = tools:readlines(Fname),
    Time = list_to_integer(StringTime),
    %% TimeTable = tools:split(IdList,","),
    TimeTable = tools:as_ints(lists:filter(fun(E) -> E/="x"end, tools:split(IdList,","))),
    ClosestTime = getClosestTime(Time, TimeTable, []),
    MinIndex = findMinIndex(ClosestTime),
    MinElement = lists:nth(MinIndex,ClosestTime),
    Id = lists:nth(MinIndex,TimeTable),
    io:fwrite("MinIndex~p Value:~p Id:~p ~n",[MinIndex,MinElement,Id]),
    Res = (MinElement-Time)*Id,
    io:fwrite("Time: ~p List:~p Result:~p~n",[Time, TimeTable, Res]).


findMinIndex([H|T]) -> findMinIndex(T, 2, H, 1).
findMinIndex([], Index, MinValue, MinIndex)-> MinIndex; 
findMinIndex([H|T], Index, MinValue, MinIndex) ->
    IsLess = (H<MinValue),
    io:fwrite("Compare ~p < ~p = ~p ~n",[H,MinValue,IsLess]),
    if
	IsLess->
	    findMinIndex(T, Index+1, H, Index);
	true  ->
	    findMinIndex(T, Index+1, MinValue, MinIndex)
    end.
getClosestTime(_, [], Result)-> lists:reverse(Result);
getClosestTime(Time, [H|T], Result) ->
    Res = ((Time div H)+1)*H,
    io:fwrite("Time:~p~n",[Res]),
    getClosestTime(Time, T, [Res|Result]).

getClosestNext(Time, Id) when (Time rem Id)>0 ->
    ((Time div Id)+1)*Id-Time;
getClosestNext(_,_) ->0.
