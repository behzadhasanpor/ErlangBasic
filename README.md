# ErlangBasic
<h1>Erlang Cuncurrent & Distributed program</h1>
<hr/>
<h1>PURPOSE</h1>
this rep. is a simple concurrent project based on erlang <br/>
it just have educational aspect!(for begginers) <br/>
there it can be improve by your hands and become better ,i hope<br/>
there is a picture that i prepare,and can introduce project plans :
<br>
<img src='https://image.ibb.co/kAzbYT/Screenshot_from_2018_06_05_08_10_40.png' />
<br/>
<h2> HOW TO USE </h2>
you can use it in diffrent ways,but i choose one: <br/>
having three terminal opened as : 
<ul>
<li><pre>  $ erl -sname  server 
(server@your_hostname)> c(server).
(server@your_hostname)> server:start_server().
</pre></li>
<li><pre>   erl -sname  client 
(client@your_hostname)> c(client).
(client@your_hostname)> Timer=client:start_timer(server@your_hostname).
(client@your_hostname)> Timer(start,"name").
</pre></li>
<li><pre>   erl -sname  suppervisor 
(suppervisor@your_hostname)> c(sUpervisor).
(suppervisor@your_hostname)> Sup=sUpervisor:start_sup(server@your_hostname).
(suppervisor@your_hostname)> Sup(show).
</pre></li>
</ul>

for more info see the codes.
<br>
improve that if you want
<br>
