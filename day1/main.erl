
-module(main).
-export([main/1]).

main([NStr]) ->
    io:fwrite("File name: ~s \n", [NStr]),
    Data = readlines(NStr),
    print_list(Data),
    halt().

readlines(Fname)->
    {ok, Raw_Data} = file:read_file(Fname),
    binary:split(Raw_Data, [<<"\n">>], [global]).

print_list([])-> [];
print_list([H|T]) ->
    %% S = erlang:binary_to_list(H),
    io:format("printing: ~s~n", [H]),
    print_list(T).
