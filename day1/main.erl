
-module(main).
-export([main/1, string2charList/1, string2int/1, computeDigitSum/1, stringList2IntList/1, computeListDigitSum/1]).

main([NStr]) ->
    io:fwrite("File name: ~s \n", [NStr]),
    Data = readlines(NStr),
    %% print_list(Data),
    halt().

computeListDigitSum(List) ->
    computeListDigitSum(List, []).
computeListDigitSum([], Result)->lists:reverse(Result);
computeListDigitSum([H|T], Result)->
    computeListDigitSum(T, [[H,computeDigitSum(H)]|Result]).

stringList2IntList(List)->
    stringList2IntList(List, []).
stringList2IntList([], Result)->lists:reverse(Result);
stringList2IntList([H|T], Result)->
    stringList2IntList(T, [list_to_integer(H)|Result]).
    

computeDigitSum(Int)->
    computeDigitSum(Int, 0).
computeDigitSum(0, Sum)-> Sum;
computeDigitSum(Int, Sum)->
    computeDigitSum(Int div 10, Sum+(Int rem 10)).

readlines(Fname)->
    {ok, Raw_Data} = file:read_file(Fname),
    binary:split(Raw_Data, [<<"\n">>], [global]).

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
