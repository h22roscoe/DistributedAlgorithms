%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(process3).
-export([start/2]).

start(Id, Parent) ->
  PL = spawn(perfect_P2P_links, start, [self()]),
  BEB = spawn(best_effort_broadcast, start, []),
  Parent ! {link, PL, BEB},
  next(Id, PL, BEB).

next(Id, PL, BEB) ->
  receive
    {task1, start, Max_Messages, Timeout} ->
      timer:send_after(Timeout, stop),
      Map = [{N, {0, 0}} || N <- Ns],
      self() ! broadcast,
      if 
        Max_Messages == 0 ->
          task3(Map, infinity, Id);
        true ->
          task3(Map, Max_Messages, Id)
      end
  end.

task3(Map, Max_Messages, Id) ->
  receive
    {hello, Sender} ->
      NewMap = update_recs(Sender, Map),
      task3(NewMap, Max_Messages, Id);
    broadcast ->  
      [N ! {hello, self()} || {N, {_, Sen}} <- Map, Sen < Max_Messages],
      WithSends = [add_sends(N, Max_Messages) || N <- Map],
      task3(WithSends, Max_Messages, Id);
    stop -> io:format("~p: ~w~n", [Id, lists:map(fun({_, Snd}) -> Snd end, Ns)])
  after 0 -> self() ! broadcast, task3(Map, Max_Messages, Id)
  end.

add_sends({N, {Rec, Sen}}, Max_Messages) ->
  if
    Sen < Max_Messages -> {N, {Rec, Sen + 1}};
    true -> {N, {Rec, Sen}}
  end.

update_recs(Sender, [{Sender, {Rec, Sen}} | Rest]) ->
  [{Sender, {Rec + 1, Sen}} | Rest];
update_recs(Sender, [Head | Rest]) ->
  [Head | update_recs(Sender, Rest)].
