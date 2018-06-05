-module(client).
-compile(export_all).


start_timer(Server_Node)->
	F=fun
		(Command,Name)->
		 if
			Command==start->
				Ref=monitor(process,server),
				Pid=spawn(client,client,[Server_Node,Ref]),
				{server,Server_Node} ! {{client,Pid,Ref},{start,0,Name}},ok;
			Command==stop ->
				{server,Server_Node} ! {{client},{stop,Name}},ok;
			true ->
				terminated_by_client
		end
		end,
	F.

client(SNode,Ref)->
	receive
		{ok,Name,started}->
			io:format("~s started.~n",[Name]),
			erlang:flush(),
			client(SNode,Ref);
		{espilate_time,EsTime}->
			io:format("time = ~p.~n",[EsTime]),
			erlang:flush(),
			client(SNode,Ref);
		{ok,Name,stopped}->
			io:format("~s stopped.~n",[Name]),
			erlang:flush(),
			client(SNode,Ref);
		{error,_,no_exists}->
			no_exists,
			client(SNode,Ref);
		{'DOWN',Ref,process,_,Reason}->
			io:format("server downded because of ~s.~n",[Reason]),
			erlang:flush()
	end.
	
