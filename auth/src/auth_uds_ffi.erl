-module(auth_uds_ffi).
-export([listen_uds/1, accept_uds/1, connect_uds/1, send_uds/2, recv_uds/2, close_uds/1, delete_file/1, spawn_proc/1, sleep/1, get_env/2]).

listen_uds(PathBin) ->
    Path = binary_to_list(PathBin),
    file:delete(Path),
    filelib:ensure_dir(Path),
    case gen_tcp:listen(0, [
        {ifaddr, {local, Path}},
        {mode, binary},
        {packet, line},
        {active, false},
        {reuseaddr, true}
    ]) of
        {ok, ListenSocket} -> {ok, ListenSocket};
        {error, Reason} -> {error, atom_to_binary(Reason, utf8)}
    end.

accept_uds(ListenSocket) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} -> {ok, Socket};
        {error, Reason} -> {error, atom_to_binary(Reason, utf8)}
    end.

connect_uds(PathBin) ->
    Path = binary_to_list(PathBin),
    case gen_tcp:connect({local, Path}, 0, [
        {mode, binary},
        {packet, line},
        {active, false}
    ], 5000) of
        {ok, Socket} -> {ok, Socket};
        {error, Reason} -> {error, atom_to_binary(Reason, utf8)}
    end.

send_uds(Socket, DataBin) ->
    case gen_tcp:send(Socket, DataBin) of
        ok -> {ok, nil};
        {error, Reason} -> {error, atom_to_binary(Reason, utf8)}
    end.

recv_uds(Socket, Timeout) ->
    case gen_tcp:recv(Socket, 0, Timeout) of
        {ok, Bin} -> {ok, Bin};
        {error, Reason} -> {error, atom_to_binary(Reason, utf8)}
    end.

close_uds(Socket) ->
    gen_tcp:close(Socket),
    nil.

delete_file(PathBin) ->
    file:delete(binary_to_list(PathBin)),
    nil.

spawn_proc(Fun) ->
    spawn_link(Fun),
    nil.

sleep(Ms) ->
    timer:sleep(Ms),
    nil.

get_env(NameBin, DefaultBin) ->
    case os:getenv(binary_to_list(NameBin)) of
        false -> DefaultBin;
        Val -> list_to_binary(Val)
    end.
