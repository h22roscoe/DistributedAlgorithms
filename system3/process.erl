%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(process).
-export([start/2]).

start(Id, System) ->
  BEB = spawn(beb, start, []),
  App = spawn(app, start, []),
  PL = spawn(p2p, start, []),
  App ! {bind, Id, BEB},
  BEB ! {bind, App, PL},
  PL ! {bind, BEB, Id},
  System ! {new_process, Id, App, PL, BEB}.
