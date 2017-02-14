%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(lossyp2p).
-export([start/1]).

start(Reliability) ->
  receive
    {bind, Owner, OwnerId} -> next(Owner, OwnerId, Reliability)
  end.

next(Owner, OwnerId, Reliability) ->
  receive
    {map, Map} -> next(Owner, OwnerId, Map, Reliability)
  end.

next(Owner, OwnerId, Map, Reliability) ->
  receive
    {pl_send, To, Msg} ->
      Rand = rand:uniform(100),
      if Reliability >= Rand ->
        maps:get(To, Map) ! {internal, OwnerId, Msg};
      true ->
        dont_send
      end;
    {internal, From, Msg} ->
      Owner ! {pl_deliver, From, Msg}
  end,
  next(Owner, OwnerId, Map, Reliability).

