%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(app).
-export([start/0]).

start() ->
  receive
    {bind, Id, BEB} -> next(Id, BEB)
  end.

next(Id, BEB) ->
  receive
    {task5, start, Max_Messages, Timeout, Ns} ->
      timer:send_after(Timeout, stop),
      if Id == 3 -> timer:send_after(300, stop); true -> nothing end, % crash process 3
      Map = maps:from_list([{N, 0} || N <- Ns]),
      if Max_Messages == 0 ->
        task5(Map, infinity, Id, BEB, 0);
      true ->
        task5(Map, Max_Messages, Id, BEB, 0)
      end
  end.

task5(Map, Max_Messages, Id, BEB, Sen) ->
  receive
    {beb_deliver, Sender, hello} ->
      Recs = maps:get(Sender, Map),
      NewMap = Map#{Sender := Recs + 1}, % increment the received counter in the map respective to sender
      task5(NewMap, Max_Messages, Id, BEB, Sen);
    stop ->
      List = maps:to_list(Map),
      WithSen = lists:map(fun({_, Rec}) -> {Sen, Rec} end, List),
      io:format("~p: ~w~n", [Id, WithSen])
  after 0 ->
    if Sen < Max_Messages ->
      BEB ! {beb_broadcast, hello},
      task5(Map, Max_Messages, Id, BEB, Sen + 1);
    true ->
      task5(Map, Max_Messages, Id, BEB, Sen)
    end
  end.
