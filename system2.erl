%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(system2).
-export([start/0]).

start() ->
  N = 5,
  Processes = [spawn(process2, start, [Id]) || Id <- lists:seq(1, N)],
  PLs = [spawn(perfect_P2P_links, start, []) || _ <- lists:seq(1, N)], 
  link(N, Processes, PLs),
  [P ! {task2, start, 1000, 3000} || P <- Processes],
  ok.

link(N, Processes, PLs) ->
  [lists:nth(I, PLs) ! {bind, lists:nth(I, Processes), PLs} || I <- lists:seq(1, N)],
  [lists:nth(I, Processes) ! {bind, lists:nth(I, PLs)} || I <- lists:seq(1, N)].
