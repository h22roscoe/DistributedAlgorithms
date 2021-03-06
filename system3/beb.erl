%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(beb).
-export([start/0]).

start() ->
  receive
    {bind, App, PL} -> next(App, PL)
  end.

next(App, PL) ->
  receive
    {processes, Processes} -> next(Processes, App, PL)
  end.

next(Processes, App, PL) ->
  receive
    {beb_broadcast, Msg} ->
      [PL ! {pl_send, To, Msg} || To <- Processes]; % receive from BEB and send to PLs
    {pl_deliver, From, Msg} ->
      App ! {beb_deliver, From, Msg} % receive from PL and send to App
  end,
  next(Processes, App, PL).
