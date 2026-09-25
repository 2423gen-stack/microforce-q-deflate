-module(bbs_uds_ffi).
-export([connect_uds/1, send_uds/2, recv_uds/2, close_uds/1]).

connect_uds(PathBin) ->
    Path = binary_to_list(PathBin),
    case gen_tcp:connect({local, Path}, 0, [
        {mode, binary},
        {packet, line},
        {active, false}
    ], 3000) of
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
