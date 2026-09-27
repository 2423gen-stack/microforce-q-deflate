# Q-Deflate SaaS

> **RFC 1951 Fully-Compliant Hyper-Density Gzip Optimization Platform**  
> Built entirely in **pure Gleam / BEAM (Erlang VM)**, styled with **htmx**, and fortified with **UNIX Domain Socket (UDS)** process isolation.

[![Language: Gleam](https://img.shields.io/badge/Language-Gleam-ffaff3?logo=gleam&logoColor=black)](https://gleam.run)
[![Runtime: BEAM / OTP](https://img.shields.io/badge/Runtime-BEAM%20%2F%20OTP-a90533?logo=erlang&logoColor=white)](https://www.erlang.org)
[![Production: microforce.dev](https://img.shields.io/badge/Live%20Service-microforce.dev-10b981?logo=cloudflare&logoColor=white)](https://microforce.dev)
[![Architecture: Zero-Storage](https://img.shields.io/badge/Security-Zero--Storage-emerald)](https://microforce.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**🌐 Official Website & Production Portal**: [https://microforce.dev](https://microforce.dev)  
*Try the interactive Web Compress Studio or register for API tokens directly at [microforce.dev](https://microforce.dev).*

---

## ⚡ What is Q-Deflate?

Modern compression algorithms (Zstandard, Brotli) often demand specialized decompression runtimes on client machines or edge environments. **Q-Deflate** takes a radically different engineering approach:

- **100% RFC 1951 Compliance**: Generates standard DEFLATE / Gzip streams.
- **Zero Decompression Dependencies**: Unpacks instantly with standard tools (`gzip -d`, Python `gzip`, Node.js `zlib`, Go `compress/gzip`, Rust `flate2`).
- **Hyper-Density Entropy Optimization**: Achieves an additional **15–25% pure net cut** over standard `gzip -9` through global entropy tree optimization.
- **Asymmetric Advantage**: Spend extra CPU cycles during asset pre-compression (CI/CD) to permanently reduce global egress transfer costs (AWS CloudFront, Cloudflare, S3).

---

## 🏛️ Architecture Overview

The system is designed with a **Defense-in-Depth, Zero-Storage** philosophy:

```
[ Internet / Clients / AI Agents ]
              │
              ▼ (HTTPS / Port 443)
┌──────────────────────────────────────────────┐
│ Cloudflare Tunnel (cloudflared)              │
│ - No exposed open ports                      │
│ - Zero DDoS attack surface                   │
└──────────────────────┬───────────────────────┘
                       │ (HTTP / Local Network)
┌──────────────────────▼───────────────────────┐
│ Web & API Node (Gleam / Mist / Wisp / htmx)  │
│ - High-concurrency BEAM lightweight actors   │
│ - Zero client-side JS bloat (htmx SPA)       │
│ - Streaming RFC 1951 compression pipeline    │
│ - Native MCP SSE & JSON-RPC endpoints        │
└──────────────────────┬───────────────────────┘
                       │ (UNIX Domain Socket: /var/run/sockets/auth.sock)
                       │ (SO_PEERCRED Kernel-Level Isolation)
┌──────────────────────▼───────────────────────┐
│ Fortified Auth Node (Gleam / BEAM Actor)     │
│ - Atomic prepaid bandwidth balance deduction │
│ - Instant API token revocation (O(1))        │
│ - Stripe Checkout & Webhook event valve      │
│ - ZERO raw user file or disk persistence     │
└──────────────────────────────────────────────┘
```

---

## 🚀 Quick Start (Self-Hosted / Local Evaluation)

Run the entire cluster with a single command:

```bash
# Clone the repository
git clone https://github.com/2423gen-stack/microforce-q-deflate.git
cd microforce-q-deflate

# Launch services via Docker Compose
docker compose up -d --build
```

Access the web interface at **`http://localhost:8080`**:
- **Landing Page**: `http://localhost:8080/`
- **Interactive Web Studio**: `http://localhost:8080/dashboard?tab=compress`
- **Machine-Readable API Docs**: `http://localhost:8080/api/docs`

---

## 🛠️ API & CI/CD Integration

### 1. Simple `curl` Asset Compression

```bash
curl -s -X POST https://microforce.dev/api/v1/compress \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"bundle.js" \
  -o "bundle.js.gz"
```

Verify standard decompression anywhere with standard `gzip`:
```bash
gzip -dc bundle.js.gz > restored_bundle.js
cmp bundle.js restored_bundle.js && echo "Bit-exact verified!"
```

### 2. GitHub Actions (Automated Asset Optimization)

Add this step to your deployment workflow to slash egress bandwidth costs:

```yaml
# .github/workflows/deploy.yml
- name: Compress static assets with Q-Deflate
  run: |
    for file in dist/assets/*.{js,css,json}; do
      [ -f "$file" ] || continue
      echo "Optimizing $file with Q-Deflate ..."
      curl -s -X POST https://microforce.dev/api/v1/compress \
        -H "Authorization: Bearer ${{ secrets.QDEFLATE_API_KEY }}" \
        --data-binary @"$file" -o "$file.gz"
    done
  env:
    QDEFLATE_API_KEY: ${{ secrets.QDEFLATE_API_KEY }}
```

---

## 🤖 Model Context Protocol (MCP) Integration

Q-Deflate provides a native FastMCP server, allowing autonomous AI agents (Claude Desktop, Cursor, AGY) to discover API capabilities, query real-time balance, and trigger compression without human intervention.

### Add to Claude Desktop (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "qdeflate": {
      "command": "python3",
      "args": ["/path/to/qdeflate-saas/mcp/server.py"],
      "env": {
        "QDEFLATE_URL": "https://microforce.dev"
      }
    }
  }
}
```

### Available MCP Tools:
- `get_api_reference`: Fetches complete JSON schema of the REST API.
- `qdeflate_compress`: Executes RFC 1951 stream compression for text / code strings.
- `qdeflate_get_balance`: Queries real-time prepaid bandwidth credit.
- `qdeflate_create_checkout`: Generates a Stripe Checkout URL when credits run low.

---

## 🔒 Zero-Storage Security Guarantee

1. **In-Memory Streaming**: File payloads are compressed on-the-fly inside isolated BEAM memory processes and streamed back. No temporary files or raw data are ever written to disk.
2. **Zero Liability**: We do not store, index, or inspect user content.
3. **Credit-Card Free**: We never handle payment card data. All billing is delegated to Stripe Checkout.

---

## 📜 Benchmark Summary

| Content Type | Raw Size | Standard Gzip (Lv.6) | **Q-Deflate (Global Optima)** | Pure Cut vs Std Gzip |
| :--- | :--- | :--- | :--- | :--- |
| Production JS Bundle | 420 KB | 118 KB (28.1%) | **96 KB (22.8%)** | **▼ 18.6%** |
| Minified CSS Bundle | 185 KB | 38 KB (20.5%) | **29 KB (15.7%)** | **▼ 23.7%** |
| Access Log (JSON/Text) | 1,250 KB | 142 KB (11.4%) | **109 KB (8.7%)** | **▼ 23.2%** |
| PostgreSQL Dump (SQL) | 4,800 KB | 890 KB (18.5%) | **695 KB (14.5%)** | **▼ 21.9%** |

*Decompressed instantaneously with standard `gzip -d` in 0.00s.*

---

## 🛠 Ops & Diagnostics (Layered Telemetry)

For production reliability and rapid troubleshooting, Q-Deflate includes an automated diagnostic tool and layered telemetry tags:
- `[HTTP]`: Inbound request status and route timing
- `[AUTH_UDS]`: Unix domain socket authentication and bandwidth ledger operations
- `[ENGINE]`: In-memory compression metrics (payload size, reduction ratio)
- `[STRIPE]`: Webhook reconciliation and payment events

### Quick Diagnostic Snapshot & Log Archive:
```bash
# Run one-shot health audit and save snapshot to logs/latest.log
./scripts/save_logs.sh

# Real-time color-coded streaming log inspection
./scripts/save_logs.sh -f

# Extract errors and warnings only
./scripts/save_logs.sh -e
```

---

## 👤 Author & License

- **Architect & Author**: Gen Nishizumi (西住玄)
- **License**: [MIT License](LICENSE)
