-module(api).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
        {'_', [{"/register", register, #{}}]}
    ]),
    {ok, Data} = cowboy:start_clear(my_http_listener,
        [{port, 8555}],
        #{env => #{dispatch => Dispatch}
    }). 
stop(_State) ->
	ok.
