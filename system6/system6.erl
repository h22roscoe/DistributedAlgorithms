%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(system6).
-export([start/0]).

start() ->
  N = 5,
  [spawn(process, start, [Id, self()]) || Id <- lists:seq(1, N)],

  % group IDs, Apps, PLs and BEBs for later extraction
  Quads = [receive {new_process, Id, App, PL, BEB} -> {Id, App, PL, BEB} end || _ <- lists:seq(1, N)]

  % Extract relevant info from Quads and initiate task6
  Ids = lists:map(fun({Id, _, _, _}) -> Id end, Quads),
  [BEB ! {processes, Ids} || {_, _, _, BEB} <- Quads],
  IdPLMap = maps:from_list([{Id, PL} || {Id, _, PL, _} <- Quads]),
  [PL ! {map, IdPLMap} || {_, _, PL, _} <- Quads],
  [App ! {task6, start, 10000, 10000, Ids} || {_, App, _, _} <- Quads],
  ok.
