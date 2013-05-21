ErlasticSearch
=========
A thrift based erlang client for [ElasticSearch](http://www.elasticsearch.org/).



Installation
============
Add this as a rebar dependency to your project.

1. Be sure to set up ElasticSearch to support thrift!
   * Install the thrift plugin (available [here](https://github.com/elasticsearch/elasticsearch-transport-thrift))
      * Probably something like --> ```bin/plugin -install elasticsearch/elasticsearch-transport-thrift/1.5.0.```
   * You'll need to add (at least) the following settings to config.yaml
      * ```thrift.port: 9500```
      * ```thrift.protocol: 'binary'```
    * You might want to set the port to whatever you want instead of ```9500```
    * Start ElasticSearch
       * If you plan on running the tests, you probably want to do this.
       * Heck, if you plan on using ElasticSearch, you probably want to do this.
       * If you plan on running the tests, you might want to run it in 'in-memory' mode.
          * Probably something like --> ```elasticsearch -f -Des.index.storage.type=memory -Des.config=/usr/local/opt/elasticsearch/config/elasticsearch.yml```
1. Update your environment with the following parameters (look in [app.config](https://github.com/dieswaytoofast/erlasticsearch/blob/master/app.config) for examples)
   * ```thrift.options```
   * ```thrift.host```
   * ```thrift.port```
1. Start a client process
	* ```erlasticsearch:start_link().```
1. Profit



WARNING
============
__**THE TESTS WILL CREATE AND DELETE INDICES IN WHATEVER ELASTICSEARCH INSTANCE YOU POINT THE CLIENT AT**__

__**THE TESTS WILL CREATE AND DELETE INDICES IN WHATEVER ELASTICSEARCH INSTANCE YOU POINT THE CLIENT AT**__

__**THE TESTS WILL CREATE AND DELETE INDICES IN WHATEVER ELASTICSEARCH INSTANCE YOU POINT THE CLIENT AT**__

__**!!!!!!!SERIOUSLY!!!!!!**__


__**YOU HAVE BEEN WARNED**__






Details
============

1. erlasticsearch includes a poolboy module which starts up a pool as specified in the application environment variable _pools_.  See [poolboy](https://github.com/devinus/poolboy/blob/master/README.md) for how to configure a pool.  The default pool has 10 clients and is called _erlasticsearch_pool_.  You can run functions on this pool by using the _erlasticsearch_poolboy_ module functions.
1. The thrift client is in the form of a _gen_server_ process (a _gen_server_).  You can start a client process as follows
	* ```{ok, Pid} = erlasticsearch:start_link().```
1. Any JSON expected by ElasticSearch will need to go in as JSON
   * For example --> ```<<"{\"settings\":{\"number_of_shards\":3}}">>```
1. Output returned by most everything is in the form ```{ok, #restResponse{}} | error()```
   * See the format of ```#restResponse{}``` [here](https://github.com/dieswaytoofast/erlasticsearch/blob/master/src/elasticsearch_types.hrl).
   * See the format of ```error()``` [here](https://github.com/dieswaytoofast/erlasticsearch/blob/master/src/erlasticsearch.hrl)
   * The payload _from_ ElasticSearch - when it exists - will almost always be JSON
      * e.g. --> ```<<"{\"ok\":true,\"acknowledged\":true}">>```
1. Boolean methods (e.g. ```is_index/2, is_type/3, is_doc/4```) return a ```boolean()``` (d-uh)


Index CRUD
-----
These methods are available to perform CRUD activities on Indexes (kinda, sorta, vaguely the equivalent of Databases)

Function | Parameters | Description
----- | ----------- | --------
create_index/2 | ServerRef, IndexName  | Creates the Index called _IndexName_
create_index/3 | ServerRef, IndexName, Parameters | Creates the Index called _IndexName_, with additional options as specified [here](http://www.elasticsearch.org/guide/reference/api/admin-indices-create-index/)
delete_index/2 | ServerRef, IndexName  | Deletes the Index called _IndexName_
is_index/2 | ServerRef, IndexName  | Checks if the Index called _IndexName_ exists. (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]```)
is_type/3 | ServerRef, IndexName, TypeName  | Checks if the Type called _TypeName exists in the index _IndexName_. (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]```), as well as a list of types (e.g. ```[<<"type1">>, <<"type2">>]```)
open_index/2 | ServerRef, IndexName  | Opens the Index called _IndexName_
close_index/2 | ServerRef, IndexName  | Closes the Index called _IndexName_



**EXAMPLES**

```erlang
erlasticsearch@pecorino)1> {ok, Pid} = erlasticsearch:start_link().
{ok,<0.178.0>}
erlasticsearch@pecorino)2> erlasticsearch:create_index(Pid, <<"foo2">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"acknowledged\":true}">>}}
erlasticsearch@pecorino)3> erlasticsearch:create_index(Pid, <<"foo3">>, <<"{\"settings\":{\"number_of_shards\":3}}">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"acknowledged\":true}">>}}
erlasticsearch@pecorino)4> erlasticsearch:create_index(Pid, <<"foo4">>, <<"{\"settings\":{\"number_of_shards\":3}}">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"acknowledged\":true}">>}}
```
```erlang
erlasticsearch@pecorino)5> erlasticsearch:delete_index(Pid, <<"foo2">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"acknowledged\":true}">>}}
```
```erlang
erlasticsearch@pecorino)6> erlasticsearch:is_index(Pid, <<"foo3">>).
false
erlasticsearch@pecorino)7> erlasticsearch:is_index(Pid, <<"foo4">>).
true
erlasticsearch@pecorino)8> erlasticsearch:is_index(Pid, [<<"foo3">>, <<"foo4">>]).
true
erlasticsearch@pecorino)9> erlasticsearch:is_index(Pid, <<"no_such_index">>).
false
erlasticsearch@pecorino)10> erlasticsearch:is_type(Pid, <<"foo3">>, <<"existing_type_1">>).
true
erlasticsearch@pecorino)11> erlasticsearch:is_type(Pid, [<<"foo3">>, <<"foo4">>], <<"existing_type_1">>).
true
erlasticsearch@pecorino)11> erlasticsearch:is_type(Pid, [<<"foo3">>, <<"foo4">>], [<<"existing_type_1">>, <<"existing_type_2">>]).
true
```
```erlang
erlasticsearch@pecorino)12> erlasticsearch:open_index(Pid, <<"index1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"acknowledged\":true}">>}}
erlasticsearch@pecorino)13> erlasticsearch:close_index(Pid, <<"index1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"acknowledged\":true}">>}}
```



Document CRUD
-----
These methods are available to perform CRUD activities on actual documents

Function | Parameters | Description
----- | ----------- | --------
insert_doc/5 | ServerRef, IndexName, Type, Id, Doc  | Creates the Doc under _IndexName_, with type _Type_, and id _Id_
insert_doc/6 | ServerRef, IndexName, Type, Id, Doc, Params  | Creates the Doc under _IndexName_, with type _Type_, and id _Id_, and passes the tuple-list _Params_ to ElasticSearch
is_doc/4 | ServerRef, IndexName, Type, Id  | Checks if the Doc under _IndexName_, with type _Type_, and id _Id_ exists
get_doc/4 | ServerRef, IndexName, Type, Id  | Gets the Doc under _IndexName_, with type _Type_, and id _Id_
get_doc/5 | ServerRef, IndexName, Type, Id, Params  | Gets the Doc under _IndexName_, with type _Type_, and id _Id_, and passes the tuple-list _Params_ to ElasticSearch
mget_doc/2 | ServerRef, Doc  | Gets documents from the ElasticSearch cluster based on the Index(s), Type(s), and Id(s) in _Doc_
mget_doc/3 | ServerRef, IndexName, Doc  | Gets documents from the ElasticSearch cluster index _IndexName_ based on the Type(s), and Id(s) in _Doc_
mget_doc/4 | ServerRef, IndexName, TypeName, Doc  | Gets documents from the ElasticSearch cluster index _IndexName_, with type _TypeName_, based on the Id(s) in _Doc_
delete_doc/4 | ServerRef, IndexName, Type, Id  | Deleset the Doc under _IndexName_, with type _Type_, and id _Id_
delete_doc/5 | ServerRef, IndexName, Type, Id, Params  | Deletes the Doc under _IndexName_, with type _Type_, and id _Id_, and passes the tuple-list _Params_ to ElasticSearch
count/2 | ServerRef, Doc | Counts the docs in the cluster based on the search in _Doc_. (note that if _Doc_ is empty, you get a count of all the docs in the cluster)
count/3 | ServerRef, Doc, Params | Counts the docs in the cluster based on the search in _Doc_, using _Params_.  Note that either _Doc_ or _Params_ can be empty, but clearly not both :-)
count/4 | ServerRef, IndexName, Doc, Params | Counts the docs in the cluster based on the search in _Doc_, associated with the index _IndexName_, using _Params_  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]```. This list can also be empty - ```[]```)
count/5 | ServerRef, IndexName, TypeName, Doc, Params | Counts the docs in the cluster based on the search in _Doc_, associated with the index _IndexName_, and type _TypeName_ using _Params_  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]```, as well as a list of types (e.g. ) ```[<<"type1">>, <<"type2">>]```. Each of these lists can also be empty - ```[]```)
delete_by_query/2 | ServerRef, Doc | Deletes the docs in the cluster based on the search in _Doc_. (note that if _Doc_ is empty, you get a count of all the docs in the cluster)
delete_by_query/3 | ServerRef, Doc, Params | Deletes the docs in the cluster based on the search in _Doc_, using _Params_.  Note that either _Doc_ or _Params_ can be empty, but clearly not both :-)
delete_by_query/4 | ServerRef, IndexName, Doc, Params | Deletes the docs in the cluster based on the search in _Doc_, associated with the index _IndexName_, using _Params_  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]```. This list can also be empty - ```[]```)
delete_by_query/5 | ServerRef, IndexName, TypeName, Doc, Params | Deletes the docs in the cluster based on the search in _Doc_, associated with the index _IndexName_, and type _TypeName_ using _Params_  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]```, as well as a list of types (e.g. ) ```[<<"type1">>, <<"type2">>]```. Each of these lists can also be empty - ```[]```)




_Note_:

1. For both ```insert_doc/4``` and ```insert_doc/5```, sending in ```undefined``` as the ```Id``` will result in ElasticSearch generating an Id for the document.  This Id will be returned as part of the result...
2. Yes, the order of the arguments to mget_doc/[2,3,4] is weird.  Its just that ElasticSearch is slightly strange in this one...

**EXAMPLES**

```erlang
erlasticsearch@pecorino)5> {ok, Pid} = erlasticsearch:start_link().
{ok,<0.178.0>}
erlasticsearch@pecorino)6> erlasticsearch:insert_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>, <<"{\"some_key\":\"some_val\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1}">>}}
erlasticsearch@pecorino)7> erlasticsearch:insert_doc(Pid, <<"index2">>, <<"type3">>, <<"id2">>, <<"{\"some_key\":\"some_val\"}">>, [{'_ttl', '1d'}]).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index2\",\"_type\":\"type3\",\"_id\":\"id2\",\"_version\":1}">>}}
erlasticsearch@pecorino)8> erlasticsearch:insert_doc(Pid, <<"index3">>, <<"type3">>, undefined, <<"{\"some_key\":\"some_val\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index3\",\"_type\":\"type3\",\"_id\":\"8Ji9R-TtT4KXxUOvb14K8g\",\"_version\":1}">>}}
```
```erlang
erlasticsearch@pecorino)9> erlasticsearch:is_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>).
true
```
```erlang
erlasticsearch@pecorino)9> erlasticsearch:get_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1,\"exists\":true, \"_source\" : {\"som"...>>}}
erlasticsearch@pecorino)10> erlasticsearch:get_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>, [{fields, foobar}]).
{ok,{restResponse,200,undefined,
                  <<"{\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1,\"exists\":true}">>}}
erlasticsearch@pecorino)11> erlasticsearch:get_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>, [{fields, some_key}]).
{ok,{restResponse,200,undefined,
                  <<"{\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1,\"exists\":true,\"fields\":{\"some_ke"...>>}}
```
```erlang
erlasticsearch@pecorino)12> erlasticsearch:delete_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"found\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":2}">>}}
```
```erlang
erlasticsearch@pecorino)13> erlasticsearch:insert_doc(Pid, <<"index1">>, <<"type1">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)14> erlasticsearch:insert_doc(Pid, <<"index2">>, <<"type2">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index2\",\"_type\":\"type2\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)15> erlasticsearch:count(Pid, <<>>).
{ok,{restResponse,200,undefined,
                  <<"{\"count\":4,\"_shards\":{\"total\":105,\"successful\":105,\"failed\":0}}">>}}
erlasticsearch@pecorino)16> erlasticsearch:count(Pid, <<>>, [{q, <<"key_1:value_1">>}]).
{ok,{restResponse,200,undefined,
                  <<"{\"count\":2,\"_shards\":{\"total\":105,\"successful\":105,\"failed\":0}}">>}}
erlasticsearch@pecorino)17> erlasticsearch:count(Pid, <<"{\"term\":{\"key_1\":\"value_1\"}}">>, []).
{ok,{restResponse,200,undefined,
                  <<"{\"count\":2,\"_shards\":{\"total\":105,\"successful\":105,\"failed\":0}}">>}}
erlasticsearch@pecorino)18> erlasticsearch:count(Pid, [<<"index1">>],<<>>, [{q, <<"key_1:value_1">>}]).
{ok,{restResponse,200,undefined,
                  <<"{\"count\":1,\"_shards\":{\"total\":5,\"successful\":5,\"failed\":0}}">>}}
erlasticsearch@pecorino)19> erlasticsearch:count(Pid, [<<"index1">>,<<"index2">>],[<<"type1">>, <<"type2">>],<<>>, [{q, <<"key_1:value_1">>}]).
{ok,{restResponse,200,undefined,
                  <<"{\"count\":2,\"_shards\":{\"total\":10,\"successful\":10,\"failed\":0}}">>}}
```
```erlang
erlasticsearch@pecorino)20> erlasticsearch:insert_doc(Pid, <<"index1">>, <<"type1">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)21> erlasticsearch:insert_doc(Pid, <<"index2">>, <<"type2">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index2\",\"_type\":\"type2\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)22> erlasticsearch:delete_by_query(Pid, <<"{\"term\":{\"key_1\":\"value_1\"}}">>).                  {ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_indices\":{\"index_137402104\":{\"_shards\":{\"total\":5,\"successful\":5,\"failed\":0}},\""...>>}}
erlasticsearch@pecorino)23> erlasticsearch:count(Pid, <<"{\"term\":{\"key_1\":\"value_1\"}}">>).                            {ok,{restResponse,200,undefined,
                  <<"{\"count\":0,\"_shards\":{\"total\":245,\"successful\":245,\"failed\":0}}">>}}
```
```erlang
erlasticsearch@pecorino)24> erlasticsearch:insert_doc(Pid, <<"index1">>, <<"type1">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)25> erlasticsearch:insert_doc(Pid, <<"index2">>, <<"type2">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index2\",\"_type\":\"type2\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)26> erlasticsearch:delete_by_query(Pid, <<>>, [{q, <<"key1:value1">>}]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_indices\":{\"index_137402104\":{\"_shards\":{\"total\":5,\"successful\":5,\"failed\":0}},\""...>>}}
erlasticsearch@pecorino)27> erlasticsearch:count(Pid, <<"{\"term\":{\"key_1\":\"value_1\"}}">>).
{ok,{restResponse,200,undefined,
                  <<"{\"count\":0,\"_shards\":{\"total\":245,\"successful\":245,\"failed\":0}}">>}}
```
```erlang
erlasticsearch@pecorino)28> erlasticsearch:insert_doc(Pid, <<"index1">>, <<"type1">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)29> erlasticsearch:insert_doc(Pid, <<"index2">>, <<"type2">>, <<"1">>, <<"{\"key_1\":\"value_1\"},{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index2\",\"_type\":\"type2\",\"_id\":\"1\",\"_version\":1}">>}}
erlasticsearch@pecorino)30> erlasticsearch:delete_by_query(Pid, [<<"index1">>, <<"index2">>], [<<"type1">>, <<"type2">>], <<>>, [{q, <<"key1:value1">>}]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_indices\":{\"index1\":{\"_shards\":{\"total\":5,\"successful\":5,\"failed\":0}},\"index2\":{"...>>}}
erlasticsearch@pecorino)31> erlasticsearch:count(Pid, <<"{\"term\":{\"key_1\":\"value_1\"}}">>).
{ok,{restResponse,200,undefined,
                  <<"{\"count\":0,\"_shards\":{\"total\":245,\"successful\":245,\"failed\":0}}">>}}
```
```erlang
erlasticsearch@pecorino)32> erlasticsearch:insert_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>, <<"{\"key_1\":\"value_1\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1}">>}}
erlasticsearch@pecorino)33>  erlasticsearch:insert_doc(Pid, <<"index2">>, <<"type2">>, <<"id2">>, <<"{\"key_2\":\"value_2\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index2\",\"_type\":\"type2\",\"_id\":\"id2\",\"_version\":1}">>}}
erlasticsearch@pecorino)34> FullDoc = jsx:encode([{docs, [[{<<"_index">>, <<"index1">>},{<<"_type">>, <<"type1">>},{<<"_id">>, <<"id1">>}], [{<<"_index">>, <<"index2">>},{<<"_type">>, <<"type2">>},{<<"_id">>, <<"id2">>}]]}]).
<<"{\"docs\":[{\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\"},{\"_index\":\"index2\",\"_type\":\"type2\",\"_id\":\"id2\"}]}">>
erlasticsearch@pecorino)35> erlasticsearch:mget_doc(Pid, FullDoc).                                                         {ok,{restResponse,200,undefined,
                  <<"{\"docs\":[{\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1,\"exists\":true, \"_source"...>>}}
erlasticsearch@pecorino)36> TypeDoc = jsx:encode([{docs, [[{<<"_type">>, <<"type1">>},{<<"_id">>, <<"id1">>}], [{<<"_type">>, <<"type2">>},{<<"_id">>, <<"id2">>}]]}]).
<<"{\"docs\":[{\"_type\":\"type1\",\"_id\":\"id1\"},{\"_type\":\"type2\",\"_id\":\"id2\"}]}">>
erlasticsearch@pecorino)37> erlasticsearch:mget_doc(Pid, <<"index1">>, TypeDoc).
{ok,{restResponse,200,undefined,
                  <<"{\"docs\":[{\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1,\"exists\":true, \"_source"...>>}}
erlasticsearch@pecorino)38> IdDoc = jsx:encode([{docs, [[{<<"_id">>, <<"id1">>}], [{<<"_id">>, <<"id2">>}]]}]).
<<"{\"docs\":[{\"_id\":\"id1\"},{\"_id\":\"id2\"}]}">>
erlasticsearch@pecorino)39> erlasticsearch:mget_doc(Pid, <<"index1">>, <<"type1">>, IdDoc).
{ok,{restResponse,200,undefined,
                  <<"{\"docs\":[{\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1,\"exists\":true, \"_source"...>>}}
```



Search
-----
API to perform searches against ElasticSearch (this _is_ why you are using ElasticSearch, right?)

Function | Parameters | Description
----- | ----------- | --------
search/4 | ServerRef, IndexName, Type, Doc  | Searches the index _IndexName_, with type _Type_ for the JSON query embedded in _Doc_
search/5 | ServerRef, IndexName, Type, Doc, Params  | Searches the index _IndexName_, with type _Type_ for the JSON query embedded in _Doc_, and passes the tuple-list _Params_ to ElasticSearch



**EXAMPLES**

```erlang
erlasticsearch@pecorino)1> {ok, Pid} = erlasticsearch:start_link().
{ok,<0.178.0>}
erlasticsearch@pecorino)2> erlasticsearch:insert_doc(Pid, <<"index1">>, <<"type1">>, <<"id1">>, <<"{\"some_key\":\"some_val\"}">>).
{ok,{restResponse,201,undefined,
                  <<"{\"ok\":true,\"_index\":\"index1\",\"_type\":\"type1\",\"_id\":\"id1\",\"_version\":1}">>}}
erlasticsearch@pecorino)3> erlasticsearch:search(Pid, <<"index1">>, <<"type1">>, <<>>, [{q, "some_key:some_val"}]).
{ok,{restResponse,200,undefined,
                  <<"{\"took\":1,\"timed_out\":false,\"_shards\":{\"total\":5,\"successful\":5,\"failed\":0},\"hits\":{\"total\":"...>>}}
```

Index Helpers
-----
A bunch of functions that do "things" to indices (flush, refresh, etc.)

Function | Parameters | Description
----- | ----------- | --------
flush/1 | ServerRef  | Flushes all the indices
flush/2 | ServerRef, Index | Flushes the index _IndexName_.  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]```)
optimize/1 | ServerRef  | Optimizes all the indices
optimize/2 | ServerRef, Index | Optimizes the index _IndexName_.  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]``` This list can also be empty - ```[]```)
segments/1 | ServerRef  | Provides segment information for all the indices in the cluster
segments/2 | ServerRef, Index | Provides segment information for the index _IndexName_.  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]``` This list can also be empty - ```[]```)
refresh/1 | ServerRef  | Refreshes all the indices
refresh/2 | ServerRef, Index | Refreshes the index _IndexName_.  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]``` This list can also be empty - ```[]```)
status/2 | ServerRef, Index | Returns the status of index _IndexName_.  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]``` This list can also be empty - ```[]```)
clear_cache/1 | ServerRef  | Clears all the caches in the cluster
clear_cache/2 | ServerRef, Index | Clears all the caches associated with the index _IndexName_.  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]``` This list can also be empty - ```[]```)
clear_cache/3 | ServerRef, Index, params | Clears all the caches associated with the index _IndexName_, using _Params_  (Note that a list of Indices can also be sent in (e.g., ```[<<"foo">>, <<"bar">>]``` This list can also be empty - ```[]```)


**EXAMPLES**

```erlang
erlasticsearch@pecorino)1> {ok, Pid} = erlasticsearch:start_link().
{ok,<0.178.0>}
erlasticsearch@pecorino)2> erlasticsearch:refresh(Pid).                                                                                   {ok,{restResponse,200,undefined,                                                                                                                                               <<"{\"ok\":true,\"_shards\":{\"total\":552,\"successful\":276,\"failed\":0}}">>}}
erlasticsearch@pecorino)3> erlasticsearch:refresh(Pid, <<"index1">>).                                                                        {ok,{restResponse,200,undefined,                                                                                                                                               <<"{\"ok\":true,\"_shards\":{\"total\":10,\"successful\":5,\"failed\":0}}">>}}
erlasticsearch@pecorino)4> erlasticsearch:refresh(Pid, [<<"index1">>, <<"index2">>]).
{ok,{restResponse,200,undefined,                                                                                                                                               <<"{\"ok\":true,\"_shards\":{\"total\":16,\"successful\":8,\"failed\":0}}">>}}
```
```erlang
erlasticsearch@pecorino)5> erlasticsearch:flush(Pid).                                                                                   {ok,{restResponse,200,undefined,                                                                                                                                               <<"{\"ok\":true,\"_shards\":{\"total\":552,\"successful\":276,\"failed\":0}}">>}}
erlasticsearch@pecorino)6> erlasticsearch:refresh(Pid, <<"index1">>).                                                                        {ok,{restResponse,200,undefined,                                                                                                                                               <<"{\"ok\":true,\"_shards\":{\"total\":10,\"successful\":5,\"failed\":0}}">>}}
erlasticsearch@pecorino)7> erlasticsearch:refresh(Pid, [<<"index1">>, <<"index2">>]).
{ok,{restResponse,200,undefined,                                                                                                                                               <<"{\"ok\":true,\"_shards\":{\"total\":16,\"successful\":8,\"failed\":0}}">>}}
```
```erlang
erlasticsearch@pecorino)8> erlasticsearch:status(Pid, <<"index1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":6,\"successful\":3,\"failed\":0},\"indices\":{\"index1\":{\"index\":{\"prim"...>>}}
erlasticsearch@pecorino)9> erlasticsearch:status(Pid, [<<"index1">>, <<"index2">>]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":16,\"successful\":8,\"failed\":0},\"indices\":{\"index2\":{\"index\":{\"pri"...>>}}
erlasticsearch@pecorino)10> erlasticsearch:optimize(Pid, <<"index1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":10,\"successful\":5,\"failed\":0}}">>}}
erlasticsearch@pecorino)11> erlasticsearch:optimize(Pid, [<<"index1">>, <<"index2">>]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":16,\"successful\":8,\"failed\":0}}">>}}
erlasticsearch@pecorino)12> erlasticsearch:optimize(Pid).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":692,\"successful\":346,\"failed\":0}}">>}}
```
```erlang
erlasticsearch@pecorino)13> erlasticsearch:segments(<<"bar1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":170,\"successful\":85,\"failed\":0},\"indices\":{\"test_1\":{\"shards\":"...>>}}
erlasticsearch@pecorino)14> erlasticsearch:segments(<<"bar1">>, [<<"index1">>]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":10,\"successful\":5,\"failed\":0},\"indices\":{\"index1\":{\"shards\":{\""...>>}}
erlasticsearch@pecorino)15> erlasticsearch:segments(<<"bar1">>, [<<"index1">>, <<"index2">>]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":20,\"successful\":10,\"failed\":0},\"indices\":{\"index1\":{\"shards\":{"...>>}}
```
```erlang
erlasticsearch@pecorino)16> erlasticsearch:clear_cache(<<"bar1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":130,\"successful\":65,\"failed\":0}}">>}}
erlasticsearch@pecorino)17> erlasticsearch:clear_cache(<<"bar1">>, [<<"index1">>]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":10,\"successful\":5,\"failed\":0}}">>}}
erlasticsearch@pecorino)18> erlasticsearch:clear_cache(<<"bar1">>, [<<"index1">>], [{filter, true}]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":10,\"successful\":5,\"failed\":0}}">>}}
erlasticsearch@pecorino)19> erlasticsearch:clear_cache(<<"bar1">>, [], [{filter, true}]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"_shards\":{\"total\":140,\"successful\":70,\"failed\":0}}">>}}
```


Cluster Helpers
-----
A bunch of functions that do "things" to clusters (health, etc.)

Function | Parameters | Description
----- | ----------- | --------
health/1 | ServerRef  | Reports the health of the cluster
state/1 | ServerRef  | Reports the state of the cluster
state/2 | ServerRef, Params  | Reports the state of the cluster, with optional parameters
nodes_info/1 | ServerRef  | Reports the state of all the nodes in the cluster
nodes_info/2 | ServerRef, NodeName  | Reports the state of the node _NodeName_ in the cluster. (Note that a list of Nodes can also be sent in (e.g., ```[<<"node1">>, <<"node2">>]``` This list can also be empty - ```[]```)
nodes_info/3 | ServerRef, NodeName, Params  | Reports the state of the node _NodeName_ in the cluster, with optional _Params_. (Note that a list of Nodes can also be sent in (e.g., ```[<<"node1">>, <<"node2">>]``` This list can also be empty - ```[]```)
nodes_stats/1 | ServerRef  | Reports stats on all the nodes in the cluster
nodes_stats/2 | ServerRef, NodeName  | Reports the stats of the node _NodeName_ in the cluster. (Note that a list of Nodes can also be sent in (e.g., ```[<<"node1">>, <<"node2">>]```)
nodes_stats/3 | ServerRef, NodeName, Params  | Reports the stats of the node _NodeName_ in the cluster, with optional _Params_. (Note that a list of Nodes can also be sent in (e.g., ```[<<"node1">>, <<"node2">>]``` This list can also be empty - ```[]```)


**EXAMPLES**
```erlang
erlasticsearch@pecorino)1> {ok, Pid} = erlasticsearch:start_link().
{ok,<0.178.0>}
erlasticsearch@pecorino)2> erlasticsearch:refresh(Pid).                                                                                   {ok,{restResponse,200,undefined,                                                                                                                                               <<"{\"ok\":true,\"_shards\":{\"total\":552,\"successful\":276,\"failed\":0}}">>}}
erlasticsearch@pecorino)3> erlasticsearch:health(Pid).
{ok,{restResponse,200,undefined,
                  <<"{\"cluster_name\":\"elasticsearch_mahesh\",\"status\":\"yellow\",\"timed_out\":false,\"number_of_nodes\""...>>}}
```
```erlang
erlasticsearch@pecorino)4> erlasticsearch:state(Pid).
{ok,{restResponse,200,undefined,
                  <<"{\"cluster_name\":\"elasticsearch_mahesh\",\"master_node\":\"7k3ViuT5SQ67ayWsF1y8hQ\",\"blocks\":{\"ind"...>>}}
erlasticsearch@pecorino)5> erlasticsearch:state(Pid, [{filter_nodes, true}]).
{ok,{restResponse,200,undefined,
                  <<"{\"cluster_name\":\"elasticsearch_mahesh\",\"blocks\":{\"indices\":{\"index1\":{\"4\":{\"description\":\"inde"...>>}}
```
```erlang
erlasticsearch@pecorino)6> erlasticsearch:nodes_info(Pid).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"name\":\""...>>}}
erlasticsearch@pecorino)7> erlasticsearch:nodes_info(Pid, <<"node1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"name\":\""...>>}}
erlasticsearch@pecorino)8> erlasticsearch:nodes_info(Pid, [<<"node1">>]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"name\":\""...>>}}
erlasticsearch@pecorino)9> erlasticsearch:nodes_info(Pid, [<<"node1">>], [{os, true}, {process, true}]).
{ok,{restResponse,200,undefined,
                  <<"{\"ok\":true,\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"name\":\""...>>}}
```
```erlang
erlasticsearch@pecorino)10> erlasticsearch:nodes_stats(Pid).
{ok,{restResponse,200,undefined,
                  <<"{\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"timestamp\":136865"...>>}}
erlasticsearch@pecorino)11> erlasticsearch:nodes_stats(Pid, <<"node1">>).
{ok,{restResponse,200,undefined,
                  <<"{\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"timestamp\":136865"...>>}}
erlasticsearch@pecorino)12> erlasticsearch:nodes_stats(Pid, [<<"node1">>]).
{ok,{restResponse,200,undefined,
                  <<"{\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"timestamp\":136865"...>>}}
erlasticsearch@pecorino)13> erlasticsearch:nodes_stats(Pid, [<<"node1">>], [{process, true}, {transport, true}]).
{ok,{restResponse,200,undefined,
                  <<"{\"cluster_name\":\"elasticsearch_mahesh\",\"nodes\":{\"node1\":{\"timestamp\":136865"...>>}}
```



Credits
=======
This is _not_ to be confused with [erlastic_search](https://github.com/tsloughter/erlastic_search) by [Tristan Sloughter](https://github.com/tsloughter), which is HTTP/REST based, and almost certainly did not involve quite this level of head-thumping associated w/ figuring out how Thrift works…

(Yes, this is a _Credit_)
