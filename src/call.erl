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
  {ok, Resonse} = httpc:request(post, ?REQUEST_DATA(Request), [], []),
  Resonse.
concat(Params) ->
 string:join([if
                is_integer(Value) -> Rule ++ " = <int> \"" ++ integer_to_list(Value) ++ "\"";
                is_float(Value) -> Rule ++ " = <float> \"" ++ float_to_list(Value) ++ "\"";
                true -> Rule ++ " = \"" ++ Value ++ "\""
              end || {Rule, Value} <- Params], ", ") ++ ";".