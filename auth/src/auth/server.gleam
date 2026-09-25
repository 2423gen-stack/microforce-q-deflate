//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// UDS サーバーメインループ
//// 外部ポートゼロでUDSソケットをリッスンし、各接続に対して非同期にプロトコルを処理

import auth/protocol
import auth/uds
import gleam/bit_array
import gleam/string

pub type Handler =
  fn(protocol.AuthRequest) -> protocol.AuthResponse

/// UDSサーバーをバックグラウンドプロセスとして起動
pub fn start_server(socket_path: String, handler: Handler) -> Result(uds.ListenSocket, String) {
  case uds.listen(socket_path) {
    Ok(listener) -> {
      uds.spawn(fn() {
        accept_loop(listener, handler)
      })
      Ok(listener)
    }
    Error(err) -> Error(err)
  }
}

fn accept_loop(listener: uds.ListenSocket, handler: Handler) -> Nil {
  case uds.accept(listener) {
    Ok(client) -> {
      // 接続ごとに軽量アクター/プロセスで並列処理
      uds.spawn(fn() {
        handle_connection(client, handler)
      })
      accept_loop(listener, handler)
    }
    Error(_) -> {
      // リスナー終了
      Nil
    }
  }
}

fn handle_connection(client: uds.Socket, handler: Handler) -> Nil {
  case uds.recv(client, 5000) {
    Ok(raw_bits) -> {
      case bit_array.to_string(raw_bits) {
        Ok(raw_str) -> {
          let trimmed = string.trim_end(raw_str)
          let resp = case protocol.decode_request(trimmed) {
            Ok(req) -> handler(req)
            Error(err) -> protocol.AuthError(error_code: "malformed_request", message: err)
          }
          let encoded = protocol.encode_response(resp)
          case bit_array.from_string(encoded) {
            resp_bits -> {
              let _ = uds.send(client, resp_bits)
              uds.close(client)
            }
          }
        }
        Error(_) -> {
          let encoded = protocol.encode_response(protocol.AuthError(
            error_code: "encoding_error",
            message: "UTF-8 decode failed",
          ))
          let _ = uds.send(client, bit_array.from_string(encoded))
          uds.close(client)
        }
      }
    }
    Error(_) -> {
      uds.close(client)
    }
  }
}
