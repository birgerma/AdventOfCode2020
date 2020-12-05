-module(day4).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    

sol2()->
    %% Fname="example2",
    Fname="input",
    Data = readPassports(Fname),
    Valid = checkValidPassports(Data, []),
    Validated = getValidatedKeys(Data, Valid, []),
    Correct = validateData(Validated,[]),
    length(Correct).

%% 30 not correct, 215 too low, 216 correct
sol1()->
    Fname="input",
    %% Data = tools:readlines(Fname),
    Data = readPassports(Fname),
    Valid = checkValidPassports(Data, []),
    tools:countElements(Valid, true).
    %% printTrue(Data, Valid).


validateData([],Result)->lists:reverse(Result);
validateData([H|T], Result) ->
    IsValid = isValidData(H),
    io:fwrite("Validating: ~p ~p~n",[H,IsValid]),
    if
	IsValid  ->
	    validateData(T,[H|Result]);
	true ->
	    validateData(T,Result)
    end.


isValidData([])->true;
isValidData([H|T])->
    EntryList = tools:split(H,":"),
    IsValid = isDataValid(lists:nth(1,EntryList),lists:nth(2,EntryList)),
    %% io:fwrite("Is valid: ~p~n",[IsValid]),
    if
	IsValid ->
	    isValidData(T);
	true ->
	    false
    end.


correctLength(Data,4)->
    length(Data)==4.

correctRange(Num, Min, Max)->
    (Num>=Min) and (Num=<Max).

isDataValid("byr",Data)->
    %% L=length(Data),
    IsOk = correctLength(Data,4) and correctRange(list_to_integer(Data), 1920, 2002),
    io:fwrite("Validating byr=~p ~p~n",[Data, IsOk]),
    IsOk;
isDataValid("iyr",Data)->
    correctLength(Data,4) and correctRange(list_to_integer(Data), 2010, 2020);
isDataValid("eyr",Data)->
    correctLength(Data,4) and correctRange(list_to_integer(Data), 2020, 2030);

isDataValid("hgt",Data)->
    %% io:fwrite("Validating hgt:~p~n",[Data]),
    {Height, Suffix} = extractHeight(Data,[],[]),
    %% io:fwrite("Unit:~s~n",[Suffix]),
    isValidHeight(Height, Suffix);
isDataValid("hcl",Data)->
    isValidHairColor(Data);
isDataValid("ecl",Data)->
    Colors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
    lists:member(Data,Colors);
isDataValid("pid",Data)->
    Res = re:run(Data, "^\\d{9}$"),
    io:fwrite("Check pid: ~p ~p ~n",[Data, Res]),
    (Res/=nomatch);

isDataValid(Key,Data)->
    true.

isValidHairColor(Color)->
    %% io:fwrite("Checking ~p ~n",[Color]),
    Res = re:run(Color, "^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$"),
    (Res/=nomatch).
    %% io:fwrite("Checking ~p ~p~n",[Color, IsOk]);
    %% [Numbers, Letters] = splitInTwo(T,[]),
    %% io:fwrite("My lists:~p:~p~n",[Numbers, Letters]);

splitInTwo(List,Head) when length(Head)>=length(List) ->
    [Head, lists:reverse(List)];
splitInTwo([H|T], Head) -> splitInTwo(T, [H|Head]).


extractHeight([],Num,Unit) -> 
    %% io:fwrite("Done:~s ~s~n",[Num,Unit]),
    Value = lists:reverse(Num),
    Suffix = lists:reverse(Unit),
    %% io:fwrite("Done:~s ~s~n",[Value,Suffix]),
    {list_to_integer(Value),Suffix};
extractHeight([H|T],Num,Unit) when H==$c;H==$m;H==$i;H==$n-> 
    %% io:fwrite("Found a unit:~c~n",[H]),
    extractHeight(T, Num, [H|Unit]);
extractHeight([H|T],Num,Unit) ->
    %% io:fwrite("Base case, only numbers:~c~n",[H]),
    extractHeight(T, [H|Num], Unit).
    
    
isValidHeight(Num,"cm")->
    correctRange(Num, 150, 193);
isValidHeight(Num,"in")->
    correctRange(Num, 59, 76);
isValidHeight(_,_)-> false.

getValidatedKeys([], _, Result)->lists:reverse(Result);
getValidatedKeys([_|T1], [false|T2], Result) ->getValidatedKeys(T1,T2,Result);
getValidatedKeys([H|T1], [_|T2], Result) ->getValidatedKeys(T1,T2,[H|Result]).
    
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
    
    
