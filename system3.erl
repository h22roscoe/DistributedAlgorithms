%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(system3).
-export([start/0]).

start() ->
  N = 5,
  Processes = [spawn(process3, start, [Id]) || Id <- lists:seq(1, N)],
  Map = [receive {link, P, PL, BEB} -> {P, {PL, BEB}} end || _ <- lists:seq(1, N)], 
  PLs = lists:map(fun({_, {PL, _}}) -> PL end, Map),
  BEBs = lists:map(fun({_, {_, BEB}}) -> BEB end, Map),
  [PL ! {bind, Map} || PL <- PLs], 
  [P ! {task2, start, 0, 3000, lists:seq(1, N)} || P <- Processes],
  ok.
