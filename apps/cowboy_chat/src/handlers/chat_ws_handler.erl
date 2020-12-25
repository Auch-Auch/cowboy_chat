-module(chat_ws_handler).

-export([init/2]).
-export([websocket_handle/2, websocket_info/2, websocket_init/1]).

init(Req, State) -> {cowboy_websocket, Req, State}.

websocket_init(State) ->
  io:format("New connection~n"),
  {ok, State}.


websocket_handle({text, Msg}, State) ->
  Data = jsx:decode(Msg, []),
  case Data of
    [{<<"name">>, Name}] ->
      cowboy_server:enter(self(), Name),
      {ok, State};

    [{<<"type">>, <<"User disconected">>}] ->
      cowboy_server:send_message(self(), <<"User disconected">>),
      cowboy_server:leave(self()),
      {ok, State};

    [{<<"message">>, Message}] ->
      cowboy_server:send_message(self(), Message),
      {ok, State};

    [{<<"names">>, _}] ->
      cowboy_server:send_names(),
      {ok, State};

    _Any -> {ok, State}
  end;

websocket_handle(_Data, State) -> {ok, State}.


websocket_info({message, Message}, State) -> {reply, {text, Message}, State};
websocket_info(_Info, State) -> {ok, State}.
