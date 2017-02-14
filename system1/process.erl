%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(process).
-export([start/1]).

start(Id) ->
  receive
    {neighbours, Ns} -> next(Ns, Id)
  end.

next(Ns, Id) ->
  receive
    {task1, start, Max_Messages, Timeout} ->
      timer:send_after(Timeout, stop),
      Map = maps:from_list([{N, 0} || N <- Ns]),
      self() ! broadcast,
      if Max_Messages == 0 ->
        task1(Map, infinity, Id, 0);
      true ->
        task1(Map, Max_Messages, Id, 0)
      end
  end.

task1(Map, Max_Messages, Id, Sen) ->
  receive
    {hello, Sender} ->
      NewMap = Map#{Sender := maps:get(Sender, Map) + 1},
      task1(NewMap, Max_Messages, Id, Sen);
    stop ->
      List = maps:to_list(Map),
      WithSen = lists:map(fun({_, Rec}) -> {Sen, Rec} end, List),
      io:format("~p: ~w~n", [Id, WithSen])
  after 0 -> 
    if Sen < Max_Messages ->  
      [N ! {hello, self()} || {N, _} <- maps:to_list(Map)],
      task1(Map, Max_Messages, Id, Sen + 1);
    true ->
      task1(Map, Max_Messages, Id, Sen)
    end
  end.

