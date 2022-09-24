-module(api_sup).
-behavior(supervisor).

-compile(export_all).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [#{
        id => api,
        start => {api, start, [[], []]},
        restart => permanent,
        shutdown => brutal_kill,
        type => worker
    }],
    {ok, {SupFlags, ChildSpecs}}.