%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(rb).
-export([start/0]).

start() ->
  receive {bind, App, BEB} -> next(App, BEB, []) end.

next(App, BEB, Delivered) ->
  receive
    {rb_broadcast, M} ->
      BEB ! {beb_broadcast, {data, self(), M}},
      next(App, BEB, Delivered);
    {beb_deliver, From, {data, S, M}} ->
      Mem = lists:member(M, Delivered),
      if Mem ->
        next(App, BEB, Delivered);
      true ->
        App ! {rb_deliver, From, M},
        BEB ! {beb_broadcast, {data, S, M}},
        next(App, BEB, Delivered ++ [M])
      end
   end.
