%%% Harry Roscoe (har14) and Sahil Parekh (sp5714)
-module(process2).
-export([start/1]).

start(Id) ->
  receive
    {bind, PL} -> next(Id, PL)
  end.

next(Id, PL) ->
  receive
    {task2, start, Max_Messages, Timeout} ->
      timer:send_after(Timeout, stop),
      Map = [{N, {0, 0}} || N <- Ns],
      PL ! {pl_send, broadcast},
      if 
        Max_Messages =:= 0 ->
          task2(Map, infinity, Id);
        true ->
          task2(Map, Max_Messages, Id)
      end
  end.

task2(Ns, Max_Messages, Id) ->
  receive
    {hello, Sender} ->
      NextNs = update_recs(Sender, Ns),
      task1(NextNs, Max_Messages, Id);
    broadcast ->  
      [N ! {hello, self()} || {N, {_, Sen}} <- Ns, Sen < Max_Messages],
      WithSends = [add_sends(N, Max_Messages) || N <- Ns],
      task1(WithSends, Max_Messages, Id);
    stop -> io:format("~p: ~w~n", [Id, lists:map(fun({_, Snd}) -> Snd end, Ns)])
  after 0 -> self() ! broadcast, task1(Ns, Max_Messages, Id)
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
