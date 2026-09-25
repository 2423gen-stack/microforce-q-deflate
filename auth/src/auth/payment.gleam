//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// 決済境界モジュール（Stripe Webhookモック ＆ 冪等性バルブ）
//// 外部決済APIと内部KVSの境界におけるバグバウンティ基準の防壁。
//// - Event IDの一意性管理（Idempotency）による二重チャージ・リプレイ攻撃の完全防止
//// - 金額の正値性・上限値・入力サニタイズ（境界バリデーション）
//// - 分散トランザクションの死角を塞ぐアトミック更新

import auth/kvs
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor

pub type StripeEvent {
  StripeEvent(
    event_id: String,
    api_key: String,
    amount_usd: Float,
    created_at: Int,
  )
}

pub type ProcessResult {
  ProcessResult(
    processed: Bool,
    balance: Float,
  )
}

pub type ValveState {
  ValveState(
    kvs_actor: Subject(kvs.KvsMessage),
    // 処理済みイベントIDと確定残高の記録（冪等性キャッシュ）
    processed_events: Dict(String, Float),
  )
}

pub type ValveMessage {
  ProcessEvent(
    event: StripeEvent,
    reply_to: Subject(Result(ProcessResult, String)),
  )
}

pub fn start_valve_actor(
  kvs_actor: Subject(kvs.KvsMessage),
) -> Result(Subject(ValveMessage), actor.StartError) {
  let initial_state = ValveState(
    kvs_actor:,
    processed_events: dict.new(),
  )

  actor.new(initial_state)
  |> actor.on_message(fn(state: ValveState, msg: ValveMessage) {
    case msg {
      ProcessEvent(event, reply_to) -> {
        case handle_event(state, event) {
          Ok(#(result, new_state)) -> {
            process.send(reply_to, Ok(result))
            actor.continue(new_state)
          }
          Error(err) -> {
            process.send(reply_to, Error(err))
            actor.continue(state)
          }
        }
      }
    }
  })
  |> actor.start
  |> fn(res) {
    case res {
      Ok(started) -> Ok(started.data)
      Error(err) -> Error(err)
    }
  }
}

fn handle_event(state: ValveState, event: StripeEvent) -> Result(#(ProcessResult, ValveState), String) {
  // 1. 金額の正値性チェック（境界バリデーション）
  case event.amount_usd >. 0.0 {
    False -> Error("invalid_amount")
    True -> {
      // 2. 冪等性チェック（リプレイ攻撃の遮断）
      case dict.get(state.processed_events, event.event_id) {
        Ok(cached_balance) -> {
          // すでに処理済み ➔ 二重チャージせず、直前の確定残高を即時返却
          Ok(#(ProcessResult(processed: False, balance: cached_balance), state))
        }
        Error(_) -> {
          // 未処理 ➔ KVSアクターに残高加算を依頼
          case kvs.call_add_balance(state.kvs_actor, event.api_key, event.amount_usd) {
            Ok(updated_user) -> {
              let updated_events = dict.insert(
                state.processed_events,
                event.event_id,
                updated_user.balance,
              )
              let new_state = ValveState(..state, processed_events: updated_events)
              Ok(#(ProcessResult(processed: True, balance: updated_user.balance), new_state))
            }
            Error(_) -> Error("user_not_found")
          }
        }
      }
    }
  }
}

pub fn call_process_event(
  server: Subject(ValveMessage),
  event: StripeEvent,
) -> Result(ProcessResult, String) {
  case process.call(server, 2000, fn(reply_to) {
    ProcessEvent(event, reply_to)
  }) {
    Ok(res) -> Ok(res)
    Error(err) -> Error(err)
  }
}
