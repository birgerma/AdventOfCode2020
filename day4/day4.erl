-module(day4).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    

sol2()->
    Fname="input",
    Data = tools:readlines(Fname).

%% 30 not correct, 215 too low, 216 correct
sol1()->
    Fname="input",
    %% Data = tools:readlines(Fname),
    Data = readPassports(Fname),
    Valid = checkValidPassports(Data, []),
    tools:countElements(Valid, true).
    %% printTrue(Data, Valid).

readPassports(Fname)->
    %% Fname="example",
    {ok, Raw_Data} = file:read_file(Fname),
    StrList = re:split(Raw_Data,"\n"),
    List=tools:binList2StrList(StrList),
    Passports = combineEntries(List,[], []).

combineEntries([],[],Result) ->
    lists:reverse(Result);
combineEntries([],Current,Result) ->
    combineEntries([], [], [Current|Result]);
combineEntries([[]|T], Current, Result) -> 
    %% io:fwrite("Add current ~n",[]),
    combineEntries(T, [], [Current|Result]);
combineEntries([[]|T], Current, Result) -> 
    %% io:fwrite("Add current ~n",[]),
    combineEntries(T, [], [Current|Result]);
combineEntries([H|T], Current, Result) -> 
    Pass=tools:split(H," "),
    Combined = Current++Pass,
    %% io:fwrite("To combine:~p and ~p ~n", [Pass, Current]),
    %% io:fwrite("Result:~p~n",[Combined]),
    combineEntries(T, Combined, Result).


printTrue([], _)->done;
printTrue([H1|T1],[H2|T2]) when H2 ->
    io:fwrite("valid: ~p~n",[H1]),
    printTrue(T1,T2);
printTrue([H1|T1],[H2|T2]) -> printTrue(T1,T2).

    

checkValidPassports([], Result)-> lists:reverse(Result);
checkValidPassports([H|T], Result) -> checkValidPassports(T, [isValid(H)|Result]).


isValid(H)->
    io:fwrite("Check passport:~p~n",[H]),
    Pass=H,
    %% Pass = tools:split(H, " "),
    %% io:fwrite("Passport:~p~n ", [H]),
    if 
	length(Pass)<7->
	    false;
	true  ->
	    hasAllKeys(Pass)
    end.

hasAllKeys(Pass)->
    %% io:fwrite("Passport:~p~n ", [Pass]),
    Keys = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"],
    hasAllKeys(Pass, 1, Keys).
    
hasAllKeys(_, _, [])-> true;
hasAllKeys(_, _, ["cid"])-> true;
hasAllKeys(Pass, Index, _ ) when Index>length(Pass) -> false;
hasAllKeys(List, Index, [K|T])->
    H = lists:nth(Index, List),
    Key = lists:nth(1,tools:split(H, ":")),
    if
	Key==K->
	    hasAllKeys(List, 1, T);
	true ->
	    hasAllKeys(List, Index+1, [K|T])
    end.
    
    
