-module(api).
-export([start/2]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
    {'_', [{'_', home, #{}}]}
    ]),
    cowboy:start_clear(my_http_listener,
        [{port, 8512}],
        #{env => #{dispatch => Dispatch}}
    ).