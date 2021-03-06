%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(system2).
-export([start/0]).

start() ->
  N = 5,
  [spawn(process, start, [self(), Id]) || Id <- lists:seq(1, N)],
  IdAppPLs = [receive {new_process, Id, PL, App} -> {Id, App, PL} end || Id <- lists:seq(1, N)], % group IDs, PLs and Apps for later extraction
  Ids = lists:map(fun({Id, _, _}) -> Id end, IdAppPLs),
  IdPLMap = maps:from_list([{Id, PL} || {Id, _, PL} <- IdAppPLs]),  % create map of IDs to PLs
  [PL ! {map, IdPLMap} || {_, _, PL} <- IdAppPLs],
  [App ! {task2, start, 250000, 10000, Ids} || {_, App, _} <- IdAppPLs],
  ok.
