-module(day2).
-compile(export_all).

sol1()->
    Fname="input1.txt",
    Lines=readlines(Fname),
    PwdPolityList = splitPasswordPolies(Lines),
    NCorrect = countcorrectpasswords(PwdPolityList),
    io:fwrite("Solution 1: ~p~n",[NCorrect]).

sol2()->
    Fname="input1.txt",
    %% Fname="example.txt",
    Lines=readlines(Fname),
    PwdPolityList = splitPasswordPolies(Lines),
    NCorrect = countcorrectpasswordsV2(PwdPolityList),
    io:fwrite("Solution 2: ~p~n",[NCorrect]).

countcorrectpasswords(PwdPolityList)->
        countcorrectpasswords(PwdPolityList, 0).
countcorrectpasswords([], Count) -> Count;
countcorrectpasswords([H|T], Count) -> 
    IsCorrect = verifyPasswordPolicy(H),
    if
	IsCorrect ->
	    countcorrectpasswords(T, Count+1);
	true -> 
	    countcorrectpasswords(T, Count)
    end.

countcorrectpasswordsV2(PwdPolityList)->
        countcorrectpasswordsV2(PwdPolityList, 0).
countcorrectpasswordsV2([], Count) -> Count;
countcorrectpasswordsV2([H|T], Count) -> 
    IsCorrect = verifyPasswordPolicyV2(H),
    io:fwrite("~p ~p ~p ~n",[IsCorrect|H]),
    if
	IsCorrect ->
	    countcorrectpasswordsV2(T, Count+1);
	true -> 
	    countcorrectpasswordsV2(T, Count)
    end.

verifyPasswordPolicy(PwdPolList) ->
    verifyPassword(lists:nth(2, PwdPolList), lists:nth(1, PwdPolList)).

verifyPasswordPolicyV2(PwdPolList) ->
    verifyPasswordV2(lists:nth(2, PwdPolList), lists:nth(1, PwdPolList)).

verifyPassword(Pwd, RawPol)->
    Pol=extractPolicyString(RawPol),
    Count = countChar(Pwd,lists:nth(3,Pol)),
    verifyPolicy(lists:nth(1,Pol), lists:nth(2,Pol), Count).

verifyPasswordV2(Pwd, RawPol)->
    Pol=extractPolicyString(RawPol),
    Char = lists:nth(3,Pol),
    verifyPolicyV2(lists:nth(1,Pol), lists:nth(2,Pol), Char, Pwd).

verifyPolicy(MinStr, MaxStr, Count) ->
    Min = list_to_integer(MinStr),
    Max = list_to_integer(MaxStr),
    (Count=<Max) and (Count>=Min).

verifyPolicyV2(IndexStr1, IndexStr2, Char, Pwd) ->
    I1 = list_to_integer(IndexStr1),
    I2 = list_to_integer(IndexStr2),
    C = lists:nth(1,Char),
    (lists:nth(I1,Pwd)==C) xor (lists:nth(I2,Pwd)==C).
								

extractPolicyString(PolStr)->
    RawPol = split(PolStr," "),
    Char = lists:nth(2,RawPol),
    Limits = split(lists:nth(1,RawPol),"-"),
    [lists:nth(1,Limits), lists:nth(2,Limits), Char].

countChar(Str, Char)-> countChar(split(Str,""), Char, 0).
countChar([], Char, Count)-> Count;
countChar([H|T], Char, Count) when H==Char -> countChar(T, Char, Count+1);
countChar([H|T], Char, Count)-> 
    countChar(T, Char, Count).


cleanPolicy(Pol) -> cleanPolicy(Pol, []).
cleanPolicy([],Result) -> lists:reverse(Result); 
cleanPolicy([H|T], Result) when H==""; H==" "; H=="-" -> cleanPolicy(T, Result);
cleanPolicy([H|T],Result) -> cleanPolicy(T, [H|Result]). 

splitPasswordPolicy(PwdPol)->
    List = re:split(PwdPol,":"),
    StringList=binList2StrList(List),
    trimList(StringList).

splitPasswordPolies(List)-> splitPasswordPolies(List,[]).
splitPasswordPolies([],Result)-> lists:reverse(Result);
splitPasswordPolies([H|T],Result)->
    splitPasswordPolies(T,[splitPasswordPolicy(H)|Result]).

trimList(List)->
    trimList(List, []).
trimList([], Result)-> lists:reverse(Result);
trimList([H|T], Result)->
    trimList(T, [string:trim(H)|Result]).

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
