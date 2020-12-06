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
    Data = tools:readlines(Fname).


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
    
