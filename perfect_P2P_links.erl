%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(perfect_P2P_links).
-export([start/0]).

start() ->
  receive
    {bind, Process, PLs} -> next(Process, PLs)
  end.

next(Process, PLs) ->
  receive
    {pl_send, Msg} ->
      [PL ! {broadcast, Msg} || PL <- PLs];
    {broadcast, Msg} ->
      Process ! {pl_deliver, Msg}
  end,
  next(Process, PLs).
