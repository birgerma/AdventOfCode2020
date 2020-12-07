-module(day7).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    
%% Correct: 6782
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    RuleList = parseLuggageRules(Data,[]),
    Colors = extract_indexes(1,RuleList,[]),
    isBagIn("shiny-gold", ["light-plum"],RuleList).
    %% RuleDict = rules2dict(RuleList,dict:new()),
    %% BigBag = "dim-purple",
    %% Bag = "shiny-gold",
    %% containsBag(Bag, BigBag, RuleDict).

isBagIn(Goal, [H|Rest] ,[H|T]) ->
    io:fwrite("Found:~p~n",[H]);
    %% isBagIn(Goal, [H|Rest] ,T);

isBagIn(Goal, [Current|Rest] ,[H|T]) ->
    io:fwrite("Rule:~p Current:~p~n",[H, Current]),
    FoundRule = lists:nth(1,H)==Current,
    if
	FoundRule ->
	    io:fwrite("Found a rule. Found goal:~p ~p~n",[lists:member(Goal,H), length(H)]),
	    GoalFound = lists:member(Goal,H),
	    if
		GoalFound ->
		    true;
		true ->
		    		
	true  ->
	    io:fwrite("Not found, continue~n")
    end.
    %% isBagIn(Goal, [Current|Rest] ,T).
    

%% Correct: 3596
sol2()->
    Fname="input",
    Data = tools:readlines(Fname).


remove_int([],Result) -> lists:reverse(Result);
remove_int([H|T],Result) when is_integer(H) ->
    remove_int(T, Result);
remove_int([H|T],Result) -> io:fwrite("Arg:~p~n",[H]),remove_int(T,[H|Result]).


as_list(ListString)->
    as_list(tools:split(ListString,","),[]).
as_list([H|T],Result)->
    io:fwrite("As list:~p, ~p~n",[H,T]).

containsBag(Bag, BigBag, RuleDict)->
    Contains = dict:fetch(BigBag, RuleDict),
    %% Bags = as_list(remove_int(Contains,[])),
    io:fwrite("Find bag:~p ~p ~p~n",[Bag, BigBag, length(Contains)]).

extract_indexes(_,[],Result)->lists:reverse(Result);
extract_indexes(Index, [H|T], Result) -> extract_indexes(Index,T,[lists:nth(Index,H)|Result]).
    

rules2dict([],Dict) ->
    Dict;
rules2dict([H|T],Dict) ->
    %% io:fwrite("Rule:~p~n",[H]),
    rules2dict(T,appendRule(H,Dict)).

appendRule([H|T], Dict)->
    dict:append(H,T, Dict).


parseLuggageRules([],Result)-> lists:reverse(Result);
parseLuggageRules([H|T],Result)->
    Rule = parseRule(tools:split(H," ")),
    %% io:fwrite("Parsed rule:~p~n",[Rule]),
    parseLuggageRules(T, [Rule|Result]).


parseRule([]) -> [];
parseRule(Rule) -> 
    %% io:fwrite("Rule:~p~n",[Rule]),
    Filtered = filterRule(Rule,[]),
    %% Color = pop(Rule,2),
    %% io:fwrite("Filtered rule: ~p~n",[Filtered]),
    Parsed = parseColor(Filtered,[]).
    %% parseRule(T,Result).

parseColor([C1,C2|T],Result)->
    Color = C1++"-"++C2,
    parseNum(T,[Color|Result]).

parseNum([],Result)-> lists:reverse(Result);
parseNum([N|T],Result) when N=="no" -> lists:reverse([0|Result]);
parseNum([N|T],Result)->
    parseColor(T, [list_to_integer(N)|Result]).

filterRule([],Result) -> lists:reverse(Result);
filterRule([H|T],Result) when H/="bags",H/="bag",H/="bag.",H/="bag,",H/="bags,",H/="bags.",H/="contain"->
    filterRule(T, [H|Result]);
filterRule([H|T],Result) ->
    filterRule(T, Result).

    
%% pop(List, N)->
%%     pop(List, N, []).
%% pop([],_,Result) ->
%%     lists:reverse(Result);
%% pop([H|T],N,Result) when N>0 -> pop(T,N-1,[H|Result]);
%% pop(_,0,Result) -> lists:reverse(Result).
