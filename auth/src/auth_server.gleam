//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// auth_server エントリポイント
//// 外部ポート0・UDS完全密室でリッスンを開始する

import auth/kvs
import auth/payment
import auth/protocol
import auth/server
import auth/uds
import gleam/io

const default_socket_path = "/var/run/sockets/auth.sock"

pub fn main() -> Nil {
  let socket_path = uds.get_env("AUTH_SOCKET_PATH", default_socket_path)
  io.println("=== Starting ai-channel auth_server (UDS Fortress) ===")
  io.println("Listening on UDS socket: " <> socket_path)
  io.println("External TCP Ports: 0 (Strictly isolated)")

  let assert Ok(kvs_actor) = kvs.start_actor()
  let assert Ok(valve_actor) = payment.start_valve_actor(kvs_actor)

  // 看板娘セシリアのマスターアカウントを初期投入
  let _ = kvs.call_create_user(
    kvs_actor,
    "usr_cecilia",
    "qdf_live_cecilia_master",
    1000.0,
  )

  let handler = fn(req: protocol.AuthRequest) -> protocol.AuthResponse {
    case req {
      protocol.Ping -> protocol.Pong
      protocol.VerifyKey(key) -> {
        case kvs.call_get_by_key(kvs_actor, key) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(_) -> protocol.AuthError(error_code: "invalid_key", message: "API key is invalid")
        }
      }
      protocol.GetUser(key) -> {
        case kvs.call_get_by_key(kvs_actor, key) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(_) -> protocol.AuthError(error_code: "invalid_key", message: "API key is invalid")
        }
      }
      protocol.GetUserById(user_id) -> {
        case kvs.call_get_by_id(kvs_actor, user_id) {
          Ok(u) ->
            protocol.UserDetail(
              user_id: u.user_id,
              api_key: u.api_key,
              balance: u.balance,
              quota_bytes: u.quota_bytes,
            )
          Error(_) -> protocol.AuthError(error_code: "user_not_found", message: "User not found")
        }
      }
      protocol.RegenerateKey(user_id, new_key) -> {
        case kvs.call_regenerate_key(kvs_actor, user_id, new_key) {
          Ok(u) ->
            protocol.UserDetail(
              user_id: u.user_id,
              api_key: u.api_key,
              balance: u.balance,
              quota_bytes: u.quota_bytes,
            )
          Error(err) -> protocol.AuthError(error_code: err, message: "Regenerate key failed")
        }
      }
      protocol.AddBalance(user_id, amount) -> {
        case kvs.call_add_balance_by_user_id(kvs_actor, user_id, amount) {
          Ok(u) ->
            protocol.UserDetail(
              user_id: u.user_id,
              api_key: u.api_key,
              balance: u.balance,
              quota_bytes: u.quota_bytes,
            )
          Error(err) -> protocol.AuthError(error_code: err, message: "Add balance failed")
        }
      }
      protocol.DeductBalance(key, amount) -> {
        case kvs.call_deduct_balance(kvs_actor, key, amount) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Deduction failed")
        }
      }
      protocol.CreateUser(user_id, api_key, initial_balance) -> {
        case kvs.call_create_user(kvs_actor, user_id, api_key, initial_balance) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Create user failed")
        }
      }
      protocol.ProcessPayment(event_id, api_key, amount) -> {
        let event = payment.StripeEvent(
          event_id:,
          api_key:,
          amount_usd: amount,
          created_at: 0,
        )
        case payment.call_process_event(valve_actor, event) {
          Ok(res) -> protocol.PaymentProcessed(processed: res.processed, balance: res.balance)
          Error(err) -> protocol.AuthError(error_code: err, message: "Payment processing failed")
        }
      }
    }
  }

  case server.start_server(socket_path, handler) {
    Ok(_) -> {
      io.println("UDS Fortress initialized successfully. Entering infinite sleep.")
      // メインプロセスを維持
      keep_alive()
    }
    Error(err) -> {
      io.println("Failed to bind UDS socket: " <> err)
    }
  }
}

fn keep_alive() -> Nil {
  uds.sleep(60000)
  keep_alive()
}
