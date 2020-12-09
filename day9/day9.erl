-module(day9).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    
%% Correct:
sol2()->
    Fname="input",
    Data = tools:readlines(Fname).
    
    
%% Correct: 2089807806 
sol1()->
    %% Fname="example",
    Fname="input",
    N = 25,
    Data = tools:readlines(Fname),
    Numbers = tools:as_ints(Data),
    %% Tree = createTree(Numbers),
    {Pre, Rest} = lists:split(N, Numbers),
    io:fwrite("Pre:~p, Rest:~p~n",[Pre, Rest]),
    Result = checkValidXmasList(Pre, Rest, []),
    findFirstFalse(Result).
    %% {Preemble, NewTree} = popTree(N, Tree,[]),
    %% printTree(NewTree).

findFirstFalse([{Ok, Num}|T]) when not Ok -> Num;
findFirstFalse([H|T]) -> findFirstFalse(T). 
    
checkValidXmasList(Pre, [], Result)-> lists:reverse(Result);
checkValidXmasList([PreH|PreT], [H|T], Result) ->
    io:fwrite("Checking number:~p~n",[H]),
    Res = checkValid([PreH|PreT], H),
    checkValidXmasList(lists:append(PreT,[H]),T,[{Res, H}|Result]).
    
    

checkValid([], _)->false;
checkValid([H], _)->false;
checkValid([H|T], Num) ->
    Compliment = Num-H,
    io:fwrite("Having ~p, Looking for ~p~n",[H,Compliment]),
    IsMember = lists:member(Compliment, T),
    if
	IsMember->
	    true;
	true  ->
	    checkValid(T, Num)
    end.
    
popTree(N, Tree,Result) when N>length(Result)->
    {_, Value, NewTree} = gb_trees:take_smallest(Tree),
    popTree(N, NewTree, [Value|Result]);
popTree(_, Tree, Result) ->
    {lists:reverse(Result), Tree}.

printTree(Tree) ->
    IsEmpty = gb_trees:is_empty(Tree),
    printTree(Tree, IsEmpty).
printTree(Tree, IsEmpty) when IsEmpty->io:fwrite("Tree is empty~n");
printTree(Tree, _) ->
    {_, Value, NewTree} = gb_trees:take_smallest(Tree),
    io:fwrite("Next number:~p~n",[Value]),
    printTree(NewTree).

createTree(List)->
    createTree(List, gb_trees:empty()).
createTree([], Tree)->
    Tree;
createTree([H|T],Tree) -> createTree(T, gb_trees:insert(H,H,Tree)).

