% Harry Roscoe (har14) and Sahil Parekh (sp5714)
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
      Map = [{N, {0, 0}} || N <- Ns],
      if 
        Max_Messages =:= 0 ->
          task1(Map, infinity, Id);
        true ->
          task1(Map, Max_Messages, Id)
      end
  end.

task1(Ns, Max_Messages, Id) ->
  self() ! broadcast,
  receive
    {hello, Sender} ->
      NextNs = update_recs(Sender, Ns),
      task1(NextNs, Max_Messages, Id);
    broadcast ->  
      [N ! {hello, self()} || {N, {_, Sen}} <- Ns, Sen < Max_Messages],
      WithSends = [add_sends(N, Max_Messages) || N <- Ns],
      task1(WithSends, Max_Messages, Id);
    stop -> io:format("~p: ~p~n", [Id, lists:map(fun({_, Snd}) -> Snd end, Ns)])
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
