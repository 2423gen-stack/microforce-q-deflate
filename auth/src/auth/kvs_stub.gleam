//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// Agile DB オープンコア公開用標準スタブ（インメモリ版）
//// 外部公開リポジトリ向けの標準KVS実装。
//// コア知財（多次元幾何学・ヒルベルト空間射影テンソル演算モジュール）はブラックボックス化され、
//// 本番環境では非公開プラグイン/バイナリとしてホットスワップされる。

import auth/kvs.{type Database, type User}
import gleam/dict

pub fn new_database() -> Database {
  kvs.new()
}

pub fn default_admin_user() -> User {
  kvs.User(
    user_id: "usr_admin",
    password_hash: "",
    api_key: "qdf_live_admin_key",
    balance: 100.0,
    quota_bytes: 104857600,
    metadata: dict.from_list([#("role", "admin"), #("engine", "agile_db_stub")]),
  )
}
