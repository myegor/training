-module(tmp).
 
-behaviour(gen_server).
 
%% API
-export([start_link/0,load/1,lookup/2,update/2,flush/1]).
 
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
 
-define(SERVER, ?MODULE).
 
-record(state, {dbstate}).
 
%%% API
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
 
load(Server)        -> gen_server:call(Server,{load}).
lookup(Server,Name) -> gen_server:call(Server,{get,Name}).
update(Server,BT)   -> gen_server:call(Server,{put,BT}).
flush(Server)       -> gen_server:call(Server,{flush}).

explain_status(notloaded)          -> <<"not loaded, use load">>;
explain_status(badargs)            -> <<"bad arguments">>;
explain_status(ok)                 -> <<"done.">>.
explain_status(notfound,AccountId) -> <<AccountId/binary," not found">>.



%%% gen_server callbacks
init([]) ->
    {ok, #state{dbstate=notloaded}}.
 
handle_call({load},From,#state{ dbstate = notloaded }) ->
    accountdb:load("accounts.txt"),
    {reply,{ok,explain_status(ok)},#state{dbstate=loaded}};

handle_call({load},From,#state{ dbstate = loaded }) ->
    {reply,{ok,explain_status(ok)},#state{dbstate=loaded}};

handle_call({flush},From,#state{ dbstate = notloaded }) ->
    {reply,{fail,explain_status(notloaded)},#state{dbstate=loaded}};

handle_call({flush},From,#state{ dbstate = loaded }) ->
    accountdb:save("accounts.txt"),
    {reply,{ok,explain_status(ok)},#state{dbstate=loaded}};

handle_call({get,{Param}},From,#state{ dbstate = loaded }) ->
    Reply = case accountdb:read(Param) of
                    [{_,H}|_] -> {ok,H};
                    []        -> {fail,explain_status(notfound,Param)}
            end,
    {reply,Reply,#state{dbstate=loaded}};

handle_call({get,_},From,#state{ dbstate = notloaded }) ->
    {reply,{fail,explain_status(notloaded)},#state{dbstate=loaded}};


handle_call({get,_},From,#state{ dbstate = loaded }) -> {reply,{fail,explain_status(badargs)},#state{dbstate=loaded}};

handle_call({put,BT},From,#state{ dbstate = loaded }) ->
    accountdb:write(BT),
    {reply,{ok,explain_status(ok)},#state{dbstate=loaded}};


handle_call({put,_},From,#state{ dbstate = notloaded }) ->
    {reply,{fail,explain_status(notloaded)},#state{dbstate=loaded}};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.
 
handle_cast(_Msg, State) ->
    {noreply, State}.
 
handle_info(_Info, State) ->
    {noreply, State}.
 
terminate(_Reason, _State) -> ok.
 
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
 
%%% Internal functions