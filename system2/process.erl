%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(process).
-export([start/2]).

start(System, Id) ->
  PL = spawn(p2p, start, []),
  App = spawn(app, start, []),
  App ! {bind, Id, PL},
  PL ! {bind, App, Id},
  System ! {new_process, Id, PL, App}.

