//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// 決済境界（Stripe Webhookモック＆冪等性バルブ）の単体テスト（TDD Red ➔ Green）

import auth/kvs
import auth/payment

pub fn idempotency_and_topup_test() {
  // 1. KVSアクターと決済バルブを起動
  let assert Ok(kvs_actor) = kvs.start_actor()
  let assert Ok(valve_actor) = payment.start_valve_actor(kvs_actor)

  // ユーザー登録
  let _ = kvs.call_create_user(
    kvs_actor,
    "usr_customer",
    "",
    "qdf_live_customer_key",
    10.0,
  )

  // 2. 正常なチャージイベント
  let event1 = payment.StripeEvent(
    event_id: "evt_stripe_12345",
    api_key: "qdf_live_customer_key",
    amount_usd: 10.0,
    created_at: 1726750000,
  )

  let assert Ok(res1) = payment.call_process_event(valve_actor, event1)
  assert res1.processed == True
  assert res1.balance == 20.0

  // 3. リプレイ攻撃／重複Webhook（同一event_idで再度飛んできた場合）
  // ➔ 冪等性（Idempotency）により、二重チャージされずに前回結果が返ること！
  let assert Ok(res2) = payment.call_process_event(valve_actor, event1)
  assert res2.processed == False
  assert res2.balance == 20.0

  // 4. 残高が二重引き落とし／加算されていないことをKVS本体で確認
  let assert Ok(user) = kvs.call_get_by_key(kvs_actor, "qdf_live_customer_key")
  assert user.balance == 20.0

  // 5. 無効なAPIキーへのWebhook（境界バリデーション）
  let bad_event = payment.StripeEvent(
    event_id: "evt_stripe_99999",
    api_key: "qdf_nonexistent_key",
    amount_usd: 10.0,
    created_at: 1726750000,
  )
  let assert Error("user_not_found") = payment.call_process_event(valve_actor, bad_event)

  // 6. 不正な金額（マイナスチャージや0円）の完全遮断
  let negative_event = payment.StripeEvent(
    event_id: "evt_stripe_hack",
    api_key: "qdf_live_customer_key",
    amount_usd: -50.0,
    created_at: 1726750000,
  )
  let assert Error("invalid_amount") = payment.call_process_event(valve_actor, negative_event)
}
