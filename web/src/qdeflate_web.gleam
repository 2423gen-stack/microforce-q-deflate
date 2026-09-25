// Copyright (c) 2026 Gen Nishizumi (西住玄)
// SPDX-License-Identifier: MIT

import gleam/erlang/process
import mist
import qdeflate_web/web
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let ctx = web.Context
  let handler = fn(req) { web.handle_request(req, ctx) }

  // Mist HTTPサーバー起動 (0.0.0.0 で全インターフェース待受, ポート8080)
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(8080)
    |> mist.start

  process.sleep_forever()
}
