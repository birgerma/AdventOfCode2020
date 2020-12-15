-module(main).
-compile(export_all).

-import('tools', [readlines/1]).

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

    io:fwrite("Solution part1 (Time:~f ms): ~p~n", [Time1, Sol1]),
    io:fwrite("Solution part2 (Time:~f ms): ~p~n", [Time2, Sol2]),
    io:fwrite("Total execution time: ~f ms~n", [Total]).

%% 216 correct
sol1(Fname)->
    Data = readPassports(Fname),
    Valid = checkValidPassports(Data, []),
    tools:countElements(Valid, true).

%% 150 correct
sol2(Fname)->
    Data = readPassports(Fname),
    Valid = checkValidPassports(Data, []),
    Validated = getValidatedKeys(Data, Valid, []),
    Correct = validateData(Validated,[]),
    length(Correct).

validateData([],Result)->lists:reverse(Result);
validateData([H|T], Result) ->
    IsValid = isValidData(H),
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
    if
	IsValid ->
	    isValidData(T);
	true ->
	    false
    end.

correctLength(Data,L)->
    length(Data)==L.

correctRange(Num, Min, Max)->
    (Num>=Min) and (Num=<Max).

isDataValid("byr",Data)->
    correctLength(Data,4) and correctRange(list_to_integer(Data), 1920, 2002);
isDataValid("iyr",Data)->
    correctLength(Data,4) and correctRange(list_to_integer(Data), 2010, 2020);
isDataValid("eyr",Data)->
    correctLength(Data,4) and correctRange(list_to_integer(Data), 2020, 2030);

isDataValid("hgt",Data)->
    {Height, Suffix} = extractHeight(Data,[],[]),
    isValidHeight(Height, Suffix);
isDataValid("hcl",Data)->
    isValidHairColor(Data);
isDataValid("ecl",Data)->
    Colors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
    lists:member(Data,Colors);
isDataValid("pid",Data)->
    Res = re:run(Data, "^\\d{9}$"),
    (Res/=nomatch);
isDataValid(_,_)-> true.

isValidHairColor(Color)->
    Res = re:run(Color, "^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$"),
    (Res/=nomatch).

splitInTwo(List,Head) when length(Head)>=length(List) ->
    [Head, lists:reverse(List)];
splitInTwo([H|T], Head) -> splitInTwo(T, [H|Head]).

extractHeight([],Num,Unit) -> 
    Value = lists:reverse(Num),
    Suffix = lists:reverse(Unit),
    {list_to_integer(Value),Suffix};
extractHeight([H|T],Num,Unit) when H==$c;H==$m;H==$i;H==$n-> 
    extractHeight(T, Num, [H|Unit]);
extractHeight([H|T],Num,Unit) ->
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
    {ok, Raw_Data} = file:read_file(Fname),
    StrList = re:split(Raw_Data,"\n"),
    List=tools:binList2StrList(StrList),
    combineEntries(List,[], []).

combineEntries([],[],Result) ->
    lists:reverse(Result);
combineEntries([],Current,Result) ->
    combineEntries([], [], [Current|Result]);
combineEntries([[]|T], Current, Result) -> 
    combineEntries(T, [], [Current|Result]);
combineEntries([H|T], Current, Result) -> 
    Pass=tools:split(H," "),
    Combined = Current++Pass,
    combineEntries(T, Combined, Result).

checkValidPassports([], Result)-> lists:reverse(Result);
checkValidPassports([H|T], Result) -> checkValidPassports(T, [isValid(H)|Result]).

isValid(Pass)->
    if 
	length(Pass)<7->
	    false;
	true  ->
	    hasAllKeys(Pass)
    end.

hasAllKeys(Pass)->
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
