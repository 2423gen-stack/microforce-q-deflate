//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// UDSソケット通信の単体テスト

import auth/uds
import gleam/bit_array

pub fn uds_ping_pong_test() {
  let socket_path = "/tmp/ai_channel_auth_test.sock"
  uds.delete_socket_file(socket_path)

  let assert Ok(listener) = uds.listen(socket_path)

  // サーバーアクターを起動
  uds.spawn(fn() {
    let assert Ok(client_socket) = uds.accept(listener)
    let assert Ok(recv_bits) = uds.recv(client_socket, 5000)
    let assert Ok(recv_str) = bit_array.to_string(recv_bits)
    assert recv_str == "{\"action\":\"ping\"}\n"

    let assert Ok(_) = uds.send(client_socket, <<"{\"status\":\"ok\"}\n":utf8>>)
    uds.close(client_socket)
  })

  // 短いスリープでサーバー立ち上がり待機
  uds.sleep(50)

  // クライアント側から接続してping送信
  let assert Ok(client) = uds.connect(socket_path)
  let assert Ok(_) = uds.send(client, <<"{\"action\":\"ping\"}\n":utf8>>)
  let assert Ok(resp_bits) = uds.recv(client, 5000)
  let assert Ok(resp_str) = bit_array.to_string(resp_bits)

  assert resp_str == "{\"status\":\"ok\"}\n"

  uds.close(client)
  uds.close_listener(listener)
  uds.delete_socket_file(socket_path)
}
