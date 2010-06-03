-module(testing_config).

-include_lib("eunit/include/eunit.hrl").
-include_lib("riak_solr/include/riak_solr.hrl").

parse_test_() ->
    [{setup, fun() -> start_config_server() end,
      fun({ok, Pid}) -> exit(Pid, kill) end,
      [fun() ->
               {ok, Schema} = riak_solr_config:get_schema("schema1"),
               validate_schema(schema1, Schema) end,
       fun() ->
               %% Parse...
               {ok, Xml} = file:read_file("./../test/test_data/add.xml"),
               {ok, Command, Entries} = riak_solr_xml_xform:xform(Xml),

               %% Validate...
               {ok, Schema} = riak_solr_config:get_schema("schema1"),
               ok = Schema:validate_commands(Command, Entries),
               sanity_check_cmds(Cmds1) end]}].

%% Helper functions
start_config_server() ->
    application:load(riak_solr),
    application:set_env(riak_solr, schema_dir, "./../test/test_data"),
    riak_solr_config:start_link().

sanity_check_cmds([]) ->
    ok;
sanity_check_cmds([H|T]) ->
    ?assertMatch(true, is_list(dict:fetch("first_name", H))),
    ?assertMatch(true, is_list(dict:fetch("last_name", H))),
    ?assertMatch(true, is_integer(dict:fetch("paygrade", H))),
    case dict:find("likes_cookies", H) of
        {ok, Value} ->
            ?assertMatch(true, Value);
        _ ->
            ok
    end,
    sanity_check_cmds(T).

validate_schema(schema1, Schema) ->
    ?assertMatch("schema1", Schema:name()),
    ?assertMatch("1.1", Schema:version()),
    FirstName = Schema:find_field("first_name"),
    LastName = Schema:find_field("last_name"),
    Paygrade = Schema:find_field("paygrade"),
    Cookies = Schema:find_field("likes_cookies"),
    ?assertMatch("first_name", FirstName#riak_solr_field.name),
    ?assertMatch(string, FirstName#riak_solr_field.type),
    ?assertMatch(true, FirstName#riak_solr_field.required),
    ?assertMatch("last_name", LastName#riak_solr_field.name),
    ?assertMatch(string, LastName#riak_solr_field.type),
    ?assertMatch(true, LastName#riak_solr_field.required),
    ?assertMatch("paygrade", Paygrade#riak_solr_field.name),
    ?assertMatch(integer, Paygrade#riak_solr_field.type),
    ?assertMatch(true, Paygrade#riak_solr_field.required),
    ?assertMatch("likes_cookies", Cookies#riak_solr_field.name),
    ?assertMatch(boolean, Cookies#riak_solr_field.type),
    ?assertMatch(false, Cookies#riak_solr_field.required).
