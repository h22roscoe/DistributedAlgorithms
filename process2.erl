%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(process2).
-export([start/2]).

start(Id, Parent) ->
  PL = spawn(perfect_P2P_links, start, [self()]),
  Parent ! {new_pl, self(), PL},
  next(Id, PL).

next(Id, PL) ->
  receive
    {task2, start, Max_Messages, Timeout, Ns} ->
      timer:send_after(Timeout, stop),
      Map = [{N, {0, 0}} || N <- Ns],
      self() ! broadcast,
      if Max_Messages == 0 ->
        task2(Map, infinity, Id, PL);
      true ->
        task2(Map, Max_Messages, Id, PL)
      end
  end.

task2(Map, Max_Messages, Id, PL) ->
  receive
    {pl_deliver, Sender, hello} ->
      NewMap = update_recs(Sender, Map),
      task2(NewMap, Max_Messages, Id, PL);
    broadcast ->
      [PL ! {pl_send, N, hello} || {N, {_, Sen}} <- Map, Sen < Max_Messages],
      WithSends = [add_sends(N, Max_Messages) || N <- Map],
      task2(WithSends, Max_Messages, Id, PL);
    stop -> io:format("~p: ~w~n", [Id, lists:map(fun({_, Snd}) -> Snd end, Map)])
  after 0 ->
    self() ! broadcast,
    task2(Map, Max_Messages, Id, PL)
  end.

add_sends({N, {Rec, Sen}}, Max_Messages) ->
  if Sen < Max_Messages ->
    {N, {Rec, Sen + 1}};
  true ->
    {N, {Rec, Sen}}
  end.

update_recs(Sender, [{Sender, {Rec, Sen}} | Rest]) ->
  [{Sender, {Rec + 1, Sen}} | Rest];
update_recs(Sender, [Head | Rest]) ->
  [Head | update_recs(Sender, Rest)].
