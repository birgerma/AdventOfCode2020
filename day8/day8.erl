-module(day8).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    io:fwrite("Solution part1: ~p~n",[sol1()]),
    io:fwrite("Solution part2: ~p~n",[sol2()]).
    
%% Correct: 1816
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    Instructions = parseInstructions(Fname),
    Executed = dict:new(),
    {Pcc, Acc} = run(Instructions, 1, 0, Executed, 1),
    Acc.

%% Correct: 1149
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    Instructions = parseInstructions(Fname),
    {Pcc, Acc} = correctCode(Instructions,Instructions,1),
    Acc.

findNextJmpNop([],Index,Head)->
    lists:reverse(Head);
findNextJmpNop([H|T],Index,Head) when Index>1 -> 
    findNextJmpNop(T, Index-1, [H|Head]);
findNextJmpNop([{Ins, Arg}|T], Index, Head) when Ins=="nop"-> 
    Top = lists:reverse(Head),
    Bottom = [{"jmp",Arg}|T],
    lists:append(Top,Bottom);
findNextJmpNop([{Ins, Arg}|T], Index, Head) when Ins=="jmp"-> 
    Top = lists:reverse(Head),
    Bottom = [{"nop",Arg}|T],
    lists:append(Top,Bottom);
findNextJmpNop([H|T], Index, Head) ->
    findNextJmpNop(T, Index-1, [H|Head]).

swapJmpNop(Instructions, Index, Prev)->
    findNextJmpNop(Instructions,Index,[]).
    	      
correctCode(OriginalInstructions, Instructions, SwitchIndex) when SwitchIndex>length(Instructions)->
    io:fwrite("NOT FOUND ~n",[]),
    {-1, SwitchIndex};
correctCode(OriginalInstructions, Instructions, SwitchIndex) ->
    Executed = dict:new(),
    {Pcc, Acc} = run(Instructions, 1, 0, Executed, 1),
    if
	Pcc<length(Instructions)->
	    NewInstructions = swapJmpNop(OriginalInstructions, SwitchIndex, []),
	    correctCode(OriginalInstructions,NewInstructions, SwitchIndex+1);
	true  ->
	    {Pcc, Acc}
    end.

run(Instructions, Pcc, Executed, Acc, Counter) when Counter>300->
    io:fwrite("Out of memory, return~n"),
    {Pcc, Acc};
run(Instructions, Pcc, Acc, Executed, Counter) when Pcc>length(Instructions)->{Pcc,Acc};
run(Instructions, Pcc, Acc, Executed, Counter)->
    Ins = lists:nth(Pcc,Instructions),
    {Next, NewAcc}  = execute(Ins, Pcc, Acc),
    NewExecuted = dict:store(Pcc,true,Executed),
    IsExecuted = dict:find(Next,Executed)/=error,
    if 
	not IsExecuted ->
	    run(Instructions,Next, NewAcc, NewExecuted, Counter+1);
	IsExecuted ->
	    {Pcc,Acc}
    end.
    
execute({Ins,Arg}, Pcc, Acc) when Ins=="nop"-> {Pcc+1, Acc};
execute({Ins,Arg}, Pcc, Acc) when Ins=="acc"-> {Pcc+1, Acc+lists:nth(1,Arg)};
execute({Ins,Arg}, Pcc, Acc) when Ins=="jmp"-> {Pcc+lists:nth(1,Arg), Acc};
execute({Ins,Arg}, Pcc, Acc)->    
    {Pcc+1,Acc}.

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
    parseArgs(T,[Arg|Result]).
    
    
