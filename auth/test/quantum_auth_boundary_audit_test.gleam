//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// 量子幾何学監査テスト：Auth境界・不変条件（Invariants）の物理実機検証
//// 1. 空パスワードハッシュに対するバイパス耐性（無条件拒絶）
//// 2. 間違ったパスワードに対する照合拒絶
//// 3. パスワード更新境界の不可逆性と新旧整合性
//// 4. 重複ユーザー作成耐性
//// 5. 存在しないユーザーに対する安全な拒絶

import auth/kvs
import auth/protocol
import auth/server
import auth/uds
import gleam/bit_array
import gleam/string

pub fn quantum_auth_boundary_invariants_test() {
  let socket_path = "/tmp/quantum_auth_boundary_audit.sock"
  uds.delete_socket_file(socket_path)

  let assert Ok(kvs_actor) = kvs.start_actor()

  // 1. テストユーザーの初期シード
  // usr_regular: パスワード "secret123"
  let hash = uds.hash_password("secret123")
  let _ = kvs.call_create_user(
    kvs_actor,
    "usr_regular",
    hash,
    "qdf_live_regular_key",
    100.0,
  )

  // usr_empty_hash: 移行データ等を想定したパスワードハッシュ空文字のユーザー
  let _ = kvs.call_create_user(
    kvs_actor,
    "usr_empty_hash",
    "",
    "qdf_live_empty_key",
    50.0,
  )

  // UDSサーバーハンドラ
  let handler = fn(req: protocol.AuthRequest) -> protocol.AuthResponse {
    case req {
      protocol.Authenticate(user_id, password) -> {
        case kvs.call_authenticate(kvs_actor, user_id, password) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Auth failed")
        }
      }
      protocol.UpdatePassword(user_id, new_password) -> {
        let new_hash = uds.hash_password(new_password)
        case kvs.call_update_password(kvs_actor, user_id, new_hash) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Update failed")
        }
      }
      protocol.CreateUser(user_id, password, api_key, balance) -> {
        let u_hash = case password {
          "" -> ""
          p -> uds.hash_password(p)
        }
        case kvs.call_create_user(kvs_actor, user_id, u_hash, api_key, balance) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Create failed")
        }
      }
      _ -> protocol.Pong
    }
  }

  let assert Ok(listener) = server.start_server(socket_path, handler)
  uds.sleep(50)

  let send_req = fn(payload: String) -> String {
    let assert Ok(c) = uds.connect(socket_path)
    let assert Ok(_) = uds.send(c, bit_array.from_string(payload <> "\n"))
    let assert Ok(resp) = uds.recv(c, 5000)
    uds.close(c)
    let assert Ok(resp_str) = bit_array.to_string(resp)
    resp_str
  }

  // --- 検証①: 空パスワードハッシュのユーザーに対するバイパス攻撃 ---
  // パスワード空文字で試行 -> 拒絶されること！
  let r1 = send_req("{\"action\":\"authenticate\",\"user_id\":\"usr_empty_hash\",\"password\":\"\"}")
  assert string.contains(r1, "invalid_password")

  // パスワード適当文字列で試行 -> 拒絶されること！
  let r2 = send_req("{\"action\":\"authenticate\",\"user_id\":\"usr_empty_hash\",\"password\":\"random_password\"}")
  assert string.contains(r2, "invalid_password")

  // --- 検証②: 通常ユーザーに対するパスワード検証 ---
  // 間違ったパスワード -> 拒絶されること！
  let r3 = send_req("{\"action\":\"authenticate\",\"user_id\":\"usr_regular\",\"password\":\"wrong_password\"}")
  assert string.contains(r3, "invalid_password")

  // 正しいパスワード -> 認証成功すること！
  let r4 = send_req("{\"action\":\"authenticate\",\"user_id\":\"usr_regular\",\"password\":\"secret123\"}")
  assert string.contains(r4, "\"status\":\"ok\"")
  assert string.contains(r4, "\"user_id\":\"usr_regular\"")

  // --- 検証③: パスワード更新と新旧整合性 ---
  // パスワードを "new_secret_456" に変更
  let r5 = send_req("{\"action\":\"update_password\",\"user_id\":\"usr_regular\",\"new_password\":\"new_secret_456\"}")
  assert string.contains(r5, "\"status\":\"ok\"")

  // 旧パスワードで照合 -> 拒絶されること！
  let r6 = send_req("{\"action\":\"authenticate\",\"user_id\":\"usr_regular\",\"password\":\"secret123\"}")
  assert string.contains(r6, "invalid_password")

  // 新パスワードで照合 -> 認証成功すること！
  let r7 = send_req("{\"action\":\"authenticate\",\"user_id\":\"usr_regular\",\"password\":\"new_secret_456\"}")
  assert string.contains(r7, "\"status\":\"ok\"")

  // --- 検証④: 存在しないユーザーに対する拒絶 ---
  let r8 = send_req("{\"action\":\"authenticate\",\"user_id\":\"usr_ghost\",\"password\":\"any\"}")
  assert string.contains(r8, "user_not_found")

  // --- 検証⑤: 重複ユーザー作成耐性 ---
  let r9 = send_req("{\"action\":\"create_user\",\"user_id\":\"usr_regular\",\"password\":\"hack\",\"api_key\":\"k2\",\"initial_balance\":10.0}")
  assert string.contains(r9, "user_already_exists")

  uds.close_listener(listener)
  uds.delete_socket_file(socket_path)
}
