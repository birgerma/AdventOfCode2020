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
    io:fwrite("Total execution time: ~f sec~n", [Total]),
    Test = os:timestamp(),
    MeanETime1 = tools:etimeMs(fun()-> sol1()end, 1000),
    MeanETime2 = tools:etimeMs(fun()-> sol2()end, 1000),
    io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime1]),
    io:fwrite("Mean time part1 ~f[ms]~n",[MeanETime2]).
    
    
%% Correct: 
sol2()->
    Fname="input",
    Data = tools:readlines(Fname).

%% Correct: 
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
    %% io:fwrite("Check ticket:~p~n",[Ticket]),
    %% checkEntries(Ticket, Rules, []).
    checkAgainstAll(Ticket, Rules).

checkEntries([], Rules, Result) ->
    lists:reverse(Result);
checkEntries([Entry|T], Rules, Result) ->
    %% io:fwrite("Check entry: ~p~n",[Entry]),
    IsValid = checkAgainstAll(Entry, Rules),
    %% io:fwrite("Valid:~p~n",[IsValid]),
    checkEntries(T, Rules, [checkAgainstAll(Entry, Rules)|Result]).

checkAgainstAll(Entry, [])-> false;
checkAgainstAll(Entry, [Rule|T])->
    {Name, I1, I2} = Rule,
    IsValid = (inInterval(Entry, I1) or inInterval(Entry,I2)),
    %% io:fwrite("Check entry ~p against rule ~p ~w ~w Valid:~p~n",[Entry, Name, I1, I2, IsValid]),
    if
	IsValid->
	    true;
	true->
	    checkAgainstAll(Entry, T)
    end.

inInterval(Entry, [Min,Max])->
    IsIn = ((Entry>=Min) and (Entry=<Max)).

parseRawData(Data)->parseRawData(Data,[],[],[]).
parseRawData([],Rules,Ticket,Nearby)-> {Rules, Ticket, Nearby};
parseRawData([H,TicketData|T],Rules,Ticket,Nearby) when H=="your ticket:"->
    TicketList = tools:as_ints(tools:split(TicketData,",")),
    %% io:fwrite("Found ticket:~p~n",[TicketList]),
    parseRawData(T,Rules,TicketList,Nearby);
parseRawData([H|T],Rules,Ticket,Nearby) when H=="nearby tickets:"->
    %% io:fwrite("Found nearby:~p~n",[parseNearby(T,[])]),
    N = parseNearby(T,[]),
    parseRawData([],Rules,Ticket,N);
parseRawData([H|T],Rules,Ticket,Nearby) when H=="" -> %% Ignore
    parseRawData(T,Rules,Ticket,Nearby);
parseRawData([H|T],Rules,Ticket,Nearby)->
    %% io:fwrite("Rule:~p ~n",[H]),
    R = parseRule(H),
    parseRawData(T,[R|Rules],Ticket,Nearby).

parseRule(Data)->parseRule(Data, "", [],[]).
parseRule([], Current, Name, I1)->
    %% io:fwrite("~n",[]),
    {Name, I1, formatInterval(Current)};
parseRule([H|T], Current, Name, I1) when H==32-> %% ignore space
    parseRule(T, Current, Name, I1);
parseRule([H|T], Current, Name, I1) when H==$:->
    parseRule(T, "", lists:reverse(Current), I1);
parseRule([H1,H2|T], Current, Name, I1) when H1==$o,H2==$r,length(Name)>0->
    parseRule(T, "", Name, formatInterval(Current));
parseRule([H|T], Current, Name, I1)->
    %% io:fwrite("~c",[H]),
    parseRule(T, [H|Current], Name, I1).

formatInterval(Raw)->
    %% io:fwrite("Interval:~p~n",[lists:reverse(Raw)]),
    tools:as_ints(tools:split(lists:reverse(Raw),"-")).

parseNearby([],Result)->
    lists:reverse(Result);
parseNearby([H|T],Result) ->
    N= tools:as_ints(tools:split(H,",")),
    parseNearby(T,[N|Result]).
