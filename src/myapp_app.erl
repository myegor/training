-module(myapp_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    application:start(myapp).

start(_StartType, _StartArgs) ->
    myapp_sup:start_link().

stop(_State) ->
    ok.
