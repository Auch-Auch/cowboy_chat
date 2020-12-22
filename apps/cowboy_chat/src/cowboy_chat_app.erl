-module(cowboy_chat_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([{'_',
				       [{"/", cowboy_static,
					 {priv_file, cowboy_chat,
					  "static/index.html"}},
					{"/chat", cowboy_static,
					 {priv_file, cowboy_chat,
					  "static/chat.html"}},
					{"/ws", chat_ws_handler, []},
					{"/[...]", cowboy_static,
					 {priv_dir, cowboy_chat, "",
					  [{mimetypes, cow_mimetypes,
					    all}]}}]}]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}],
				 #{env => #{dispatch => Dispatch}}),
    cowboy_chat_sup:start_link().

stop(_State) -> ok.
