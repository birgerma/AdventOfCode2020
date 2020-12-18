-module(main).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    Start1 = os:timestamp(),
    Sol1 = sol1(),
    Start2 = os:timestamp(),
    Sol2 = sol2(),
    EndTime = os:timestamp(),
    Time1 = timer:now_diff(Start2, Start1)/1000,
    Time2 = timer:now_diff(EndTime, Start2)/1000,
    Total = timer:now_diff(EndTime, Start1)/1000,

    io:fwrite("Solution part1 (Time:~f ms): ~p~n", [Time1, Sol1]),
    io:fwrite("Solution part2 (Time:~f ms): ~p~n", [Time2, Sol2]),
    io:fwrite("Total execution time: ~f ms~n", [Total]).
    
%% Correct: 
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    Equations = formatData(Data,[]),
    Solutions = evaluate_adv_equations(Equations,[]),
    lists:sum(Solutions).

%% Correct: 
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    Equations = formatData(Data,[]),
    Solutions = evaluate_equations(Equations,[]),
    lists:sum(Solutions).

test()->
    Fname="example",
    Fname="example",
    Data = tools:readlines(Fname),
    Equations = formatData(Data,[]),
    Solutions = evaluate_adv_equations(Equations,[]).


test2()->
    Fname="example",
    Data = tools:readlines(Fname),
    Equations = formatData(Data,[]),
    Equation = lists:nth(6,Equations),
    Solutions = evaluate_adv_equations(Equations,[]).

       
    %% Solutions = evaluate_equations(Equations,[]).


%% insertPar([],Rest,Par)->
%%     %% io:fwrite("At end, insert at beginning (~p)~n", [[Par|Rest]]),
%%     lists:reverse([Par|Rest]);
%% insertPar(["("|T],Rest,Par)-> insertAfterRight(["("|T],Rest,Par)
%% insertPar([A,Op|T],Rest,Par) when Op=="*";Op=="-";Op=="+"->
%%     io:fwrite("Fond operator ~p ~p ~p~n",[A,Op,T]),
%%     [A,Par,Op|T];

%% insertPar([H|T],Rest,Par)->
%%     io:fwrite("Nothing found, continue~n"),
%%     insertPar(T,[H|Rest],Par).


findLeftTerm(Eq)->
    findLeftTerm(Eq,[],0).
findLeftTerm([],Rest,_) -> Rest;
findLeftTerm([A],[],_) -> A;
findLeftTerm([A,Op|T],Rest, 0) when Op=="*";Op=="-";Op=="+" -> 
    %% io:fwrite("Found term: ~p ~p ~p ~n",[A,Op,T]),
    Term = [A|Rest],
    %% io:fwrite("Left term: ~p ~n",[Term]),
    %% io:fwrite("Rest: ~p~n",[[Op|T]]),
    {Term, [Op|T]}.


findRightTerm(Eq)->
    findRightTerm(Eq,[],0).
findRightTerm([],Rest,_) -> Rest;
findRightTerm([A],[],_) -> A;
findRightTerm([")"|T],Rest, Par)->
    findRightTerm(T,[")"|Rest], Par-1);
findRightTerm(["("|T],Rest, Par)->
    findRightTerm(T,["("|Rest], Par+1);
findRightTerm([A,Op|T],Rest, 0) when Op=="*";Op=="-";Op=="+" -> 
    io:fwrite("Found term: ~p ~p ~p ~n",[A,Op,T]),
    Term = [A|Rest],
    io:fwrite("Right term: ~p ~n",[Term]),
    io:fwrite("Rest: ~p~n",[[Op|T]]),
    {Term, [Op|T]};
findRightTerm([H|T],Rest, Par)->
    findRightTerm(T,[H|Rest], Par).

convertAdvanced(List)-> convertAdvanced([], List).    
convertAdvanced(Left, []) ->
    lists:reverse(Left);
convertAdvanced(Left, ["+"|T]) ->
    {Term, Rest} = findLeftTerm(Left),
    NewLeft = lists:append([Term,["("],Rest]),
    io:fwrite("New Left: ~p~n",[lists:reverse(NewLeft)]),
    Right = findRightTerm(T);

    %% io:fwrite("Fond plus, insert parenthesis~n"),
    %% NewLeft = ["+"|insertPar(Left,[],"(")],
    %% io:fwrite("Init tail: ~p~n",[T]),
    %% NewRight = insertPar(T,[],")"),
    %% io:fwrite("New Left: ~p~n",[NewLeft]),
    %% io:fwrite("New Right: ~p~n",[NewRight]),
    %% Total = lists:append([lists:reverse(NewLeft),NewRight]),
    %% io:fwrite("New total:~p",[Total]),
    %% convertAdvanced(NewLeft, NewRight);

convertAdvanced(Left, [H|T]) ->
    io:fwrite("Left:~p Char:~p Right:~p ~n",[Left, H, T]),
    convertAdvanced([H|Left], T).


list_to_eq([],Result)->
    lists:reverse(Result);
list_to_eq([P|T],Result) when P=="(";P==")"-> 
    %% io:fwrite("Found (~n"),
    list_to_eq(T, [P|Result]);
list_to_eq(["+"|T],Result) ->list_to_eq(T, ["+"|Result]);
list_to_eq(["-"|T],Result) ->list_to_eq(T, ["-"|Result]);
list_to_eq(["*"|T],Result) ->list_to_eq(T, ["*"|Result]);
list_to_eq([H|T],Result) -> 
    %% io:fwrite("Head:~p~n",[H]),
    Parenthesis = (lists:member($(,H) or lists:member($),H)),
    if
	Parenthesis->
	    Entry = tools:split(H,""),
	    list_to_eq(lists:append(Entry, T), Result);
	true ->
	    list_to_eq(T, [list_to_integer(H)|Result])
    end.


remove_space(Str)->
    remove_space(Str,[]).
remove_space([],Result)->lists:reverse(Result); 
remove_space([32|T],Result)->remove_space(T,Result); %% Remove 
remove_space([H|T],Result)->remove_space(T,[H|Result]).

evaluate_adv_equations([],Result) ->
    lists:reverse(Result);
evaluate_adv_equations([H|T],Result) ->
    evaluate_adv_equations(T,[evalAdv(H,[])|Result]).

evaluate_equations([],Result) ->
    lists:reverse(Result);
evaluate_equations([H|T],Result) ->
    evaluate_equations(T,[eval(H)|Result]).


eval([Res])-> Res;
eval([A,Op,"("|T]) -> 
    %% io:fwrite(" start par ~n"), 
    %% Res = eval(T),
    %% io:fwrite("Here we are 1!~n"),
    eval([A,Op|eval(T)]);
    %% compute(A,Op, eval(T));
    %% io:fwrite("Res:~p~n",[Res]),
    %% eval(T);
eval(["("|T]) -> 
    %% io:fwrite("First entry is patenthesis~n"),
    %% eval(T),
    %% Res = eval(T),
    %% io:fwrite("Here we are 2!~n"),
    eval(eval(T));

eval([A,")"|T]) -> 
    %% io:fwrite("Done computing parenthesis"),
    %% io:fwrite(" ~p stop par ~n",[A]), 
    %% io:fwrite("Rest:~p",[[A|T]]),
    [A|T];
eval([A,Op,B|T])->
    %% io:fwrite("Compute stuff~n"),
    Res = compute(A,Op,B),
    %% io:fwrite("Char:~p~n",[$0]),
    %% io:fwrite("Compute: ~p ~p ~p= ~p~n ",[A,Op,B,Res]),
    eval([Res|T]);
eval([H|T])->
    io:fwrite(" No match:~p~n ",[H]).

mult([],Result)->Result;
mult([H|T],Result)->
    mult(T,Result*H).


evalAdv2([],Rest)->
    io:fwrite("Done Rest: ~p~n",[lists:reverse(Rest)]);
evalAdv2([A,"+",B|T],Rest) when is_integer(A), is_integer(B) ->
    Res = compute(A,"+",B),
    io:fwrite("Found plus term: ~p ~p ~p=~p ~n",[A,"+",B,Res]),
    evalAdv2([Res|T],Rest);
evalAdv2([H|T],Rest) ->
    io:fwrite("Current ~p~n",[[H|T]]),
    evalAdv2(T,[H|Rest]).


evalAdv([Res],Result)-> 
    io:fwrite("Done: Res: ~p Result:~p~n",[Res,Result]),
    Rest = [Res|Result],
    io:fwrite("Compute mult:~p~n",[Rest]),
    eval([Res|Result]);
evalAdv([A,Op,"("|T],Result) -> 
    io:fwrite("Evaluate brackets 2~n"),
    Res = evalAdv(T,[]),
    io:fwrite("Bracket res:~p~n",[Res]),
    %% evalAdv([A,Op|evalAdv(T,[])],Result);
    evalAdv([A,Op|Res],Result);
evalAdv(["(",A,")"|T],Result)->
    evalAdv([A|T],Result);
evalAdv([A,"+",B|T],Result)->
    Res = compute(A,"+",B),
    evalAdv([Res|T],Result);
evalAdv(["(",A,"+",B,")"|T],Result)->
    Res = compute(A,"+",B),
    evalAdv([Res|T],Result);
evalAdv(["(",A,"*",B,")"|T],Result)->
    io:fwrite("Here we are neio!~n"),
    io:fwrite("(~p * ~p) ~n",[A,B]),
    Res = compute(A,"*",B),
    evalAdv([Res|T],Result);
evalAdv(["("|T],Result) ->
    io:fwrite("Evaluate brackets 1~n"),
    evalAdv(evalAdv(T,[]),Result);
evalAdv([A,")"|T],Result) ->
    Rest = [A|Result],
    io:fwrite("Ending bracket: A=~p T=~p Result=~p Rest:~p~n",[A,T,Result,Rest]),
    Ret = lists:append([["("],Rest,[")"]]),
    NoAdd = (not lists:member("+",Ret)),
    Res = eval(Ret),
    io:fwrite("To return:~w NoAdd:~p Res:~p~n",[Ret,NoAdd, Res]),
    if 
	NoAdd->
	    [eval(Ret)|T];
	true->
	    [evalAdv(Ret,[])|T]
    end;
    %% [evalAdv(Ret,[])|T];

    %% evalAdv(lists:append(["(",Rest,T,")"]),[]);
    %% lists:append(Rest,T);
    %% [A|T];
evalAdv([A,"*"|T],Result)->
    io:fwrite("Found *, saving ~p ~p ~n", [A,"*"]),
    evalAdv(T,["*",A|Result]);
evalAdv([A,Op,B|T],Result)->
    io:fwrite("Computing: A=~p Op=~p B=~p Tail=~p Result=~p~n",[A,Op,B,T,Result]),
    Res = compute(A,Op,B),
    evalAdv([Res|T],Result);
evalAdv([H|T],Result)->
    io:fwrite(" No match:~p~n ",[H]).

%% evaluateComputations([H|T],Result)->
%%     Res = evaluateComputation(H,[]).
    %% evaluateComputations([H|T],[Res|Result])->
compute(A,"+",B)->
    A+B;
compute(A,"-",B)->
    A-B;
compute(A,"*",B)->
    A*B.



%% evaluateComputation([],Result)-> lists:reverse(Result);
%% evaluateComputation([A,Op,B],Result)-> 
%%     io:fwrite("End computation ~p ~c ~p = ~p~n",[A,Op,B,eval(A,Op,B)]),
%%     eval(A,Op,B);
%% evaluateComputation([A,Op|T],Result)->
%%     %% io:fwrite("Head:~p ~c ~p=~n",[A,Op,evaluateComputation(T,Result)]),
%%     eval(A,Op,evaluateComputation(T,Result)).


%% eval(A,$+,B)-> 
%%     io:fwrite("~p+~p~n",[A,B]),
%%     A+B;
%% eval(A,$-,B)-> 
%%     io:fwrite("~p-~p~n",[A,B]),
%%     A-B;
%% eval(A,$*,B)-> 
%%     io:fwrite("~p*~p~n",[A,B]),
%%     A*B.
    
formatData([],Result)-> lists:reverse(Result);
formatData([Line|T],Result)->
    Equation = list_to_eq(tools:split(Line," "),[]),
    formatData(T, [Equation|Result]).


formatLine([],Result)-> Result;%%lists:reverse(Result);
formatLine([$+|T],Result)-> formatLine(T,[$+|Result]);
formatLine([$-|T],Result)-> formatLine(T,[$-|Result]);
formatLine([$*|T],Result)-> formatLine(T,[$*|Result]);
formatLine([$(|T],Result)-> formatLine(T,[$(|Result]);
formatLine([$)|T],Result)-> formatLine(T,[$)|Result]);
formatLine([32|T],Result)-> formatLine(T,Result);
formatLine([H|T],Result)->
    formatLine(T,[char_to_int(H)|Result]).

char_to_int($0) -> 0;
char_to_int($1) -> 1;
char_to_int($2) -> 2;
char_to_int($3) -> 3;
char_to_int($4) -> 4;
char_to_int($5) -> 5;
char_to_int($6) -> 6;
char_to_int($7) -> 7;
char_to_int($8) -> 8;
char_to_int($9) -> 9;
char_to_int(C) -> io:fwrite("Error:~p",[C]),error.
