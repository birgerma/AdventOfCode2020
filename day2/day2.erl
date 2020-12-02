-module(day2).
-compile(export_all).





removeEmptyLists([[]|T])->
    T;
removeEmptyLists(List) -> List.


readlines(Fname)->
    {ok, Raw_Data} = file:read_file(Fname),
    StrList = re:split(Raw_Data,"\n"),
    List=binList2StrList(StrList),
    removeEmptyLists(List).

binList2StrList(BinList)->
    binList2StrList(BinList, []).
binList2StrList([], Result)->
    Result;
binList2StrList([H|T], Result) ->
    binList2StrList(T, [unicode:characters_to_list(H)|Result]).
