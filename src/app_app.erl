%%%-------------------------------------------------------------------
%% @doc app public API
%% @end
%%%-------------------------------------------------------------------

-module(app_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("HEREEEEEEEEEEEE: ~p", [application:info()]),
    api:start(none, none).

stop(_State) ->
    ok.

%% internal functions
