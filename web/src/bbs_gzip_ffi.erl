-module(bbs_gzip_ffi).
-export([gzip_compress/1, generate_random_key/0, create_stripe_checkout/7, create_stripe_checkout/8, get_env/1]).

gzip_compress(Binary) ->
    case find_port_executable() of
        {ok, ExePath} ->
            try_port_compress(ExePath, Binary);
        error ->
            fallback_zlib_compress(Binary)
    end.

find_port_executable() ->
    Candidates = [
        "priv/qdeflate_port",
        "/app/priv/qdeflate_port",
        case code:priv_dir(qdeflate_web) of
            PrivDir when is_list(PrivDir) -> PrivDir ++ "/qdeflate_port";
            _ -> ""
        end,
        case code:priv_dir(bbs) of
            PrivDir2 when is_list(PrivDir2) -> PrivDir2 ++ "/qdeflate_port";
            _ -> ""
        end
    ],
    check_candidates(Candidates).

check_candidates([]) -> error;
check_candidates([Path | Rest]) ->
    case filelib:is_regular(Path) of
        true -> {ok, Path};
        false -> check_candidates(Rest)
    end.

try_port_compress(ExePath, Binary) ->
    try
        Port = open_port({spawn_executable, ExePath}, [{packet, 4}, binary, use_stdio]),
        Port ! {self(), {command, Binary}},
        receive
            {Port, {data, CompressedGz}} ->
                port_close(Port),
                {ok, CompressedGz}
        after 15000 ->
            catch port_close(Port),
            fallback_zlib_compress(Binary)
        end
    catch
        _:_ ->
            fallback_zlib_compress(Binary)
    end.

fallback_zlib_compress(Binary) ->
    try
        Gz = zlib:gzip(Binary),
        {ok, Gz}
    catch
        _:Reason ->
            {error, unicode:characters_to_binary(io_lib:format("~p", [Reason]))}
    end.

generate_random_key() ->
    Bytes = crypto:strong_rand_bytes(16),
    Hex = binary:encode_hex(Bytes),
    <<"qdf_live_", Hex/binary>>.

get_env(KeyBin) ->
    Key = binary_to_list(KeyBin),
    case os:getenv(Key) of
        false -> {error, nil};
        Val -> {ok, list_to_binary(Val)}
    end.


create_stripe_checkout(SecretKeyBin, SuccessUrlBin, CancelUrlBin, UserIdBin, PlanNameBin, AmountCents, CreditsMb) ->
    create_stripe_checkout(SecretKeyBin, SuccessUrlBin, CancelUrlBin, UserIdBin, PlanNameBin, AmountCents, CreditsMb, 0).

create_stripe_checkout(SecretKeyBin, SuccessUrlBin, CancelUrlBin, UserIdBin, PlanNameBin, AmountCents, CreditsMb, TipCents) ->
    ssl:start(),
    inets:start(),
    Url = "https://api.stripe.com/v1/checkout/sessions",
    Headers = [
        {"Authorization", "Bearer " ++ binary_to_list(SecretKeyBin)}
    ],
    ContentType = "application/x-www-form-urlencoded",
    
    AmountStr = integer_to_list(AmountCents),
    CreditsMbStr = float_to_list(CreditsMb, [{decimals, 1}, compact]),
    
    BaseFormData = [
        {"payment_method_types[]", "card"},
        {"mode", "payment"},
        {"success_url", binary_to_list(SuccessUrlBin)},
        {"cancel_url", binary_to_list(CancelUrlBin)},
        {"line_items[0][price_data][currency]", "usd"},
        {"line_items[0][price_data][unit_amount]", AmountStr},
        {"line_items[0][price_data][product_data][name]", binary_to_list(PlanNameBin)},
        {"line_items[0][quantity]", "1"},
        {"metadata[user_id]", binary_to_list(UserIdBin)},
        {"metadata[credits_mb]", CreditsMbStr}
    ],
    
    FormData = case TipCents of
        T when is_integer(T), T > 0 ->
            TipStr = integer_to_list(T),
            BaseFormData ++ [
                {"line_items[1][price_data][currency]", "usd"},
                {"line_items[1][price_data][unit_amount]", TipStr},
                {"line_items[1][price_data][product_data][name]", "Developer Tip (US Restaurant Style 🇺🇸)"},
                {"line_items[1][quantity]", "1"},
                {"metadata[tip_usd_cents]", TipStr}
            ];
        _ ->
            BaseFormData
    end,
    
    EncodePair = fun({K, V}) ->
        uri_string:quote(K) ++ "=" ++ uri_string:quote(V)
    end,
    Body = string:join([EncodePair(P) || P <- FormData], "&"),
    
    HttpOptions = [{ssl, [{verify, verify_none}]}],
    Options = [{body_format, binary}],
    
    case httpc:request(post, {Url, Headers, ContentType, Body}, HttpOptions, Options) of
        {ok, {{_, 200, _}, _, RespBody}} ->
            {ok, RespBody};
        {ok, {{_, StatusCode, _}, _, RespBody}} ->
            Msg = io_lib:format("Stripe HTTP ~p: ~s", [StatusCode, RespBody]),
            {error, unicode:characters_to_binary(Msg)};
        {error, Reason} ->
            Msg = io_lib:format("Request failed: ~p", [Reason]),
            {error, unicode:characters_to_binary(Msg)}
    end.

