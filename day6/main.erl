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

%% main()->
%%     io:fwrite("Solution part1: ~p~n",[sol1()]),
%%     io:fwrite("Solution part2: ~p~n",[sol2()]).

%% Correct: 6782
sol1(Fname)->
    Answers = getAnswearData(Fname),
    UniqeGroupAns = getUniqueQuestionData(mergeGroupData(Answers,[]),[]),
    sum(getStringLengths(UniqeGroupAns,[]),0).

%% Correct: 3596
sol2(Fname)->
    Answers = getAnswearData(Fname),
    Common=findAllCommonAnswers(Answers,[]),
    sum(getStringLengths(Common,[]),0).

findCommon([],_, Result)-> Result;
findCommon([H|T],List, Result)->
    IsCommon = isCharInAll(H,List),
    if
	IsCommon ->
	    findCommon(T,List,[H|Result]);
	true ->
	    findCommon(T,List,Result)
    end.

isCharInAll(_, [])-> true;
isCharInAll(Char, [H|T])-> 
    IsIn = lists:member(Char, H),
    if
	IsIn ->
	    isCharInAll(Char,T);
	true  ->
	    false
    end.
    
getShortestString([],Shortest) -> Shortest;
getShortestString([H|T],"") -> getShortestString(T,H);
getShortestString([H|T],Shortest) when length(H)<length(Shortest)->getShortestString(T,H);
getShortestString([_|T],Shortest) -> getShortestString(T,Shortest).
    
findCommonChars(StringList)->
    Shortest = getShortestString(StringList,""),
    findCommon(Shortest, StringList,[]).

findAllCommonAnswers([],Result) -> lists:reverse(Result);
findAllCommonAnswers([H|T],Result)->
    Common = findCommonChars(H),
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
