-module(assembler).
-compile(export_all).

-import('tools', [readlines/1]).

sol1()->
    Fname="example", %% Correct: 1816
    Data = tools:readlines(Fname),
    Instructions = parseInstructions(Fname),
    Executed = dict:new(),
    State = getInitState(),
    FinalState = run(Instructions, 1, State, Executed, []),
    FinalState.

getInitState()->
    States = [{"Pcc",1}, {"Acc", 0}],
    dict:from_list(States).
%% Correct: 1149
%% sol2()->
%%     Fname="input",
%%     Data = tools:readlines(Fname),
%%     Instructions = parseInstructions(Fname),
%%     {Pcc, Acc} = correctCode(Instructions,Instructions,1),
%%     Acc.

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
    {-1, SwitchIndex}.
%% correctCode(OriginalInstructions, Instructions, SwitchIndex) ->
%%     Executed = dict:new(),
%%     {Pcc, Acc} = run(Instructions, 1, 0, Executed, 1),
%%     if
%% 	Pcc<length(Instructions)->
%% 	    NewInstructions = swapJmpNop(OriginalInstructions, SwitchIndex, []),
%% 	    correctCode(OriginalInstructions,NewInstructions, SwitchIndex+1);
%% 	true  ->
%% 	    {Pcc, Acc}
%%     end.

run(Instructions, Pcc, State, Executed, History) when length(History)>10->
    io:fwrite("Out of memory, return~n"),
    io:fwrite("History:~p~n",[History]),
    State;
%% run(Instructions, State, Executed, History) when >length(Instructions)->State;
run(Instructions, Pcc, State, Executed, History)->
    %% Pcc = dict:fetch("Pcc",State),
    Acc = dict:fetch("Acc",State),
    Ins = lists:nth(Pcc,Instructions),
    {Next, NewState}  = execute(Ins, Pcc, State),
    NewExecuted = dict:store(Pcc,true,Executed),
    IsExecuted = dict:find(Next,Executed)/=error,
    io:fwrite("Run instruction:~p ~p~n",[Ins,Next]),
    if 
	not IsExecuted ->
	    %% NewState = dict:store("Acc", NewAcc, State),
	    run(Instructions, Next, NewState, NewExecuted, [[Pcc,Ins]|History]);
	IsExecuted ->
	    {Pcc,State}
    end.
    
execute({Ins,Arg}, Pcc, State) when Ins=="nop"-> {Pcc+1, State};
execute({Ins,Arg}, Pcc, State) when Ins=="acc"-> 
    Acc = dict:fetch("Acc", State)+lists:nth(1,Arg),
    NewState = dict:store("Acc",Acc, State),
    {Pcc+1, NewState};
execute({Ins,Arg}, Pcc, State) when Ins=="jmp"-> {Pcc+lists:nth(1,Arg), State};
execute({Ins,Arg}, Pcc, State)->    
    {Pcc+1,State}.

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
    
    
