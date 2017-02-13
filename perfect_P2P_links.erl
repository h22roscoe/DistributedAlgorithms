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
      send_to(Process, To, Map, Msg);
    {send, From, Msg} ->
      Process ! {pl_deliver, From, Msg}
  end,
  next(Process, Map).

send_to(From, To, [{To, PL} | _], Msg) ->
  PL ! {send, From, Msg};
send_to(From, To, [_ | Rest], Msg) ->
  send_to(From, To, Rest, Msg).
