APPNAME=cowboy_chat
SERVICENAME=cowboy_chat

REBAR=./rebar3
ERL=erl
ERLC=erlc
dep_cowboy_commit = master
all: compile

$(REBAR):
	$(ERL) \
		-noshell -s inets start -s ssl start \
		-eval 'httpc:request(get, {"https://s3.amazonaws.com/rebar3/rebar3", []}, [], [{stream, "./rebar3"}])' \
		-s inets stop -s init stop
	chmod +x $(REBAR)

compile: $(REBAR)
	@$(REBAR) compile

dialyzer: $(REBAR)
	@$(REBAR) dialyzer

clean: $(REBAR)
	@$(REBAR) clean

xref: $(REBAR)
	@$(REBAR) xref

run:
	@$(REBAR) shell +pc unicode --config config/sys.config --sname $(SERVICENAME)_$(APPNAME)@localhost
