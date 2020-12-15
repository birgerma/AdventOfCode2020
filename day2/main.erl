-module(main).
-compile(export_all).

main()->
    Fname="input1.txt",
    Lines=readlines(Fname),
    Data = formatInput(Lines),

    Start1 = os:timestamp(),
    Sol1 = sol1(Data),
    Start2 = os:timestamp(),
    Sol2 = sol2(Data),
    EndTime = os:timestamp(),
    Time1 = timer:now_diff(Start2, Start1)/1000000,
    Time2 = timer:now_diff(EndTime, Start2)/1000000,
    Total = timer:now_diff(EndTime, Start1)/1000000,

    io:fwrite("Solution part1 (Time:~f sec): ~p~n", [Time1, Sol1]),
    io:fwrite("Solution part2 (Time:~f sec): ~p~n", [Time2, Sol2]),
    io:fwrite("Total execution time: ~f sec~n", [Total]).

sol1(Data)->
    Validated = lapply(fun(H) -> passwordPolicy(H) end, Data),
    countBool(Validated).

sol2(Data)->
    Validated = lapply(fun(H) -> passwordPolicy2(H) end, Data),
    countBool(Validated).

countBool(List)->countBool(List, 0).
countBool([], Count)->Count;
countBool([H|T], Count) when H-> countBool(T,Count+1);
countBool([_|T], Count) -> countBool(T,Count).

lapply(F,List)->lapply(F, List,[]).
lapply(_,[],Result)-> lists:reverse(Result);
lapply(F, [H|T], Result) -> 
    lapply(F, T, [F(H)|Result]).

		   
passwordPolicy(Input)->
    Pwd = lists:nth(1,Input),
    Pol = lists:nth(2,Input),
    Char = lists:nth(3,Pol),
    Count = countChar(Pwd,Char),
    (Count>=lists:nth(1,Pol)) and (Count=<lists:nth(2,Pol)).

passwordPolicy2(Input)->
    Pwd = lists:nth(1,Input),
    Pol = lists:nth(2,Input),
    Char = lists:nth(1,lists:nth(3,Pol)),
    I1 = lists:nth(1,Pol),
    I2 = lists:nth(2,Pol),
    (lists:nth(I1,Pwd)==Char) xor (lists:nth(I2,Pwd)==Char).

formatInput(InputList)->
    formatInput(InputList, []).
formatInput([], Result)-> lists:reverse(Result);
formatInput([H|T], Result) ->
    Pwd = extractPassword(H),
    Policy = extractPolicy(H),
    formatInput(T, [[Pwd, Policy]|Result]).

extractPassword(List)->
    lists:nth(2,split(List,": ")).
extractPolicy(List)->
    PolStr=lists:nth(1,split(List,": ")),
    PolList = split(PolStr," "),
    Char = lists:nth(2,PolList),
    LimitList = split(lists:nth(1,PolList),"-"),
    [list_to_integer(lists:nth(1,LimitList)),list_to_integer(lists:nth(2,LimitList)),Char].

countChar(Str, Char)-> countChar(split(Str,""), Char, 0).
countChar([], Char, Count)-> Count;
countChar([H|T], Char, Count) when H==Char -> countChar(T, Char, Count+1);
countChar([H|T], Char, Count)-> 
    countChar(T, Char, Count).


removeEmptyLists(List)->removeEmptyLists(List,[]).
removeEmptyLists([], Result)->lists:reverse(Result);
removeEmptyLists([[]|T], Result)->removeEmptyLists(T,Result);
removeEmptyLists([H|T], Result) -> removeEmptyLists(T,[H|Result]).


split(Str, Split)->
    removeEmptyLists(binList2StrList(re:split(Str,Split))).

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
