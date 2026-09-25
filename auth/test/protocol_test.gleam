//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// プロトコルデコード／エンコードの単体テスト

import auth/protocol

pub fn ping_encode_decode_test() {
  let assert Ok(protocol.Ping) = protocol.decode_request("{\"action\":\"ping\"}")
  let encoded = protocol.encode_response(protocol.Pong)
  assert encoded == "{\"status\":\"ok\",\"message\":\"pong\"}\n"
}

pub fn verify_key_decode_test() {
  let json_str = "{\"action\":\"verify_key\",\"api_key\":\"qdf_live_secret123\"}"
  let assert Ok(protocol.VerifyKey("qdf_live_secret123")) = protocol.decode_request(json_str)
}

pub fn auth_ok_encode_test() {
  let resp = protocol.AuthOk(user_id: "usr_cecilia", balance: 100.0, quota_bytes: 104857600)
  let encoded = protocol.encode_response(resp)
  assert encoded == "{\"status\":\"ok\",\"user_id\":\"usr_cecilia\",\"balance\":100.0,\"quota_bytes\":104857600}\n"
}

pub fn auth_error_encode_test() {
  let resp = protocol.AuthError(error_code: "insufficient_funds", message: "残高が不足しています")
  let encoded = protocol.encode_response(resp)
  assert encoded == "{\"status\":\"error\",\"error_code\":\"insufficient_funds\",\"message\":\"残高が不足しています\"}\n"
}
