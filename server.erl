-module(server).
-compile(export_all).



%%-------------------------------------------------
%% names = orddict => (Ref,Name)
%% pids  = orddict => (Ref,Pid)
%% times = orddict => (Ref,Time)
%% timers= orddict => (Ref,Timer)
%%-------------------------------------------------
-record(srv,{names,pids,times,timers}).


%%-------------------------------------------------
%% here the server will started and initialized.
%% the sev => record will be initalize with new-
%% orddicts 
%%-------------------------------------------------
start_server()->
	register(server,spawn(server,server,[#srv{names=orddict:new(),pids=orddict:new(),times=orddict:new(),timers=orddict:new()}])),
	{server_registered_as,server}.


server(S=#srv{ names= _Names,pids= _Pids,times= _Times,timers= _Timers})->
	receive	


	%%%%%%%%%%%%%%RECEIVE FROM CLIENTS%%%%%%%%%%%%%%%%%%%%%%


	
		{{client,Pid,Ref},{start,N0,Name}}->
			case eval(N0) of
				true->
					%% store data to records
					NewNames=orddict:store(Ref,Name,_Names),	
					NewPids =orddict:store(Ref,Pid,_Pids),
					NewTimes=orddict:store(Ref,N0,_Times),
					%% send command to timer unit
					Timer=spawn(server,timer,[NewTimes,Ref,self()]),
					NewTimers=orddict:store(Ref,Timer,_Timers),
					Timer ! start,
					%% send response to client
					Pid ! {ok,Name,started},
					%% re-provoke server with new value
					server(#srv{names=NewNames,pids=NewPids,times=NewTimes,timers=NewTimers});
				false->
					Pid ! {error,validation_error},
					server(#srv{names=_Names,pids=_Pids,times=_Times,timers=_Timers})
			end;
		{{client},{stop,Name}}->
			case find_Ref(_Names,Name) of
				{true,Ref}->
					{ok,Pid}=orddict:find(Ref,_Pids),
					{ok,Timer}=orddict:find(Ref,_Timers),
					Pid ! {ok,Name,stopped},
					Timer ! stop,
					server(#srv{names=_Names,pids=_Pids,times=_Times,timers=_Timers});
				false->
					server(#srv{names=_Names,pids=_Pids,times=_Times,timers=_Timers})
			end;




	%%%%%%%%%%%%%%RECEIVE FROM TIMERS%%%%%%%%%%%%%%%%%%%%%%	

	
		{ok,started}->
			server(#srv{names=_Names,pids=_Pids,times=_Times,timers=_Timers});
		{stopped,Times,Ref}->			
			{ok,Pid}=orddict:find(Ref,_Timers),
			exit(Pid,kill),
			{ok,Cl_pid}=orddict:find(Ref,_Pids),
			{ok,EsTime}=orddict:find(Ref,Times),
			Cl_pid ! {espilate_time,EsTime},
			Timers=orddict:erase(Ref,_Timers),
			NewNames=orddict:erase(Ref,_Names),	
			NewPids =orddict:erase(Ref,_Pids),
			NewTimes=orddict:erase(Ref,Times),
			server(#srv{names=NewNames,pids=NewPids,times=NewTimes,timers=Timers});


	%%%%%%%%%%%%%%RECEIVE FROM SUPERVISOR%%%%%%%%%%%%%%%%%%%%%%


	
		{{sup,Pid},{show}}->
			Pid ! {showing,S},
			server(#srv{names=_Names,pids=_Pids,times=_Times,timers=_Timers});
		{{sup,Pid},{shutdown}}->
			Pid ! shutting_down		
			
	end.


%% server timers
timer(Times,Ref,Pid)->
	receive
		start->
			Pid ! {ok,started},
			timer(Times,Ref,Pid);
		stop ->
			Pid ! {stopped,Times,Ref}
						
	after 1000 ->
		{ok,Current_time}=orddict:find(Ref,Times),
		NewTimes=orddict:store(Ref,Current_time+1,Times),
		timer(NewTimes,Ref,Pid)
	end.
		
			
find_Ref([],_)->
	false;
find_Ref([{Key,Value}|_],Val)when Value == Val->
		{true,Key};
find_Ref([{_,_}|Rest],Val)->
		find_Ref(Rest,Val).			


eval(N)when N>=0 andalso is_integer(N)->
	true;
eval(_)->
	false.







	
