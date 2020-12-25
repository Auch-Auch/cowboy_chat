-module(cowboy_server).

-behaviour(gen_server).

-export([add_name/2, enter/2, leave/1, send_message/2, send_names/0, start_link/0]).

%% gen_server callbacks

-export(
  [
    code_change/3,
    do_send_message/3,
    do_send_names/2,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    init/1,
    terminate/2
  ]
).

-define(SERVER, ?MODULE).

-record(state, {clients = []}).

%%%=============================================================================
%%% API
%%%=============================================================================

start_link() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

enter(Pid, Name) -> gen_server:cast(?SERVER, {enter, Pid, Name}).

leave(Pid) -> gen_server:cast(?SERVER, {leave, Pid}).

send_message(Pid, Name) -> gen_server:cast(?SERVER, {send_message, Pid, Name}).

add_name(Pid, Name) -> gen_server:cast(?SERVER, {add_name, Pid, Name}).

send_names() -> gen_server:cast(?SERVER, {names}).

%%%=============================================================================
%%% gen_server callbacks
%%%=============================================================================

init([]) ->
  Dispatch =
    cowboy_router:compile(
      [
        {
          '_',
          [
            {"/", cowboy_static, {priv_file, cowboy_chat, "static/index.html"}},
            {"/ws", chat_ws_handler, []},
            {
              "/[...]",
              cowboy_static,
              {priv_dir, cowboy_chat, "", [{mimetypes, cow_mimetypes, all}]}
            }
          ]
        }
      ]
    ),
  {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
  {ok, #state{}}.


handle_call(_Request, _From, State) -> {noreply, State}.

handle_cast({enter, Pid, Name}, State = #state{clients = Clients}) ->
  {noreply, State#state{clients = [{Pid, Name} | Clients]}};

handle_cast({leave, Pid}, State = #state{clients = Clients}) ->
  {noreply, State#state{clients = proplists:delete(Pid, Clients)}};

handle_cast({send_message, Pid, Message}, State) ->
  do_send_message(Pid, Message, State),
  {noreply, State};

handle_cast({names}, State) ->
  do_send_names({names}, State),
  {noreply, State}.


handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) -> cowboy:stop_listener(cowboy_chat).

code_change(_OldVsn, State, _Extra) -> {ok, State}.

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

do_send_names({names}, #state{clients = Clients}) ->
  Clients_lists = lists:map(fun ({_, Name}) -> Name end, Clients),
  Clients_json = jsx:encode([{<<"clients">>, Clients_lists}]),
  lists:foreach(fun ({OtherPid, _}) -> OtherPid ! {message, Clients_json} end, Clients).


do_send_message(Pid, Message, #state{clients = Clients}) ->
  FromName = proplists:get_value(Pid, Clients),
  OtherPids = proplists:delete(Pid, Clients),
  lists:foreach(
    fun
      ({OtherPid, _}) ->
        Message_json = jsx:encode([{<<"message">>, iolist_to_binary([FromName, ":  ", Message])}]),
        OtherPid ! {message, Message_json}
    end,
    OtherPids
  ).
