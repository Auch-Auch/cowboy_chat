-module(cowboy_chat_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    cowboy_chat_sup:start_link().

stop(_State) -> ok.
