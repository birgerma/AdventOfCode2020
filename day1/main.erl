
-module(main).
-export([main/1, string2charList/1, string2int/1, computeDigitSum/1, stringList2IntList/1, computeListDigitSum/1, readlines/1, findPairSum/2, sol1/1]).

sol1(Fname) ->
    io:fwrite("File name: ~s \n", [Fname]),
    Data = stringList2IntList(readlines(Fname)),
    io:fwrite("Here I am! ~n", []),
    Res = findPairSum(Data, 2020),
    io:fwrite("Answear: ~p~n", [Res]).

findPairSum(List,Expected)->
    findPairSum(List, List, Expected).
findPairSum([H1|_],[H2|_], Expected) when H1+H2==Expected ->
    io:fwrite("~1p * ~1p~n",[H1, H2]),
    H1*H2;
findPairSum([],[],Expected) -> -1;
findPairSum([H|T], [], Expected) -> findPairSum(T, [H|T], Expected);
findPairSum(List, [H|T], Expected) -> 
    %% io:fwrite("Left Head: ~1p~n",[H]),
    findPairSum(List, T, Expected).


computeListDigitSum(List) ->
    computeListDigitSum(List, []).
computeListDigitSum([], Result)->lists:reverse(Result);
computeListDigitSum([H|T], Result)->
    computeListDigitSum(T, [[H,computeDigitSum(H)]|Result]).

stringList2IntList(List)->
    stringList2IntList(List, []).
stringList2IntList([], Result)->lists:reverse(Result);
stringList2IntList([[]|T], Result)->stringList2IntList(T, Result);
stringList2IntList([H|T], Result)->
    stringList2IntList(T, [list_to_integer(H)|Result]).
    

computeDigitSum(Int)->
    computeDigitSum(Int, 0).
computeDigitSum(0, Sum)-> Sum;
computeDigitSum(Int, Sum)->
    computeDigitSum(Int div 10, Sum+(Int rem 10)).

readlines(Fname)->
    {ok, Raw_Data} = file:read_file(Fname),
    StrList = re:split(Raw_Data,"\n"),
    binList2StrList(StrList).
    %% Str = unicode:characters_to_list(StrList).
    %% binary:split(Raw_Data, [<<"\n">>], [global]).

binList2StrList(BinList)->
    binList2StrList(BinList, []).
binList2StrList([], Result)->
    Result;
binList2StrList([H|T], Result) ->
    binList2StrList(T, [unicode:characters_to_list(H)|Result]).

string2charList(Str)->
    List = re:split(Str,""),
    lists:reverse(tl(lists:reverse(List))).

string2int(Str)->
    list_to_integer(Str).

print_list([])-> [];
print_list([H|T]) ->
    %% S = erlang:binary_to_list(H),
    io:format("printing: ~s~n", [H]),
    print_list(T).
