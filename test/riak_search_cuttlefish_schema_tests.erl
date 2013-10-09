-module(riak_search_cuttlefish_schema_tests).

-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

%% basic schema test will check to make sure that all defaults from the schema
%% make it into the generated app.config
basic_schema_test() ->
    %% The defaults are defined in ../priv/riak_search.schema. it is the file under test. 
    Config = cuttlefish_unit:generate_templated_config("../priv/riak_search.schema", [], context()),

    cuttlefish_unit:assert_config(Config, "riak_search.enabled", false),
    cuttlefish_unit:assert_config(Config, "merge_index.data_root", "./data/merge_index"),
    cuttlefish_unit:assert_config(Config, "merge_index.buffer_rollover_size", 1048576),
    cuttlefish_unit:assert_config(Config, "merge_index.max_compact_segments", 20),
    ok.

override_schema_test() ->
    %% Conf represents the riak.conf file that would be read in by cuttlefish.
    %% this proplists is what would be output by the conf_parse module
    Conf = [
        {["search"], on},
        {["merge_index", "data_root"], "/absolute/data/merge_index"},
        {["merge_index", "buffer_rollover_size"], "2MB"},
        {["merge_index", "max_compact_segments"], 10}
    ],

    Config = cuttlefish_unit:generate_templated_config("../priv/riak_search.schema", Conf, context()),

    cuttlefish_unit:assert_config(Config, "riak_search.enabled", true),
    cuttlefish_unit:assert_config(Config, "merge_index.data_root", "/absolute/data/merge_index"),
    cuttlefish_unit:assert_config(Config, "merge_index.buffer_rollover_size", 2097152),
    cuttlefish_unit:assert_config(Config, "merge_index.max_compact_segments", 10),
    ok.


context() ->
    [
        {platform_data_dir, "./data"}
    ].
