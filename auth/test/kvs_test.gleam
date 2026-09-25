//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// Agile DB 自己申告型KVSアダプターの単体テスト（TDD Red ➔ Green）

import auth/kvs
import auth/protocol
import auth/server
import auth/uds
import gleam/bit_array
import gleam/dict

pub fn kvs_crud_test() {
  let db = kvs.new()

  // 1. ユーザー作成（自己申告型）
  let user = kvs.User(
    user_id: "usr_cecilia",
    api_key: "qdf_live_sec123",
    balance: 500.0,
    quota_bytes: 104857600,
    metadata: dict.from_list([#("role", "admin"), #("plan", "unlimited")]),
  )

  let assert Ok(db) = kvs.insert_user(db, user)

  // 2. APIキーによるO(1)直引き照会
  let assert Ok(found) = kvs.get_by_api_key(db, "qdf_live_sec123")
  assert found.user_id == "usr_cecilia"
  assert found.balance == 500.0
  assert found.quota_bytes == 104857600
  let assert Ok(role) = dict.get(found.metadata, "role")
  assert role == "admin"

  // 3. 残高減算（正常系）
  let assert Ok(#(updated_user, db)) = kvs.deduct_balance(db, "qdf_live_sec123", 50.0)
  assert updated_user.balance == 450.0

  // 4. 残高不足（エラー系）
  let assert Error("insufficient_funds") = kvs.deduct_balance(db, "qdf_live_sec123", 500.0)

  // 5. 存在しないキー照会（エラー系）
  let assert Error("invalid_key") = kvs.get_by_api_key(db, "qdf_nonexistent")
}

pub fn kvs_server_integration_test() {
  let socket_path = "/tmp/ai_channel_kvs_server_test.sock"
  uds.delete_socket_file(socket_path)

  // KVSアクターを起動
  let assert Ok(kvs_actor) = kvs.start_actor()

  // 初期ユーザーを投入
  let _ = kvs.call_create_user(
    kvs_actor,
    "usr_test",
    "qdf_live_valid_key",
    100.0,
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
      protocol.ProcessPayment(_, _, _) ->
        protocol.AuthError(error_code: "unsupported", message: "Not tested in kvs_test")
      protocol.GetUserById(user_id) -> {
        case kvs.call_get_by_id(kvs_actor, user_id) {
          Ok(u) -> protocol.UserDetail(u.user_id, u.api_key, u.balance, u.quota_bytes)
          Error(_) -> protocol.AuthError(error_code: "user_not_found", message: "User not found")
        }
      }
      protocol.RegenerateKey(user_id, new_key) -> {
        case kvs.call_regenerate_key(kvs_actor, user_id, new_key) {
          Ok(u) -> protocol.UserDetail(u.user_id, u.api_key, u.balance, u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Regenerate failed")
        }
      }
      protocol.AddBalance(user_id, amount) -> {
        case kvs.call_add_balance_by_user_id(kvs_actor, user_id, amount) {
          Ok(u) -> protocol.UserDetail(u.user_id, u.api_key, u.balance, u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Add balance failed")
        }
      }
    }
  }

  let assert Ok(listener) = server.start_server(socket_path, handler)
  uds.sleep(50)

  // 1. verify_key 照会
  let assert Ok(c1) = uds.connect(socket_path)
  let assert Ok(_) = uds.send(c1, <<"{\"action\":\"verify_key\",\"api_key\":\"qdf_live_valid_key\"}\n":utf8>>)
  let assert Ok(r1) = uds.recv(c1, 5000)
  let assert Ok(r1_str) = bit_array.to_string(r1)
  assert r1_str == "{\"status\":\"ok\",\"user_id\":\"usr_test\",\"balance\":100.0,\"quota_bytes\":104857600}\n"
  uds.close(c1)

  // 2. deduct_balance 減算
  let assert Ok(c2) = uds.connect(socket_path)
  let assert Ok(_) = uds.send(c2, <<"{\"action\":\"deduct_balance\",\"api_key\":\"qdf_live_valid_key\",\"amount\":20.0}\n":utf8>>)
  let assert Ok(r2) = uds.recv(c2, 5000)
  let assert Ok(r2_str) = bit_array.to_string(r2)
  assert r2_str == "{\"status\":\"ok\",\"user_id\":\"usr_test\",\"balance\":80.0,\"quota_bytes\":104857600}\n"
  uds.close(c2)

  // 3. create_user 新規作成
  let assert Ok(c3) = uds.connect(socket_path)
  let assert Ok(_) = uds.send(c3, <<"{\"action\":\"create_user\",\"user_id\":\"usr_new\",\"api_key\":\"qdf_new_key\",\"initial_balance\":300.0}\n":utf8>>)
  let assert Ok(r3) = uds.recv(c3, 5000)
  let assert Ok(r3_str) = bit_array.to_string(r3)
  assert r3_str == "{\"status\":\"ok\",\"user_id\":\"usr_new\",\"balance\":300.0,\"quota_bytes\":104857600}\n"
  uds.close(c3)

  uds.close_listener(listener)
  uds.delete_socket_file(socket_path)
}
