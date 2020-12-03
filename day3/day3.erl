-module(day3).
-compile(export_all).

-import('tools', [readlines/1]).


sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    Trace = traverse(Data, 3, 1),
    Count = countChar(Trace, $#).

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
    %% io:fwrite("~p ",[H]),
    Next = getNext(Index+StepX, length(H)),
    Char = lists:nth(Next, H),
    %% io:fwrite(":~p ~c ~n",[Next, Char]),
    traverse(popList([H|T], StepY), Next, StepX, StepY, [Char|Trace]).
    %% traverse(popList([H|T], StepY), Next, StepX, StepY, Trace).


popList(List, 0) -> List;
popList([H|T], N) when N>0 ->
    popList(T, N-1).
    
getNext(0, _) -> 1;
getNext(Next, L) when Next>L->getNext((Next rem L),L);
getNext(Next, L) ->Next. 

