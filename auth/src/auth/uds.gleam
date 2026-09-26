//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// UDS (UNIX Domain Socket) 通信モジュール
//// /var/run/sockets/auth.sock を介した改行区切りJSON-over-UDSの送受信

pub type Socket

pub type ListenSocket

@external(erlang, "auth_uds_ffi", "listen_uds")
pub fn listen(path: String) -> Result(ListenSocket, String)

@external(erlang, "auth_uds_ffi", "accept_uds")
pub fn accept(listener: ListenSocket) -> Result(Socket, String)

@external(erlang, "auth_uds_ffi", "connect_uds")
pub fn connect(path: String) -> Result(Socket, String)

@external(erlang, "auth_uds_ffi", "send_uds")
pub fn send(socket: Socket, data: BitArray) -> Result(Nil, String)

@external(erlang, "auth_uds_ffi", "recv_uds")
pub fn recv(socket: Socket, timeout_ms: Int) -> Result(BitArray, String)

@external(erlang, "auth_uds_ffi", "close_uds")
pub fn close(socket: Socket) -> Nil

@external(erlang, "auth_uds_ffi", "close_uds")
pub fn close_listener(listener: ListenSocket) -> Nil

@external(erlang, "auth_uds_ffi", "delete_file")
pub fn delete_socket_file(path: String) -> Nil

@external(erlang, "auth_uds_ffi", "spawn_proc")
pub fn spawn(fun: fn() -> Nil) -> Nil

@external(erlang, "auth_uds_ffi", "sleep")
pub fn sleep(ms: Int) -> Nil

@external(erlang, "auth_uds_ffi", "get_env")
pub fn get_env(name: String, default: String) -> String

@external(erlang, "auth_uds_ffi", "hash_password")
pub fn hash_password(password: String) -> String

@external(erlang, "auth_uds_ffi", "verify_password")
pub fn verify_password(password: String, stored_hash: String) -> Bool
