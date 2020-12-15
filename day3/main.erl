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

%% Correct: 1592662500
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    Slopes = [[1,1], [3,1], [5,1], [7,1], [1,2]],
    Traces = computeTraces(Data,Slopes),
    Counts = countCharList(Traces, $#),
    multiply(Counts).

%% Correct: 250
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    Trace = traverse(Data, 3, 1),
    Count = countChar(Trace, $#).

multiply(List)->
    multiply(List, 1).
multiply([], Result)->
    Result;
multiply([H|T], Result) -> 
    multiply(T, Result*H).

countCharList(Traces, Char)->
    countCharList(Traces, Char, [0]).
countCharList([], Char, Result)-> [H|T] = lists:reverse(Result), T;
countCharList([H|T], Char, Result) -> 
    C = countChar(H,Char),
    countCharList(T, Char, [C|Result]).

computeTraces(Data,Slopes)->
    computeTraces(Data,Slopes,[]).
computeTraces(_,[], Result)-> lists:reverse(Result);
computeTraces(Data, [H|T], Result) -> 
    StepX=lists:nth(1,H),
    StepY=lists:nth(2,H),
    computeTraces(Data, T, [traverse(Data, StepX, StepY)|Result]).
    
countChar(String, Char)->
    countChar(String, Char, 0).
countChar("",_,Count)->Count;
countChar([H|T],Char,Count) when H==Char->countChar(T, Char, Count+1);
countChar([H|T], Char, Count) ->countChar(T,Char,Count).
    
traverse(Data, StepX, StepY)->   
    List = popList(Data, StepY),
    traverse(List, 1, StepX, StepY, []).
traverse([],_,_,_,Trace)->
    lists:reverse(Trace);
traverse([H|T], Index, StepX, StepY, Trace) ->
    Next = getNext(Index+StepX, length(H)),
    Char = lists:nth(Next, H),
    traverse(popList([H|T], StepY), Next, StepX, StepY, [Char|Trace]).

popList([], _) -> [];
popList(List, 0) -> List;
popList([H|T], N) when N>0 ->
    popList(T, N-1).
    
getNext(0, _) -> 1;
getNext(Next, L) when Next>L->getNext((Next rem L),L);
getNext(Next, L) ->Next. 
