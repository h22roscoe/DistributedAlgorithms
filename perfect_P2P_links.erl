%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(perfect_P2P_links).
-export([start/1]).

start(Process) ->
  receive
    {bind, Map} -> next(Process, Map)
  end.

next(Process, Map) ->
  receive
    {pl_send, To, Msg} ->
      [PL ! {send, Msg} || {Id, PL} <- Map, Id == To];
    {send, Msg} ->
      Process ! {pl_deliver, Msg}
  end,
  next(Process, Map).
