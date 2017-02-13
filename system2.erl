%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(system2).
-export([start/0]).

start() ->
  N = 5,
  Processes = [spawn(process2, start, [Id, self()]) || Id <- lists:seq(1, N)],
  Map = [receive {new_pl, Id, PL} -> {Id, PL} end || _ <- lists:seq(1, N)],
  PLs = lists:map(fun({_, PL}) -> PL end, Map),
  [PL ! {bind, Map} || PL <- PLs],  
  [P ! {task2, start, 0, 3000, lists:seq(1, N)} || P <- Processes],
  ok.

