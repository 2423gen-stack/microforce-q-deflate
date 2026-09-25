//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// BBS本体からauthコンテナへUDS経由で問い合わせるクライアントモジュール
//// /var/run/sockets/auth.sock を介した超高速 O(1) 認証判定

import gleam/bit_array
import gleam/dynamic/decode
import gleam/json

pub type AuthUser {
  AuthUser(
    user_id: String,
    balance: Float,
    quota_bytes: Int,
  )
}

pub type AuthUserDetail {
  AuthUserDetail(
    user_id: String,
    api_key: String,
    balance: Float,
    quota_bytes: Int,
  )
}

pub type Socket

@external(erlang, "bbs_uds_ffi", "connect_uds")
fn connect_uds(path: String) -> Result(Socket, String)

@external(erlang, "bbs_uds_ffi", "send_uds")
fn send_uds(socket: Socket, data: BitArray) -> Result(Nil, String)

@external(erlang, "bbs_uds_ffi", "recv_uds")
fn recv_uds(socket: Socket, timeout_ms: Int) -> Result(BitArray, String)

@external(erlang, "bbs_uds_ffi", "close_uds")
fn close_uds(socket: Socket) -> Nil

/// UDS経由でAPIキーを検証する
pub fn verify_api_key(socket_path: String, api_key: String) -> Result(AuthUser, String) {
  case connect_uds(socket_path) {
    Ok(sock) -> {
      let payload =
        json.object([
          #("action", json.string("verify_key")),
          #("api_key", json.string(api_key)),
        ])
        |> json.to_string
        <> "\n"

      let _ = send_uds(sock, bit_array.from_string(payload))
      let res = case recv_uds(sock, 3000) {
        Ok(resp_bits) -> {
          case bit_array.to_string(resp_bits) {
            Ok(resp_str) -> parse_auth_response(resp_str)
            Error(_) -> Error("Encoding error")
          }
        }
        Error(err) -> Error("UDS recv error: " <> err)
      }
      close_uds(sock)
      res
    }
    Error(err) -> Error("UDS connect error: " <> err)
  }
}

/// UDS経由で残高を減算する (amount: 処理MB数またはドル額)
pub fn deduct_balance(socket_path: String, api_key: String, amount: Float) -> Result(AuthUser, String) {
  case connect_uds(socket_path) {
    Ok(sock) -> {
      let payload =
        json.object([
          #("action", json.string("deduct_balance")),
          #("api_key", json.string(api_key)),
          #("amount", json.float(amount)),
        ])
        |> json.to_string
        <> "\n"

      let _ = send_uds(sock, bit_array.from_string(payload))
      let res = case recv_uds(sock, 3000) {
        Ok(resp_bits) -> {
          case bit_array.to_string(resp_bits) {
            Ok(resp_str) -> parse_auth_response(resp_str)
            Error(_) -> Error("Encoding error")
          }
        }
        Error(err) -> Error("UDS recv error: " <> err)
      }
      close_uds(sock)
      res
    }
    Error(err) -> Error("UDS connect error: " <> err)
  }
}

fn parse_auth_response(json_string: String) -> Result(AuthUser, String) {
  let status_decoder = {
    use status <- decode.field("status", decode.string)
    decode.success(status)
  }

  case json.parse(json_string, status_decoder) {
    Ok("ok") -> {
      let user_decoder = {
        use user_id <- decode.field("user_id", decode.string)
        use balance <- decode.field("balance", decode.float)
        use quota_bytes <- decode.field("quota_bytes", decode.int)
        decode.success(AuthUser(user_id:, balance:, quota_bytes:))
      }
      case json.parse(json_string, user_decoder) {
        Ok(user) -> Ok(user)
        Error(_) -> Error("Malformed user payload")
      }
    }
    Ok("error") -> {
      let err_decoder = {
        use msg <- decode.field("message", decode.string)
        decode.success(msg)
      }
      case json.parse(json_string, err_decoder) {
        Ok(msg) -> Error(msg)
        Error(_) -> Error("Authentication failed")
      }
    }
    _ -> Error("Unknown response status")
  }
}

/// UDS経由でユーザーIDから詳細情報を取得する
pub fn get_user_by_id(socket_path: String, user_id: String) -> Result(AuthUserDetail, String) {
  case connect_uds(socket_path) {
    Ok(sock) -> {
      let payload =
        json.object([
          #("action", json.string("get_user_by_id")),
          #("user_id", json.string(user_id)),
        ])
        |> json.to_string
        <> "\n"

      let _ = send_uds(sock, bit_array.from_string(payload))
      let res = case recv_uds(sock, 3000) {
        Ok(resp_bits) -> {
          case bit_array.to_string(resp_bits) {
            Ok(resp_str) -> parse_user_detail(resp_str)
            Error(_) -> Error("Encoding error")
          }
        }
        Error(err) -> Error("UDS recv error: " <> err)
      }
      close_uds(sock)
      res
    }
    Error(err) -> Error("UDS connect error: " <> err)
  }
}

/// UDS経由でAPIキーを再生成する
pub fn regenerate_api_key(
  socket_path: String,
  user_id: String,
  new_key: String,
) -> Result(AuthUserDetail, String) {
  case connect_uds(socket_path) {
    Ok(sock) -> {
      let payload =
        json.object([
          #("action", json.string("regenerate_key")),
          #("user_id", json.string(user_id)),
          #("new_key", json.string(new_key)),
        ])
        |> json.to_string
        <> "\n"

      let _ = send_uds(sock, bit_array.from_string(payload))
      let res = case recv_uds(sock, 3000) {
        Ok(resp_bits) -> {
          case bit_array.to_string(resp_bits) {
            Ok(resp_str) -> parse_user_detail(resp_str)
            Error(_) -> Error("Encoding error")
          }
        }
        Error(err) -> Error("UDS recv error: " <> err)
      }
      close_uds(sock)
      res
    }
    Error(err) -> Error("UDS connect error: " <> err)
  }
}

/// UDS経由で残高を加算する (amount: 加算MB数)
pub fn add_balance(
  socket_path: String,
  user_id: String,
  amount: Float,
) -> Result(AuthUserDetail, String) {
  case connect_uds(socket_path) {
    Ok(sock) -> {
      let payload =
        json.object([
          #("action", json.string("add_balance")),
          #("user_id", json.string(user_id)),
          #("amount", json.float(amount)),
        ])
        |> json.to_string
        <> "\n"

      let _ = send_uds(sock, bit_array.from_string(payload))
      let res = case recv_uds(sock, 3000) {
        Ok(resp_bits) -> {
          case bit_array.to_string(resp_bits) {
            Ok(resp_str) -> parse_user_detail(resp_str)
            Error(_) -> Error("Encoding error")
          }
        }
        Error(err) -> Error("UDS recv error: " <> err)
      }
      close_uds(sock)
      res
    }
    Error(err) -> Error("UDS connect error: " <> err)
  }
}

/// UDS経由で新規ユーザーを作成する
pub fn create_user(
  socket_path: String,
  user_id: String,
  api_key: String,
  initial_balance: Float,
) -> Result(AuthUser, String) {
  case connect_uds(socket_path) {
    Ok(sock) -> {
      let payload =
        json.object([
          #("action", json.string("create_user")),
          #("user_id", json.string(user_id)),
          #("api_key", json.string(api_key)),
          #("initial_balance", json.float(initial_balance)),
        ])
        |> json.to_string
        <> "\n"

      let _ = send_uds(sock, bit_array.from_string(payload))
      let res = case recv_uds(sock, 3000) {
        Ok(resp_bits) -> {
          case bit_array.to_string(resp_bits) {
            Ok(resp_str) -> parse_auth_response(resp_str)
            Error(_) -> Error("Encoding error")
          }
        }
        Error(err) -> Error("UDS recv error: " <> err)
      }
      close_uds(sock)
      res
    }
    Error(err) -> Error("UDS connect error: " <> err)
  }
}

fn parse_user_detail(json_string: String) -> Result(AuthUserDetail, String) {
  let status_decoder = {
    use status <- decode.field("status", decode.string)
    decode.success(status)
  }

  case json.parse(json_string, status_decoder) {
    Ok("ok") -> {
      let user_decoder = {
        use user_id <- decode.field("user_id", decode.string)
        use api_key <- decode.field("api_key", decode.string)
        use balance <- decode.field("balance", decode.float)
        use quota_bytes <- decode.field("quota_bytes", decode.int)
        decode.success(AuthUserDetail(user_id:, api_key:, balance:, quota_bytes:))
      }
      case json.parse(json_string, user_decoder) {
        Ok(detail) -> Ok(detail)
        Error(_) -> Error("Malformed user detail payload")
      }
    }
    Ok("error") -> {
      let err_decoder = {
        use msg <- decode.field("message", decode.string)
        decode.success(msg)
      }
      case json.parse(json_string, err_decoder) {
        Ok(msg) -> Error(msg)
        Error(_) -> Error("Operation failed")
      }
    }
    _ -> Error("Unknown response status")
  }
}
