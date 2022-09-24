-module(home).

-export([init/2, allowed_methods/2, home/2, content_types_provided/2,
         content_types_accepted/2, add_entry/2, resource_exists/2, delete_resources/2]).


allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[{{<<"application">>, <<"json">>, []}, home}], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, add_entry}], Req, State}.

add_entry(Req, State) ->
    case auth_handler:handle(Req) of
        {ok, authorized} ->
            case cowboy_req:method(Req) of
                <<"POST">> ->
                    {ok, Data, _Req} = cowboy_req:read_body(Req),
                    Info = jiffy:decode(Data),
                    lists:foreach(fun({[_IMSI_TUPLE = {<<"IMSI">>, IMSI},
                                        _ICCID_TUPLE = {<<"ICCID">>, ICCID}]}) ->
                                     mnesia_storage:create(#{'IMSI' => binary:bin_to_list(IMSI),
                                                             'ICCID' => binary:bin_to_list(ICCID)})
                                  end,
                                  Info),
                    Resp = cowboy_req:set_resp_body("successful request", Req),
                    cowboy_req:reply(201, Resp),
                    {stop, Resp, State};
                _ ->
                    {stop, Req, State}
            end;
        {ok, unauthorized} ->
            Resp = cowboy_req:set_resp_body("unauthorized user", Req),
            cowboy_req:reply(401, Resp),
            {stop, Resp, State}
    end.

resource_exists(Req, State) ->
    case auth_handler:handle(Req) of
        {ok, authorized} ->
            case cowboy_req:method(Req) of
                <<"DELETE">> ->
                    {ok, Content, _Req} = cowboy_req:read_body(Req),
                    Data = jiffy:decode(Content),
                    {[{Key, Value}]} = Data,
                    Resp =
                        case mnesia_storage:remove({binary_to_atom(Key, utf8),
                                                    binary:bin_to_list(Value)})
                        of
                            no_such_entry ->
                                cowboy_req:reply(404,
                                                 cowboy_req:set_resp_body("Couldn't find such entry",
                                                                          Req));
                            {entry_removed, _Removed_User} ->
                                cowboy_req:reply(201, cowboy_req:set_resp_body("Entry deleted", Req))
                        end,
                    {stop, Resp, State};
                _ -> % other request
                    
                    {true, Req, State}
            end;
        {ok, unauthorized} ->
            Resp = cowboy_req:set_resp_body("unauthorized user", Req),
            cowboy_req:reply(401, Resp),
            {stop, Resp, State}
    end.

delete_resources(Req, State) ->
    {true, Req, State}.

home(Req, State) ->
    lager:info("Ayoo we at homeee Req: ~p~n", [{Req, State}]),
    {jiffy:encode([hello, <<"Hello">>]), Req, State}.

init(Req0, State) ->
    {cowboy_rest, Req0, State}.
