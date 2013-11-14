-module(telnet_handler).
-compile([export_all]).



-behaviour(telnet_srv).


-export([init/0, transform/2]).

-record(state,{dbserver}).

to_record([]) -> fail;

to_record([H|T]) ->
        try 
            {erlang:binary_to_existing_atom(H,latin1),list_to_tuple(T)}
        catch
            _:_ -> fail
        end.

parse_command(B) ->
    lists:filter(
        fun (<<>>) -> false;
            (_)    -> true 
        end,
        binary:split(B,[<<" ">>,<<"\r\n">>,<<"\n">>],[global])).

handle_command(quit,_,_)      -> false;

handle_command(load,#state {dbserver = Srv} = SrvState,_)      ->
    {_,Output} = tmp:load(Srv),
    {ok,Output,SrvState};

handle_command(get,#state {dbserver = Srv} = SrvState,BT) -> 
    {_,Output} = tmp:lookup(Srv,BT),
    {ok,Output,SrvState};

handle_command(update,#state {dbserver = Srv} = SrvState,BT) -> 
    {_,Output} = tmp:update(Srv,BT),
    {ok,Output,SrvState}.

init() ->
%    P = case whereis(tmp) of
%            undefined -> {ok,X} = tmp:start_link(), X;
%            X         -> X
%        end,
    #state{dbserver = tmp}.


transform(Input,SrvState) -> 
            M = to_record(parse_command(Input)),
            case M of
               fail  -> {ok,silent,SrvState}; 
               {C,P} -> io:format("~s ~w~n",[C,P]),
                        try handle_command(C,SrvState,P)
                        catch
                            error:{badmatch,_} -> {ok,<<"Unknown command\r\n">>}
                        end
            end.




