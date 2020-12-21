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
sol2()->
    Fname="input",
    Data = tools:readlines(Fname),
    FoodData = formatFoodData(Data,[]),
    ADict = createAllergyDict(FoodData,dict:new()),
    
    Common = findCommonIngredients(dict:fetch_keys(ADict), ADict, []),
    IDict = findFoodWithAlergene(Common,[],dict:new()),
    Allergenes = dict:to_list(IDict),
    createAllergeneString(Allergenes).


%% Correct: 
sol1()->
    Fname="input",
    Data = tools:readlines(Fname),
    FoodData = formatFoodData(Data,[]),
    ADict = createAllergyDict(FoodData,dict:new()),
    
    Common = findCommonIngredients(dict:fetch_keys(ADict), ADict, []),
    IDict = findFoodWithAlergene(Common,[],dict:new()),
    Allergenes = dict:fetch_keys(IDict),
    Foods = getAllFoods(FoodData,[]),
    NonAlFood = extractElements(Foods, Allergenes,[]),
    length(NonAlFood).

test1()->
    Fname="example",
    Data = tools:readlines(Fname),
    FoodData = formatFoodData(Data,[]),
    ADict = createAllergyDict(FoodData,dict:new()),
    
    Common = findCommonIngredients(dict:fetch_keys(ADict), ADict, []),
    IDict = findFoodWithAlergene(Common,[],dict:new()),
    Allergenes = dict:fetch_keys(IDict),
    Foods = getAllFoods(FoodData,[]),
    NonAlFood = extractElements(Foods, Allergenes,[]),
    length(NonAlFood).

test2()->
    Fname="example",
    Data = tools:readlines(Fname),
    FoodData = formatFoodData(Data,[]),
    ADict = createAllergyDict(FoodData,dict:new()),
    
    Common = findCommonIngredients(dict:fetch_keys(ADict), ADict, []),
    IDict = findFoodWithAlergene(Common,[],dict:new()),
    Allergenes = dict:to_list(IDict),
    %% io:fwrite("~p~n",[Allergenes]),
    lists:sort(fun({KeyA,ValA}, {KeyB,ValB}) -> {ValA,KeyA} =< {ValB,KeyB} end, [{a,b},{b,a}]),
    Sorted = lists:sort(fun({KeyA,ValA}, {KeyB,ValB}) -> {ValA,KeyA} =< {ValB,KeyB} end, Allergenes),
    createAllergeneString(Allergenes).
    %% Foods = getAllFoods(FoodData,[]),
    %% NonAlFood = extractElements(Foods, Allergenes,[]),
    %% length(NonAlFood).

createAllergeneString(Allergenes)->
    Sorted = lists:sort(fun({KeyA,ValA}, {KeyB,ValB}) -> {ValA,KeyA} =< {ValB,KeyB} end, Allergenes),
    %% io:fwrite("Sorted:~p~n",[Sorted]),
    createAllergeneString(Sorted,[]).
createAllergeneString([],Result)-> lists:reverse(Result);
createAllergeneString([{Item, _}],Result)->
    createAllergeneString([],lists:append(lists:reverse(Item),Result));
createAllergeneString([{Item, _}|T],Result)->
    NewItem = lists:append(Item,","),
    %% io:fwrite("New item:~p~n",[NewItem]),
    createAllergeneString(T,lists:append(lists:reverse(NewItem),Result)).

extractElements([], Extract,Result)-> lists:reverse(Result);
extractElements([E|T], Extract,Result)->
    ToRemove = lists:member(E,Extract),
    if
	ToRemove->
	    extractElements(T, Extract,Result);
	true ->
	    extractElements(T, Extract,[E|Result])
    end.

getAllFoods([],Result)->
    lists:reverse(Result);
getAllFoods([{Food,_}|T],Result)->
    %% io:fwrite("Food:~p~n",[Food]),
    getAllFoods(T,Food++Result).
    

findFoodWithAlergene([],[],Dict)-> Dict;
findFoodWithAlergene([],Stack,Dict)-> findFoodWithAlergene(Stack,[],Dict);
findFoodWithAlergene([{A, I}|T],Stack,Dict)->
    %% io:fwrite("Allergene:~p~n",[A]),
    if
	length(I)==1->
	    %% io:fwrite("Unique, add to map~n"),
	    [Item] = I,
	    NewDict = dict:store(Item,A,Dict),
	    findFoodWithAlergene(T,Stack,NewDict);
	true ->
	    %% io:fwrite("Extract already found items~n"),
	    NewI = removeKnownItems(I,Dict,[]),
	    findFoodWithAlergene(T,[{A,NewI}|Stack],Dict)
    end.
    %% findFoodWithAlergene([{A, I}|T],Dict)->

removeKnownItems([],KnownDict,Result)-> lists:reverse(Result);
removeKnownItems([H|T],KnownDict,Result)->
    IsKnown = dict:is_key(H, KnownDict),
    %% io:fwrite("Item:~p is known:~p~n",[H,IsKnown]),
    if
	IsKnown->
	    removeKnownItems(T,KnownDict,Result);
	true  ->
	    removeKnownItems(T,KnownDict,[H|Result])
    end.

findCommonIngredients([], _, Result)-> lists:reverse(Result);
findCommonIngredients([H|T], Dict, Result)->
    %% io:fwrite("Allergene:~p~n",[H]),
    %% io:fwrite("Ingredients:~p~n",[dict:fetch(H,Dict)]),
    Common = keepCommon(dict:fetch(H,Dict)),
    findCommonIngredients(T, Dict, [{H,Common}|Result]).
    


keepCommon([L])->L;
keepCommon([L1,L2|T])->
    Common = getCommon(L1,L2,[]),
    keepCommon([Common|T]).
    
getCommon([],List,Result)-> lists:reverse(Result);
getCommon([A|T],List,Result)->
    IsCommon = lists:member(A,List),
    if
	IsCommon->
	    getCommon(T,List,[A|Result]);
	true ->
	    getCommon(T,List,Result)
    end.

createAllergyDict([],Dict)->Dict;
createAllergyDict([{I,A}|T],Dict)->
    %% io:fwrite("Ingre:~p All:~p~n",[I,A]),
    NewDict = addDictEntries(A,I,Dict),
    createAllergyDict(T,NewDict).
    
addDictEntries([],_,Dict)->Dict;
addDictEntries([A|T],I,Dict)->
    %% io:fwrite("Add entries for ~p~n",[A]),
    NewDict = appentToDict(A,I,Dict),
    addDictEntries(T,I,NewDict).
	
appentToDict(A,I,Dict)->
    Exists = dict:is_key(A,Dict),
    if
	not Exists ->
	    %% io:fwrite("Adding key~p",[A]),
	    NewDict = dict:store(A, [], Dict);
	true ->
	    NewDict = Dict
    end,
    %% io:fwrite("Append list:~p~n",[I]),
    dict:append_list(A,[I],NewDict).
    

formatFoodData([],Result)-> lists:reverse(Result);
formatFoodData([H|T],Result)->
    %% io:fwrite("Raw:~p~n",[H]),
    Res = extract_food_data(tools:split(H," "),[]),
    formatFoodData(T, [Res|Result]).


extract_food_data([],Food)-> ok;
extract_food_data(["(contains"|T],Food)->
    %% io:fwrite("Found allergenes~n"),
    {lists:reverse(Food),extract_allergenes(T,[])};
extract_food_data([H|T],Food)->
    %% io:fwrite("Entry:~p~n",[H]),
    extract_food_data(T,[H|Food]).

extract_allergenes([],Result)->
    %% Item = lists:droplast(H),
    %% io:fwrite("Last item:~p~n",[Item]),
    %% lists:reverse([Item|Result]);
    lists:reverse(Result);
extract_allergenes([H|T],Result)->
    %% io:fwrite("Aller:~p~n",[H]),
    extract_allergenes(T,[lists:droplast(H)|Result]).
