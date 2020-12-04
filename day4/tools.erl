-module(tools).
-export([readlines/1, split/2, countElements/2, binList2StrList/1]).

countElements(List, Element)->
    countElements(List, Element, 0).
countElements([], _, Count)-> Count;
countElements([H|T], Element, Count) when H==Element -> countElements(T, Element, Count+1);
countElements([H|T], Element, Count) -> countElements(T, Element, Count).


readlines(Fname)->
    {ok, Raw_Data} = file:read_file(Fname),
    StrList = re:split(Raw_Data,"\n"),
    List=binList2StrList(StrList),
    removeEmptyLists(List).

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
