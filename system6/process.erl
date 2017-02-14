%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(process).
-export([start/2]).

start(Id, System) ->
  BEB = spawn(beb, start, []),
  RB = spawn(rb, start, []),
  App = spawn(app, start, []),
  PL = spawn(p2p, start, []),
  App ! {bind, Id, RB},
  BEB ! {bind, RB, PL},
  PL ! {bind, BEB, Id},
  RB ! {bind, App, BEB},
  System ! {new_process, Id, App, PL, BEB}.
