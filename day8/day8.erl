-module(day8).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    
%% Correct: 6782
sol1()->
    Fname="input",
    %% Fname="example",
    Data = tools:readlines(Fname),
    Instructions = parseInstructions(Fname),
    Pcc=1,
    Executed = dict:new(),
    run(Instructions, Pcc, 0, Executed, 1).


%% run(Instructions, Pcc, Executed, Counter) when Pcc==580->
%%     io:fwrite("Counter: ~p Intruction:~p~n",[Counter, lists:nth(Pcc,Instructions)]);
run(Instructions, Pcc, Executed, Acc, Counter) when Counter>300->
    io:fwrite("Out of memory, return~n"),
    Pcc;
run(Instructions, Pcc, Acc, Executed, Counter) when Pcc>length(Instructions)->Pcc;
run(Instructions, Pcc, Acc, Executed, Counter)->
    Ins = lists:nth(Pcc,Instructions),
    io:fwrite("Instruction:~p Pcc:~p~n",[Ins,Pcc]),
    {Next, NewAcc}  = execute(Ins, Pcc, Acc),
    NewExecuted = dict:store(Pcc,true,Executed),
    IsExecuted = dict:find(Next,Executed)/=error,
    %% IsExecuted = false,
    if 
	not IsExecuted ->
	    io:fwrite("Instruction:~p Pcc:~p Next:~p Executed:~p Acc:~p~n",[Ins,Pcc,Next, dict:find(Next,Executed)/=error,Acc]),
	    run(Instructions,Next, NewAcc, NewExecuted, Counter+1);
	IsExecuted ->
	    io:fwrite("Instruction:~p Pcc:~p Next:~p Executed:~p~n",[Ins,Pcc,Next, dict:find(Next,Executed)]),
	    {Pcc,Acc}
    end.
    
execute({Ins,Arg}, Pcc, Acc) when Ins=="nop"-> {Pcc+1, Acc};
execute({Ins,Arg}, Pcc, Acc) when Ins=="acc"-> {Pcc+1, Acc+lists:nth(1,Arg)};
execute({Ins,Arg}, Pcc, Acc) when Ins=="jmp"-> {Pcc+lists:nth(1,Arg), Acc};
execute({Ins,Arg}, Pcc, Acc)->    
    io:fwrite("Execute:~p Arg:~p ~n",[Ins,Arg]),
    {Pcc+1,Acc}.

sol2()->
    Fname="input",
    Data = tools:readlines(Fname).

parseInstructions(Fname)->
    Lines = tools:readlines(Fname),
    parseInstructionList(Lines,[]).

parseInstructionList([],Result)-> lists:reverse(Result);
parseInstructionList([H|T], Result) ->
    RawIns = tools:split(H," "),
    Ins = parseInstruction(RawIns),
    parseInstructionList(T,[Ins|Result]).
    
parseInstruction([I|A])->
    Args = parseArgs(A,[]),
    {I,Args}.

parseArgs([],Result) -> lists:reverse(Result);
parseArgs([H|T],Result) -> 
    Arg = list_to_integer(H),
    %% io:fwrite("Arg:~p~n",[Arg]),
    parseArgs(T,[Arg|Result]).
    
    
