
-module(main).
-compile(export_all).

main()->
    Fname="input",
    Start1 = os:timestamp(),
    Sol1 = sol1(Fname),
    Start2 = os:timestamp(),
    Sol2 = sol2(Fname),
    EndTime = os:timestamp(),
    Time1 = timer:now_diff(Start2, Start1)/1000,
    Time2 = timer:now_diff(EndTime, Start2)/1000,
    Total = timer:now_diff(EndTime, Start1)/1000,

    io:fwrite("Solution part1:(Time:~f ms): ~p~n", [Time1, Sol1]),
    io:fwrite("Solution part2 (Time:~f ms): ~p~n", [Time2, Sol2]),
    io:fwrite("Total execution time: ~f ms~n", [Total]).

sol1(Fname) ->
    Data = stringList2IntList(readlines(Fname)),
    findPairSum(Data, 2020).

sol2(Fname) ->
    Data = stringList2IntList(readlines(Fname)),
    findTrippleSum(Data, 2020).

findPairSum(List,Expected)->
    findPairSum(List, List, Expected).
findPairSum([H1|_],[H2|_], Expected) when H1+H2==Expected ->
    H1*H2;
findPairSum([],[],_) -> -1;
findPairSum([H|T], [], Expected) -> findPairSum(T, [H|T], Expected);
findPairSum(List, [_|T], Expected) -> 
    findPairSum(List, T, Expected).

findTrippleSum(List,Expected)->
    findTrippleSum(List, List, List, Expected).
findTrippleSum([H1|_],[H2|_], [H3|_], Expected) when H1+H2+H3==Expected ->
    H1*H2*H3;
findTrippleSum([],[],[], _) -> -1;
findTrippleSum([H|T], [], List, Expected) -> findTrippleSum(T, [H|T], List,  Expected);
findTrippleSum(List, [_|T], [], Expected) -> findTrippleSum(List, T, List, Expected);
findTrippleSum(List1, List2, [_|T], Expected) -> 
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
