%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(p2p).
-export([start/0]).

start() ->
  receive
    {bind, Owner, OwnerId} -> next(Owner, OwnerId)
  end.

next(Owner, OwnerId) ->
  receive
    {map, Map} -> next(Owner, OwnerId, Map)
  end.

next(Owner, OwnerId, Map) ->
  receive
    {pl_send, To, Msg} ->
      maps:get(To, Map) ! {internal, OwnerId, Msg};
    {internal, From, Msg} ->
      Owner ! {pl_deliver, From, Msg}
  end,
  next(Owner, OwnerId, Map).

