# Copyright (c) 2026 Gen Nishizumi (西住玄)
# SPDX-License-Identifier: MIT

#!/usr/bin/env python3
"""
Q-Deflate MCP Server (FastMCP)
AIエージェントが自律的に超高密度圧縮、残高照会、課金決済URL発行を行うための公式MCPサーバー。
"""

import os
import json
import urllib.request
import urllib.error
from mcp.server.fastmcp import FastMCP

BASE_URL = os.environ.get("QDEFLATE_URL", "https://microforce.dev")

mcp = FastMCP(
    name="qdeflate",
    instructions="""
Q-Deflate SaaS (https://microforce.dev) 公式 Model Context Protocol (MCP) サーバーです。
RFC 1951完全互換・0秒解凍の超高密度エントロピー圧縮エンジンへのアクセスを提供します。

【提供ツール】
- get_api_reference: REST APIの完全な構造化仕様書（認証・圧縮・課金・Zero-Storage）を取得。
- qdeflate_compress: RFC 1951完全互換Gzip超高密度圧縮を実行。
- qdeflate_get_balance: アカウントのリアルタイム残高（MB）とクォータを照会。
- qdeflate_create_checkout: プリペイド残高チャージ用のStripe Checkout決済URLを発行。
"""
)

@mcp.tool()
def get_api_reference() -> str:
    """Q-Deflate SaaSの完全なREST API仕様書（エンドポイント一覧、認証仕様、テレメトリヘッダー、エラーコード、Zero-Storageポリシー等）をJSON形式で取得します。
    外部ドキュメントやWeb検索を行わずに、AIエージェント自身でAPI仕様を即座に把握・ディスカバリできます。
    """
    try:
        req = urllib.request.Request(
            f"{BASE_URL}/api/docs",
            headers={"User-Agent": "qdeflate-mcp"}
        )
        with urllib.request.urlopen(req) as res:
            return res.read().decode("utf-8")
    except Exception as e:
        return json.dumps({"error": str(e)}, ensure_ascii=False)

@mcp.tool()
def qdeflate_compress(data_string: str, api_token: str) -> str:
    """Q-Deflate APIを呼び出して、文字列データをRFC 1951完全互換の超高密度Gzipバイナリへ圧縮します。
    
    Args:
        data_string: 圧縮対象のテキストデータ（JSON、ソースコード、ログなど）
        api_token: 認証用Bearerトークン（例: qdf_live_...）
    
    Returns:
        処理結果のステータスメトリクス（消費MB、残り残高MB、削減率、Gzipヘッダー検証など）
    """
    try:
        payload = data_string.encode("utf-8")
        req = urllib.request.Request(
            f"{BASE_URL}/api/v1/compress",
            data=payload,
            headers={
                "Authorization": f"Bearer {api_token}",
                "Content-Type": "application/octet-stream",
                "User-Agent": "qdeflate-mcp",
            },
        )
        with urllib.request.urlopen(req) as res:
            gz_data = res.read()
            processed_mb = res.headers.get("X-QDeflate-Processed-MB", "0.0")
            remaining_mb = res.headers.get("X-QDeflate-Remaining-MB", "0.0")
            saved_ratio = res.headers.get("X-QDeflate-Saved-Ratio", "0.0%")
            
            return json.dumps({
                "status": "success",
                "original_bytes": len(payload),
                "compressed_bytes": len(gz_data),
                "saved_ratio": saved_ratio,
                "processed_mb": processed_mb,
                "remaining_balance_mb": remaining_mb,
                "is_valid_rfc1951_gzip": gz_data[:2] == b"\x1f\x8b",
            }, ensure_ascii=False, indent=2)
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return json.dumps({"error": f"HTTP {e.code}", "detail": body}, ensure_ascii=False)
    except Exception as e:
        return json.dumps({"error": str(e)}, ensure_ascii=False)

@mcp.tool()
def qdeflate_get_balance(api_token: str) -> str:
    """Q-Deflate APIアカウントのリアルタイム残高（プリペイド帯域MB）、単一ファイル処理クォータ、レート情報を取得します。
    
    Args:
        api_token: 認証用Bearerトークン（例: qdf_live_...）
    """
    try:
        req = urllib.request.Request(
            f"{BASE_URL}/api/v1/balance",
            headers={
                "Authorization": f"Bearer {api_token}",
                "User-Agent": "qdeflate-mcp",
            }
        )
        with urllib.request.urlopen(req) as res:
            return res.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return json.dumps({"error": f"HTTP {e.code}", "detail": body}, ensure_ascii=False)
    except Exception as e:
        return json.dumps({"error": str(e)}, ensure_ascii=False)

@mcp.tool()
def qdeflate_create_checkout(api_token: str, plan: str = "starter") -> str:
    """プリペイド帯域クレジットを追加購入するためのStripe Hosted Checkout URLを発行します。
    AIエージェントが残高枯渇を検知した際、本ツールで発行された決済URLを人間（ユーザー）に提示してチャージを促すことができます。
    
    Args:
        api_token: 認証用Bearerトークン（例: qdf_live_...）
        plan: チャージプラン ('starter': ¥1,000 / 100,000 MB, 'standard': ¥5,000 / 550,000 MB)
    """
    try:
        req = urllib.request.Request(
            f"{BASE_URL}/api/v1/checkout?plan={plan}",
            data=b"",
            headers={
                "Authorization": f"Bearer {api_token}",
                "User-Agent": "qdeflate-mcp",
            }
        )
        with urllib.request.urlopen(req) as res:
            return res.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return json.dumps({"error": f"HTTP {e.code}", "detail": body}, ensure_ascii=False)
    except Exception as e:
        return json.dumps({"error": str(e)}, ensure_ascii=False)

if __name__ == "__main__":
    mcp.run()
