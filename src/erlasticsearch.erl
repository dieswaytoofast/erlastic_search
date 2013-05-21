%%%-------------------------------------------------------------------
%%% @author Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>
%%% @copyright (C) 2013 Mahesh Paolini-Subramanya
%%% @doc type definitions and records.
%%% @end
%%%
%%% This source file is subject to the New BSD License. You should have received
%%% a copy of the New BSD license with this software. If not, it can be
%%% retrieved from: http://www.opensource.org/licenses/bsd-license.php
%%%-------------------------------------------------------------------

-module(erlasticsearch).
-author('Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>').

-behaviour(gen_server).

-include("erlasticsearch.hrl").

%% API
-export([start/0, start/1]).
-export([start_link/0, start_link/1]).
-export([stop/1]).

%% ElasticSearch
% Tests
-export([is_index/2]).
-export([is_type/3]).
-export([is_doc/4]).

% Cluster helpers
-export([health/1]).
-export([state/1, state/2]).
-export([nodes_info/1, nodes_info/2, nodes_info/3]).
-export([nodes_stats/1, nodes_stats/2, nodes_stats/3]).

% Index CRUD
-export([create_index/2, create_index/3]).
-export([delete_index/2]).
-export([open_index/2]).
-export([close_index/2]).

% Doc CRUD
-export([insert_doc/5, insert_doc/6]).
-export([get_doc/4, get_doc/5]).
-export([mget_doc/2, mget_doc/3, mget_doc/4]).
-export([delete_doc/4, delete_doc/5]).
-export([search/4, search/5]).
-export([count/2, count/3, count/4, count/5]).
-export([delete_by_query/2, delete_by_query/3, delete_by_query/4, delete_by_query/5]).

%% Index helpers
-export([status/2]).
-export([refresh/1, refresh/2]).
-export([flush/1, flush/2]).
-export([optimize/1, optimize/2]).
-export([clear_cache/1, clear_cache/2, clear_cache/3]).
-export([segments/1, segments/2]).

-export([is_200/1, is_200_or_201/1]).
-export([decode_response/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(APP, ?MODULE).

-record(state, {connection :: connection()}).

%% ------------------------------------------------------------------
%% API
%% ------------------------------------------------------------------

%% @equiv start([]).
-spec start() -> {ok, pid()}.
start() ->
    start([]).

-spec start(params()) -> {ok, pid()}.
start(Options) when is_list(Options) ->
    gen_server:start(?MODULE, [Options], []).

start_link() ->
    start_link([]).

start_link(Options) ->
    gen_server:start_link(?MODULE, [Options], []).

%% @doc Stop a client
-spec stop(server_ref()) -> ok | error().
stop(ServerRef) ->
    gen_server:call(ServerRef, {stop}, infinity).

%% @doc Get the health the  ElasticSearch cluster
-spec health(server_ref()) -> response().
health(ServerRef) ->
    gen_server:call(ServerRef, {health}, infinity).

%% @equiv state(ServerRef, []).
-spec state(server_ref()) -> response().
state(ServerRef) ->
    state(ServerRef, []).

%% @doc Get the state of the  ElasticSearch cluster
-spec state(server_ref(), params()) -> response().
state(ServerRef, Params) ->
    gen_server:call(ServerRef, {state, Params}, infinity).

%% @equiv nodes_info(ServerRef, [], []).
-spec nodes_info(server_ref()) -> response().
nodes_info(ServerRef) ->
    nodes_info(ServerRef, [], []).

%% @equiv nodes_info(ServerRef, [NodeName], []).
-spec nodes_info(server_ref(), node_name()) -> response().
nodes_info(ServerRef, NodeName) when is_binary(NodeName) ->
    nodes_info(ServerRef, [NodeName], []);
%% @equiv nodes_info(ServerRef, NodeNames, []).
nodes_info(ServerRef, NodeNames) when is_list(NodeNames) ->
    nodes_info(ServerRef, NodeNames, []).

%% @doc Get the nodes_info of the  ElasticSearch cluster
-spec nodes_info(server_ref(), [node_name()], params()) -> response().
nodes_info(ServerRef, NodeNames, Params) ->
    gen_server:call(ServerRef, {nodes_info, NodeNames, Params}, infinity).

%% @equiv nodes_stats(ServerRef, [], []).
-spec nodes_stats(server_ref()) -> response().
nodes_stats(ServerRef) ->
    nodes_stats(ServerRef, [], []).

%% @equiv nodes_stats(ServerRef, [NodeName], []).
-spec nodes_stats(server_ref(), node_name()) -> response().
nodes_stats(ServerRef, NodeName) when is_binary(NodeName) ->
    nodes_stats(ServerRef, [NodeName], []);
%% @equiv nodes_stats(ServerRef, NodeNames, []).
nodes_stats(ServerRef, NodeNames) when is_list(NodeNames) ->
    nodes_stats(ServerRef, NodeNames, []).

%% @doc Get the nodes_stats of the  ElasticSearch cluster
-spec nodes_stats(server_ref(), [node_name()], params()) -> response().
nodes_stats(ServerRef, NodeNames, Params) ->
    gen_server:call(ServerRef, {nodes_stats, NodeNames, Params}, infinity).

%% @doc Get the status of an index/indices in the  ElasticSearch cluster
-spec status(server_ref(), index() | [index()]) -> response().
status(ServerRef, Index) when is_binary(Index) ->
    status(ServerRef, [Index]);
status(ServerRef, Indexes) when is_list(Indexes)->
    gen_server:call(ServerRef, {status, Indexes}, infinity).

%% @equiv create_index(ServerRef, Index, <<>>)
-spec create_index(server_ref(), index()) -> response().
create_index(ServerRef, Index) ->
    create_index(ServerRef, Index, <<>>).

%% @doc Create an index in the ElasticSearch cluster
-spec create_index(server_ref(), index(), doc()) -> response().
create_index(ServerRef, Index, Doc) ->
    gen_server:call(ServerRef, {create_index, Index, Doc}, infinity).

%% @doc Delete an index in the ElasticSearch cluster
-spec delete_index(server_ref(), index()) -> response().
delete_index(ServerRef, Index) ->
    gen_server:call(ServerRef, {delete_index, Index}, infinity).

%% @doc Open an index in the ElasticSearch cluster
-spec open_index(server_ref(), index()) -> response().
open_index(ServerRef, Index) ->
    gen_server:call(ServerRef, {open_index, Index}, infinity).

%% @doc Close an index in the ElasticSearch cluster
-spec close_index(server_ref(), index()) -> response().
close_index(ServerRef, Index) ->
    gen_server:call(ServerRef, {close_index, Index}, infinity).

%% @doc Check if an index/indices exists in the ElasticSearch cluster
-spec is_index(server_ref(), index() | [index()]) -> boolean().
is_index(ServerRef, Index) when is_binary(Index) ->
    is_index(ServerRef, [Index]);
is_index(ServerRef, Indexes) when is_list(Indexes) ->
    gen_server:call(ServerRef, {is_index, Indexes}, infinity).

%% @equiv count(ServerRef, ?ALL, [], Doc []).
-spec count(server_ref(), doc()) -> boolean().
count(ServerRef, Doc) when is_binary(Doc) ->
    count(ServerRef, ?ALL, [], Doc, []).

%% @equiv count(ServerRef, ?ALL, [], Doc, Params).
-spec count(server_ref(), doc(), params()) -> boolean().
count(ServerRef, Doc, Params) when is_binary(Doc), is_list(Params) ->
    count(ServerRef, ?ALL, [], Doc, Params).

%% @equiv count(ServerRef, Index, [], Doc, Params).
-spec count(server_ref(), index() | [index()], doc(), params()) -> boolean().
count(ServerRef, Index, Doc, Params) when is_binary(Index), is_binary(Doc), is_list(Params) ->
    count(ServerRef, [Index], [], Doc, Params);
count(ServerRef, Indexes, Doc, Params) when is_list(Indexes), is_binary(Doc), is_list(Params) ->
    count(ServerRef, Indexes, [], Doc, Params).

%% @doc Get the number of matches for a query
-spec count(server_ref(), index() | [index()], type() | [type()], doc(), params()) -> boolean().
count(ServerRef, Index, Type, Doc, Params) when is_binary(Index), is_binary(Type), is_binary(Doc), is_list(Params) ->
    count(ServerRef, [Index], [Type], Doc, Params);
count(ServerRef, Indexes, Type, Doc, Params) when is_list(Indexes), is_binary(Type), is_binary(Doc), is_list(Params) ->
    count(ServerRef, Indexes, [Type], Doc, Params);
count(ServerRef, Index, Types, Doc, Params) when is_binary(Index), is_list(Types), is_binary(Doc), is_list(Params) ->
    count(ServerRef, [Index], Types, Doc, Params);
count(ServerRef, Indexes, Types, Doc, Params) when is_list(Indexes), is_list(Types), is_binary(Doc), is_list(Params) ->
    gen_server:call(ServerRef, {count, Indexes, Types, Doc, Params}, infinity).

%% @equiv delete_by_query(ServerRef, ?ALL, [], Doc []).
-spec delete_by_query(server_ref(), doc()) -> boolean().
delete_by_query(ServerRef, Doc) when is_binary(Doc) ->
    delete_by_query(ServerRef, ?ALL, [], Doc, []).

%% @equiv delete_by_query(ServerRef, ?ALL, [], Doc, Params).
-spec delete_by_query(server_ref(), doc(), params()) -> boolean().
delete_by_query(ServerRef, Doc, Params) when is_binary(Doc), is_list(Params) ->
    delete_by_query(ServerRef, ?ALL, [], Doc, Params).

%% @equiv delete_by_query(ServerRef, Index, [], Doc, Params).
-spec delete_by_query(server_ref(), index() | [index()], doc(), params()) -> boolean().
delete_by_query(ServerRef, Index, Doc, Params) when is_binary(Index), is_binary(Doc), is_list(Params) ->
    delete_by_query(ServerRef, [Index], [], Doc, Params);
delete_by_query(ServerRef, Indexes, Doc, Params) when is_list(Indexes), is_binary(Doc), is_list(Params) ->
    delete_by_query(ServerRef, Indexes, [], Doc, Params).

%% @doc Get the number of matches for a query
-spec delete_by_query(server_ref(), index() | [index()], type() | [type()], doc(), params()) -> boolean().
delete_by_query(ServerRef, Index, Type, Doc, Params) when is_binary(Index), is_binary(Type), is_binary(Doc), is_list(Params) ->
    delete_by_query(ServerRef, [Index], [Type], Doc, Params);
delete_by_query(ServerRef, Indexes, Type, Doc, Params) when is_list(Indexes), is_binary(Type), is_binary(Doc), is_list(Params) ->
    delete_by_query(ServerRef, Indexes, [Type], Doc, Params);
delete_by_query(ServerRef, Index, Types, Doc, Params) when is_binary(Index), is_list(Types), is_binary(Doc), is_list(Params) ->
    delete_by_query(ServerRef, [Index], Types, Doc, Params);
delete_by_query(ServerRef, Indexes, Types, Doc, Params) when is_list(Indexes), is_list(Types), is_binary(Doc), is_list(Params) ->
    gen_server:call(ServerRef, {delete_by_query, Indexes, Types, Doc, Params}, infinity).

%% @doc Check if a type exists in an index/indices in the ElasticSearch cluster
-spec is_type(server_ref(), index() | [index()], type() | [type()]) -> boolean().
is_type(ServerRef, Index, Type) when is_binary(Index), is_binary(Type) ->
    is_type(ServerRef, [Index], [Type]);
is_type(ServerRef, Indexes, Type) when is_list(Indexes), is_binary(Type) ->
    is_type(ServerRef, Indexes, [Type]);
is_type(ServerRef, Index, Types) when is_binary(Index), is_list(Types) ->
    is_type(ServerRef, [Index], Types);
is_type(ServerRef, Indexes, Types) when is_list(Indexes), is_list(Types) ->
    gen_server:call(ServerRef, {is_type, Indexes, Types}, infinity).

%% @equiv insert_doc(Index, Type, Id, Doc, []).
-spec insert_doc(server_ref(), index(), type(), id(), doc()) -> response().
insert_doc(ServerRef, Index, Type, Id, Doc) ->
    insert_doc(ServerRef, Index, Type, Id, Doc, []).

%% @doc Insert a doc into the ElasticSearch cluster
-spec insert_doc(server_ref(), index(), type(), id(), doc(), params()) -> response().
insert_doc(ServerRef, Index, Type, Id, Doc, Params) ->
    gen_server:call(ServerRef, {insert_doc, Index, Type, Id, Doc, Params}, infinity).

%% @doc Checks to see if the doc exists
-spec is_doc(server_ref(), index(), type(), id()) -> response().
is_doc(ServerRef, Index, Type, Id) ->
    gen_server:call(ServerRef, {is_doc, Index, Type, Id}, infinity).

%% @equiv get_doc(ServerRef, Index, Type, Id, []).
-spec get_doc(server_ref(), index(), type(), id()) -> response().
get_doc(ServerRef, Index, Type, Id) ->
    get_doc(ServerRef, Index, Type, Id, []).

%% @doc Get a doc from the ElasticSearch cluster
-spec get_doc(server_ref(), index(), type(), id(), params()) -> response().
get_doc(ServerRef, Index, Type, Id, Params) ->
    gen_server:call(ServerRef, {get_doc, Index, Type, Id, Params}, infinity).

%% @equiv mget_doc(ServerRef, <<>>, <<>>, Doc)
-spec mget_doc(server_ref(), doc()) -> response().
mget_doc(ServerRef, Doc) ->
    mget_doc(ServerRef, <<>>, <<>>, Doc).

%% @equiv mget_doc(ServerRef, Index, <<>>, Doc)
-spec mget_doc(server_ref(), index(), doc()) -> response().
mget_doc(ServerRef, Index, Doc) ->
    mget_doc(ServerRef, Index, <<>>, Doc).

%% @doc Get a doc from the ElasticSearch cluster
-spec mget_doc(server_ref(), index(), type(), doc()) -> response().
mget_doc(ServerRef, Index, Type, Doc) ->
    gen_server:call(ServerRef, {mget_doc, Index, Type, Doc}, infinity).

%% @equiv delete_doc(ServerRef, Index, Type, Id, []).
-spec delete_doc(server_ref(), index(), type(), id()) -> response().
delete_doc(ServerRef, Index, Type, Id) ->
    delete_doc(ServerRef, Index, Type, Id, []).
%% @doc Delete a doc from the ElasticSearch cluster
-spec delete_doc(server_ref(), index(), type(), id(), params()) -> response().
delete_doc(ServerRef, Index, Type, Id, Params) ->
    gen_server:call(ServerRef, {delete_doc, Index, Type, Id, Params}, infinity).

%% @equiv search(ServerRef, Index, Type, Doc, []).
-spec search(server_ref(), index(), type(), doc()) -> response().
search(ServerRef, Index, Type, Doc) ->
    search(ServerRef, Index, Type, Doc, []).
%% @doc Search for docs in the ElasticSearch cluster
-spec search(server_ref(), index(), type(), doc(), params()) -> response().
search(ServerRef, Index, Type, Doc, Params) ->
    gen_server:call(ServerRef, {search, Index, Type, Doc, Params}, infinity).

%% @equiv refresh(ServerRef, ?ALL).
%% @doc Refresh all indices
%-spec refresh(server_ref()) -> response().
refresh(ServerRef) ->
    refresh(ServerRef, ?ALL).

%% @doc Refresh one or more indices
%-spec refresh(server_ref(), index() | [index()]) -> response().
refresh(ServerRef, Index) when is_binary(Index) ->
    refresh(ServerRef, [Index]);
refresh(ServerRef, Indexes) when is_list(Indexes) ->
    gen_server:call(ServerRef, {refresh, Indexes}, infinity).

%% @doc Flush all indices
%% @equiv flush(ServerRef, ?ALL).
-spec flush(server_ref()) -> response().
flush(ServerRef) ->
    flush(ServerRef, ?ALL).

%% @doc Flush one or more indices
-spec flush(server_ref(), index() | [index()]) -> response().
flush(ServerRef, Index) when is_binary(Index) ->
    flush(ServerRef, [Index]);
flush(ServerRef, Indexes) when is_list(Indexes) ->
    gen_server:call(ServerRef, {flush, Indexes}, infinity).

%% @equiv optimize(ServerRef, ?ALL).
%% @doc Optimize all indices
-spec optimize(server_ref()) -> response().
optimize(ServerRef) ->
    optimize(ServerRef, ?ALL).

%% @doc Optimize one or more indices
-spec optimize(server_ref(), index() | [index()]) -> response().
optimize(ServerRef, Index) when is_binary(Index) ->
    optimize(ServerRef, [Index]);
optimize(ServerRef, Indexes) when is_list(Indexes) ->
    gen_server:call(ServerRef, {optimize, Indexes}, infinity).

%% @equiv segments(ServerRef, ?ALL).
%% @doc Optimize all indices
-spec segments(server_ref()) -> response().
segments(ServerRef) ->
    segments(ServerRef, ?ALL).

%% @doc Optimize one or more indices
-spec segments(server_ref(), index() | [index()]) -> response().
segments(ServerRef, Index) when is_binary(Index) ->
    segments(ServerRef, [Index]);
segments(ServerRef, Indexes) when is_list(Indexes) ->
    gen_server:call(ServerRef, {segments, Indexes}, infinity).

%% @equiv clear_cache(ServerRef, ?ALL, []).
%% @doc Clear all the caches
-spec clear_cache(server_ref()) -> response().
clear_cache(ServerRef) ->
    clear_cache(ServerRef, ?ALL, []).

%% @equiv clear_cache(ServerRef, Indexes, []).
-spec clear_cache(server_ref(), index() | [index()]) -> response().
clear_cache(ServerRef, Index) when is_binary(Index) ->
    clear_cache(ServerRef, [Index], []);
clear_cache(ServerRef, Indexes) when is_list(Indexes) ->
    clear_cache(ServerRef, Indexes, []).

%% @equiv clear_cache(ServerRef, Indexes, []).
-spec clear_cache(server_ref(), index() | [index()], params()) -> response().
clear_cache(ServerRef, Index, Params) when is_binary(Index), is_list(Params) ->
    clear_cache(ServerRef, [Index], Params);
clear_cache(ServerRef, Indexes, Params) when is_list(Indexes), is_list(Params) ->
    gen_server:call(ServerRef, {clear_cache, Indexes, Params}, infinity).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([Options]) ->
    Connection = connection(Options),
    {ok, #state{connection = Connection}}.

handle_call({stop}, _From, State) ->
    {stop, normal, ok, State};

handle_call({_Request = health}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_health(),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = state, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_state(Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = nodes_info, NodeNames, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_nodes_info(NodeNames, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = nodes_stats, NodeNames, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_nodes_stats(NodeNames, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = status, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_status(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = create_index, Index, Doc}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_create_index(Index, Doc),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = delete_index, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_delete_index(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = open_index, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_open_index(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = close_index, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_close_index(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = count, Index, Type, Doc, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_count(Index, Type, Doc, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = delete_by_query, Index, Type, Doc, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_delete_by_query(Index, Type, Doc, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = is_index, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_is_index(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    % Check if the result is 200 (true) or 404 (false)
    Result = is_200(RestResponse),
    {reply, Result, State#state{connection = Connection1}};

handle_call({_Request = is_type, Index, Type}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_is_type(Index, Type),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    % Check if the result is 200 (true) or 404 (false)
    Result = is_200(RestResponse),

    {reply, Result, State#state{connection = Connection1}};

handle_call({_Request = insert_doc, Index, Type, Id, Doc, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_insert_doc(Index, Type, Id, Doc, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = get_doc, Index, Type, Id, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_get_doc(Index, Type, Id, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = mget_doc, Index, Type, Doc}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_mget_doc(Index, Type, Doc),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = is_doc, Index, Type, Id}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_is_doc(Index, Type, Id),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    Result = is_200(RestResponse),
    {reply, Result, State#state{connection = Connection1}};

handle_call({_Request = delete_doc, Index, Type, Id, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_delete_doc(Index, Type, Id, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = search, Index, Type, Doc, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_search(Index, Type, Doc, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = refresh, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_refresh(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = flush, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_flush(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = optimize, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_optimize(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = segments, Index}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_segments(Index),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call({_Request = clear_cache, Index, Params}, _From, State = #state{connection = Connection0}) ->
    RestRequest = rest_request_clear_cache(Index, Params),
    {Connection1, RestResponse} = process_request(Connection0, RestRequest),
    {reply, RestResponse, State#state{connection = Connection1}};

handle_call(_Request, _From, State) ->
    {stop, unhandled_call, State}.

handle_cast(_Request, State) ->
    {stop, unhandled_info, State}.

handle_info(_Info, State) ->
    {stop, unhandled_info, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------
%% @doc Build a new connection
-spec connection(params()) -> connection().
connection(StartOptions) ->
    ThriftHost = get_env(thrift_host, ?DEFAULT_THRIFT_HOST),
    ThriftPort = get_env(thrift_port, ?DEFAULT_THRIFT_PORT),
    {ok, Connection} = thrift_client_util:new(ThriftHost, ThriftPort, elasticsearch_thrift, StartOptions),
    Connection.

%% @doc Process the request over thrift
-spec process_request(connection(), request()) -> {connection(), response()}.
process_request(Connection, Request) ->
    thrift_client:call(Connection, 'execute', [Request]).

%% @doc Build a new rest request
rest_request_health() ->
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = ?HEALTH}.

rest_request_state(Params) when is_list(Params) ->
    Uri = make_uri([?STATE], Params),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri}.

rest_request_nodes_info(NodeNames, Params) when is_list(NodeNames),
                                                is_list(Params) ->
    NodeNameList = bstr:join(NodeNames, <<",">>),
    Uri = make_uri([?NODES, NodeNameList], Params),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri}.

rest_request_nodes_stats(NodeNames, Params) when is_list(NodeNames),
                                                is_list(Params) ->
    NodeNameList = bstr:join(NodeNames, <<",">>),
    Uri = make_uri([?NODES, NodeNameList, ?STATS], Params),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri}.

rest_request_status(Index) when is_list(Index) ->
    IndexList = bstr:join(Index, <<",">>),
    Uri = bstr:join([IndexList, ?STATUS], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri}.

rest_request_create_index(Index, Doc) when is_binary(Index),
                                              is_binary(Doc) ->
    #restRequest{method = ?elasticsearch_Method_PUT,
                 uri = Index,
                 body = Doc}.

rest_request_delete_index(Index) when is_binary(Index) ->
    #restRequest{method = ?elasticsearch_Method_DELETE,
                 uri = Index}.

rest_request_open_index(Index) when is_binary(Index) ->
    Uri = bstr:join([Index, ?OPEN], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_POST,
                 uri = Uri}.

rest_request_close_index(Index) when is_binary(Index) ->
    Uri = bstr:join([Index, ?CLOSE], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_POST,
                 uri = Uri}.

rest_request_count(Index, Type, Doc, Params) when is_list(Index),
                                        is_list(Type),
                                        is_binary(Doc),
                                        is_list(Params) ->
    IndexList = bstr:join(Index, <<",">>),
    TypeList = bstr:join(Type, <<",">>),
    Uri = make_uri([IndexList, TypeList, ?COUNT], Params),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri,
                 body = Doc}.

rest_request_delete_by_query(Index, Type, Doc, Params) when is_list(Index),
                                        is_list(Type),
                                        is_binary(Doc),
                                        is_list(Params) ->
    IndexList = bstr:join(Index, <<",">>),
    TypeList = bstr:join(Type, <<",">>),
    Uri = make_uri([IndexList, TypeList, ?QUERY], Params),
    #restRequest{method = ?elasticsearch_Method_DELETE,
                 uri = Uri,
                 body = Doc}.

rest_request_is_index(Index) when is_list(Index) ->
    IndexList = bstr:join(Index, <<",">>),
    #restRequest{method = ?elasticsearch_Method_HEAD,
                 uri = IndexList}.

rest_request_is_type(Index, Type) when is_list(Index),
                                        is_list(Type) ->
    IndexList = bstr:join(Index, <<",">>),
    TypeList = bstr:join(Type, <<",">>),
    Uri = bstr:join([IndexList, TypeList], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_HEAD,
                 uri = Uri}.

rest_request_insert_doc(Index, Type, undefined, Doc, Params) when is_binary(Index),
                                                      is_binary(Type),
                                                      is_binary(Doc),
                                                      is_list(Params) ->
    Uri = make_uri([Index, Type], Params),
    #restRequest{method = ?elasticsearch_Method_POST,
                 uri = Uri,
                 body = Doc};

rest_request_insert_doc(Index, Type, Id, Doc, Params) when is_binary(Index),
                                                      is_binary(Type),
                                                      is_binary(Id),
                                                      is_binary(Doc),
                                                      is_list(Params) ->
    Uri = make_uri([Index, Type, Id], Params),
    #restRequest{method = ?elasticsearch_Method_PUT,
                 uri = Uri,
                 body = Doc}.

rest_request_is_doc(Index, Type, Id) when is_binary(Index),
                                                   is_binary(Type),
                                                   is_binary(Id) ->
    Uri = make_uri([Index, Type, Id], []),
    #restRequest{method = ?elasticsearch_Method_HEAD,
                 uri = Uri}.

rest_request_get_doc(Index, Type, Id, Params) when is_binary(Index),
                                                   is_binary(Type),
                                                   is_binary(Id),
                                                   is_list(Params) ->
    Uri = make_uri([Index, Type, Id], Params),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri}.

rest_request_mget_doc(Index, Type, Doc) when is_binary(Index),
                                                   is_binary(Type),
                                                   is_binary(Doc) ->
    Uri = make_uri([Index, Type, ?MGET], []),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri,
                 body = Doc}.

rest_request_delete_doc(Index, Type, Id, Params) when is_binary(Index),
                                                   is_binary(Type),
                                                   is_binary(Id),
                                                   is_list(Params) ->
    Uri = make_uri([Index, Type, Id], Params),
    #restRequest{method = ?elasticsearch_Method_DELETE,
                 uri = Uri}.

rest_request_search(Index, Type, Doc, Params) when is_binary(Index),
                                                   is_binary(Type),
                                                   is_binary(Doc),
                                                   is_list(Params) ->
    Uri = make_uri([Index, Type, ?SEARCH], Params),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri,
                 body = Doc}.

rest_request_refresh(Index) when is_list(Index) ->
    IndexList = bstr:join(Index, <<",">>),
    Uri = bstr:join([IndexList, ?REFRESH], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_POST,
                 uri = Uri}.

rest_request_flush(Index) when is_list(Index) ->
    IndexList = bstr:join(Index, <<",">>),
    Uri = bstr:join([IndexList, ?FLUSH], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_POST,
                 uri = Uri}.

rest_request_optimize(Index) when is_list(Index) ->
    IndexList = bstr:join(Index, <<",">>),
    Uri = bstr:join([IndexList, ?OPTIMIZE], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_POST,
                 uri = Uri}.

rest_request_segments(Index) when is_list(Index) ->
    IndexList = bstr:join(Index, <<",">>),
    Uri = bstr:join([IndexList, ?SEGMENTS], <<"/">>),
    #restRequest{method = ?elasticsearch_Method_GET,
                 uri = Uri}.

rest_request_clear_cache(Index, Params) when is_list(Index) ->
    IndexList = bstr:join(Index, <<",">>),
    Uri = make_uri([IndexList, ?CLEAR_CACHE], Params),
    #restRequest{method = ?elasticsearch_Method_POST,
                 uri = Uri}.

%% @doc Make a complete URI based on the tokens and props
make_uri(BaseList, PropList) ->
    Base = bstr:join(BaseList, <<"/">>),
    case PropList of
        [] ->
            Base;
        PropList ->
            Props = d_uri:uri_params_encode(PropList),
            bstr:join([Base, Props], <<"?">>)
    end.

%% @doc The official way to get a value from this application's env.
%%      Will return Default if that key is unset.
-spec get_env(Key :: atom(), Default :: term()) -> term().
get_env(Key, Default) ->
    case application:get_env(?APP, Key) of
        {ok, Value} ->
            Value;
        _ ->
            Default
    end.
-spec is_200(response()) -> boolean().
is_200({ok, Response}) ->
    case Response#restResponse.status of
        200 -> true;
        _ -> false
    end.

-spec is_200_or_201(response()) -> boolean().
is_200_or_201({ok, Response}) ->
    case Response#restResponse.status of
        200 -> true;
        201 -> true;
        _ -> false
    end.

-spec decode_response(response()) -> any().
decode_response({ok, {_,_,_,Json}}) ->
    jsx:decode(Json).
