-module(register).

-export([init/2, allowed_methods/2, resource_exists/2, delete_resources/2]).


allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>, <<"DELETE">>], Req, State}.

resource_exists(Req, State) ->
    Headers = cowboy_req:headers(Req),
    BasicAuth = lists:nth(2, string:lexemes(maps:get(<<"authorization">>, Headers), " ")),
    [Username, Password] = string:lexemes(erlang:binary_to_list(base64:decode(BasicAuth)), ":"),
    io:format("~p ~p", [Username, Password]),
    case cowboy_req:method(Req) of 
        "POST" ->
            {stop, cowboy_req:reply(200, Req), State};
        _ ->
            {stop, cowboy_req:reply(200, Req), State}
    end.

delete_resources(Req, State) ->
    {true, Req, State}.

init(Req0, State) ->
    {cowboy_rest, Req0, State}.
