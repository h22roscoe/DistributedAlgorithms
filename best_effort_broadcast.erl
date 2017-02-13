%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(best_effort_broadcast).
-export([start/0]).

start() ->
  receive
    {bind, Processes, P, PL} -> next(Processes, P, PL)
  end.

next(Processes, P, PL) ->
  receive
    {beb_broadcast, Msg} ->
      [PL ! {pl_send, To, Msg} || To <- Processes];
    {pl_deliver, From, Msg} ->
      C ! {beb_deliver, From, Msg}
  end,
  next(Processes, P, PL).
