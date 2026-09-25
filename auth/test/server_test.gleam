//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// UDS サーバーE2E単体テスト

import auth/protocol
import auth/server
import auth/uds
import gleam/bit_array

pub fn server_e2e_ping_test() {
  let socket_path = "/tmp/ai_channel_server_e2e.sock"
  uds.delete_socket_file(socket_path)

  let handler = fn(req: protocol.AuthRequest) -> protocol.AuthResponse {
    case req {
      protocol.Ping -> protocol.Pong
      protocol.VerifyKey(key) -> {
        case key == "qdf_test_valid" {
          True -> protocol.AuthOk(user_id: "usr_001", balance: 50.0, quota_bytes: 1048576)
          False -> protocol.AuthError(error_code: "invalid_key", message: "APIキーが無効です")
        }
      }
      _ -> protocol.AuthError(error_code: "unimplemented", message: "未実装のアクション")
    }
  }

  let assert Ok(listener) = server.start_server(socket_path, handler)
  uds.sleep(50)

  // 1. Pingテスト
  let assert Ok(client1) = uds.connect(socket_path)
  let assert Ok(_) = uds.send(client1, <<"{\"action\":\"ping\"}\n":utf8>>)
  let assert Ok(resp1) = uds.recv(client1, 5000)
  let assert Ok(resp1_str) = bit_array.to_string(resp1)
  assert resp1_str == "{\"status\":\"ok\",\"message\":\"pong\"}\n"
  uds.close(client1)

  // 2. 有効キーテスト
  let assert Ok(client2) = uds.connect(socket_path)
  let assert Ok(_) = uds.send(client2, <<"{\"action\":\"verify_key\",\"api_key\":\"qdf_test_valid\"}\n":utf8>>)
  let assert Ok(resp2) = uds.recv(client2, 5000)
  let assert Ok(resp2_str) = bit_array.to_string(resp2)
  assert resp2_str == "{\"status\":\"ok\",\"user_id\":\"usr_001\",\"balance\":50.0,\"quota_bytes\":1048576}\n"
  uds.close(client2)

  // 3. 無効キーテスト
  let assert Ok(client3) = uds.connect(socket_path)
  let assert Ok(_) = uds.send(client3, <<"{\"action\":\"verify_key\",\"api_key\":\"qdf_test_fake\"}\n":utf8>>)
  let assert Ok(resp3) = uds.recv(client3, 5000)
  let assert Ok(resp3_str) = bit_array.to_string(resp3)
  assert resp3_str == "{\"status\":\"error\",\"error_code\":\"invalid_key\",\"message\":\"APIキーが無効です\"}\n"
  uds.close(client3)

  uds.close_listener(listener)
  uds.delete_socket_file(socket_path)
}
