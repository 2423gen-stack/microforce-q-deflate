//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// Agile DB 自己申告型KVSアダプター（インメモリ・高速バッファ）
//// スキーマレス・マイグレーション不要で、任意のメタデータ属性を受容する。
//// 読み取り直引き O(1) ＆ アクター内蔵キューによる直列アトミック更新

import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor

pub type User {
  User(
    user_id: String,
    api_key: String,
    balance: Float,
    quota_bytes: Int,
    metadata: Dict(String, String),
  )
}

pub type Database {
  Database(
    by_api_key: Dict(String, User),
    by_user_id: Dict(String, User),
  )
}

pub fn new() -> Database {
  Database(
    by_api_key: dict.new(),
    by_user_id: dict.new(),
  )
}

/// ユーザーの登録（自己申告型）
pub fn insert_user(db: Database, user: User) -> Result(Database, String) {
  let by_api_key = dict.insert(db.by_api_key, user.api_key, user)
  let by_user_id = dict.insert(db.by_user_id, user.user_id, user)
  Ok(Database(by_api_key:, by_user_id:))
}

/// APIキーによるO(1)直引き照会
pub fn get_by_api_key(db: Database, api_key: String) -> Result(User, String) {
  case dict.get(db.by_api_key, api_key) {
    Ok(user) -> Ok(user)
    Error(_) -> Error("invalid_key")
  }
}

/// ユーザーIDによる照会
pub fn get_by_user_id(db: Database, user_id: String) -> Result(User, String) {
  case dict.get(db.by_user_id, user_id) {
    Ok(user) -> Ok(user)
    Error(_) -> Error("user_not_found")
  }
}

/// 残高の減算（アトミック判定）
pub fn deduct_balance(
  db: Database,
  api_key: String,
  amount: Float,
) -> Result(#(User, Database), String) {
  case get_by_api_key(db, api_key) {
    Ok(user) -> {
      case user.balance >=. amount {
        True -> {
          let updated = User(..user, balance: user.balance -. amount)
          let assert Ok(updated_db) = insert_user(db, updated)
          Ok(#(updated, updated_db))
        }
        False -> Error("insufficient_funds")
      }
    }
    Error(err) -> Error(err)
  }
}

/// 残高の加算（チャージ）
pub fn add_balance(
  db: Database,
  api_key: String,
  amount: Float,
) -> Result(#(User, Database), String) {
  case get_by_api_key(db, api_key) {
    Ok(user) -> {
      let updated = User(..user, balance: user.balance +. amount)
      let assert Ok(updated_db) = insert_user(db, updated)
      Ok(#(updated, updated_db))
    }
    Error(err) -> Error(err)
  }
}

pub fn regenerate_key(
  db: Database,
  user_id: String,
  new_key: String,
) -> Result(#(User, Database), String) {
  case get_by_user_id(db, user_id) {
    Ok(user) -> {
      let old_key = user.api_key
      let updated = User(..user, api_key: new_key)
      let by_api_key =
        db.by_api_key
        |> dict.delete(old_key)
        |> dict.insert(new_key, updated)
      let by_user_id = dict.insert(db.by_user_id, user_id, updated)
      Ok(#(updated, Database(by_api_key:, by_user_id:)))
    }
    Error(err) -> Error(err)
  }
}

pub fn add_balance_by_user_id(
  db: Database,
  user_id: String,
  amount: Float,
) -> Result(#(User, Database), String) {
  case get_by_user_id(db, user_id) {
    Ok(user) -> {
      let updated = User(..user, balance: user.balance +. amount)
      let assert Ok(updated_db) = insert_user(db, updated)
      Ok(#(updated, updated_db))
    }
    Error(err) -> Error(err)
  }
}

// -------------------------------------------------------------
// OTP Actor による並行アトミック管理（電話交換機DNA）
// -------------------------------------------------------------

pub type KvsMessage {
  GetByKey(api_key: String, reply_to: Subject(Result(User, String)))
  GetById(user_id: String, reply_to: Subject(Result(User, String)))
  Deduct(api_key: String, amount: Float, reply_to: Subject(Result(User, String)))
  Add(api_key: String, amount: Float, reply_to: Subject(Result(User, String)))
  AddByUserId(user_id: String, amount: Float, reply_to: Subject(Result(User, String)))
  Regenerate(user_id: String, new_key: String, reply_to: Subject(Result(User, String)))
  Create(user_id: String, api_key: String, initial_balance: Float, reply_to: Subject(Result(User, String)))
}

pub fn start_actor() -> Result(Subject(KvsMessage), actor.StartError) {
  actor.new(new())
  |> actor.on_message(fn(db: Database, msg: KvsMessage) {
    case msg {
      GetByKey(key, reply_to) -> {
        process.send(reply_to, get_by_api_key(db, key))
        actor.continue(db)
      }
      GetById(user_id, reply_to) -> {
        process.send(reply_to, get_by_user_id(db, user_id))
        actor.continue(db)
      }
      Deduct(key, amount, reply_to) -> {
        case deduct_balance(db, key, amount) {
          Ok(#(updated_user, new_db)) -> {
            process.send(reply_to, Ok(updated_user))
            actor.continue(new_db)
          }
          Error(err) -> {
            process.send(reply_to, Error(err))
            actor.continue(db)
          }
        }
      }
      Add(key, amount, reply_to) -> {
        case add_balance(db, key, amount) {
          Ok(#(updated_user, new_db)) -> {
            process.send(reply_to, Ok(updated_user))
            actor.continue(new_db)
          }
          Error(err) -> {
            process.send(reply_to, Error(err))
            actor.continue(db)
          }
        }
      }
      AddByUserId(user_id, amount, reply_to) -> {
        case add_balance_by_user_id(db, user_id, amount) {
          Ok(#(updated_user, new_db)) -> {
            process.send(reply_to, Ok(updated_user))
            actor.continue(new_db)
          }
          Error(err) -> {
            process.send(reply_to, Error(err))
            actor.continue(db)
          }
        }
      }
      Regenerate(user_id, new_key, reply_to) -> {
        case regenerate_key(db, user_id, new_key) {
          Ok(#(updated_user, new_db)) -> {
            process.send(reply_to, Ok(updated_user))
            actor.continue(new_db)
          }
          Error(err) -> {
            process.send(reply_to, Error(err))
            actor.continue(db)
          }
        }
      }
      Create(user_id, api_key, balance, reply_to) -> {
        let user = User(
          user_id:,
          api_key:,
          balance:,
          quota_bytes: 104857600,
          metadata: dict.new(),
        )
        case insert_user(db, user) {
          Ok(new_db) -> {
            process.send(reply_to, Ok(user))
            actor.continue(new_db)
          }
          Error(err) -> {
            process.send(reply_to, Error(err))
            actor.continue(db)
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

pub fn call_get_by_key(server: Subject(KvsMessage), key: String) -> Result(User, String) {
  case process.call(server, 1000, fn(reply_to) { GetByKey(key, reply_to) }) {
    Ok(u) -> Ok(u)
    Error(err) -> Error(err)
  }
}

pub fn call_deduct_balance(server: Subject(KvsMessage), key: String, amount: Float) -> Result(User, String) {
  case process.call(server, 1000, fn(reply_to) { Deduct(key, amount, reply_to) }) {
    Ok(u) -> Ok(u)
    Error(err) -> Error(err)
  }
}

pub fn call_add_balance(server: Subject(KvsMessage), key: String, amount: Float) -> Result(User, String) {
  case process.call(server, 1000, fn(reply_to) { Add(key, amount, reply_to) }) {
    Ok(u) -> Ok(u)
    Error(err) -> Error(err)
  }
}

pub fn call_create_user(
  server: Subject(KvsMessage),
  user_id: String,
  api_key: String,
  initial_balance: Float,
) -> Result(User, String) {
  case process.call(server, 1000, fn(reply_to) {
    Create(user_id, api_key, initial_balance, reply_to)
  }) {
    Ok(u) -> Ok(u)
    Error(err) -> Error(err)
  }
}

pub fn call_get_by_id(server: Subject(KvsMessage), user_id: String) -> Result(User, String) {
  case process.call(server, 1000, fn(reply_to) { GetById(user_id, reply_to) }) {
    Ok(u) -> Ok(u)
    Error(err) -> Error(err)
  }
}

pub fn call_regenerate_key(server: Subject(KvsMessage), user_id: String, new_key: String) -> Result(User, String) {
  case process.call(server, 1000, fn(reply_to) { Regenerate(user_id, new_key, reply_to) }) {
    Ok(u) -> Ok(u)
    Error(err) -> Error(err)
  }
}

pub fn call_add_balance_by_user_id(server: Subject(KvsMessage), user_id: String, amount: Float) -> Result(User, String) {
  case process.call(server, 1000, fn(reply_to) { AddByUserId(user_id, amount, reply_to) }) {
    Ok(u) -> Ok(u)
    Error(err) -> Error(err)
  }
}

