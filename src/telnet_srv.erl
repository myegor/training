-module(telnet_srv).
-compile([export_all]).
 

-export([behaviour_info/1]).
 
behaviour_info(callbacks) ->
    [
        {init,0},
        {transform,2}
    ];
behaviour_info(_Other) ->
    undefined.

start_link(Port,Mod) ->
%    case whereis(telnetserver) of
%        undefined -> 
%            ok;
%        P         -> 
%            P!exit,
%            ok
%    end,
    {ok,spawn_link(fun() -> telnetserver(Port,Mod) end)}.

telnetserver(Port,Mod) ->
    register(telnetserver,self()), 
    {ok, Listen} = gen_tcp:listen(Port, [binary,{active, false}, {reuseaddr,true}]),
    spawn(fun() -> acceptor(Listen,Mod) end),
    receive
        exit -> ok
    end.     


acceptor(ListenSocket,Mod) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            SrvState = Mod:init(),
            spawn(fun() -> acceptor(ListenSocket,Mod) end),
            do_output(Socket),
            handle(Socket,SrvState);
        {error,closed} -> ok
    end.

do_output(Socket,Output) -> gen_tcp:send(Socket,Output++[<<"\r\n">>]).


do_output(Socket)        -> gen_tcp:send(Socket,[<<"accountdb:>">>]).   



handle(Socket,SrvState) ->
    inet:setopts(Socket, [{active, once}]),
    receive
        {tcp, Socket, Msg} ->
            case telnet_handler:transform(Msg,SrvState) of
                false                   -> exit(normal);
                {ok,silent,NewSrvState} -> handle(Socket,NewSrvState);
                {ok,Output,NewSrvState} -> do_output(Socket,Output),do_output(Socket),handle(Socket,NewSrvState)
            end;
        {error,closed} -> ok
    end.