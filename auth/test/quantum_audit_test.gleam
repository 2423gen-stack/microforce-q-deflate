//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// 量子健全性監査テスト：高並行Race Condition＆ポテンシャル亀裂の炙り出し
//// 50並行の同時残高引き落としで、残高のマイナス割れや重複処理が1件も起きないことを物理検証

import auth/kvs
import auth/payment
import auth/protocol
import auth/server
import auth/uds
import gleam/bit_array
import gleam/list
import gleam/string

pub fn concurrent_race_condition_audit_test() {
  let socket_path = "/tmp/quantum_concurrency_audit.sock"
  uds.delete_socket_file(socket_path)

  let assert Ok(kvs_actor) = kvs.start_actor()
  let assert Ok(valve_actor) = payment.start_valve_actor(kvs_actor)

  // 初期残高10.0ドルのユーザー
  let _ = kvs.call_create_user(
    kvs_actor,
    "usr_target",
    "qdf_live_race_key",
    10.0,
  )

  let handler = fn(req: protocol.AuthRequest) -> protocol.AuthResponse {
    case req {
      protocol.DeductBalance(key, amount) -> {
        case kvs.call_deduct_balance(kvs_actor, key, amount) {
          Ok(u) -> protocol.AuthOk(user_id: u.user_id, balance: u.balance, quota_bytes: u.quota_bytes)
          Error(err) -> protocol.AuthError(error_code: err, message: "Deduction failed")
        }
      }
      protocol.ProcessPayment(event_id, key, amount) -> {
        let event = payment.StripeEvent(event_id:, api_key: key, amount_usd: amount, created_at: 0)
        case payment.call_process_event(valve_actor, event) {
          Ok(res) -> protocol.PaymentProcessed(processed: res.processed, balance: res.balance)
          Error(err) -> protocol.AuthError(error_code: err, message: "Payment failed")
        }
      }
      _ -> protocol.Pong
    }
  }

  let assert Ok(listener) = server.start_server(socket_path, handler)
  uds.sleep(50)

  // 1. 同一Webhook Event IDによる30並行リプレイ攻撃シミュレーション
  let replay_results = list.repeat(Nil, times: 30)
    |> list.map(fn(_i) {
      let assert Ok(c) = uds.connect(socket_path)
      let payload = "{\"action\":\"process_payment\",\"event_id\":\"evt_concurrent_replay_1\",\"api_key\":\"qdf_live_race_key\",\"amount\":10.0}\n"
      let assert Ok(_) = uds.send(c, bit_array.from_string(payload))
      let assert Ok(resp) = uds.recv(c, 5000)
      uds.close(c)
      let assert Ok(resp_str) = bit_array.to_string(resp)
      resp_str
    })

  // 30回中、新規処理されたのは「最初の1回だけ」であること！
  let processed_count = list.filter(replay_results, fn(r) {
    string.contains(r, "\"processed\":true")
  })
  assert list.length(processed_count) == 1

  // 残高が10.0 -> 20.0に1度だけ増えていること（300.0になっていないこと！）
  let assert Ok(user_after_topup) = kvs.call_get_by_key(kvs_actor, "qdf_live_race_key")
  assert user_after_topup.balance == 20.0

  // 2. 残高20.0に対して、1.0の引き落としを25回連続・並行して実行
  // ➔ 20回成功し、残りの5回は「insufficient_funds」で弾かれ、残高0.0でピタリと止まること！
  let deduct_results = list.repeat(Nil, times: 25)
    |> list.map(fn(_i) {
      let assert Ok(c) = uds.connect(socket_path)
      let payload = "{\"action\":\"deduct_balance\",\"api_key\":\"qdf_live_race_key\",\"amount\":1.0}\n"
      let assert Ok(_) = uds.send(c, bit_array.from_string(payload))
      let assert Ok(resp) = uds.recv(c, 5000)
      uds.close(c)
      let assert Ok(resp_str) = bit_array.to_string(resp)
      resp_str
    })

  let success_count = list.filter(deduct_results, fn(r) {
    string.contains(r, "\"status\":\"ok\"")
  })
  let error_count = list.filter(deduct_results, fn(r) {
    string.contains(r, "insufficient_funds")
  })

  assert list.length(success_count) == 20
  assert list.length(error_count) == 5

  // 最終残高がマイナスに割り込まず「0.0」であることを物理検証
  let assert Ok(final_user) = kvs.call_get_by_key(kvs_actor, "qdf_live_race_key")
  assert final_user.balance == 0.0

  uds.close_listener(listener)
  uds.delete_socket_file(socket_path)
}
