-module(myapp_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD_TELNET(I, Type), {I, {I, start_link, [1234,telnet_handler]}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok,Port} = application:get_env(myapp,telnet_port),
    {ok, { {one_for_all, 5, 10}, 
            [
             ?CHILD(tmp,worker),
             ?CHILD_TELNET(telnet_srv,worker)
            ]
        }
    }.

