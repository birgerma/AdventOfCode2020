
-module(main).
-export([sol/0, sol1/1, sol2/1]).

sol()->
    Fname="input1.txt",
    sol1(Fname),
    sol2(Fname).

sol1(Fname) ->
    %% io:fwrite("File name: ~s \n", [Fname]),
    Data = stringList2IntList(readlines(Fname)),
    Res = findPairSum(Data, 2020),
    io:fwrite("Solution 1: ~p~n", [Res]).

sol2(Fname) ->
    %% io:fwrite("File name: ~s \n", [Fname]),
    Data = stringList2IntList(readlines(Fname)),
    Res = findTrippleSum(Data, 2020),
    io:fwrite("Solution 2: ~p~n", [Res]).

findPairSum(List,Expected)->
    findPairSum(List, List, Expected).
findPairSum([H1|_],[H2|_], Expected) when H1+H2==Expected ->
    %% io:fwrite("~1p * ~1p~n",[H1, H2]),
    H1*H2;
findPairSum([],[],_) -> -1;
findPairSum([H|T], [], Expected) -> findPairSum(T, [H|T], Expected);
findPairSum(List, [_|T], Expected) -> 
    %% io:fwrite("Left Head: ~1p~n",[H]),
    findPairSum(List, T, Expected).


findTrippleSum(List,Expected)->
    findTrippleSum(List, List, List, Expected).
findTrippleSum([H1|_],[H2|_], [H3|_], Expected) when H1+H2+H3==Expected ->
    %% io:fwrite("~1p * ~1p * ~1p ~n",[H1, H2, H3]),
    H1*H2*H3;
findTrippleSum([],[],[], _) -> -1;
findTrippleSum([H|T], [], List, Expected) -> findTrippleSum(T, [H|T], List,  Expected);
findTrippleSum(List, [H|T], [], Expected) -> findTrippleSum(List, T, List, Expected);
findTrippleSum(List1, List2, [H|T], Expected) -> 
    %% io:fwrite("Left Head: ~1p~n",[H]),
    findTrippleSum(List1, List2, T, Expected).

stringList2IntList(List)->
    stringList2IntList(List, []).
stringList2IntList([], Result)->lists:reverse(Result);
stringList2IntList([[]|T], Result)->stringList2IntList(T, Result);
stringList2IntList([H|T], Result)->
    stringList2IntList(T, [list_to_integer(H)|Result]).
    
readlines(Fname)->
    {ok, Raw_Data} = file:read_file(Fname),
    StrList = re:split(Raw_Data,"\n"),
    binList2StrList(StrList).

binList2StrList(BinList)->
    binList2StrList(BinList, []).
binList2StrList([], Result)->
    Result;
binList2StrList([H|T], Result) ->
    binList2StrList(T, [unicode:characters_to_list(H)|Result]).
