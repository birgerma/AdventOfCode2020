-module(main).
-compile(export_all).

-import('tools', [readlines/1]).

main()->
    Start1 = os:timestamp(),
    Sol1 = sol1(),
    Start2 = os:timestamp(),
    Sol2 = sol2(),
    EndTime = os:timestamp(),
    Time1 = timer:now_diff(Start2, Start1)/1000000,
    Time2 = timer:now_diff(EndTime, Start2)/1000000,
    Total = timer:now_diff(EndTime, Start1)/1000000,

    io:fwrite("Solution part1 (Time:~f sec): ~p~n", [Time1, Sol1]),
    io:fwrite("Solution part2 (Time:~f sec): ~p~n", [Time2, Sol2]),
    io:fwrite("Total execution time: ~f sec~n", [Total]).
    
%% Correct: 26988
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    {Rules, Ticket, Nearby} = parseRawData(Data),
    Nearby,
    Flatten = lists:flatten(Nearby),
    Valid = checkEntries(Flatten, Rules,[]),
    InvalidEntries = bool_filter(Flatten, bool_invert(Valid,[])),
    lists:sum(InvalidEntries).
    %% io:fwrite("Rules:~p~n",[Rules]).
    %% Tmp = [lists:nth(1, Nearby)],
    %% checkNearbyTickets(Tmp, Rules).

    
%% Correct: 426362917709
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    {Rules, Ticket, Nearby} = parseRawData(Data),
    N = length(lists:nth(1,Nearby)),
    Trans = transpose(Nearby),
    Flat = lists:flatten(Trans),

    ValidTickets = validTickets(Nearby, Rules,[]),

    RuleMap = findUniqueRules(Rules, transpose(ValidTickets), [],[]),
    RuleIndexMap = findRuleIndex(RuleMap, transpose(ValidTickets),[]),
    FinalRuleMap = mapRuleTicket(RuleIndexMap, Ticket,[]),
    DepartureRules = filterDepartureRules(FinalRuleMap,[]),
    multiplyTicketItems(DepartureRules, 1).

multiplyTicketItems([], Prod)-> Prod;
multiplyTicketItems([H|T], Prod)->
    {_,Value}=H,
    multiplyTicketItems(T, Prod*Value).

filterDepartureRules([],Result) -> lists:reverse(Result);
filterDepartureRules([H|T],Result)->
    {Rule, _} = H,
    {Name,_,_} = Rule,
    IsDeparture = stringStartsWith(Name, "departure"),
    if
	IsDeparture->
	    filterDepartureRules(T,[H|Result]);
	true ->
	    filterDepartureRules(T,Result)
    end.

stringStartsWith(_, [])-> true;
stringStartsWith([Char|T], [Char|T1])->stringStartsWith(T, T1);
stringStartsWith(_,_) -> false.
    

validTickets([], Rules, Result)-> lists:reverse(Result);
validTickets([Ticket|T], Rules, Result)->
    ValidEntries = checkEntries(Ticket, Rules,[]),
    IsValid = (tools:boolSum(ValidEntries)==length(ValidEntries)),
    if
	IsValid->
	    validTickets(T,Rules, [Ticket|Result]);
	true ->
	    validTickets(T,Rules, Result)
    end.

mapRuleTicket([], Ticket,Result)-> Result;
mapRuleTicket([RuleIndexMap|T], Ticket,Result)->
    {Rule, Index} = RuleIndexMap,
    Map = {Rule, lists:nth(Index, Ticket)},
    mapRuleTicket(T, Ticket,[Map|Result]).

findRuleIndex([], Trans,Result)-> Result;
findRuleIndex([H|T], Trans,Result)->
    {Rule, Entry} = H,
    Index = getIndex(Trans,Entry, 1),
    findRuleIndex(T, Trans,[{Rule, Index}|Result]).
    
getIndex([Entry|T],Entry, Index)->Index;
getIndex([_|T], Entry, Index) -> getIndex(T,Entry, Index+1).
    
delete([],I,Index, Prev) -> lists:reverse(Prev);
delete([H|T],I,Index, Prev) when I==Index->
    delete(T,I+1,Index, Prev);
delete([H|T],I,Index, Prev) ->
    delete(T,I+1,Index, [H|Prev]).

findUniqueRules([],Entries,[],Result)->Result;
findUniqueRules([],Entries,Stack,Result)->findUniqueRules(Stack,Entries,[],Result);
findUniqueRules([R|T],Entries,Stack,Result)->
    Res = checkRule(R, Entries),
    IsValid = isValid(Res),
    Index = getValidIndex(Res),
    if
	IsValid ->
	    NewEntries = delete(Entries,1,Index,[]),
	    NewRes = {R, lists:nth(Index, Entries)},
	    findUniqueRules(T,NewEntries,Stack,[NewRes|Result]);
	true->
	    findUniqueRules(T,Entries,[R|Stack],Result)
    end.

isValid(BoolMat)->
    N=length(lists:nth(1,BoolMat)),
    BoolSum = boolSum(BoolMat,[]),
    Count = countEntries(BoolSum, N, 0),
    (Count==1).

getValidIndex(BoolMat)->
    N=length(lists:nth(1,BoolMat)),
    BoolSum = boolSum(BoolMat,[]),
    getValidIndex(BoolSum, N, 1).
getValidIndex([], N, Index) -> 0;
getValidIndex([N|T],N,Index) -> Index;
getValidIndex([_|T],N,Index) -> getValidIndex(T,N,Index+1).

countEntries([], N,Count) -> Count;
countEntries([N|T], N,Count) -> countEntries(T, N,Count+1);
countEntries([_|T], N,Count) -> countEntries(T, N,Count).
    
boolSum([],Result)->
    lists:reverse(Result);
boolSum([H|T], Result) ->
    boolSum(T, [tools:boolSum(H)|Result]).

checkRule(Rule, Entries)->
    N = length(lists:nth(1,Entries)),
    Valid = unflat(checkEntries(lists:flatten(Entries), [Rule],[]),N,[],[]).

unflat([], N, [],Result)->
    lists:reverse(Result);
unflat([],N,Current,Result) ->
    unflat([],N, [],[lists:reverse(Current)|Result]);
unflat(List,N,Current,Result) when length(Current)==N->
    unflat(List,N,[],[lists:reverse(Current)|Result]);
unflat([H|T],N,Current,Result) ->
    unflat(T,N,[H|Current],Result).
				       
transpose([[]|_]) -> [];
transpose(M) ->
  [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M))].

bool_invert([],Result) -> lists:reverse(Result);
bool_invert([E|T],Result) -> bool_invert(T,[not E|Result]).

bool_filter(Flatten, Valid)->
    bool_filter(Flatten, Valid, []).
bool_filter([], Valid, Result)->lists:reverse(Result);
bool_filter([E|T1], [Valid|T2], Result) when Valid-> bool_filter(T1, T2, [E|Result]);
bool_filter([_|T1], [_|T2], Result) -> bool_filter(T1, T2, Result).

checkNearbyTickets(Tickets, Rules)->
    checkNearbyTickets(Tickets, Rules, [], []).
checkNearbyTickets([], Rules, Valid, Invalid)->
    {lists:reverse(Valid), lists:reverse(Invalid)};
checkNearbyTickets([Ticket|T], Rules, Valid, Invalid) ->
    IsValid = checkValidity(Ticket, Rules).

checkValidity(Ticket, Rules)->
    checkAgainstAll(Ticket, Rules).

checkEntries([], Rules, Result) ->
    lists:reverse(Result);
checkEntries([Entry|T], Rules, Result) ->
    IsValid = checkAgainstAll(Entry, Rules),
    checkEntries(T, Rules, [checkAgainstAll(Entry, Rules)|Result]).

checkAgainstAll(Entry, [])-> false;
checkAgainstAll(Entry, [Rule|T])->
    {Name, I1, I2} = Rule,
    IsValid = (inInterval(Entry, I1) or inInterval(Entry,I2)),
    if
	IsValid->
	    true;
	true->
	    checkAgainstAll(Entry, T)
    end.

inInterval(Entry, [Min,Max])->
    IsIn = ((Entry>=Min) and (Entry=<Max)).

parseRawData(Data)->parseRawData(Data,[],[],[]).
parseRawData([],Rules,Ticket,Nearby)-> {lists:reverse(Rules), Ticket, Nearby};
parseRawData([H,TicketData|T],Rules,Ticket,Nearby) when H=="your ticket:"->
    TicketList = tools:as_ints(tools:split(TicketData,",")),
    parseRawData(T,Rules,TicketList,Nearby);
parseRawData([H|T],Rules,Ticket,Nearby) when H=="nearby tickets:"->
    N = parseNearby(T,[]),
    parseRawData([],Rules,Ticket,N);
parseRawData([H|T],Rules,Ticket,Nearby) when H=="" -> %% Ignore
    parseRawData(T,Rules,Ticket,Nearby);
parseRawData([H|T],Rules,Ticket,Nearby)->
    R = parseRule(H),
    parseRawData(T,[R|Rules],Ticket,Nearby).

parseRule(Data)->parseRule(Data, "", [],[]).
parseRule([], Current, Name, I1)->
    {Name, I1, formatInterval(Current)};
parseRule([H|T], Current, Name, I1) when H==32-> %% ignore space
    parseRule(T, Current, Name, I1);
parseRule([H|T], Current, Name, I1) when H==$:->
    parseRule(T, "", lists:reverse(Current), I1);
parseRule([H1,H2|T], Current, Name, I1) when H1==$o,H2==$r,length(Name)>0->
    parseRule(T, "", Name, formatInterval(Current));
parseRule([H|T], Current, Name, I1)->
    parseRule(T, [H|Current], Name, I1).

formatInterval(Raw)->
    tools:as_ints(tools:split(lists:reverse(Raw),"-")).

parseNearby([],Result)->
    lists:reverse(Result);
parseNearby([H|T],Result) ->
    N= tools:as_ints(tools:split(H,",")),
    parseNearby(T,[N|Result]).
