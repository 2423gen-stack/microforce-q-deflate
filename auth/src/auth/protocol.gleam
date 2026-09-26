//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// UDS プロトコル定義（JSON Lines over UDS）
//// AUTH_SPEC.md 第4章に基づくリクエスト／レスポンスのエンコード・デコード

import gleam/dynamic/decode
import gleam/json

pub type AuthRequest {
  VerifyKey(api_key: String)
  DeductBalance(api_key: String, amount: Float)
  CreateUser(user_id: String, password: String, api_key: String, initial_balance: Float)
  Authenticate(user_id: String, password: String)
  UpdatePassword(user_id: String, new_password: String)
  GetUser(api_key: String)
  GetUserById(user_id: String)
  RegenerateKey(user_id: String, new_key: String)
  AddBalance(user_id: String, amount: Float)
  ProcessPayment(event_id: String, api_key: String, amount: Float)
  Ping
}

pub type AuthResponse {
  AuthOk(user_id: String, balance: Float, quota_bytes: Int)
  UserDetail(user_id: String, api_key: String, balance: Float, quota_bytes: Int)
  PaymentProcessed(processed: Bool, balance: Float)
  Pong
  AuthError(error_code: String, message: String)
}

/// JSON文字列をリクエスト型へデコード
pub fn decode_request(json_string: String) -> Result(AuthRequest, String) {
  let action_decoder = {
    use action <- decode.field("action", decode.string)
    decode.success(action)
  }

  case json.parse(json_string, action_decoder) {
    Ok("ping") -> Ok(Ping)
    Ok("verify_key") -> {
      let decoder = {
        use key <- decode.field("api_key", decode.string)
        decode.success(VerifyKey(api_key: key))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Missing or invalid api_key")
      }
    }
    Ok("get_user") -> {
      let decoder = {
        use key <- decode.field("api_key", decode.string)
        decode.success(GetUser(api_key: key))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Missing or invalid api_key")
      }
    }
    Ok("get_user_by_id") -> {
      let decoder = {
        use user_id <- decode.field("user_id", decode.string)
        decode.success(GetUserById(user_id: user_id))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Missing or invalid user_id")
      }
    }
    Ok("regenerate_key") -> {
      let decoder = {
        use user_id <- decode.field("user_id", decode.string)
        use new_key <- decode.field("new_key", decode.string)
        decode.success(RegenerateKey(user_id: user_id, new_key: new_key))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Invalid regenerate_key params")
      }
    }
    Ok("update_password") -> {
      let decoder = {
        use user_id <- decode.field("user_id", decode.string)
        use new_password <- decode.field("new_password", decode.string)
        decode.success(UpdatePassword(user_id: user_id, new_password: new_password))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Invalid update_password params")
      }
    }
    Ok("add_balance") -> {
      let decoder = {
        use user_id <- decode.field("user_id", decode.string)
        use amount <- decode.field("amount", decode.float)
        decode.success(AddBalance(user_id: user_id, amount: amount))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Invalid add_balance params")
      }
    }
    Ok("deduct_balance") -> {
      let decoder = {
        use key <- decode.field("api_key", decode.string)
        use amount <- decode.field("amount", decode.float)
        decode.success(DeductBalance(api_key: key, amount: amount))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Invalid deduct_balance params")
      }
    }
    Ok("create_user") -> {
      let decoder = {
        use user_id <- decode.field("user_id", decode.string)
        use password <- decode.optional_field(
          "password",
          "",
          decode.string,
        )
        use api_key <- decode.field("api_key", decode.string)
        use balance <- decode.field("initial_balance", decode.float)
        decode.success(CreateUser(user_id:, password:, api_key:, initial_balance: balance))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Invalid create_user params")
      }
    }
    Ok("authenticate") -> {
      let decoder = {
        use user_id <- decode.field("user_id", decode.string)
        use password <- decode.field("password", decode.string)
        decode.success(Authenticate(user_id:, password:))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Invalid authenticate params")
      }
    }
    Ok("process_payment") -> {
      let decoder = {
        use event_id <- decode.field("event_id", decode.string)
        use api_key <- decode.field("api_key", decode.string)
        use amount <- decode.field("amount", decode.float)
        decode.success(ProcessPayment(event_id:, api_key:, amount:))
      }
      case json.parse(json_string, decoder) {
        Ok(req) -> Ok(req)
        Error(_) -> Error("Invalid process_payment params")
      }
    }
    Ok(unknown) -> Error("Unknown action: " <> unknown)
    Error(_) -> Error("Malformed JSON request")
  }
}

/// レスポンス型をJSON文字列へエンコード（末尾に改行付与）
pub fn encode_response(response: AuthResponse) -> String {
  case response {
    Pong -> {
      json.object([
        #("status", json.string("ok")),
        #("message", json.string("pong")),
      ])
      |> json.to_string
      <> "\n"
    }
    PaymentProcessed(processed, balance) -> {
      json.object([
        #("status", json.string("ok")),
        #("processed", json.bool(processed)),
        #("balance", json.float(balance)),
      ])
      |> json.to_string
      <> "\n"
    }
    AuthOk(user_id, balance, quota_bytes) -> {
      json.object([
        #("status", json.string("ok")),
        #("user_id", json.string(user_id)),
        #("balance", json.float(balance)),
        #("quota_bytes", json.int(quota_bytes)),
      ])
      |> json.to_string
      <> "\n"
    }
    UserDetail(user_id, api_key, balance, quota_bytes) -> {
      json.object([
        #("status", json.string("ok")),
        #("user_id", json.string(user_id)),
        #("api_key", json.string(api_key)),
        #("balance", json.float(balance)),
        #("quota_bytes", json.int(quota_bytes)),
      ])
      |> json.to_string
      <> "\n"
    }
    AuthError(error_code, message) -> {
      json.object([
        #("status", json.string("error")),
        #("error_code", json.string(error_code)),
        #("message", json.string(message)),
      ])
      |> json.to_string
      <> "\n"
    }
  }
}
