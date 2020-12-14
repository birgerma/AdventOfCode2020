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
    Data = tools:readlines(Fname),
    WayPoint = {10, -1},
    Pos = {0,0},
    Dir={1,0},
    io:fwrite("Data:~p~n",[Data]),
    {X,Y} = runActions(Data, Pos, WayPoint),
    abs(X)+abs(Y).
    
    

%% Correct: 
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    io:fwrite("Data:~p~n",[Data]),
    {X,Y}=runActions(Data, 1,0,0,0),
    abs(X)+abs(Y).
    
runActions([], {X,Y},  _) -> {X,Y};
runActions([[Action|StrArg]|T], {X,Y}, {Wx,Wy}) ->
    %% io:fwrite("Running new actions~n"),
    io:fwrite("X=~p, Y=~p Wx=~p, Wy=~p ~n ",[X,Y, Wx,Wy]),
    Arg = list_to_integer(StrArg),
    if
	(Action==$R) or (Action==$L)->
	    io:fwrite("Turn action:~c arg:~p~n",[Action, Arg]),
	    {NextWx, NextWy, _, _} = runAction(Action, Arg, Wx,Wy, 0, 0),
	    io:fwrite("Old dir:~p New dir:~p",[{Wx,Wy},{NextWx, NextWy}]),
	    runActions(T, {X,Y}, {NextWx,NextWy});
	(Action==$F) ->
	    io:fwrite("Move ship ~p ~p ~p ~p ~p ~n",[Arg,Wx,Wy, X,Y]),
	    {XDir, YDir, NextX, NextY} = runAction(Action, Arg, Wx,Wy, X, Y),
	    io:fwrite("New  ~p ~p ~p ~p ~n",[XDir,YDir, NextX, NextY]),
	    runActions(T, {NextX,NextY}, {Wx,Wy});
	true ->
	    io:fwrite("Move waypoint~n"),
	    {_, _, NextX, NextY} = runAction(Action, Arg, 0, 0, Wx,Wy),
	    runActions(T, {X,Y}, {NextX,NextY})	    
    end.
    %% runActions(T, {X,Y}, {Wx,Wy}).

runActions([],Xdir, YDir, X,Y)->
    {X,Y};
runActions([[Action|StrArg]|T],XDir, YDir, X,Y)->
    io:fwrite("X=~p, Y=~p~n",[X,Y]),
    Arg = list_to_integer(StrArg),
    io:fwrite("Action:~c Arg:~p~n",[Action,Arg]),
    {NextXDir, NextYDir, NextX, NextY} = runAction(Action, Arg, XDir, YDir, X,Y),
    runActions(T,NextXDir, NextYDir, NextX,NextY).

runAction(Action, Arg, Xdir, Ydir, X,Y) when Action==$N ->
    {Xdir, Ydir, X, Y-Arg};
runAction(Action, Arg, Xdir, Ydir, X,Y) when Action==$S ->
    {Xdir, Ydir, X, Y+Arg};
runAction(Action, Arg, Xdir, Ydir, X,Y) when Action==$E ->
    {Xdir, Ydir, X+Arg, Y};
runAction(Action, Arg, Xdir, Ydir, X,Y) when Action==$W ->
    {Xdir, Ydir, X-Arg, Y};
runAction(Action, Arg, Xdir, Ydir, X,Y) when Action==$R ->
    {NextXdir, NextYdir} = turnRight(Xdir, Ydir, Arg),
    {NextXdir, NextYdir, X, Y};
runAction(Action, Arg, Xdir, Ydir, X,Y) when Action==$L->
    runAction($R, 360-Arg, Xdir, Ydir, X,Y);
runAction(Action, Arg, XDir, YDir, X,Y) when Action==$F ->
    Dx = XDir*Arg,
    Dy = YDir*Arg,
    {XDir, YDir, X+Dx, Y+Dy}.

turnRight(Xdir, Ydir, 0)->{Xdir, Ydir};
turnRight(Xdir, Ydir, Angle) -> io:fwrite("Xdir:~p Ydir~p~n",[Xdir,Ydir]),turnRight(-Ydir, Xdir, Angle-90).
