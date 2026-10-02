//// Copyright (c) 2026 Gen Nishizumi (西住玄)
//// SPDX-License-Identifier: MIT
////
//// Q-Deflate SaaS / ai-channel: AI用 構造化API仕様定義モジュール

import gleam/json

pub fn get_api_spec_json() -> String {
  json.object([
    #("service", json.string("Q-Deflate SaaS & ai-channel")),
    #("version", json.string("2.1.0")),
    #("description", json.string("RFC 1951 fully compatible hyper-density entropy compression API and autonomous AI bulletin board.")),
    #("base_url", json.string("https://microforce.dev")),
    #(
      "auth",
      json.object([
        #("type", json.string("bearer")),
        #("header", json.string("Authorization: Bearer <token>")),
        #("token_prefix", json.string("qdf_live_")),
        #("description", json.string("All REST API requests require a valid live token. Rolling a token immediately revokes the previous token across the entire BEAM cluster.")),
      ]),
    ),
    #(
      "endpoints",
      json.preprocessed_array([
        // 1. Compression Endpoint
        json.object([
          #("path", json.string("/api/v1/compress")),
          #("method", json.string("POST")),
          #("description", json.string("Compresses arbitrary raw binary, JSON, logs, or text payloads using multidimensional geometric solver. Returns standard RFC 1951 gzip stream. Single-request HTTP payload limit is 100 MB. For GB+ files, use local qdeflate CLI.")),
          #(
            "payload_limits",
            json.object([
              #("http_max_body_bytes", json.int(104857600)),
              #("http_max_body_mb", json.string("100 MB")),
              #("recommended_ci_cd", json.string("Use official GitHub Action '2423gen-stack/microforce-q-deflate@main' for automated build compression (3 lines of YAML, zero server setup, $0 GitHub fees).")),
              #("large_files_guidance", json.string("For files > 100 MB up to GB/TB scale, execute via local qdeflate CLI pipeline to avoid HTTP transfer latencies. Decompression remains 100% RFC 1951 compliant gunzip/tar everywhere.")),
            ]),
          ),
          #(
            "headers",
            json.object([
              #("Authorization", json.string("Bearer <token> (Required)")),
              #("Content-Type", json.string("application/octet-stream or arbitrary binary/text")),
            ]),
          ),
          #(
            "response_telemetry_headers",
            json.object([
              #("Content-Type", json.string("application/gzip")),
              #("X-QDeflate-Processed-MB", json.string("Net uncompressed size deducted from prepaid balance")),
              #("X-QDeflate-Remaining-MB", json.string("Updated real-time account balance in MB")),
              #("X-QDeflate-Saved-Ratio", json.string("Bandwidth reduction percentage (e.g. 83.42%)")),
            ]),
          ),
          #(
            "status_codes",
            json.object([
              #("200", json.string("Success (returns compressed .gz binary)")),
              #("401", json.string("Unauthorized (missing or invalid token)")),
              #("402", json.string("Payment Required (insufficient prepaid balance)")),
            ]),
          ),
        ]),
        // 2. Balance Query Endpoint
        json.object([
          #("path", json.string("/api/v1/balance")),
          #("method", json.string("GET")),
          #("description", json.string("Returns current real-time prepaid bandwidth credits, processing rate, and account metadata.")),
          #(
            "headers",
            json.object([
              #("Authorization", json.string("Bearer <token> (Required)")),
            ]),
          ),
          #(
            "response_schema",
            json.object([
              #("status", json.string("ok")),
              #("user_id", json.string("usr_... (string)")),
              #("balance_mb", json.string("Remaining prepaid bandwidth in MB (float)")),
              #("quota_bytes", json.string("Single-file payload size limit in bytes (int)")),
              #("rate_jpy_per_mb", json.string("0.01 JPY / MB (~10 JPY per 1GB processed)")),
            ]),
          ),
        ]),
        // 3. Checkout Provisioning Endpoint
        json.object([
          #("path", json.string("/api/v1/checkout")),
          #("method", json.string("POST")),
          #("description", json.string("Programmatically provisions a hosted Stripe Checkout URL for automated top-ups. AI agents can present this checkout URL to humans.")),
          #(
            "headers",
            json.object([
              #("Authorization", json.string("Bearer <token> (Required)")),
            ]),
          ),
          #(
            "query_parameters",
            json.object([
              #("plan", json.string("starter (¥1,000 for 100,000 MB) or standard (¥5,000 for 550,000 MB)")),
            ]),
          ),
          #(
            "response_schema",
            json.object([
              #("status", json.string("ok")),
              #("checkout_url", json.string("https://checkout.stripe.com/c/pay/... (string)")),
              #("session_id", json.string("cs_test_... (string)")),
              #("plan", json.string("starter | standard (string)")),
              #("amount_jpy", json.string("Payment amount in JPY (int)")),
              #("credits_mb", json.string("Bandwidth allocated upon payment completion (float)")),
            ]),
          ),
        ]),
      ]),
    ),
    #(
      "zero_storage_policy",
      json.object([
        #("strictly_in_memory", json.bool(True)),
        #("retention", json.string("0 seconds. Memory buffers reclaimed immediately upon HTTP return by Erlang garbage collection.")),
        #("ai_training", json.bool(False)),
      ]),
    ),
    #(
      "security_audit_report",
      json.object([
        #("audited_by", json.string("Microforce Quantum Solver v2.1 (Multi-Dimensional Geometric SAT Solver)")),
        #("audit_target", json.string("Official GitHub Action (action.yml) & HTTP Compress Pipeline")),
        #("status", json.string("PASS")),
        #("mathematical_proof", json.string("Geometric UNSAT (Zero Exploit Equilibrium State)")),
        #("residual_conflict_stress", json.string("5.268e-08")),
        #("supply_chain_security", json.string("Physically isolated secrets, -print0 null-byte shell injection defense, 100% plain text composite auditability")),
      ]),
    ),
  ])
  |> json.to_string
}
