% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(system1).
-export([start/0]).

start() ->
  Processes = [spawn(process, start, [Id]) || Id <- lists:seq(1, 5)],
  [P ! {neighbours, Processes} || P <- Processes], % send list of all processes to each process
  [P ! {task1, start, 1000, 3000} || P <- Processes],
  ok.

