-module(call).

-export([login/2, register/3]).

-define(HEADERS, [
    {"DB", "application"},
    {"NS", "application"}, 
    {"Accept", "*/*"}, 
    {"Authorization", "Basic cm9vdDpyb290"}, 
    {"User-Agent", "Erlang-OTP"}
  ]).

-define(REQUEST_DATA(Request), {
  "http://localhost:8000/sql",
  ?HEADERS,
  "application/json",
  Request
}).

login(Username, Password) ->
  Hashed_password = binary_to_list(base64:encode(crypto:hash(sha256, Password))),
  Request = "SELECT * FROM users." ++ "\"" ++ Username ++ "\" WHERE hashed_password = \"" ++ Hashed_password ++ "\";",
  make_request(Request).


% Params = [{"key", "value"}]
register(Username, Password, Params) ->
  Hashed_password = binary_to_list(base64:encode(crypto:hash(sha256, Password))),
  Request = "CREATE users:" ++ Username ++ " SET " ++ 
                  "hashed_password = \"" ++ Hashed_password ++ 
                  "\", username = \"" ++ Username ++ "\", " ++
                  concat(Params),
  make_request(Request).


make_request(Request) ->
  {ok, Response} = httpc:request(post, ?REQUEST_DATA(Request), [], []),
  io:format("Respp: ~n~p~n~n~n", [Response]),
  case Response of
    {{_, Status_code, _}, _Resp_headers, Resp_body} when Status_code == 200 ->
      {ok, Status_code, Resp_body};
    {{_, Status_code, _}, _Resp_headers, Resp_body} ->
      {err, Status_code, Resp_body}
  end.

concat(Params) ->
 string:join([if
                is_integer(Value) -> binary_to_list(Rule) ++ " = <int> \"" ++ integer_to_list(Value) ++ "\"";
                is_float(Value) -> binary_to_list(Rule) ++ " = <float> \"" ++ float_to_list(Value) ++ "\"";
                is_binary(Value) -> binary_to_list(Rule) ++ " = \"" ++ binary_to_list(Value) ++ "\"";
                true -> binary_to_list(Rule) ++ " = \"" ++ Value ++ "\""
              end || {Rule, Value} <- Params], ", ") ++ ";".
