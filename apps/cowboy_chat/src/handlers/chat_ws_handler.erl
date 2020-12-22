-module(chat_ws_handler).

-export([init/2]).

-export([websocket_handle/2, websocket_init/1]).

init(Req, State) ->
    io:format("New connection~n"),
    {cowboy_websocket, Req, State}.

websocket_init(State) -> {ok, State}.

websocket_handle({text, Msg}, State) ->
    io:format("~p~n", [Msg]), {ok, State};
websocket_handle({pong, _}, State) -> {ok, State};
websocket_handle(Data, State) -> {ok, State}.
