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
    %% Test = os:timestamp(),
    %% MeanETime1 = tools:etimeMs(fun()-> sol1()end, 1000),
    %% MeanETime2 = tools:etimeMs(fun()-> sol2()end, 1000),
    %% io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime1]),
    %% io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime2]).
    
    
%% Correct: 
%% Incorrect: 32769
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    {{Name1, Deck1}, {Name2, Deck2}} = formatPlayerData(Data),
    %% {R1, R2} = playRecursive(Deck1,Deck2),
    {R1, R2} = playRecursive(Deck1,Deck2),
    
    P1_is_winner = (length(R1)>length(R2)),
    if
	P1_is_winner->
	    Loser = R2,
	    Winner = R1;
	true ->
	    Loser = R1,
	    Winner = R2
    end,
    io:fwrite("Winner deck~p~n",[Winner]),
    io:fwrite("Loser deck:~p~n", [Loser]),

    computeScore(Winner,length(Winner),0).

%% Correct: 32677
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    {{Name1, Deck1}, {Name2, Deck2}} = formatPlayerData(Data),
    {R1, R2} = play(Deck1,Deck2),
    P1_is_winner = (length(R1)>length(R2)),
    if
	P1_is_winner->
	    Winner = R1;
	true ->
	    Winner = R2
    end,
    io:fwrite("Winner deck~p~n",[Winner]),
    computeScore(Winner,length(Winner),0).

testScore()->
    Deck = [37,21,45,33,9,7,48,18,29,3,44,22,41,8,47,32,43,4,35,26,24,19,34,28,17,5,11,2,27,20,50,46,15,14,36,23,12,10,39,16,31,13,30,6,25,1,49,42,40,38],
    computeScore(Deck,length(Deck),0).

test1()->
    Fname="example",
    Data = tools:readlines(Fname),
    {{Name1, Deck1}, {Name2, Deck2}} = formatPlayerData(Data),
    {R1, R2} = play(Deck1,Deck2),
    P1_is_winner = (length(R1)>length(R2)),
    if
	P1_is_winner->
	    Loser = R2,
	    Winner = R1;
	true ->
	    Loser = R1,
	    Winner = R2
    end,
    io:fwrite("Winner deck~p~n",[Winner]),
    io:fwrite("Loser deck:~p~n", [Loser]),
    computeScore(Winner,length(Winner),0).
    

test2()->
    Fname="example",
    Data = tools:readlines(Fname),
    {{Name1, Deck1}, {Name2, Deck2}} = formatPlayerData(Data),
    %% {R1, R2} = playRecursive(Deck1,Deck2),
    {R1, R2} = playRecursive(Deck1,Deck2),
    
    P1_is_winner = (length(R1)>length(R2)),
    if
	P1_is_winner->
	    Winner = R1;
	true ->
	    Winner = R2
    end,
    io:fwrite("Winner deck~p~n",[Winner]),
    computeScore(Winner,length(Winner),0).
    

print(String)->
    print(String,true).
print(String,true)->
    io:fwrite(String);
print(String,false)-> ok;
print(String, Args)->
    print(String,Args,true).
print(String, Args, false)-> ok;
print(String, Args, true)-> io:fwrite(String,Args).
    
playRecursive(Deck1,Deck2)->
    playRecursive(Deck1,Deck2, [], [], dict:new(),1).
playRecursive(Deck1,Deck2, Stack1, Stack2, Memory, Round) when Round<0->
    {Deck1++lists:reverse(Stack1), Deck2++lists:reverse(Stack2)};
playRecursive([],Deck2, [], Stack2, Memory, Round)->
    %% io:fwrite("Player 1 lost~n"),
    {[], Deck2++lists:reverse(Stack2)};
playRecursive(Deck1,[], Stack1, [], Memory, Round)->
    %% io:fwrite("Player 2 lost~n"),
    {Deck1++lists:reverse(Stack1),[]};
playRecursive([],Deck2, Stack1, Stack2, Memory, Round)->
    playRecursive(lists:reverse(Stack1),Deck2, [], Stack2, Memory, Round);
playRecursive(Deck1,[], Stack1, Stack2, Memory, Round)->
    %% io:fwrite("Turn player 2:s deck~n"),
    playRecursive(Deck1, lists:reverse(Stack2), Stack1, [], Memory, Round);
playRecursive(Deck1,Deck2, Stack1, Stack2, Memory, Round)->
    ShouldPrint = false,
    print("Round:~p~n",[Round],ShouldPrint),
    print("Player 1's deck: ~w~w~n",[Deck1,lists:reverse(Stack1)],ShouldPrint),
    print("Player 2's deck: ~w~w~n",[Deck2,lists:reverse(Stack2)],ShouldPrint),
    GameState = lists:append([Deck1++lists:reverse(Stack1)],[Deck2++lists:reverse(Stack2)]),
    Exists = dict:is_key(GameState,Memory),
    print("GameState:~p ~nExists:~p~n",[GameState,Exists],ShouldPrint),
    if
	Exists->
	    print("Player 1 win because of rcursive inf~n",ShouldPrint),
	    {Deck1++lists:reverse(Stack1),[]};
	true ->
	    NewMem = dict:store(GameState, true, Memory),
	    dict:fetch(GameState,NewMem),
	    [H1|T1] = Deck1,
	    [H2|T2] = Deck2,
	    NCardsP1 = length(T1)+length(Stack1),
	    NCardsP2 = length(T2)+length(Stack2),
	    StartRecursive = ((NCardsP1>=H1) and (NCardsP2>=H2)),
	    print("n cards p1:~p H1=~p RecOk:~p ~n",[NCardsP1,H1, (NCardsP1>=H1)],ShouldPrint),
	    print("n cards p2:~p H2=~p RecOk:~p ~n",[NCardsP2,H2,(NCardsP2>=H2)],ShouldPrint),
	    if 
		StartRecursive ->
		    print("Should start a recursive game:~p~n",[StartRecursive],ShouldPrint),
		    print("H1=~p, n(T1)=~p H2=~p n(T2)=~p~n",[H1,NCardsP1,H2, NCardsP2],ShouldPrint),
		    print("P1 deck:~p~n",[T1++lists:reverse(Stack1)],ShouldPrint),
		    RecDeck1 = takeNFromList(H1,T1++lists:reverse(Stack1),[]),
		    RecDeck2 = takeNFromList(H2,T2++lists:reverse(Stack2),[]),
		    {Res1, Res2} = playRecursive(RecDeck1,RecDeck2, [], [], dict:new(),1),
		    P1_is_winner = (length(Res1)>length(Res2)),
		    print("Recursive game over, P1 won:~p~n",[P1_is_winner],ShouldPrint);
		true ->
		    print("Play classic game~n",ShouldPrint),
		    P1_is_winner = (H1>H2)
	    end,
	    if
	        P1_is_winner ->
		    playRecursive(T1,T2, [H2,H1|Stack1], Stack2, NewMem, Round+1);
		true ->
		    playRecursive(T1,T2, Stack1, [H1,H2|Stack2], NewMem, Round+1)
	    end

    end.
    %% GameState.

takeNFromList(0,_,Res)-> lists:reverse(Res);
takeNFromList(N,[H|T],Res)->
    takeNFromList(N-1,T,[H|Res]).

computeScore([],Factor,Score)->Score;
computeScore([C|T],Factor,Score)->
    %% io:fwrite("Compute ~p*~p Sum=~p~n",[Factor, C, Score]),
    computeScore(T,Factor-1,Score+(C*Factor)).

play(Deck1,Deck2)->
    io:fwrite("Deck1:~p~n",[Deck1]),
    io:fwrite("Deck2:~p~n",[Deck2]),
    play(Deck1, Deck2, [], []).

play([], Deck2, [], Stack2) ->
    io:fwrite("Player 1 lost~n"),
    io:fwrite("Player 2s deck:~p ~p~n",[Deck2, lists:reverse(Stack2)]),
    {[],Deck2++lists:reverse(Stack2)};
play(Deck1, [], Stack1, []) ->
    io:fwrite("Player 2 lost~n"),
    io:fwrite("Player 1s deck:~p ~p~n",[Deck1,Stack1]),
    {Deck1++lists:reverse(Stack1),[]};
play(Deck1, [], Stack1, Stack2) ->
    io:fwrite("Turn player 2s deck:~p~n",[Stack2]),
    play(Deck1, lists:reverse(Stack2), Stack1, []);
play([], Deck2, Stack1, Stack2) ->
    io:fwrite("Turn player 1s deck:~p~n",[Stack1]),
    play(lists:reverse(Stack1), Deck2, [], Stack2);

play([H1|T1], [H2|T2], Stack1, Stack2) when H1>H2->
    io:fwrite("Player1 wins (~p ~p)~n",[H1,H2]),
    play(T1, T2, [H2,H1|Stack1], Stack2);
play([H1|T1], [H2|T2], Stack1, Stack2) when H2>H1->
    io:fwrite("Player2 wins (~p ~p)~n",[H1,H2]),
    play(T1, T2, Stack1, [H1,H2|Stack2]).

formatPlayerData(Data)->
    {L1, L2} = splitOnEmpty(Data,[]),
    {createPlayerDeck(L1),createPlayerDeck(L2)}.
    %% Res = splitOnEmpty(Data,[]).

createPlayerDeck([Name|Deck])->
    {Name, tools:as_ints(Deck)}.
    

splitOnEmpty([[]|T],Result)->
    %% io:fwrite("Found split~n"),
    {lists:reverse(Result),T};
splitOnEmpty([H|T],Result)->
    splitOnEmpty(T,[H|Result]).
    
