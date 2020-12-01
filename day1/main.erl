
-module(main).
-export([main/1, string2charList/1, string2int/1, computeNumberSum/1]).

main([NStr]) ->
    io:fwrite("File name: ~s \n", [NStr]),
    Data = readlines(NStr),
    %% print_list(Data),
    halt().

computeNumberSum(Int)->
    io:format("Compute sum~n", []),
    computeNumberSum(Int, 0).
computeNumberSum(0, Sum)-> Sum;
computeNumberSum(Int, Sum)->
    computeNumberSum(Int div 10, Sum+(Int rem 10)).

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
