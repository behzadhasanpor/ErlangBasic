-module(sUpervisor).
-compile(export_all).


start_sup(Server_Node)->	
	Ref=monitor(process,server),
	Pid=spawn(sUpervisor,sup,[Server_Node,Ref]),
	F=fun
	(start)-> 
		{server,Server_Node} ! {{sup,Pid},{show}},ok;
	(stop)-> 
		{server,Server_Node} ! {{sup,Pid},{shutdown}},ok;
	(_)->
		terminated_by_client
	end,
	F.

sup(SNode,Ref)->
	receive
		{showing,S}->
			io:format("started.~n~p",[S]),
			erlang:flush(),
			sup(SNode,Ref);
		shutting_down->
			shutted_of;
		{'DOWN',Ref,process,_,Reason}->
			io:format("server downded because of ~s.~n",[Reason]),
			erlang:flush(),
			sup(SNode,Ref)
	end.
	
