// Copyright (c) 2026 Gen Nishizumi (西住玄)
// SPDX-License-Identifier: MIT

import qdeflate_web/api_docs
import qdeflate_web/auth_client
import qdeflate_web/compress_lp
import qdeflate_web/dashboard
import qdeflate_web/login
import qdeflate_web/stripe
import gleam/bit_array
import gleam/bytes_tree
import gleam/float
import gleam/http.{Get, Post}
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import simplifile
import wisp.{type Request, type Response}

@external(erlang, "bbs_gzip_ffi", "gzip_compress")
fn gzip_compress(raw: BitArray) -> Result(BitArray, String)

@external(erlang, "bbs_gzip_ffi", "generate_random_key")
fn generate_random_key() -> String

pub type Context {
  Context
}

pub fn handle_request(req: Request, _ctx: Context) -> Response {
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    // 1. Q-Deflate LP (ランディングページ - 日本語)
    [] | ["compress"] -> {
      case req.method {
        Get -> {
          wisp.ok()
          |> wisp.html_body(compress_lp.render_lp(compress_lp.Ja))
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 1-EN. Q-Deflate LP (英語版)
    ["en"] | ["compress", "en"] -> {
      case req.method {
        Get -> {
          wisp.ok()
          |> wisp.html_body(compress_lp.render_lp(compress_lp.En))
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 7. Q-Deflate Playground お試し圧縮 (POST /compress/try)
    ["compress", "try"] -> {
      case req.method {
        Post -> {
          let lang = case wisp.get_query(req) {
            [#("lang", "en"), ..] -> compress_lp.En
            _ -> compress_lp.Ja
          }
          // デモ用お試しモック（元ファイル名を受け取り、疑似圧縮結果を返す）
          // 将来UDSソケット接続時に本物の幾何学ソルバーバイナリに差し替え
          let filename = "sample_data.json"
          let orig_size = 104_8576 // 1 MB
          let comp_size = 188_743  // 約 184 KB (82%削減)
          let download_id = "demo-qdf-001"

          wisp.ok()
          |> wisp.html_body(compress_lp.render_playground_result(
            filename,
            orig_size,
            comp_size,
            download_id,
            lang,
          ))
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 8. Q-Deflate お試しダウンロード (GET /compress/download/:id)
    ["compress", "download", _id] -> {
      case req.method {
        Get -> {
          // RFC 1951 gzipヘッダーを持つ最小限のバイナリを返却
          let dummy_gz = <<31, 139, 8, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
          wisp.ok()
          |> wisp.set_header("content-type", "application/gzip")
          |> wisp.set_header("content-disposition", "attachment; filename=\"sample_data.json.gz\"")
          |> wisp.set_body(wisp.Bytes(bytes_tree.from_bit_array(dummy_gz)))
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 9. Q-Deflate 実弾API: POST /api/v1/compress
    ["api", "v1", "compress"] -> {
      case req.method {
        Post -> {
          // Authorization: Bearer <key> 抽出
          case list.key_find(req.headers, "authorization") {
            Ok("Bearer " <> token) -> {
              let socket_path = "/var/run/sockets/auth.sock"
              case auth_client.verify_api_key(socket_path, token) {
                Ok(user) -> {
                  // 生バイナリの読み込み
                  use raw_bytes <- wisp.require_bit_array_body(req)
                  let raw_size = bit_array.byte_size(raw_bytes)
                  let raw_mb = int.to_float(raw_size) /. 1048576.0

                  // 残高チェック (1MB以上なら残高確認)
                  case user.balance >=. raw_mb {
                    True -> {
                      // RFC 1951 gzip 圧縮実行
                      case gzip_compress(raw_bytes) {
                        Ok(compressed_gz) -> {
                          let comp_size = bit_array.byte_size(compressed_gz)
                          let ratio_pct = case raw_size > 0 {
                            True -> {
                              let saved = raw_size - comp_size
                              { int.to_float(saved) *. 100.0 } /. int.to_float(raw_size)
                            }
                            False -> 0.0
                          }

                          // UDS経由で残高減算
                          let remaining_balance = case auth_client.deduct_balance(socket_path, token, raw_mb) {
                            Ok(updated) -> updated.balance
                            Error(_) -> user.balance -. raw_mb
                          }

                          wisp.ok()
                          |> wisp.set_header("content-type", "application/gzip")
                          |> wisp.set_header("x-qdeflate-processed-mb", float.to_string(raw_mb))
                          |> wisp.set_header("x-qdeflate-remaining-mb", float.to_string(remaining_balance))
                          |> wisp.set_header("x-qdeflate-saved-ratio", float.to_string(ratio_pct) <> "%")
                          |> wisp.set_body(wisp.Bytes(bytes_tree.from_bit_array(compressed_gz)))
                        }
                        Error(err) -> {
                          let res = json.object([
                            #("status", json.string("error")),
                            #("message", json.string("Compression failed: " <> err)),
                          ])
                          wisp.json_response(json.to_string(res), 500)
                        }
                      }
                    }
                    False -> {
                      let res = json.object([
                        #("status", json.string("error")),
                        #("error_code", json.string("insufficient_funds")),
                        #("message", json.string("Insufficient balance. Please recharge.")),
                        #("balance_mb", json.float(user.balance)),
                        #("required_mb", json.float(raw_mb)),
                      ])
                      wisp.json_response(json.to_string(res), 402)
                    }
                  }
                }
                Error(_) -> {
                  let res = json.object([
                    #("status", json.string("error")),
                    #("error_code", json.string("unauthorized")),
                    #("message", json.string("Invalid or expired API token")),
                  ])
                  wisp.json_response(json.to_string(res), 401)
                }
              }
            }
            _ -> {
              let res = json.object([
                #("status", json.string("error")),
                #("error_code", json.string("unauthorized")),
                #("message", json.string("Missing Authorization header with Bearer token")),
              ])
              wisp.json_response(json.to_string(res), 401)
            }
          }
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 9-b. Q-Deflate 残高照会API: GET /api/v1/balance
    ["api", "v1", "balance"] -> {
      case req.method {
        Get -> {
          case list.key_find(req.headers, "authorization") {
            Ok("Bearer " <> token) -> {
              let socket_path = "/var/run/sockets/auth.sock"
              case auth_client.verify_api_key(socket_path, token) {
                Ok(user) -> {
                  let res =
                    json.object([
                      #("status", json.string("ok")),
                      #("user_id", json.string(user.user_id)),
                      #("balance_mb", json.float(user.balance)),
                      #("quota_bytes", json.int(user.quota_bytes)),
                      #("rate_jpy_per_mb", json.float(0.01)),
                    ])
                  wisp.json_response(json.to_string(res), 200)
                }
                Error(_) -> {
                  let res =
                    json.object([
                      #("status", json.string("error")),
                      #("error_code", json.string("unauthorized")),
                      #("message", json.string("Invalid or expired API token")),
                    ])
                  wisp.json_response(json.to_string(res), 401)
                }
              }
            }
            _ -> {
              let res =
                json.object([
                  #("status", json.string("error")),
                  #("error_code", json.string("unauthorized")),
                  #("message", json.string("Missing Authorization header with Bearer token")),
                ])
              wisp.json_response(json.to_string(res), 401)
            }
          }
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 9-c. Q-Deflate チャージセッション発行API: POST /api/v1/checkout
    ["api", "v1", "checkout"] -> {
      case req.method {
        Post -> {
          case list.key_find(req.headers, "authorization") {
            Ok("Bearer " <> token) -> {
              let socket_path = "/var/run/sockets/auth.sock"
              case auth_client.verify_api_key(socket_path, token) {
                Ok(user) -> {
                  let plan = case wisp.get_query(req) {
                    [#("plan", p), ..] -> p
                    _ -> "starter"
                  }
                  let #(plan_name, amount_jpy, credits_mb) = case plan {
                    "standard" -> #(
                      "Q-Deflate Standard Volume (+550,000 MB)",
                      5000,
                      550000.0,
                    )
                    _ -> #(
                      "Q-Deflate Starter Prepaid (+100,000 MB)",
                      1000,
                      100000.0,
                    )
                  }

                  let secret_key = stripe.get_stripe_secret_key()
                  let host = case list.key_find(req.headers, "host") {
                    Ok(h) -> h
                    Error(_) -> "localhost:8088"
                  }
                  let proto = case list.key_find(req.headers, "x-forwarded-proto") {
                    Ok(p) -> p
                    Error(_) -> "http"
                  }
                  let base_url = proto <> "://" <> host
                  let success_url = base_url <> "/dashboard?tab=billing"
                  let cancel_url = base_url <> "/dashboard?tab=billing"

                  case
                    stripe.create_checkout_session(
                      secret_key,
                      success_url,
                      cancel_url,
                      user.user_id,
                      plan_name,
                      amount_jpy,
                      credits_mb,
                    )
                  {
                    Ok(session) -> {
                      let res =
                        json.object([
                          #("status", json.string("ok")),
                          #("checkout_url", json.string(session.url)),
                          #("session_id", json.string(session.id)),
                          #("plan", json.string(plan)),
                          #("amount_jpy", json.int(amount_jpy)),
                          #("credits_mb", json.float(credits_mb)),
                        ])
                      wisp.json_response(json.to_string(res), 200)
                    }
                    Error(err) -> {
                      let res =
                        json.object([
                          #("status", json.string("error")),
                          #("message", json.string("Failed to initialize checkout: " <> err)),
                        ])
                      wisp.json_response(json.to_string(res), 500)
                    }
                  }
                }
                Error(_) -> {
                  let res =
                    json.object([
                      #("status", json.string("error")),
                      #("error_code", json.string("unauthorized")),
                      #("message", json.string("Invalid or expired API token")),
                    ])
                  wisp.json_response(json.to_string(res), 401)
                }
              }
            }
            _ -> {
              let res =
                json.object([
                  #("status", json.string("error")),
                  #("error_code", json.string("unauthorized")),
                  #("message", json.string("Missing Authorization header with Bearer token")),
                ])
              wisp.json_response(json.to_string(res), 401)
            }
          }
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 9-d. AI API Reference Specification: GET /api/docs or /api/v1/docs
    ["api", "docs"] | ["api", "v1", "docs"] -> {
      case req.method {
        Get -> wisp.json_response(api_docs.get_api_spec_json(), 200)
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 10. Dashboard メイン画面: GET /dashboard
    ["dashboard"] -> {
      case req.method {
        Get -> {
          case resolve_dashboard_user(req) {
            Ok(user) -> {
              let tab_name = case wisp.get_query(req) {
                [#("tab", t), ..] -> t
                _ -> "overview"
              }
              let active_tab = dashboard.parse_tab(tab_name)
              let html = dashboard.render_dashboard(user, active_tab)
              wisp.ok()
              |> wisp.html_body(html)
            }
            Error(_) -> wisp.redirect(to: "/login")
          }
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 11. Dashboard タブ部分切り替え: GET /dashboard/tab/:tab
    ["dashboard", "tab", tab_name] -> {
      case req.method {
        Get -> {
          case resolve_dashboard_user(req) {
            Ok(user) -> {
              let active_tab = dashboard.parse_tab(tab_name)
              let partial_html = dashboard.render_tab_content(user, active_tab)
              wisp.ok()
              |> wisp.html_body(partial_html)
            }
            Error(_) -> {
              wisp.redirect(to: "/login")
              |> wisp.set_header("hx-redirect", "/login")
            }
          }
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 12. Dashboard API: トークン再生成 POST /dashboard/api/tokens/regenerate
    ["dashboard", "api", "tokens", "regenerate"] -> {
      case req.method {
        Post -> {
          case resolve_dashboard_user(req) {
            Ok(user) -> {
              let new_key = generate_random_key()
              let socket_path = "/var/run/sockets/auth.sock"
              let updated_user = case auth_client.regenerate_api_key(socket_path, user.user_id, new_key) {
                Ok(u) -> u
                Error(_) -> auth_client.AuthUserDetail(..user, api_key: new_key)
              }
              wisp.ok()
              |> wisp.html_body(dashboard.render_token_card(updated_user))
            }
            Error(_) -> wisp.response(401)
          }
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 12-password. Dashboard API: パスワード変更 POST /dashboard/api/password/change
    ["dashboard", "api", "password", "change"] -> {
      case req.method {
        Post -> {
          case resolve_dashboard_user(req) {
            Ok(user) -> {
              use form <- wisp.require_form(req)
              let current_pw = case list.key_find(form.values, "current_password") {
                Ok(p) -> string.trim(p)
                Error(_) -> ""
              }
              let new_pw = case list.key_find(form.values, "new_password") {
                Ok(p) -> string.trim(p)
                Error(_) -> ""
              }
              let confirm_pw = case list.key_find(form.values, "confirm_password") {
                Ok(p) -> string.trim(p)
                Error(_) -> ""
              }

              let socket_path = "/var/run/sockets/auth.sock"

              case new_pw == "" {
                True -> {
                  wisp.ok()
                  |> wisp.html_body(dashboard.render_password_error("新しいパスワードを入力してください。"))
                }
                False -> {
                  case new_pw != confirm_pw {
                    True -> {
                      wisp.ok()
                      |> wisp.html_body(
                        dashboard.render_password_error("新しいパスワードと確認用パスワードが一致しません。"),
                      )
                    }
                    False -> {
                      case auth_client.authenticate_user(socket_path, user.user_id, current_pw) {
                        Ok(_) -> {
                          case auth_client.update_password(socket_path, user.user_id, new_pw) {
                            Ok(_) -> {
                              wisp.ok()
                              |> wisp.html_body(dashboard.render_password_success())
                            }
                            Error(err) -> {
                              wisp.ok()
                              |> wisp.html_body(
                                dashboard.render_password_error("パスワード更新に失敗しました: " <> err),
                              )
                            }
                          }
                        }
                        Error(_) -> {
                          wisp.ok()
                          |> wisp.html_body(
                            dashboard.render_password_error("現在のパスワードが正しくありません。"),
                          )
                        }
                      }
                    }
                  }
                }
              }
            }
            Error(_) -> wisp.response(401)
          }
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 12-b. Dashboard API: Stripe Checkout リダイレクト GET /dashboard/api/checkout
    ["dashboard", "api", "checkout"] -> {
      case req.method {
        Get -> {
          case resolve_dashboard_user(req) {
            Ok(user) -> {
              let plan = case wisp.get_query(req) {
                [#("plan", p), ..] -> p
                _ -> "starter"
              }
              let #(plan_name, amount_jpy, credits_mb) = case plan {
                "standard" -> #(
                  "Q-Deflate Standard Volume (+550,000 MB)",
                  5000,
                  550000.0,
                )
                _ -> #(
                  "Q-Deflate Starter Prepaid (+100,000 MB)",
                  1000,
                  100000.0,
                )
              }

          let secret_key = stripe.get_stripe_secret_key()
          let host = case list.key_find(req.headers, "host") {
            Ok(h) -> h
            Error(_) -> "localhost:8088"
          }
          let proto = case list.key_find(req.headers, "x-forwarded-proto") {
            Ok(p) -> p
            Error(_) -> "http"
          }
          let base_url = proto <> "://" <> host
          let success_url = base_url <> "/dashboard?tab=billing"
          let cancel_url = base_url <> "/dashboard?tab=billing"

          case
            stripe.create_checkout_session(
              secret_key,
              success_url,
              cancel_url,
              user.user_id,
              plan_name,
              amount_jpy,
              credits_mb,
            )
          {
            Ok(session) -> {
              wisp.redirect(session.url)
            }
            Error(err) -> {
              let res =
                json.object([
                  #("status", json.string("error")),
                  #("message", json.string("Failed to initialize checkout: " <> err)),
                ])
              wisp.json_response(json.to_string(res), 500)
            }
          }
        }
            Error(_) -> wisp.redirect(to: "/login")
          }
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    // 12-c. Stripe Webhook エンドポイント: POST /api/stripe/webhook
    ["api", "stripe", "webhook"] -> {
      case req.method {
        Post -> {
          use payload_bits <- wisp.require_bit_array_body(req)
          case bit_array.to_string(payload_bits) {
            Ok(payload_str) -> {
              case stripe.parse_webhook_payload(payload_str) {
                Ok(stripe.CheckoutCompleted(user_id, credits_mb)) -> {
                  let socket_path = "/var/run/sockets/auth.sock"
                  case auth_client.add_balance(socket_path, user_id, credits_mb) {
                    Ok(updated_user) -> {
                      let res =
                        json.object([
                          #("status", json.string("ok")),
                          #("user_id", json.string(updated_user.user_id)),
                          #("credited_mb", json.float(credits_mb)),
                          #("new_balance_mb", json.float(updated_user.balance)),
                        ])
                      wisp.json_response(json.to_string(res), 200)
                    }
                    Error(err) -> {
                      let res =
                        json.object([
                          #("status", json.string("error")),
                          #("message", json.string("Failed to add balance via UDS: " <> err)),
                        ])
                      wisp.json_response(json.to_string(res), 500)
                    }
                  }
                }
                Ok(stripe.OtherEvent(event_type)) -> {
                  let res =
                    json.object([
                      #("status", json.string("ignored")),
                      #("event_type", json.string(event_type)),
                    ])
                  wisp.json_response(json.to_string(res), 200)
                }
                Error(err) -> {
                  let res =
                    json.object([
                      #("status", json.string("error")),
                      #("message", json.string(err)),
                    ])
                  wisp.json_response(json.to_string(res), 400)
                }
              }
            }
            Error(_) -> wisp.response(400)
          }
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 13. Dashboard API: プリペイドチャージ POST /dashboard/api/charge
    ["dashboard", "api", "charge"] -> {
      case req.method {
        Post -> {
          case resolve_dashboard_user(req) {
            Ok(user) -> {
              let amount = case wisp.get_query(req) {
                [#("amount", amt_str), ..] -> {
                  case float.parse(amt_str) {
                    Ok(f) -> f
                    Error(_) -> 100000.0
                  }
                }
                _ -> 100000.0
              }
              let socket_path = "/var/run/sockets/auth.sock"
              let updated_user = case auth_client.add_balance(socket_path, user.user_id, amount) {
                Ok(u) -> u
                Error(_) -> auth_client.AuthUserDetail(..user, balance: user.balance +. amount)
              }
              wisp.ok()
              |> wisp.html_body(dashboard.render_tab_content(updated_user, dashboard.Billing))
            }
            Error(_) -> wisp.response(401)
          }
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 14. Dashboard Web Compress: POST /dashboard/api/compress
    ["dashboard", "api", "compress"] -> {
      case req.method {
        Post -> {
          case resolve_dashboard_user(req) {
            Ok(user) -> {
              let filename = case wisp.get_query(req) {
                [#("filename", f), ..] -> f
                _ -> "data.bin"
              }
              use raw_bytes <- wisp.require_bit_array_body(req)
              let raw_size = bit_array.byte_size(raw_bytes)
              let raw_mb = int.to_float(raw_size) /. 1048576.0
              let socket_path = "/var/run/sockets/auth.sock"

              case user.balance >=. raw_mb {
                True -> {
                  case gzip_compress(raw_bytes) {
                    Ok(compressed_gz) -> {
                      let comp_size = bit_array.byte_size(compressed_gz)
                      let remaining_balance = case
                        auth_client.deduct_balance(socket_path, user.api_key, raw_mb)
                      {
                        Ok(updated) -> updated.balance
                        Error(_) -> user.balance -. raw_mb
                      }

                      let download_id = generate_random_key()
                      let _ = simplifile.create_directory_all("/tmp/qdf_downloads")
                      let _ =
                        simplifile.write_bits(
                          "/tmp/qdf_downloads/" <> download_id <> ".gz",
                          compressed_gz,
                        )

                      wisp.ok()
                      |> wisp.html_body(dashboard.render_compress_result(
                        filename,
                        raw_size,
                        comp_size,
                        download_id,
                        remaining_balance,
                        raw_mb,
                      ))
                    }
                    Error(err) -> {
                      wisp.response(400)
                      |> wisp.html_body("<div class=\"p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-mono font-bold\">Compression error: " <> err <> "</div>")
                    }
                  }
                }
                False -> {
                  wisp.response(402)
                  |> wisp.html_body("<div class=\"p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-mono font-bold\">Insufficient prepaid balance to compress " <> float.to_string(raw_mb) <> " MB. Please recharge.</div>")
                }
              }
            }
            Error(_) -> wisp.response(401)
          }
        }
        _ -> wisp.method_not_allowed([Post])
      }
    }

    // 14-b. ログイン画面: GET /login, POST /login
    ["login"] -> {
      let socket_path = "/var/run/sockets/auth.sock"
      case req.method {
        Get -> {
          case resolve_dashboard_user(req) {
            Ok(_) -> wisp.redirect(to: "/dashboard")
            Error(_) -> {
              wisp.ok()
              |> wisp.html_body(login.render_login_page(option.None))
            }
          }
        }
        Post -> {
          use form <- wisp.require_form(req)
          let action = case list.key_find(form.values, "action") {
            Ok(a) -> a
            Error(_) -> "signin"
          }

          case action {
            "signin" -> {
              let identifier = case list.key_find(form.values, "identifier") {
                Ok(id) -> string.trim(id)
                Error(_) -> ""
              }
              let password = case list.key_find(form.values, "password") {
                Ok(p) -> string.trim(p)
                Error(_) -> ""
              }

              // 1. パスワード付き認証（User ID + Password）
              case auth_client.authenticate_user(socket_path, identifier, password) {
                Ok(u) -> {
                  wisp.redirect(to: "/dashboard")
                  |> wisp.set_cookie(req, "qdf_session", u.user_id, wisp.Signed, 86400)
                }
                Error(_) -> {
                  // 2. APIキー直接ログイン（qdf_live_...）
                  case auth_client.verify_api_key(socket_path, identifier) {
                    Ok(u) -> {
                      wisp.redirect(to: "/dashboard")
                      |> wisp.set_cookie(req, "qdf_session", u.user_id, wisp.Signed, 86400)
                    }
                    Error(_) -> {
                      wisp.ok()
                      |> wisp.html_body(
                        login.render_login_page(option.Some(
                          "ユーザーIDまたはパスワードが正しくありません。（Invalid credentials）",
                        )),
                      )
                    }
                  }
                }
              }
            }
            "signup" -> {
              let new_user_id = case list.key_find(form.values, "new_user_id") {
                Ok(id) -> string.trim(id)
                Error(_) -> ""
              }
              let new_password = case list.key_find(form.values, "new_password") {
                Ok(p) -> string.trim(p)
                Error(_) -> ""
              }

              case new_user_id, new_password {
                "", _ -> {
                  wisp.ok()
                  |> wisp.html_body(
                    login.render_login_page(option.Some("ユーザーIDを入力してください。")),
                  )
                }
                _, "" -> {
                  wisp.ok()
                  |> wisp.html_body(
                    login.render_login_page(option.Some("パスワードを設定してください。")),
                  )
                }
                uid, pw -> {
                  let new_key = "qdf_live_" <> generate_random_key()
                  case auth_client.create_user(socket_path, uid, pw, new_key, 1000.0) {
                    Ok(u) -> {
                      wisp.redirect(to: "/dashboard")
                      |> wisp.set_cookie(req, "qdf_session", u.user_id, wisp.Signed, 86400)
                    }
                    Error(err) -> {
                      let display_err = case string.contains(err, "user_already_exists") {
                        True -> "指定されたユーザーID（" <> uid <> "）は既に使用されています。別のIDをお試しください。"
                        False -> "アカウント作成に失敗しました: " <> err
                      }
                      wisp.ok()
                      |> wisp.html_body(
                        login.render_login_page(option.Some(display_err)),
                      )
                    }
                  }
                }
              }
            }
            _ -> wisp.redirect(to: "/login")
          }
        }
        _ -> wisp.method_not_allowed([Get, Post])
      }
    }

    // 14-c. サインアウト: GET /logout, POST /logout
    ["logout"] -> {
      wisp.redirect(to: "/login")
      |> wisp.set_cookie(req, "qdf_session", "", wisp.Signed, 0)
    }

    // 15. Dashboard ダウンロード: GET /dashboard/download/:id
    ["dashboard", "download", download_id] -> {
      case req.method {
        Get -> {
          let filename = case wisp.get_query(req) {
            [#("filename", f), ..] -> f
            _ -> "data.gz"
          }
          let filepath = "/tmp/qdf_downloads/" <> download_id <> ".gz"
          case simplifile.read_bits(filepath) {
            Ok(gz_bits) -> {
              wisp.ok()
              |> wisp.set_header("content-type", "application/gzip")
              |> wisp.set_header(
                "content-disposition",
                "attachment; filename=\"" <> filename <> "\"",
              )
              |> wisp.set_body(wisp.Bytes(bytes_tree.from_bit_array(gz_bits)))
            }
            Error(_) -> wisp.not_found()
          }
        }
        _ -> wisp.method_not_allowed([Get])
      }
    }

    _ -> wisp.not_found()
  }
}

fn resolve_dashboard_user(req: Request) -> Result(auth_client.AuthUserDetail, Nil) {
  let socket_path = "/var/run/sockets/auth.sock"
  case wisp.get_cookie(req, "qdf_session", wisp.Signed) {
    Ok(uid) if uid != "" -> {
      case auth_client.get_user_by_id(socket_path, uid) {
        Ok(u) -> Ok(u)
        Error(_) -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}
