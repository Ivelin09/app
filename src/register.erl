-module(register).

-export([init/2, allowed_methods/2, home/2, content_types_provided/2,
         content_types_accepted/2, add_entry/2, resource_exists/2, delete_resources/2]).


allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[{{<<"application">>, <<"json">>, []}, home}], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, add_entry}], Req, State}.

add_entry(Req, State) ->
    {ok, Req, State}.

resource_exists(Req, State) ->
    Headers = cowboy_req:headers(Req),
    BasicAuth = lists:nth(2, string:lexemes(maps:get(<<"authorization">>, Headers), " ")),
    [Username, Password] = string:lexemes(erlang:binary_to_list(base64:decode(<<"YXNkOjEyMw==">>)), ":"),
    case cowboy_req:method(Req) of 
        "POST" ->
            {stop, cowboy_req:reply(200, Req), State};
        _ ->
            {stop, cowboy_req:reply(200, Req), State}
    end.

delete_resources(Req, State) ->
    {true, Req, State}.

home(Req, State) ->
    {"asdasd", Req, State}.

init(Req0, State) ->
    {cowboy_rest, Req0, State}.
