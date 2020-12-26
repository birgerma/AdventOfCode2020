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
    Tiles = formatTileData(Data,[],[]),
    TileDict = dict:from_list(Tiles),
    TileData = lists:nth(1,Tiles),
    TileSides = getTileSides(Tiles,[]),
    
    Compared = compareAllTiles(Tiles,Tiles,[]),
    MatchMatrix = countMatching(Compared,[]),
    MatchList = filterNonMatching(MatchMatrix,[]),
    MatchDict = dict:from_list(MatchList),

    {InitTileId,_} = lists:nth(1,MatchList),
    InitTile = dict:fetch(InitTileId,TileDict),
    InitPos = {0,0},
    TilePositions = dict:store(InitTileId,[InitPos,InitTile],dict:new()),
        
    FinalTilePositions = matchTilePositions(dict:to_list(TilePositions), TileDict, TilePositions, MatchDict),
    length(dict:to_list(FinalTilePositions)),
    [MinX, MaxX, MinY, MaxY] = getRange(dict:to_list(FinalTilePositions)),
        
    %% io:fwrite("Range:~p ~p ~p ~p ~n",[MinX, MaxX, MinY, MaxY]),
    %% printTilePos(dict:to_list(FinalTilePositions)).
    Matrix = createTileMatrix(MinX, MinY, FinalTilePositions, MinX, MaxX, MinY, MaxY,[],[]),
    %% %% Remove borders!!!
    Final = removeBorders(Matrix,[]),
    Image = combineTiles(Final,[]),
    
    {MonstersStartCoord, CorrectPerm} = findMonstersInPermutations(getPermutations(Image)),
    MonsterCoord = createMonsterCoordinates(MonstersStartCoord,[]),
    MonsterDict = createMonsterPartDict(MonsterCoord,[]),
    countNonMonsterSquares(CorrectPerm, MonsterDict,1,0).


printTilePos([])->ok;
printTilePos([{Id, [{X,Y},Tile]}|T])->
    io:fwrite("Tile:(X=_ Y=~p)~n",[Y]),
    printTilePos(T).
    
%% Correct: 
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    Tiles = formatTileData(Data,[],[]),
    TileData = lists:nth(1,Tiles),
    TileSides = getTileSides(Tiles,[]),
    
    Compared = compareAllTiles(Tiles,Tiles,[]),
    MatchMatrix = countMatching(Compared,[]),
    NTileMatches = countMatrixBoolColumns(MatchMatrix,[]),
    Corners = getCorners(NTileMatches,[]),
    io:fwrite("Courners:~p~n",[Corners]),
    mul(Corners,1).

mul([],Res)-> Res;
mul([H|T],Res)-> mul(T,H*Res).

    

%% Correct: 
test1()->
    Fname="example",
    Data = tools:readlines(Fname),
    Tiles = formatTileData(Data,[],[]),
    TileData = lists:nth(1,Tiles),
    %% getSides(TileData).
    TileSides = getTileSides(Tiles,[]),
    
    %% I1=1,
    %% I2=2,
    %% {Id1, Tile1} = lists:nth(I1,Tiles),
    %% {Id2, Tile2} = lists:nth(I2,Tiles),
    %% Side1 = lists:nth(I1,TileSides),
    %% Side2 = lists:nth(I2,TileSides),
    %% io:fwrite("Compare Tile ~p and Tile ~p~n",[Id1,Id2]),
    %% io:fwrite("Side1:~p~n",[Side1]),
    %% io:fwrite("Side2:~p~n",[Side2]),
    %% compareSides(Side1, Side2,[]).

    Compared = compareAllTiles(Tiles,Tiles,[]),
    io:fwrite("Compared:~p~n",[Compared]),
    MatchMatrix = countMatching(Compared,[]),
    io:fwrite("Match matrix:~p~n",[MatchMatrix]),
    NTileMatches = countMatrixBoolColumns(MatchMatrix,[]),
    Corners = getCorners(NTileMatches,[]),
    lists:sum(Corners).


test3()->
    Fname="input",
    Data = tools:readlines(Fname),
    Tiles = formatTileData(Data,[],[]),
    Size = math:sqrt(length(Tiles)),
    Rows = getRows(Tiles,[]),
    
    %% io:fwrite("Rows:~p~n",[Rows]),
    %% [1063,1487,2713,2749]
    Row1 = lists:nth(2,Rows), %% 2749 and 1487 in 2nd row
    io:fwrite("Ids:~p~n",[getTileIds(Row1,[])]),
    ColStr = combineRows(Rows,[]),
    MockCol = addMockId(ColStr,1,[]),
    getRows(MockCol,[]).

    %% M1 = matchRows(Row1, Rows,[],[]),
    
    %% M1 = matchRows(flipRow(Row1,[]), Rows,[],[]).

    %% Final = orderRows(Rows, Size,[]).
    %% Image = combineTiles(Final,[]),
    %% printTile(Image).


    %% Row1 = lists:nth(1,Rows),
    %% Row2 = lists:nth(2,Rows),
    %% Row3 = lists:nth(3,Rows),
    %% Res1 = matchRows(Row3,Row2),
    %% %% Res2 = matchRows(Row2,Row3),
    %% %% Res = getLongest(Res1,Res2),
    %% io:fwrite("Result:~p~n",[Res1]).

    %% combineRows(Final,[]).
    %% Image = combineTiles(Final,[]),
    %% printTile(Image).
    %% EndTiles = getEnds(Rows,[]),
    %% orderRows(Final,Size,[]).


test4()->
    Fname="example",
    Data = tools:readlines(Fname),
    Tiles = formatTileData(Data,[],[]),
    TileDict = dict:from_list(Tiles),
    TileData = lists:nth(1,Tiles),
    %% getSides(TileData).
    TileSides = getTileSides(Tiles,[]),
    
    %% I1=1,
    %% I2=2,
    %% {Id1, Tile1} = lists:nth(I1,Tiles),
    %% {Id2, Tile2} = lists:nth(I2,Tiles),
    %% Side1 = lists:nth(I1,TileSides),
    %% Side2 = lists:nth(I2,TileSides),
    %% io:fwrite("Compare Tile ~p and Tile ~p~n",[Id1,Id2]),
    %% io:fwrite("Side1:~p~n",[Side1]),
    %% io:fwrite("Side2:~p~n",[Side2]),
    %% compareSides(Side1, Side2,[]).

    Compared = compareAllTiles(Tiles,Tiles,[]),
    %% io:fwrite("Compared:~p~n",[Compared]),
    MatchMatrix = countMatching(Compared,[]),
    %% io:fwrite("Match matrix:~p~n",[MatchMatrix]),
    MatchList = filterNonMatching(MatchMatrix,[]),
    MatchDict = dict:from_list(MatchList),
    %% io:fwrite("~p~n",[MatchList]),
    {InitTileId,_} = lists:nth(1,MatchList),
    InitTile = dict:fetch(InitTileId,TileDict),
    InitPos = {0,0},
    TilePositions = dict:store(InitTileId,[InitPos,InitTile],dict:new()),
    
    %% io:fwrite("Init tile:(~p)~n",[InitTileId]),
    %% printTile(InitTile),
    dict:fetch(InitTileId,TilePositions),
    FinalTilePositions = matchTilePositions(dict:to_list(TilePositions), TileDict, TilePositions, MatchDict),
    [MinX, MaxX, MinY, MaxY] = getRange(dict:to_list(FinalTilePositions)),

    Matrix = createTileMatrix(MinX, MinY, FinalTilePositions, MinX, MaxX, MinY, MaxY,[],[]),
    %% Remove borders!!!
    Final = removeBorders(Matrix,[]),
    Image = combineTiles(Final,[]),
    %% printTile(Image).

    %% Permutations = getPermutations(Image),
    %% Perm = lists:nth(2,Permutations),

    %% printTile(Perm),
    %% findMonsters(Perm).
    {MonstersStartCoord, CorrectPerm} = findMonstersInPermutations(getPermutations(Image)),
    MonsterCoord = createMonsterCoordinates(MonstersStartCoord,[]),
    MonsterDict = createMonsterPartDict(MonsterCoord,[]),
    countNonMonsterSquares(CorrectPerm, MonsterDict,1,0).
    
countNonMonsterSquares([], MonsterCoord,Y,Count)-> Count;
countNonMonsterSquares([Row|T], MonsterCoord,Y,Count)->
    RowCount = countNonMonsterSquaresInRow(Row, MonsterCoord,1,Y,0),
    countNonMonsterSquares(T, MonsterCoord,Y+1,Count+RowCount).

countNonMonsterSquaresInRow([], MonsterCoord,X,Y,Count) -> Count;
countNonMonsterSquaresInRow([Square|T], MonsterCoord,X,Y,Count)->
    IsMonster = dict:is_key({X,Y},MonsterCoord),
    if
	IsMonster->
	    countNonMonsterSquaresInRow(T, MonsterCoord,X+1,Y,Count);
	true ->
	    if
		Square==$#->
		    countNonMonsterSquaresInRow(T, MonsterCoord,X+1,Y,Count+1);
		true->
		    countNonMonsterSquaresInRow(T, MonsterCoord,X+1,Y,Count)
	    end
    end.

createMonsterPartDict([],Result)-> dict:from_list(Result);
createMonsterPartDict([Coord|T],Result)->
    createMonsterPartDict(T,[{Coord,true}|Result]).

createMonsterCoordinates([],Result)-> Result;
createMonsterCoordinates([{X0,Y0}|T],Result)->
    io:fwrite("Coord:~p~n",[{X0,Y0}]),
    %% Indexes = [19],
    %% Indexes = [1,6,7,12,13,18,19,20],
    %% Indexes = [2, 5, 8, 11, 14, 17],

    Row1 = createXCoord(X0-1,Y0,[19],[]),
    Row2 = createXCoord(X0-1,Y0+1,[1,6,7,12,13,18,19,20],[]),
    Row3 = createXCoord(X0-1,Y0+2,[2, 5, 8, 11, 14, 17],[]),
    createMonsterCoordinates(T,Row1++Row3++Row2++Result).
    
    
    
createXCoord(X0,Y0,[],Result)-> lists:reverse(Result);
createXCoord(X0,Y0,[XD|T],Result)->
    createXCoord(X0,Y0,T,[{X0+XD,Y0}|Result]).

findMonstersInPermutations([Perm|T])->
    Monsters = findMonsters(Perm),
    if
	length(Monsters)==0->
	    findMonstersInPermutations(T);
	true->
	    {Monsters,Perm}
    end.
    

findMonsters([A,B,C|T])->
    findMonsters([A,B,C|T], 1, 1, []).
findMonsters([A,B], X, Y, Result)-> lists:reverse(Result);
findMonsters([A,B,C|T], X, Y, Result)->
    %% io:fwrite("First rows:~n"),
    %% io:fwrite("~p~n",[A]),
    %% io:fwrite("~p~n",[B]),
    %% io:fwrite("~p~n",[C]),
    Monsters = findMonsterInRows(A,B,C,X,Y,[]),
    findMonsters([B,C|T], X, Y+1, Monsters++Result).

findMonsterInRows([R1|T1],[R2|T2],[R3|T3],X,Y,Result) when length([R1|T1])>=20 ->
    Row1 = compareRow1([R1|T1]),
    Row2 = compareRow2([R2|T2]),
    Row3 = compareRow3([R3|T3]),
    Found = (Row1 and Row2 and Row3),
    if
	Found ->
	    io:fwrite("MONSTER FOUND:(~p,~p) ~n",[X,Y]),
	    findMonsterInRows(T1,T2,T3,X+1,Y,[{X,Y}|Result]);
	true ->
	    findMonsterInRows(T1,T2,T3,X+1,Y,Result)
    end;
findMonsterInRows([R1|T1],[R2|T2],[R3|T3],X,Y,Result) -> lists:reverse(Result).

compareRow1(Row)->
    Indexes = [19],
    checkIndexes(Row, Indexes, $#).
    %% lists:nth(19,Row)==$#.
    %% #____##____##____###

compareRow2(Row)->
    Indexes = [1,6,7,12,13,18,19,20],
    checkIndexes(Row, Indexes, $#).
    %% lists:nth(16,Row)==$#.

compareRow3(Row)->
    Indexes = [2, 5, 8, 11, 14, 17],
    checkIndexes(Row, Indexes, $#).


checkIndexes(List,[], E)-> true;
checkIndexes(List,[Index|T], E)->
    IsOk = lists:nth(Index, List)==E,
    if
	IsOk->
	    checkIndexes(List,T, E);
	true->
	    false
    end.
%% SeaMonster = [
%% __________________#_
%% #____##____##____###
%% 1    67    1213  181920
%% _#__#__#__#__#__#___   
%% 2  5  8  11 14 17
%% ]

    %% NTileMatches = countMatrixBoolColumns(MatchMatrix,[]),
    %% Corners = getCorners(NTileMatches,[]),
    %% lists:sum(Corners).

removeBorders([],Result)-> lists:reverse(Result);
removeBorders([Row|T],Result)->
    %% io:fwrite("Remove borders from row:~p~n",[Row]),
    NewRow = removeRowBorders(Row,[]),
    removeBorders(T,[NewRow|Result]).

removeRowBorders([],Result)-> lists:reverse(Result);
removeRowBorders([{Id, Tile}|T],Result)->
    %% io:fwrite("Remove borders from tile ~p:~n",[Id]),
    %% printTile(Tile),
    NewTile = removeTileBorders(Tile),
    removeRowBorders(T,[NewTile|Result]).
    %% io:fwrite("New tile:~n"),
    %% printTile(NewTile).

removeTileBorders(Tile)->
    [_|Tail] = Tile, %% Drop top
    NewTile = lists:droplast(Tail), %% Drop bottom
    [_|TmpTail] = turn90(NewTile), %% Drop one side
    TurnedFinal = lists:droplast(TmpTail),
    turn270(TurnedFinal).
    
    
createTileMatrix(X, Y, TilePositions, MinX, MaxX, MinY, MaxY, Row, Result) when Y>MaxY->
    lists:reverse(Result);
createTileMatrix(X, Y, TilePositions, MinX, MaxX, MinY, MaxY, Row, Result) when X>MaxX->
    createTileMatrix(MinX, Y+1, TilePositions, MinX, MaxX, MinY, MaxY, [], [lists:reverse(Row)|Result]);
createTileMatrix(X, Y, TilePositions, MinX, MaxX, MinY, MaxY, Row, Result)->
    %% io:fwrite("Get position (~p,~p)~n",[X,Y]),
    Tile = getTileByPos(dict:to_list(TilePositions), X,Y),
    %% io:fwrite("Current tile:~p~n",[Tile]),
    createTileMatrix(X+1, Y, TilePositions, MinX, MaxX, MinY, MaxY, [Tile|Row], Result).


getTileByPos([{Id, [{X,Y},Tile]}|T], X,Y)-> {Id, Tile};
getTileByPos([_|T], X,Y)-> getTileByPos(T, X,Y).

getRange(TilePositions)->
    %% io:fwrite("Final positions:~p~n",[TilePositions]),
    InitMin = length(TilePositions),
    InitMax = -InitMin,
    getRange(TilePositions,InitMin, InitMax, InitMin, InitMax).
getRange([],MinX, MaxX, MinY, MaxY)->[MinX, MaxX, MinY, MaxY];
getRange([{Id, [{X,Y},Tile]}|T],MinX, MaxX, MinY, MaxY)->
    %% io:fwrite("X=~p, Y=~p~n",[X,Y]),
    if
	X<MinX->
	    NewMinX=X;
	true->
	    NewMinX=MinX
    end,
    if
	Y<MinY ->
	    NewMinY=Y;
	true->
	    NewMinY=MinY
    end,
    if
	X>MaxX->
	    NewMaxX = X;
	true ->
	    NewMaxX = MaxX
    end,
    if
	Y>MaxY->
	    NewMaxY = Y;
	true ->
	    NewMaxY = MaxY
    end,
    getRange(T,NewMinX, NewMaxX, NewMinY, NewMaxY).
	
    
    
matchTilePositions([], TileDict, TilePositions, MatchDict)-> TilePositions;
matchTilePositions([{Id, [Pos, Tile]}|T], TileDict, TilePositions, MatchDict)->
    %% io:fwrite("Current Id:~p~n",[Id]),
    %% io:fwrite("Current Pos:~p~n",[Pos]),
    %% io:fwrite("Current tile:~p~n",[Tile]),
    NeedsMatch = (dict:is_key(Id,MatchDict)),
    if
	NeedsMatch->
	    Matches = dict:fetch(Id, MatchDict),
	    %% io:fwrite("Matching:~p~n",[Matches]),
	    UnknownMatches = filterFoundMatches(Matches, TilePositions,[]),
	    {Res, NewTileDict} = findRelativeMatches(Id, Pos, UnknownMatches, TileDict, []),
	    NewTilePositions = addToDict(Res, TilePositions),
	    %% io:fwrite("Remov id ~p from MatchDict~n",[Id]),
	    matchTilePositions(dict:to_list(NewTilePositions), NewTileDict, NewTilePositions, dict:erase(Id, MatchDict));
	true ->
	    matchTilePositions(T, TileDict, TilePositions, MatchDict)
    end.
    %% io:fwrite("Result:~p~n",[Res])

filterFoundMatches([], TilePositions,Result) -> lists:reverse(Result);
filterFoundMatches([Id|T], TilePositions,Result)->
    IsFound = dict:is_key(Id, TilePositions),
    if
	IsFound ->
	    filterFoundMatches(T, TilePositions,Result);
	true ->
	    filterFoundMatches(T, TilePositions,[Id|Result])
    end.


addToDict([], TilePositions)-> TilePositions;
addToDict([{Id,Val}|T], TilePositions)->
    %% io:fwrite("Add tile:~p Value:~p~n",[Id, Val]),
    Exists = dict:is_key(Id, TilePositions),
    if
	Exists ->
	    addToDict(T, TilePositions);
	true ->
	    addToDict(T, dict:store(Id, Val,TilePositions))
    end.


getCoord({X,Y}, left)->{X-1,Y};
getCoord({X,Y}, bottom)->{X,Y+1};
getCoord({X,Y}, right)->{X+1,Y};
getCoord({X,Y}, top)->{X,Y-1}.
    

findRelativeMatches(Id, Pos, [], TileDict,Result)->{lists:reverse(Result), TileDict};
findRelativeMatches(Id, Pos, [Match|T], TileDict,Result)->
    %% io:fwrite("Find match for id:~p~n",[Id]),
    %% io:fwrite("Position:~p~n",[Pos]),
    %% io:fwrite("To compare:~p~n",[Match]),
    {Rel, NewTile} = findRelativeMatch(Id, Match, TileDict),
    Coor = getCoord(Pos, Rel),
    io:fwrite("Match ~p (~p) with ~p at ~p (~p)~n",[Id, Pos,Match,Rel, Coor]),
    io:fwrite("New tile (id=~p)~n",[Match]),
    printTile(NewTile),
    %% io:fwrite("Coor for match:~p Coor:~p~n",[Rel,Coor]),
    NewTileDict = dict:store(Match, NewTile, TileDict),
    findRelativeMatches(Id, Pos, T, NewTileDict, [{Match, [Coor, NewTile]}|Result]).

findRelativeMatch(Id, Match, TileDict)->
    %% io:fwrite("Find relative match between ~p and ~p.~n",[Id, Match]),
    getRelativePosition(Id, Match, TileDict).

getRelativePosition(Id, Match, TileDict)->
    FixTile = dict:fetch(Id, TileDict),
    RelTile = dict:fetch(Match, TileDict),
    Permutations = getPermutations(RelTile),
    getRelPos(FixTile, Permutations).

getRelPos(FixTile, Permutations)->
    getRelPos(FixTile, Permutations, Permutations,left).

getRelPos(FixTile, [],Permutations,left)-> 
    getRelPos(FixTile, Permutations,Permutations,bottom);
getRelPos(FixTile, [Tile|T],Permutations,left)->
    %% io:fwrite("Check permutations for a left match~n"),
    IsMatch = (getLeftSide(FixTile)==getRightSide(Tile)),
    %% io:fwrite("IsMatch:~p~n",[IsMatch]),
    if
	IsMatch->
	    {left, Tile};
	true ->
	    getRelPos(FixTile, T,Permutations,left)
    end;
    
getRelPos(FixTile, [],Permutations, bottom)->
    getRelPos(FixTile, Permutations, Permutations,right);
getRelPos(FixTile, [Tile|T],Permutations,bottom)->
    %% io:fwrite("Check permutations for a bottom match~n"),
    IsMatch = (getBottom(FixTile)==getTop(Tile)),
    %% printTile(FixTile),
    %% io:fwrite("~n"),
    %% printTile(Tile),
    %% io:fwrite("IsMatch:~p~n",[IsMatch]),
    if
	IsMatch->
	    {bottom, Tile};
	true ->
	    getRelPos(FixTile, T,Permutations,bottom)
    end;

getRelPos(FixTile, [],Permutations,right)->
    getRelPos(FixTile, Permutations,Permutations,top);
getRelPos(FixTile, [Tile|T],Permutations,right)->
    %% io:fwrite("Check permutations for a right match~n"),
    IsMatch = (getRightSide(FixTile)==getLeftSide(Tile)),
    %% printTile(Tile),
    %% io:fwrite("~n"),
    %% printTile(FixTile),
    %% io:fwrite("IsMatch:~p~n",[IsMatch]),
    if
	IsMatch->
	    {right, Tile};
	true ->
	    getRelPos(FixTile, T,Permutations,right)
    end;

getRelPos(FixTile, [],Permutations,top)->
    io:fwrite("No matches found!!!~n");
getRelPos(FixTile, [Tile|T],Permutations,top)->
    %% io:fwrite("Check permutations for a top match~n"),
    IsMatch = (getTop(FixTile)==getBottom(Tile)),
    %% printTile(Tile),
    %% io:fwrite("~n"),
    %% printTile(FixTile),
    %% io:fwrite("IsMatch:~p~n",[IsMatch]),
    if
	IsMatch->
	    {top, Tile};
	true ->
	    getRelPos(FixTile, T,Permutations,top)
    end.


filterNonMatching([],Result)-> lists:reverse(Result);
filterNonMatching([Entry|T],Result)->
    %% io:fwrite("Entry:~p~n",[Entry]),
    {Id, MatchList} = Entry,
    Matching = keepMatches(MatchList,[]),
    filterNonMatching(T,[{Id,Matching}|Result]).
    
keepMatches([],Result)-> lists:reverse(Result);
keepMatches([{Id, true}|T],Result)->
    keepMatches(T,[Id|Result]);
keepMatches([NoMatch|T],Result)->
    keepMatches(T,Result).
addMockId([],Id,Result)->lists:reverse(Result);
addMockId([Tile|T],Id,Result)->
    addMockId(T,Id+1,[{Id,Tile}|Result]).
    

orderRows(Rows,Size,[])-> orderRows(Rows,Rows,Size,[]).
orderRows([],Rows,Size,[])->ok;
orderRows([Row|T],Rows,Size,[])->
    Ids = getTileIds(Row,[]),
    io:fwrite("Match row:~p~n",[Ids]),
    NewRows = removeRow(Row,Rows),
    M1 = matchRows(Row, Rows,[],[]),
    M2 = matchRows(flipRow(Row,[]), Rows,[],[]),
    Longest = getLongest(M1,M2),
    %% io:fwrite("Match1:~p~n",[M1]),
    %% io:fwrite("Match2:~p~n",[M2]),
    %% io:fwrite("Longest col:~p~n",[length(Longest)]),
    if
	length(Longest)==Size->
	    Longest;
	true->
	    orderRows(T,Rows,Size,[])
    end.
    
removeRow(Row1,Rows)-> removeRow(Row1,Rows,[]).
removeRow(Row1,[],Result)-> lists:reverse(Result);
removeRow(Row1,[Row2|T],Result)->
    RowId1 = getTileIds(Row1,[]),
    RowId2 = getTileIds(Row2,[]),
    Id1 = lists:nth(1,RowId1),
    IsSameRow = lists:member(Id1,RowId2),
    if
	IsSameRow->
	    removeRow(Row1,T,Result);
	true ->
	    removeRow(Row1,T,[Row2|Result])
    end.
    
%%     io:fwrite("Match row:~p~n",[Row]),
%%     %% Tile = lists:nth(1,Row),
%%     {Id,_} = Tile,
%%     io:fwrite("Current Tile:~p~n",[Tile]),
%%     io:fwrite("Wanted Col length:~p~n",[Size]),
%%     %% EndTiles = getEnds(Rows,[]),
%%     %% io:fwrite("End tiles:~p~n",[EndTiles]),
%%     io:fwrite("Find vertical match with ~p~n",[Id]),
%%     Col = getTileCol(Tile, EndTiles,[]),
%%     io:fwrite("Tile column:~p~n",[Col]),
%%     if
%% 	length(Col)==Size->
%% 	    io:fwrite("Found working column~n");
%% 	true ->
%% 	    orderRows(T,EndTiles,Size,[])
%%     end.
matchRows(Row,[],Stack,Result)->lists:reverse([Row|Result]); 
%% matchRows(Row,[Row|T],Result)-> 
%%     io:fwrite("Same row, skipping~n"),
%%     matchRows(Row,T,Result);
matchRows(Row1,[Row2|T],Stack,Result) -> 
    RowId1 = getTileIds(Row1,[]),
    RowId2 = getTileIds(Row2,[]),
    Id1 = lists:nth(1,RowId1),
    IsSameRow = lists:member(Id1,RowId2),
    io:fwrite("N rows to check:~p~n",[length(T)+1]),
    io:fwrite("Match ~p ~nwith~p~n",[RowId1,RowId2]),
    if
	IsSameRow->
	    io:fwrite("Same row, skipping~n"),
	    matchRows(Row1,T,Stack,Result);
	true ->
	    io:fwrite("Not same row (~p not in ~p)~n",[Id1, RowId2]),
	    %% matchRows(Row1,T),
	    Res = matchRow(Row1,Row2),
	    if
		length(Res)>0->
		    io:fwrite("Got match, continue~n"),
		    io:fwrite("(~p fits with ~p)~n",[RowId1,RowId2]),
		    matchRows(Res, Stack++T,[],[Row1|Result]);
		true ->
		    io:fwrite("No match, add to stack~n"),
		    matchRows(Row1, T,[Row2|Stack],Result)
	    end
    end.
	    

matchRow(Row1,Row2)->
    %% io:fwrite("Row1:~p~n",[Row1]),
    %% io:fwrite("Row2:~p~n",[Row2]),
    TurnedRow = turnRow(Row2,[]),
    Flipped = flipRow(Row2,[]),
    FlippedTurned = flipRow(TurnedRow,[]),

    IsMatch = compareTilesVertical(lists:nth(1,Row1),lists:nth(1,Row2)),
    IsTurnedMatch = compareTilesVertical(lists:nth(1,Row1),lists:nth(1,TurnedRow)),
    IsFlippedMatch = compareTilesVertical(lists:nth(1,Row1),lists:nth(1,Flipped)),
    IsFlippedTurnedMatch = compareTilesVertical(lists:nth(1,Row1),lists:nth(1,FlippedTurned)),

    %% io:fwrite("Turned Row2:~p~n",[TurnedRow]),
    %% io:fwrite("Flipped Row2:~p~n",[Flipped]),
    %% io:fwrite("Flipped and turned Row2:~p~n",[FlippedTurned]),
    if
	IsMatch->
	    Row2;
	IsTurnedMatch ->
	    TurnedRow;
	IsFlippedMatch ->
	    Flipped;
	IsFlippedTurnedMatch ->
	    FlippedTurned;
	true ->
	    []
    end.
    


turnRow([],Result)-> Result;
turnRow([{Id,Tile}|T],Result)->
    Turned = turnTile(Tile),
    turnRow(T,[{Id,Turned}|Result]).

compareTilesVertical({Id1,Upper},{Id2,Lower})->
    io:fwrite("Compare Upper: (~p)~n",[Id1]),
    printTile(Upper),
    io:fwrite("Compare Lower: (~p)~n",[Id2]),
    printTile(Lower),
    Bottom = getBottom(Upper),
    Top = getTop(Lower),
    io:fwrite("Upper bottom:~p == Top lower: ~p~n",[Bottom, Top]),
    io:fwrite("Upper bottom equal to lower top:~p~n",[Bottom==Top]),
    Bottom==Top.
    

combineRows([],Result)-> lists:reverse(Result);
combineRows([Row|T],Result)->
    RowStr = combineRowTiles(Row,"",[],[]),
    io:fwrite("Row:~p~n",[Row]),
    io:fwrite("Row str:~p~n",[RowStr]),
    combineRows(T,[RowStr|Result]).

	
getEnds([],Result)->lists:reverse(Result);
getEnds([List|T],Result)->
    First = lists:nth(1,List),
    Last = lists:nth(length(List),List),
    getEnds(T,[First,Last|Result]).
    
getLongest(L1,L2) when length(L1)>length(L2)-> L1;
getLongest(_,L2) -> L2.
    
getRows(Tiles, Result)-> getRows(Tiles, Tiles, Result).
getRows([], Tiles, Result)->
    %% io:fwrite("Result:~p~n",[Result]),
    lists:reverse(Result);
getRows([Tile|T], Tiles, Result)->
    SideLength = math:sqrt(length(Tiles)),
    %% io:fwrite("Side length:~p~n",[SideLength]),
    %% io:fwrite("Tile:~p~n",[Tile]),
    {Id, TileData} = Tile,
    Reversed = {Id, turnTile(TileData)},
    %% io:fwrite("Match Tile id:~p~n",[Id]),

    Row1 = getTileRow(Tile, Tiles,[],[]),
    Row2 = getTileRow(Reversed, Tiles,[],[]),
    Row = getLongest(Row1,Row2),
    %% io:fwrite("Length row:~p~n",[length(Row)]),
    %% Row = getLongest(Row1,Row2),
    %% io:fwrite("Row:~p~n",[Row]),
    if
	length(Row)==SideLength->
	    getRows(T, Tiles, [Row|Result]);
	true ->
	    getRows(T, Tiles, Result)
    end.
	    
    %% getRow(Id, IdList, TileDict, Result)->

getTileRow({Id1,Left}, [], Stack, Result)-> lists:reverse([{Id1,Left}|Result]);
getTileRow({Id,Left}, [{Id, Right}|T], Stack, Result)-> 
    %% io:fwrite("Skipping, same id~n"),
    getTileRow({Id,Left}, T, Stack, Result);
getTileRow({Id1,Left}, [{Id2, Right}|T], Stack, Result)-> 
    Match = matchTilesHor(Left,Right),
    %% io:fwrite("Match: with ~p ~p~n",[Id2,length(Match)>0]),
    %% io:fwrite("Match:~p~n",[length(Match)>0]),
    if
	(length(Match)>0) -> %% Implement stack here!!!
	    %% io:fwrite("Found Row Match with ~p~n",[Id2]),
	    getTileRow({Id2,Match}, Stack++T, [], [{Id1,Left}|Result]);
	true ->
	    getTileRow({Id1,Left}, T, [{Id2,Right}|Stack],Result)
    end.

getTileCol({Id1,Left}, [], Result)-> lists:reverse([{Id1,Left}|Result]);
getTileCol({Id,Upper}, [{Id, _}|T], Result)-> 
    %% io:fwrite("Skipping, same id~n"),
    getTileCol({Id,Upper}, T, Result);
getTileCol({Id1,Upper}, [{Id2, Lower}|T], Result)-> 
    Match = matchTilesVer(Upper,Lower),
    io:fwrite("Match: ~p with ~p: ~p~n",[Id1, Id2,length(Match)>0]),
    %% io:fwrite("Match:~p~n",[length(Match)>0]),
    if
	(length(Match)>0) ->
	    io:fwrite("Found Col Match with ~p~n",[Id2]),
	    getTileCol({Id2,Match}, T, [{Id1,Lower}|Result]);
	true ->
	    getTileCol({Id1,Upper}, T, Result)
    end.

test2()->
    io:fwrite("Hello~n"),
    Fname="example",
    Data = tools:readlines(Fname),
    Tiles = formatTileData(Data,[],[]),
    TileData = lists:nth(1,Tiles),
    %% getSides(TileData).
    TileSides = getTileSides(Tiles,[]),
    
    %% I1=1,
    %% I2=2,
    %% {Id1, Tile1} = lists:nth(I1,Tiles),
    %% {Id2, Tile2} = lists:nth(I2,Tiles),
    %% Side1 = lists:nth(I1,TileSides),
    %% Side2 = lists:nth(I2,TileSides),
    %% io:fwrite("Compare Tile ~p and Tile ~p~n",[Id1,Id2]),
    %% io:fwrite("Side1:~p~n",[Side1]),
    %% io:fwrite("Side2:~p~n",[Side2]),
    %% compareSides(Side1, Side2,[]).

    Compared = compareAllTiles(Tiles,Tiles,[]),
    MatchMatrix = countMatching(Compared,[]),
    NTileMatches = countMatrixBoolColumns(MatchMatrix,[]),
    Corners = getCorners(NTileMatches,[]),
    TileDict = createImageDict(Tiles, dict:new()),
    Ids = getTileIds(Tiles,[]),

    CornerId = 1951,
    Corner = dict:fetch(CornerId,TileDict),
    Rest = pop(CornerId,Ids,[]),
    %% io:fwrite("Init: ~p~n",[Ids]),
    %% io:fwrite("After: ~p~n",[Rest]),
    %% {Id12, Tile12} = findNextRowTile(CornerId, Ids, TileDict),
    %% IdList2 = pop(Id12, Ids, []),

    %% {Id13, Tile13} = findNextRowTile(Id12, IdList2, TileDict),

    %% io:fwrite("First row:~p ~p ~p ~n",[CornerId, Id12, Id13]),
    {Row, NewTileDict} = getRow(CornerId, Ids, TileDict,[{CornerId, Corner}]),
    %% Row,
    NewIds = popTileIds(Ids, getTileIds(Row,[]),[]),
    %% {Col, NewTileDict2} = getCol(CornerId, NewIds, NewTileDict),
    %% if
    %% 	length(Col)>0 ->
    %% 	    io:fwrite("Flip row~n"),
    %% 	    NewRow = flipRow(Row,[]),
    %% 	    NewRow;
    %% 	true ->
    %% 	    io:fwrite("Continue withe next in row~n"),
    %% 	    io:fwrite("Cols:~p~n",[Col])
    %% end,
    %% io:fwrite("Row:~p~n",[Row]),
    %% Res = getCols(Row, NewIds, NewTileDict, []),

    NewRow = flipRow(Row,[]),
    UpdatedTileDict = updateTileDict(NewRow, TileDict),
    Res2 = getCols(NewRow, NewIds, UpdatedTileDict, []),
    Res2,
    Image = combineTiles(tools:transpose(Res2),[]),
    Y=length(Image),
    X=length(lists:nth(30,Image)),
    io:fwrite("~p~n Width:~p Height:~p~n",[Image,X,Y]).

    %% io:fwrite("Result:~p~n",[Res]),
    %% io:fwrite("Result:~p~n",[Res2]),
    %% length(lists:nth(1,Res)),
    
    %% TestId = 3079,
    %% TestIds = [1951, 2311, 2729, 1427, 2473, 2971, 1489, 1171],
    %% TestIds = [2473, 1171],
    %% {Test, TestDict} = getCol(TestId, TestIds, TileDict),
    %% Test.
	    

testPer()->
    Fname="example",
    Data = tools:readlines(Fname),
    Tiles = formatTileData(Data,[],[]),
    {Id, Tile} = lists:nth(1,Tiles),
    getPermutations(Tile).

combineTiles([],Result)-> lists:append(lists:reverse(Result));
combineTiles([Row|T],Result)->
    %% io:fwrite("Col: ~p~n",[Col]),
    Res = combineRowTiles(Row,"",[],[]),
    combineTiles(T,[Res|Result]).
    
combineRowTiles([[]|T],Current,Stack,Result)->
    lists:reverse(Result);
combineRowTiles([],Current,Stack,Result)->
    %% io:fwrite("Complete row:~p~n",[lists:reverse(Current)]),
    %% io:fwrite("Stack:~p~n",[Stack]),
    combineRowTiles(lists:reverse(Stack),"",[],[Current|Result]);
combineRowTiles([{Id,Tile}|T],Current,Stack,Result)->
    [H|Rest] = Tile,
    %% io:fwrite("Match 1 (~p) ~p ~n",[Id,H]),
    %% io:fwrite("Tile row:~p~n",[H]),
    combineRowTiles(T,Current++H,[Rest|Stack],Result);
combineRowTiles([Tile|T],Current,Stack,Result)->
    [H|Rest] = Tile,
    %% io:fwrite("Match 2 ~p ~n",[H]),
    %% io:fwrite("Tile:~p~n",[Tile]),
    combineRowTiles(T,Current++H,[Rest|Stack],Result).


getCols([],IdsLeft, TileDict, Result)-> lists:reverse(Result);
getCols([{Id,Tile}|T],IdsLeft, TileDict, Result)->
    {Col, NewTileDict} = getCol(Id, IdsLeft, TileDict),
    %% io:fwrite("Ids left:~p~n",[IdsLeft]),
    %% io:fwrite("Continue withe next in row~n"),
    %% io:fwrite("Cols:~p~n",[Col]),
    NewIds = popTileIds(IdsLeft, getTileIds(Col,[]),[]),
    getCols(T,NewIds, NewTileDict, [Col|Result]).

    %% if
    %% 	length(Col)==1 ->
    %% 	    io:fwrite("Flip row~n"),
    %% 	    Row = flipRow([{Id,Tile}|T],[]),
    %% 	    UpdatedTileDict = updateTileDict(Row, TileDict),
    %% 	    getCols(Row,IdsLeft, UpdatedTileDict, Result);
    %% 	true ->
    %% 	    io:fwrite("Continue withe next in row~n"),
    %% 	    io:fwrite("Cols:~p~n",[Col]),
    %% 	    NewIds = popTileIds(IdsLeft, getTileIds(Col,[]),[]),
    %% 	    getCols(T,NewIds, NewTileDict, [Col,Result])
    %% end.


    %% Col = getCol(CornerId, Rest, TileDict).
    %% {NextId, NextTile} = findNextColTile(CornerId, Rest, TileDict).
    %% mul(Corners,1).

updateTileDict([], TileDict)-> TileDict;
updateTileDict([{Id,Tile}|T], TileDict)->
    updateTileDict(T, dict:store(Id,Tile,TileDict)).
    

flipRow([],Result)->lists:reverse(Result);
flipRow([{Id, Tile}|T],Result)->
    %% io:fwrite("Id:~p Tile~p~n",[Id, Tile]),
    Flipped = upsideDown(Tile),
    flipRow(T,[{Id, Flipped}|Result]).

popTileIds([], Remove, Result)-> lists:reverse(Result);
popTileIds([Id|T], Remove, Result)->
    ToBeRemoved = lists:member(Id, Remove),
    if
	ToBeRemoved->
	    popTileIds(T, Remove,Result);
	 true ->
	    popTileIds(T, Remove,[Id|Result])
    end.
%% getTileIds([],Result)->lists:reverse(Result);
%% getTileIds([{Id, _}|T],Result)->
%%     getTileIds(T,[Id,Result]).

getCol(Id, IdList, TileDict)->
    Tile = dict:fetch(Id, TileDict),
    getCol(Id, IdList, TileDict, [{Id, Tile}]).
    %% if
    %%    length(Result)>1->
    %% 	    Result;
    %% 	true ->
    %% 	    NewTileDict = flipAll(TileDict)
    %% end.

getCol(Id, IdList, TileDict, Result)->
    {NextId, NextTile} = findNextColTile(Id, IdList, TileDict),
    if
	length(NextTile)>0->
	    NewIdList = pop(NextId,IdList,[]),
	    NewTileDict = dict:store(NextId,NextTile,TileDict),
	    getCol(NextId, NewIdList, NewTileDict, [{NextId,NextTile}|Result]);
	true -> 
	    %% Col has ended, return
	    {lists:reverse(Result),TileDict}
    end.

getRow(Id, IdList, TileDict, Result)->
    {NextId, NextTile} = findNextRowTile(Id, IdList, TileDict),
    if
	length(NextTile)>0->
	    NewIdList = pop(NextId,IdList,[]),
	    NewTileDict = dict:store(NextId,NextTile,TileDict),
	    getRow(NextId, NewIdList, NewTileDict, [{NextId,NextTile}|Result]);
	true -> 
	    %% Row has ended, return
	    {lists:reverse(Result),TileDict}
    end.


%% flipAll(TileDict)->
%%     flipAll(dict:to_list(TileDict),dict:new()).

%% flipAll([{Id,Tile}|T], TileDict)->
%%     io:fwrite("Tile:~p ~p ~n",[Id, Tile]).

findNextRowTile(Id, [], TileDict)-> {none, []};
findNextRowTile(Id, [NextId|T], TileDict)->
    Tile = dict:fetch(Id,TileDict),
    Next = dict:fetch(NextId,TileDict),
    %% io:fwrite("Current:~p~n",[Tile]),
    Match = matchTilesHor(Tile,Next),
    %% io:fwrite("Found match:~p~n",[Match]),
    if
	length(Match)>0->
	    {NextId,Match};
	true ->
	    findNextRowTile(Id, T, TileDict)
    end.

findNextColTile(Id, [], TileDict)-> {none, []};
findNextColTile(Id, [NextId|T], TileDict)->
    %% io:fwrite("Compare ~p with ~p~n",[Id, NextId]),
    Tile = dict:fetch(Id,TileDict),
    Next = dict:fetch(NextId,TileDict),
    %% io:fwrite("Current:~p~n",[Tile]),
    Match = matchTilesVer(Tile,Next),
    %% io:fwrite("Found Col match:~p~n",[Match]),
    if
	length(Match)>0->
	    {NextId,Match};
	true ->
	    findNextColTile(Id, T, TileDict)
    end.

matchTilesHorOld(Left,Right)->
    %% io:fwrite("Compare tiles:~n ~p~n ~p~n",[Left,Right]),
    S1 = getRightSide(Left,[]),
    S2 = getLeftSide(Right,[]),
    IsMatch = (S1==S2),
    IsReverseMatch = (S1==lists:reverse(S2)),
    %% io:fwrite("Compare sides:~p ~p Match:~p~n",[S1,S2, IsMatch]),
    if
	IsMatch ->
	    Right;
	IsReverseMatch ->
	    lists:reverse(Right);
	true ->
	    []
    end.

turn90(Tile)-> turnTile(tools:transpose(Tile)).
turn180(Tile)-> turn90(turn90(Tile)).
turn270(Tile)-> turn180(turn90(Tile)).

getPermutations(Tile)->

    Turn90 = turn90(Tile),
    Turn180 = turn180(Tile),
    Turn270 = turn270(Tile),

    Reversed = turnTile(Tile),
    ReverseTurn90 = turn90(Reversed),
    ReverseTurn180 = turn180(Reversed),
    ReverseTurn270 = turn270(Reversed),
    
    %% io:fwrite("Original: ~n"),
    %% printTile(Tile),
    
    %% io:fwrite("Turned 90:~n"),
    %% printTile(Turn90),

    %% io:fwrite("Turned 180:~n"),
    %% printTile(Turn180),

    %% io:fwrite("Turned 270:~n"),
    %% printTile(Turn270).

    %% io:fwrite("Reversed:~n"),
    %% printTile(Reversed).
    [Tile, Turn90, Turn180, Turn270, Reversed, ReverseTurn90, ReverseTurn180, ReverseTurn270].


    
matchTilesPermVer(Upper, [])-> [];
matchTilesPermVer(Upper, [Lower|T])->
    S1 = getBottom(Upper),
    S2 = getTop(Lower),
    IsMatch = (S1==S2),
    if
	IsMatch ->
	    Lower;
	true ->
	    matchTilesPermVer(Upper, T)
    end.

matchTilesPermHor(Left, [])-> [];
matchTilesPermHor(Left, [Right|T])->
    S1 = getRightSide(Left,[]),
    S2 = getLeftSide(Right),
    %% S1 = getBottom(Upper),
    %% S2 = getTop(Lower),
	IsMatch = (S1==S2),
    IsMatch = (S1==S2),
    if
	IsMatch ->
	    Right;
	true ->
	    matchTilesPermHor(Left, T)
    end.

matchTilesVer(Upper,Lower)->
    io:fwrite("Compare tiles:~n ~p~n ~p~n",[Upper,Lower]),
    S1 = getBottom(Upper),
    matchTilesPermVer(Upper, getPermutations(Lower)).

    %% S2 = getTop(Lower),
    %% io:fwrite("Upper tile lower side:~p~n",[getBottom(Upper)]),
    %% io:fwrite("Lower tile upper side:~p~n",[getTop(turnTile(Lower))]),
    %% io:fwrite("Lower tile turned upper side:~p~n",[getTop(upsideDown(Lower))]),
    %% io:fwrite("Lower tile upsidedown upper side:~p~n",[getTop(Lower)]),
    %% io:fwrite("Lower tile turned upside down upper side:~p~n",[getTop(turnTile(upsideDown(Lower)))]),

    %% IsMatch = (S1==getTop(Lower)),
    %% IsReverseMatch = (S1==getTop(turnTile(Lower))),
    %% IsUpsideDownMatch = (S1==getTop(upsideDown(Lower))),
    %% IsUpsideDownReverseMatch = (S1==getTop(turnTile(upsideDown(Lower)))),
    %% IsTurned = (S1==getTop(tools:transpose(Lower))),
    %% IsTurnedReversed = (S1==getTop(turnTile(tools:transpose(Lower)))),
    %% IsTurnedUpsideDown = (S1==getTop(tools:transpose(upsideDown(Lower)))),
    %% IsTurnedUpsideDownReversed = (S1==getTop(upsideDown(turnTile(tools:transpose(Lower))))),


    %% Test = upsideDown(turnTile(tools:transpose(Lower))),
    %% io:fwrite("Upside down:~p~n",[Test]),
    %% io:fwrite("Upper bottom:~p~n",[S1]),
    %% io:fwrite("Lower top:~p~n",[getTop(Test)]),
    %% io:fwrite("Match:~p ~p~n",[(S1==getTop(Test)),IsTurnedUpsideDownReversed]),
    %% io:fwrite("Matches: ~p ~p ~p ~p ~p ~p ~p ~p ~n",[IsMatch, IsReverseMatch, IsUpsideDownMatch, IsUp
						     %% sideDownReverseMatch, IsTurned, IsTurnedReversed, IsTurnedUpsideDown, IsTurnedUpsideDownReversed]),
    %% io:fwrite("Compare sides:~p ~p Match:~p~n",[S1,S2, IsMatch]),
    %% if
    %% 	IsMatch ->
    %% 	    %% io:fwrite("Found match~n"),
    %% 	    Lower;
    %% 	IsReverseMatch ->
    %% 	    %% io:fwrite("Should reverse tile~n"),
    %% 	    turnTile(Lower);
    %% 	IsUpsideDownMatch ->
    %% 	    upsideDown(Lower);
    %% 	IsUpsideDownReverseMatch ->
    %% 	    turnTile(upsideDown(Lower));
    %% 	IsTurned ->
    %% 	    getTop(tools:transpose(Lower));
    %% 	IsTurnedReversed ->
    %% 	    getTop(turnTile(tools:transpose(Lower)));
    %% 	IsTurnedUpsideDown ->
    %% 	    getTop(tools:transpose(upsideDown(Lower)));
    %% 	IsTurnedUpsideDownReversed ->
    %% 	    upsideDown(turnTile(tools:transpose(Lower)));
    %% 	true ->
    %% 	    []
    %% end.

matchTilesHor(Left,Right)->
    %% io:fwrite("Compare tiles:~n ~p~n ~p~n",[Upper,Lower]),
    S1 = getRightSide(Left,[]),
    matchTilesPermHor(Left, getPermutations(Right)).

    %% S2 = getLeftSide(Right,[]),

    %% S2 = getTop(Lower),
    %% io:fwrite("Upper tile lower side:~p~n",[getBottom(Upper)]),
    %% io:fwrite("Lower tile upper side:~p~n",[getTop(turnTile(Lower))]),
    %% io:fwrite("Lower tile turned upper side:~p~n",[getTop(upsideDown(Lower))]),
    %% io:fwrite("Lower tile upsidedown upper side:~p~n",[getTop(Lower)]),
    %% io:fwrite("Lower tile turned upside down upper side:~p~n",[getTop(turnTile(upsideDown(Lower)))]),

    %% IsMatch = (S1==getLeftSide(Right)),
    %% IsReverseMatch = (S1==getLeftSide(turnTile(Right))),
    %% IsUpsideDownMatch = (S1==getLeftSide(upsideDown(Right))),
    %% IsUpsideDownReverseMatch = (S1==getLeftSide(turnTile(upsideDown(Right)))),
    %% IsTurned = (S1==getLeftSide(tools:transpose(Right))),
    %% IsTurnedReversed = (S1==getLeftSide(turnTile(tools:transpose(Right)))),
    %% IsTurnedUpsideDown = (S1==getLeftSide(tools:transpose(upsideDown(Right)))),
    %% IsTurnedUpsideDownReversed = (S1==getLeftSide(upsideDown(turnTile(tools:transpose(Right))))),


    %% Test = upsideDown(turnTile(tools:transpose(Lower))),
    %% io:fwrite("Upside down:~p~n",[Test]),
    %% io:fwrite("Upper bottom:~p~n",[S1]),
    %% io:fwrite("Lower top:~p~n",[getTop(Test)]),
    %% io:fwrite("Match:~p ~p~n",[(S1==getTop(Test)),IsTurnedUpsideDownReversed]),
    %% io:fwrite("Matches: ~p ~p ~p ~p ~p ~p ~p ~p ~n",[IsMatch, IsReverseMatch, IsUpsideDownMatch, IsUp
						     %% sideDownReverseMatch, IsTurned, IsTurnedReversed, IsTurnedUpsideDown, IsTurnedUpsideDownReversed]),
    %% io:fwrite("Compare sides:~p ~p Match:~p~n",[S1,S2, IsMatch]),

    %% if
    %% 	IsMatch ->
    %% 	    %% io:fwrite("Found match~n"),
    %% 	    Right;
    %% 	IsReverseMatch ->
    %% 	    %% io:fwrite("Should reverse tile~n"),
    %% 	    turnTile(Right);
    %% 	IsUpsideDownMatch ->
    %% 	    upsideDown(Right);
    %% 	IsUpsideDownReverseMatch ->
    %% 	    turnTile(upsideDown(Right));
    %% 	IsTurned ->
    %% 	    getTop(tools:transpose(Right));
    %% 	IsTurnedReversed ->
    %% 	    getTop(turnTile(tools:transpose(Right)));
    %% 	IsTurnedUpsideDown ->
    %% 	    getTop(tools:transpose(upsideDown(Right)));
    %% 	IsTurnedUpsideDownReversed ->
    %% 	    upsideDown(turnTile(tools:transpose(Right)));
    %% 	true ->
    %% 	    []
    %% end.


			

turnTile(Tile)->
    turnTile(Tile,[]).
turnTile([],Result)-> lists:reverse(Result);
turnTile([H|T],Result) -> turnTile(T,[lists:reverse(H)|Result]).

upsideDown(Tile)->
    lists:reverse(Tile).
	
pop(_,[],Result)-> lists:reverse(Result);
pop(Id,[Id|T],Result)-> lists:reverse(Result)++T;
pop(Id, [H|T],Result) -> pop(Id,T,[H|Result]).
    
getTileIds([], Result)-> lists:reverse(Result);
getTileIds([{Id,Tile}|T], Result)->
    %% io:fwrite("~p~n",[Id]),
    getTileIds(T, [Id|Result]).
    
createImageDict([], Dict)-> Dict;
createImageDict([{Id,Tile}|T], Dict)->
    %% io:fwrite("~p~n",[Id]),
    createImageDict(T, dict:store(Id,Tile,Dict)).

getCorners([],Corners)-> Corners;
getCorners([{Id, 2}|T],Corners)->getCorners(T,[Id|Corners]);
getCorners([{Id, N}|T],Corners)->
    %% io:fwrite("Counting corner:~p~n",[N]),
    getCorners(T,Corners).
    
countMatrixBoolColumns([],Result) -> lists:reverse(Result);
countMatrixBoolColumns([{Id,Matches}|T],Result) ->
    %% io:fwrite("Entry:~p ~p ~n",[Id, Matches]),
    Count = countBoolTuples(Matches,0),
    %% io:fwrite("Tile:~p Matches with ~p cubes~n",[Id, Count]),
    countMatrixBoolColumns(T,[{Id,Count}|Result]).
    
countBoolTuples([],Count) -> Count;
countBoolTuples([{Id, true}|T],Count) -> countBoolTuples(T,Count+1);
countBoolTuples([{Id, Value}|T],Count) ->
    %% io:fwrite("Count:Id=~p Value=~p~n",[Id,Value]),
    countBoolTuples(T,Count).

countMatching([],Result) -> lists:reverse(Result);
countMatching([{Id, Matches}|T],Result)->
    %% io:fwrite("Check:~p (~p) ~n",[Id,Matches]),
    Res = countMatches(Matches,[]),
    countMatching(T,[{Id,Res}|Result]).


countMatches([],Result)-> lists:reverse(Result);
countMatches([{Id,Matches}|T],Result)->
    Res = isMatch(Matches),
    %% io:fwrite("Count bool:~p ~p ~p~n",[Id,Matches,Res]),
    countMatches(T,[{Id,Res}|Result]).

isMatch(Matches)->
    tools:boolSum(Matches)==1.

compareAllTiles([],Tiles,Result) ->
    lists:reverse(Result);
compareAllTiles([Tile|T],Tiles,Result) ->
    {Id,_} = Tile,
    %% io:fwrite("Compare tile:~p~n",[Id]),
    Res = compareTiles(Tile,Tiles,[]),
    compareAllTiles(T,Tiles,[{Id,Res}|Result]).

compareTiles(Tile1,[],Result)-> lists:reverse(Result);
compareTiles(Tile1,[Tile2|T],Result)->
    Res = compareTileSides(Tile1,Tile2),
    {Id1,_} = Tile1,
    {Id2,_} = Tile2,
    %% io:fwrite("Id1:~p Id2:~p Result:~p~n",[Id1,Id2,Res]),
    compareTiles(Tile1,T,[{Id2,Res}|Result]).
    
compareTileSides(Tile1,Tile2)->
    %% io:fwrite("Compare:~n~p~n~p~n",[Tile1,Tile2]),
    Side1 = lists:nth(1,getTileSides([Tile1],[])),
    Side2 = lists:nth(1,getTileSides([Tile2],[])),
    compareSides(Side1,Side2,[]).

compareSides([], _ ,Result)->
    lists:reverse(Result);
compareSides([L1|T1],Sides,Result) ->
    HasMatch = (hasMatches(L1,Sides) or hasMatches(lists:reverse(L1),Sides)),
    %% io:fwrite("Side1:~p~n",[L1]),
    %% io:fwrite("Side2:~p~n",[Sides]),
    %% io:fwrite("Has match:~p~n",[HasMatch]),
    compareSides(T1,Sides,[HasMatch|Result]).

hasMatches(_,[])-> false;
hasMatches(L1,[L1|T2])-> 
    %% io:fwrite("Match ~p == ~p ~n",[L1,L1]),
    true;
hasMatches(L1,[L2|T2]) -> 
    %% io:fwrite("Compare ~p == ~p ~n",[L1,L2]),
    hasMatches(L1,T2).
    

isEqual([],[]) -> true;
isEqual([H|T1],[H|T2]) ->
    isEqual(T1,T2);
isEqual(_,_) -> false.

    
getTileSides([],Result)->lists:reverse(Result);
getTileSides([Tile|T],Result)->
    %% io:fwrite("Tile:~p ~n",[Tile]),
    getTileSides(T,[getSides(Tile)|Result]).
    
getSides({Id, Tile})->
    [getLeftSide(Tile,[]),
    getTop(Tile),
    getRightSide(Tile,[]),
    getBottom(Tile)].

getBottom(Tile)->
    lists:last(Tile).
    
getTop([Top|_])->
    Top.

getRightSide(Tile) -> getRightSide(Tile,[]).
getRightSide([],Result)-> lists:reverse(Result);
getRightSide([H|T],Result) -> 
    getRightSide(T,[lists:last(H)|Result]).
    
getLeftSide(Tile) -> getLeftSide(Tile,[]).
getLeftSide([],Result) -> lists:reverse(Result);
getLeftSide([[First|Rest]|T],Result)->
    getLeftSide(T,[First|Result]).

formatTileData([],[],Result)->
    lists:reverse(Result);
formatTileData([],Tile,Result)->
    formatTileData([],[], [parseTile(lists:reverse(Tile),[])|Result]);
formatTileData([[]|T],Tile, Result) ->
    %% io:fwrite("Found break~n Tile:~p~n",[Tile]),
    formatTileData(T,[], [parseTile(lists:reverse(Tile),[])|Result]);
formatTileData([H|T],Tile,Result) ->
    %% io:fwrite("Line:~p~n",[H]),
    formatTileData(T,[H|Tile],Result).

parseTile([],Result)->
    lists:reverse(Result);
parseTile([L|T],Result)->
    %% io:fwrite("Parse tile data~p~n",[L]),
    Id = parseId(L,[]),
    Tile = T,
    %% io:fwrite("Id:~p~n",[Id]),
    %% printTile(Tile),
    {Id,Tile}.

parseId(L,Result)->
    list_to_integer(lists:droplast(lists:nth(2,tools:split(L," ")))).

printTile([])->
    %% io:fwrite("~n");
    ok;
printTile([Row|T])->
    io:fwrite("~p~n",[Row]),
    printTile(T).

