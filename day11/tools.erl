-module(tools).
-export([readlines/1, split/2, countElements/2, binList2StrList/1, as_ints/1, etimeMs/2, countChar/2]).


countChar(List, Char)->
    countChar(List, Char,0).
countChar([],_,Count)->
    Count;
countChar([Char|T],Char,Count) -> countChar(T,Char,Count+1);
countChar([_|T],Char,Count) -> countChar(T,Char,Count).


etime(F,0)-> ok;
etime(F,N)-> 
    Res=F(),
    io:fwrite("Res:~p~n",[Res]),
    etime(F,N-1).
etimeMs(F,N)->
    A=os:timestamp(),
    etime(F,N),
    B=os:timestamp(),
    timer:now_diff(B,A)/N/1000000.

as_ints(Data)->
    as_ints(Data,[]).
as_ints([],Result)-> lists:reverse(Result);
as_ints([H|T],Result)-> as_ints(T, [list_to_integer(H)|Result]).


countElements(List, Element)->
    countElements(List, Element, 0).
countElements([], _, Count)-> Count;
countElements([H|T], Element, Count) when H==Element -> countElements(T, Element, Count+1);
countElements([H|T], Element, Count) -> countElements(T, Element, Count).


%% readlines(Fname)->
%%     {ok, Raw_Data} = file:read_file(Fname),
%%     StrList = re:split(Raw_Data,"\n"),
%%     List=binList2StrList(StrList),
%%     removeEmptyLists(List).

readlines(Fname)->
    {ok, Raw_Data} = file:read_file(Fname),
    StrList = re:split(Raw_Data,"\n"),
    binList2StrList(StrList).

binList2StrList(BinList)->
    binList2StrList(BinList, []).
binList2StrList([], Result)->
    lists:reverse(Result);
binList2StrList([H|T], Result) ->
    binList2StrList(T, [unicode:characters_to_list(H)|Result]).

removeEmptyLists(List)->removeEmptyLists(List,[]).
removeEmptyLists([], Result)->lists:reverse(Result);
removeEmptyLists([[]|T], Result)->removeEmptyLists(T,Result);
removeEmptyLists([H|T], Result) -> removeEmptyLists(T,[H|Result]).


split(Str, Split)->
    removeEmptyLists(binList2StrList(re:split(Str,Split))).
