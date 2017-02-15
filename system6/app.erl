%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(app).
-export([start/0]).

start() ->
  receive
    {bind, Id, RB} -> next(Id, RB)
  end.

next(Id, RB) ->
  receive
    {task6, start, Max_Messages, Timeout, Ns} ->
      timer:send_after(Timeout, stop),
      if Id == 3 -> timer:send_after(5, stop); true -> nothing end, % crash process 3
      Map = maps:from_list([{N, 0} || N <- Ns]),
      if Max_Messages == 0 ->
        task6(Map, infinity, Id, RB, 0);
      true ->
        task6(Map, Max_Messages, Id, RB, 0)
      end
  end.

task6(Map, Max_Messages, Id, RB, Sen) ->
  receive
    {rb_deliver, Sender, {_, _, hello}} ->
      Recs = maps:get(Sender, Map),
      NewMap = Map#{Sender := Recs + 1},
      task6(NewMap, Max_Messages, Id, RB, Sen);
    stop ->
      List = maps:to_list(Map),
      WithSen = lists:map(fun({_, Rec}) -> {Sen, Rec} end, List),
      io:format("~p: ~w~n", [Id, WithSen])
  after 0 ->
    if Sen < Max_Messages ->
      RB ! {rb_broadcast, {Sen, self(), hello}},
      task6(Map, Max_Messages, Id, RB, Sen + 1);
    true ->
      task6(Map, Max_Messages, Id, RB, Sen)
    end
  end.
