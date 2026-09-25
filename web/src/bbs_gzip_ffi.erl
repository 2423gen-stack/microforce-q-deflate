-module(bbs_gzip_ffi).
-export([gzip_compress/1, generate_random_key/0, create_stripe_checkout/7, get_env/1]).

gzip_compress(Binary) ->
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


create_stripe_checkout(SecretKeyBin, SuccessUrlBin, CancelUrlBin, UserIdBin, PlanNameBin, AmountJpy, CreditsMb) ->
    ssl:start(),
    inets:start(),
    Url = "https://api.stripe.com/v1/checkout/sessions",
    Headers = [
        {"Authorization", "Bearer " ++ binary_to_list(SecretKeyBin)}
    ],
    ContentType = "application/x-www-form-urlencoded",
    
    AmountStr = integer_to_list(AmountJpy),
    CreditsMbStr = float_to_list(CreditsMb, [{decimals, 1}, compact]),
    
    FormData = [
        {"payment_method_types[]", "card"},
        {"mode", "payment"},
        {"success_url", binary_to_list(SuccessUrlBin)},
        {"cancel_url", binary_to_list(CancelUrlBin)},
        {"line_items[0][price_data][currency]", "jpy"},
        {"line_items[0][price_data][unit_amount]", AmountStr},
        {"line_items[0][price_data][product_data][name]", binary_to_list(PlanNameBin)},
        {"line_items[0][quantity]", "1"},
        {"metadata[user_id]", binary_to_list(UserIdBin)},
        {"metadata[credits_mb]", CreditsMbStr}
    ],
    
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

