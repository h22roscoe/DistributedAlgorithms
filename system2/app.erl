%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(app).
-export([start/0]).

start() ->
  receive
    {bind, Id, PL} -> next(Id, PL)
  end.

next(Id, PL) ->
  receive
    {task2, start, Max_Messages, Timeout, Ns} ->
      timer:send_after(Timeout, stop),
      Map = maps:from_list([{N, 0} || N <- Ns]),
      if Max_Messages == 0 ->
        task2(Map, infinity, Id, PL, 0);
      true ->
        task2(Map, Max_Messages, Id, PL, 0)
      end
  end.

task2(Map, Max_Messages, Id, PL, Sen) ->
  receive
    {pl_deliver, Sender, hello} -> 
      Recs = maps:get(Sender, Map),
      NewMap = Map#{Sender := Recs + 1},
      task2(NewMap, Max_Messages, Id, PL, Sen);
    stop ->
      List = maps:to_list(Map),
      WithSen = lists:map(fun({_, Rec}) -> {Sen, Rec} end, List),
      io:format("~p: ~w~n", [Id, WithSen])
  after 0 ->
    if Sen < Max_Messages ->
      [PL ! {pl_send, To, hello} || {To, _} <- maps:to_list(Map)],
      task2(Map, Max_Messages, Id, PL, Sen + 1);
    true ->
      task2(Map, Max_Messages, Id, PL, Sen)
    end
  end.

