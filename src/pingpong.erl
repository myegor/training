-module(pingpong).
-compile([export_all]).



ping() ->
    receive
        {pong,Pong} -> io:format("got pong ~n"),timer:sleep(1000),Pong!{ping,self()}, ping(); 
        die      -> true
    end.

pong() ->
    receive
        {ping,Ping} -> io:format("got ping ~n"), Ping!{pong,self()}, pong() ;
        die            -> true
    end.


start() ->
    Pong = spawn(fun () -> pong() end),
    Ping = spawn(fun () -> Pong!{ping,self()} , ping() end),
    [Pong,Ping].
