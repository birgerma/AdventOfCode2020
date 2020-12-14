-module(day9).
-compile(export_all).

-import('tools', [readlines/1]).

etime(F,0)-> ok;
etime(F,N)-> 
    %% io:fwrite("Hello~n"),
    F(),
    etime(F,N-1).
etimeMs(F,N)->
    A=os:timestamp(),
    %% io:fwrite("Hello~n"),
    etime(F,N),
    timer:now_diff(os:timestamp(),A)/(N*1000).

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
    MeanETime1 = etimeMs(fun()-> sol1()end, 1000),
    End = os:timestamp(),
    Res = timer:now_diff(End,Test)/1000000,

    io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime1]),
    io:fwrite("Test ~f[ms]:",[Res]).
    
%% Correct: 245848639
sol2()->
    Fname="input",
    N = 25,
    Data = tools:readlines(Fname),
    Numbers = tools:as_ints(Data),
    {Pre, Rest} = lists:split(N, Numbers),
    Number = findFirstFalse(checkValidXmasList(Pre, Rest, [])),
    SumList = findConSum(Numbers, Number, [], 0),
    lists:min(SumList)+lists:max(SumList).
    
%% Correct: 2089807806 
sol1()->
    Fname="input",
    N = 25,
    Data = tools:readlines(Fname),
    Numbers = tools:as_ints(Data),
    {Pre, Rest} = lists:split(N, Numbers),
    Result = checkValidXmasList(Pre, Rest, []),
    findFirstFalse(Result).

findConSum(_, Number, SubL, Sum) when Sum==Number->SubL;
findConSum(Numbers, Number, SubL, Sum) when Sum<Number ->
    N=length(SubL)+1,
    List = lists:sublist(Numbers, N),
    findConSum(Numbers, Number, List, lists:sum(List));
findConSum([_|T], Number, SubL, _) -> 
    N=length(SubL)-1,
    List = lists:sublist(T, N),
    findConSum(T, Number, List, lists:sum(List)).
				      
    

findFirstFalse([{Ok, Num}|_]) when not Ok -> Num;
findFirstFalse([_|T]) -> findFirstFalse(T). 
    
checkValidXmasList(_, [], Result)-> lists:reverse(Result);
checkValidXmasList([PreH|PreT], [H|T], Result) ->
    Res = checkValid([PreH|PreT], H),
    checkValidXmasList(lists:append(PreT,[H]),T,[{Res, H}|Result]).
    
    

checkValid([], _)->false;
checkValid([_], _)->false;
checkValid([H|T], Num) ->
    Compliment = Num-H,
    IsMember = lists:member(Compliment, T),
    if
	IsMember->
	    true;
	true  ->
	    checkValid(T, Num)
    end.

