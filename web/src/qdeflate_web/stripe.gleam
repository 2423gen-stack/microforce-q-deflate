//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// Q-Deflate SaaS: Stripe Checkout Session & Webhook ハンドラー

import gleam/bit_array
import gleam/dynamic/decode
import gleam/json

@external(erlang, "bbs_gzip_ffi", "create_stripe_checkout")
fn ffi_create_stripe_checkout_with_tip(
  secret_key: String,
  success_url: String,
  cancel_url: String,
  user_id: String,
  plan_name: String,
  amount_jpy: Int,
  credits_mb: Float,
  tip_jpy: Int,
) -> Result(BitArray, String)

@external(erlang, "bbs_gzip_ffi", "get_env")
pub fn get_env(key: String) -> Result(String, Nil)

pub type CheckoutSession {
  CheckoutSession(id: String, url: String)
}

pub type WebhookEvent {
  CheckoutCompleted(user_id: String, credits_mb: Float)
  OtherEvent(event_type: String)
}

/// Stripe Secret Key を環境変数またはデフォルトフォールバックから取得する
pub fn get_stripe_secret_key() -> String {
  case get_env("STRIPE_SECRET_KEY") {
    Ok(k) -> k
    Error(_) -> ""
  }
}

/// Stripe Checkout Session を作成して決済用URLを取得する（チップ額指定可能）
pub fn create_checkout_session_with_tip(
  secret_key: String,
  success_url: String,
  cancel_url: String,
  user_id: String,
  plan_name: String,
  amount_jpy: Int,
  credits_mb: Float,
  tip_jpy: Int,
) -> Result(CheckoutSession, String) {
  let safe_tip = case tip_jpy < 0 {
    True -> 0
    False -> tip_jpy
  }
  case
    ffi_create_stripe_checkout_with_tip(
      secret_key,
      success_url,
      cancel_url,
      user_id,
      plan_name,
      amount_jpy,
      credits_mb,
      safe_tip,
    )
  {
    Ok(raw_bits) -> {
      case bit_array.to_string(raw_bits) {
        Ok(json_str) -> parse_checkout_response(json_str)
        Error(_) -> Error("Failed to decode Stripe response as UTF-8 string")
      }
    }
    Error(err) -> Error("Stripe API call error: " <> err)
  }
}

/// Stripe Checkout Session を作成して決済用URLを取得する（通常版: チップ0円）
pub fn create_checkout_session(
  secret_key: String,
  success_url: String,
  cancel_url: String,
  user_id: String,
  plan_name: String,
  amount_jpy: Int,
  credits_mb: Float,
) -> Result(CheckoutSession, String) {
  create_checkout_session_with_tip(
    secret_key,
    success_url,
    cancel_url,
    user_id,
    plan_name,
    amount_jpy,
    credits_mb,
    0,
  )
}

fn parse_checkout_response(json_str: String) -> Result(CheckoutSession, String) {
  let decoder = {
    use id <- decode.field("id", decode.string)
    use url <- decode.field("url", decode.string)
    decode.success(CheckoutSession(id:, url:))
  }

  case json.parse(json_str, decoder) {
    Ok(session) -> Ok(session)
    Error(_) -> Error("Malformed Stripe checkout session payload")
  }
}

/// Stripe Webhook JSON ペイロードをパースする
pub fn parse_webhook_payload(payload_str: String) -> Result(WebhookEvent, String) {
  let type_decoder = {
    use event_type <- decode.field("type", decode.string)
    decode.success(event_type)
  }

  case json.parse(payload_str, type_decoder) {
    Ok("checkout.session.completed") -> {
      let session_decoder = {
        use data <- decode.field("data", {
          use object <- decode.field("object", {
            use metadata <- decode.field("metadata", {
              use user_id <- decode.field("user_id", decode.string)
              use credits_mb_str <- decode.field("credits_mb", decode.string)
              decode.success(#(user_id, credits_mb_str))
            })
            decode.success(metadata)
          })
          decode.success(object)
        })
        decode.success(data)
      }

      case json.parse(payload_str, session_decoder) {
        Ok(#(user_id, credits_str)) -> {
          let credits = case credits_str {
            "100000.0" -> 100000.0
            "550000.0" -> 550000.0
            _ -> 100000.0
          }
          Ok(CheckoutCompleted(user_id:, credits_mb: credits))
        }
        Error(_) -> Error("Failed to parse checkout.session.completed metadata")
      }
    }
    Ok(other) -> Ok(OtherEvent(other))
    Error(_) -> Error("Invalid webhook JSON event")
  }
}
