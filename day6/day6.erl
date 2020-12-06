-module(day6).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    

%% Correct: 892
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    Answers = getAnswearData(Fname),
    UniqeGroupAns = getUniqueQuestionData(mergeGroupData(Answers,[]),[]),
    sum(getStringLengths(UniqeGroupAns,[]),0).

sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    Answers = getAnswearData(Fname),
    Common=findAllCommonAnswers(Answers,[]),
    sum(getStringLengths(Common,[]),0).
    %% findCommonChars(lists:nth(1,Answers)).

findCommon([],_, Result)-> Result;
findCommon([H|T],List, Result)->
    IsCommon = isCharInAll(H,List),
    if
	IsCommon ->
	    findCommon(T,List,[H|Result]);
	true ->
	    findCommon(T,List,Result)
    end.
    %% io:fwrite("Char:~p ~p ~n",[H,Head]).

isCharInAll(Char, [])-> true;
isCharInAll(Char, [H|T])-> 
    IsIn = lists:member(Char, H),
    if
	IsIn ->
	    %% io:fwrite("Char: ~p String:~p is in:~p~n",[Char,H,IsIn]),
	    isCharInAll(Char,T);
	true  ->
	    false
    end.
    

getShortestString([],Shortest) -> Shortest;
getShortestString([H|T],"") -> getShortestString(T,H);
getShortestString([H|T],Shortest) when length(H)<length(Shortest)->getShortestString(T,H);
getShortestString([H|T],Shortest) -> getShortestString(T,Shortest).
    

findCommonChars(StringList)->
    Shortest = getShortestString(StringList,""),
    Common = findCommon(Shortest, StringList,[]),
    %% io:fwrite("Strings:~p~n",[StringList]),
    %% io:fwrite("Shortest: ~p~n",[Shortest]),
    %% io:fwrite("Common: ~p~n",[Common]),
    Common.


findAllCommonAnswers([],Result) -> lists:reverse(Result);
findAllCommonAnswers([H|T],Result)->
    Common = findCommonChars(H),
    io:fwrite("Answers:~p Common:~p~n",[H,Common]),
    findAllCommonAnswers(T,[Common|Result]).


sum([],Sum)->
    Sum;
sum([H|T],Sum) -> sum(T,Sum+H).

getStringLengths([],Result)->
    lists:reverse(Result);
getStringLengths([H|T], Result) -> getStringLengths(T,[length(H)|Result]).

getUniqueQuestionData([],Result)-> lists:reverse(Result);
getUniqueQuestionData([H|T],Result)->
    getUniqueQuestionData(T,[getUniqueChars(H)|Result]).

getUniqueChars(String)->
    getUniqueChars(lists:sort(String),[]).
getUniqueChars("",Result)->
    lists:reverse(Result);
getUniqueChars([H|T], [H|Result]) -> getUniqueChars(T,[H|Result]);
getUniqueChars([H|T],Result) -> getUniqueChars(T,[H|Result]).


mergeGroupData([],Result)->
    lists:reverse(Result);
mergeGroupData([H|T],Result) -> mergeGroupData(T,[mergeStringList(H,"")|Result]).


mergeStringList([],Result)->lists:reverse(Result);
mergeStringList([H|T],Result)->
    mergeStringList(T,H++Result).

getAnswearData(Fname)->
    Data = tools:readlines(Fname),
    combineGroupData(Data,[],[]).

combineGroupData([],Group,Result)->
    lists:reverse([Group|Result]);
combineGroupData([[]|T], Group,Result) -> combineGroupData(T,[],[Group|Result]);
combineGroupData([H|T],Group,Result) ->  combineGroupData(T,[H|Group],Result).
    
