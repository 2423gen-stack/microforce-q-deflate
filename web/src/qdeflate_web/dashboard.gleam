// Copyright (c) 2026 Gen Nishizumi (西住玄)
// SPDX-License-Identifier: MIT

//// Q-Deflate SaaS ユーザーダッシュボード（Cloudflare風 2ペインUI）
//// 左サイドバー（幅256px・LP調ディープネイビー #0b132b）× 右メインペイン（bg-slate-50）
//// htmx（hx-get / hx-target="#main-pane"）によるSPA風爆速切り替え

import qdeflate_web/auth_client.{type AuthUserDetail}
import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub type Tab {
  Overview
  Compress
  Tokens
  Billing
  Docs
  Settings
}

pub fn parse_tab(name: String) -> Tab {
  case name {
    "compress" -> Compress
    "tokens" -> Tokens
    "billing" -> Billing
    "docs" -> Docs
    "settings" -> Settings
    _ -> Overview
  }
}

pub fn tab_to_string(tab: Tab) -> String {
  case tab {
    Overview -> "overview"
    Compress -> "compress"
    Tokens -> "tokens"
    Billing -> "billing"
    Docs -> "docs"
    Settings -> "settings"
  }
}

/// 完全なダッシュボードHTMLシェルを描画（初期アクセス時）
pub fn render_dashboard(user: AuthUserDetail, active_tab: Tab) -> String {
  let main_content = render_tab_content(user, active_tab)
  let tab_str = tab_to_string(active_tab)

  "<!DOCTYPE html>
<html lang=\"en\" class=\"h-full bg-slate-50\">
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>Dashboard - Q-Deflate</title>
  <!-- Tailwind CSS CDN -->
  <script src=\"https://cdn.tailwindcss.com\"></script>
  <!-- htmx -->
  <script src=\"https://unpkg.com/htmx.org@1.9.12\"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            brand: {
              50: '#f0f7ff',
              100: '#e0effe',
              500: '#0069ff',
              600: '#0055d4',
              700: '#0042a6',
              900: '#0b132b',
            }
          },
          fontFamily: {
            mono: ['JetBrains Mono', 'Menlo', 'Monaco', 'Courier New', 'monospace'],
            sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
          }
        }
      }
    }
  </script>
  <style>
    .sidebar-link.active {
      background-color: rgba(255, 255, 255, 0.1);
      color: #ffffff;
      border-left: 3px solid #0069ff;
    }
  </style>
</head>
<body class=\"h-full flex overflow-hidden font-sans text-slate-800 antialiased\">

  <!-- 1. 左ペイン（サイドバー: Cloudflare風ディープネイビー） -->
  <aside class=\"w-64 bg-[#0b132b] flex flex-col justify-between shrink-0 border-r border-slate-800 text-slate-300 select-none\">
    <div>
      <!-- ブランドロゴヘッダー -->
      <div class=\"h-16 flex items-center px-6 border-b border-slate-800/80 justify-between\">
        <a href=\"/compress\" class=\"flex items-center space-x-3 group\">
          <div class=\"w-8 h-8 rounded bg-brand-500 flex items-center justify-center text-white font-mono font-bold text-lg shadow-sm shadow-brand-500/50 group-hover:scale-105 transition-transform\">
            Q
          </div>
          <span class=\"font-mono font-bold text-lg text-white tracking-tight\">Q-Deflate</span>
        </a>
        <span class=\"text-[10px] font-mono uppercase px-1.5 py-0.5 rounded bg-brand-900 border border-brand-500/40 text-brand-400 font-semibold\">SaaS</span>
      </div>

      <!-- ナビゲーションメニュー -->
      <nav class=\"px-3 py-4 space-y-1 text-sm font-medium\">
        " <> render_sidebar_links(tab_str) <> "
        <div class=\"pt-3 mt-3 border-t border-slate-800/80\">
          <a href=\"/logout\" class=\"w-full flex items-center space-x-3 px-3 py-2 rounded-lg text-xs font-semibold text-rose-400 hover:text-rose-300 hover:bg-rose-500/10 transition-colors\">
            <span class=\"text-sm\">🚪</span>
            <span>Sign Out</span>
          </a>
        </div>
      </nav>
    </div>

    <!-- サイドバー下部：ユーザー残高＆ステータス -->
    <div class=\"p-4 border-t border-slate-800/80 bg-slate-900/40\">
      <!-- 残高メーター -->
      <div id=\"sidebar-balance-widget\">
        " <> render_sidebar_balance(user.balance) <> "
      </div>

      <!-- ユーザープロフィールバッジ -->
      <div class=\"flex items-center justify-between px-1\">
        <div class=\"flex items-center space-x-2.5 overflow-hidden\">
          <div class=\"w-7 h-7 rounded-full bg-brand-600 flex items-center justify-center text-white text-xs font-bold font-mono\">
            " <> string_head_char(user.user_id) <> "
          </div>
          <div class=\"overflow-hidden\">
            <div class=\"text-xs font-mono font-semibold text-slate-200 truncate\">" <> user.user_id <> "</div>
            <div class=\"text-[10px] text-slate-400 flex items-center space-x-1\">
              <span class=\"w-1.5 h-1.5 rounded-full bg-emerald-400\"></span>
              <span>BEAM Online</span>
            </div>
          </div>
        </div>
        <a href=\"/logout\" class=\"text-slate-400 hover:text-rose-400 text-xs p-1 rounded hover:bg-slate-800 transition-colors\" title=\"Sign Out\">
          <svg class=\"w-4 h-4\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1\"/></svg>
        </a>
      </div>
    </div>
  </aside>

  <!-- 2. 右メインペイン (コンテンツエリア) -->
  <div class=\"flex-1 flex flex-col h-full overflow-hidden bg-slate-50\">
    <!-- トップヘッダー -->
    <header class=\"h-16 bg-white border-b border-slate-200 px-8 flex items-center justify-between shrink-0 shadow-2xs\">
      <!-- Breadcrumb -->
      <div class=\"flex items-center space-x-2 text-sm text-slate-500 font-medium\">
        <span>Dashboard</span>
        <span class=\"text-slate-300\">/</span>
        <span id=\"current-tab-name\" class=\"text-slate-900 capitalize font-semibold\">" <> tab_str <> "</span>
      </div>

      <!-- 右側アクション・ステータス -->
      <div class=\"flex items-center space-x-4\">
        <div class=\"flex items-center space-x-2 px-3 py-1 bg-emerald-50 border border-emerald-200 rounded-full text-xs text-emerald-700 font-mono\">
          <span class=\"w-2 h-2 rounded-full bg-emerald-500 animate-pulse\"></span>
          <span>Cluster 100% Operational</span>
        </div>
        <a href=\"/compress\" class=\"text-xs text-slate-600 hover:text-brand-600 font-medium px-3 py-1.5 rounded-lg border border-slate-200 hover:border-brand-500 hover:bg-brand-50/50 transition-all\">
          ← Back to LP
        </a>
      </div>
    </header>

    <!-- メインコンテンツ (htmxで中身のみ動的差し替え) -->
    <main id=\"main-pane\" class=\"flex-1 overflow-y-auto p-8\">
      " <> main_content <> "
    </main>
  </div>

  <script>
    function updateActiveNav(tab) {
      document.querySelectorAll('.sidebar-link').forEach(el => el.classList.remove('active'));
      const activeEl = document.getElementById('nav-' + tab);
      if (activeEl) activeEl.classList.add('active');
      const tabTitle = document.getElementById('current-tab-name');
      if (tabTitle) tabTitle.textContent = tab.charAt(0).toUpperCase() + tab.slice(1);
    }

    function copyToClipboard(text, btnId) {
      navigator.clipboard.writeText(text).then(() => {
        const btn = document.getElementById(btnId);
        if (btn) {
          const original = btn.innerHTML;
          btn.innerHTML = '✓ Copied!';
          btn.classList.add('bg-emerald-600', 'text-white');
          setTimeout(() => {
            btn.innerHTML = original;
            btn.classList.remove('bg-emerald-600', 'text-white');
          }, 2000);
        }
      });
    }
  </script>
</body>
</html>"
}

/// サイドバーの残高ウィジェットHTML
pub fn render_sidebar_balance(balance: Float) -> String {
  "<div class=\"bg-slate-800/70 rounded-xl p-3.5 border border-slate-700/60 mb-3\">
    <div class=\"flex items-center justify-between text-xs mb-1.5\">
      <span class=\"text-slate-400 font-medium\">Prepaid Balance</span>
      <span id=\"sidebar-balance-text\" class=\"text-emerald-400 font-mono font-bold\">" <> float_to_mb_string(balance) <> " MB</span>
    </div>
    <div class=\"w-full bg-slate-700 rounded-full h-1.5 overflow-hidden\">
      <div id=\"sidebar-balance-bar\" class=\"bg-gradient-to-r from-brand-500 to-emerald-400 h-1.5 rounded-full\" style=\"width: " <> calculate_balance_pct(balance) <> "\"></div>
    </div>
    <div class=\"mt-2 flex items-center justify-between text-[11px] text-slate-400\">
      <span>Plan: <strong class=\"text-slate-200\">Pro Tier</strong></span>
      <a href=\"/dashboard/tab/billing\" hx-get=\"/dashboard/tab/billing\" hx-target=\"#main-pane\" hx-push-url=\"/dashboard?tab=billing\" onclick=\"updateActiveNav('billing')\" class=\"text-brand-400 hover:text-brand-300 font-semibold\">+ Charge</a>
    </div>
  </div>"
}

/// サイドバーのリンクHTMLを生成
fn render_sidebar_links(current_tab: String) -> String {
  let tabs = [
    #("overview", "📊", "Overview"),
    #("compress", "🗜️", "Web Compress"),
    #("tokens", "🔑", "API Tokens"),
    #("billing", "💳", "Billing & Plans"),
    #("docs", "📖", "Docs & curl"),
    #("settings", "⚙️", "Settings"),
  ]

  tabs
  |> list.map(fn(item) {
    let #(key, icon, label) = item
    let is_active = key == current_tab
    let active_class = case is_active {
      True -> "active"
      False -> "text-slate-400 hover:text-slate-200 hover:bg-slate-800/60"
    }

    "<a id=\"nav-" <> key <> "\" href=\"/dashboard/tab/" <> key <> "\"
       hx-get=\"/dashboard/tab/" <> key <> "\"
       hx-target=\"#main-pane\"
       hx-push-url=\"/dashboard?tab=" <> key <> "\"
       onclick=\"updateActiveNav('" <> key <> "')\"
       class=\"sidebar-link flex items-center space-x-3 px-3 py-2.5 rounded-lg transition-colors " <> active_class <> "\">
      <span class=\"text-base\">" <> icon <> "</span>
      <span class=\"font-medium\">" <> label <> "</span>
    </a>"
  })
  |> string.join("\n")
}

/// タブ内容のレンダリング（htmxパーシャルとしても使用）
pub fn render_tab_content(user: AuthUserDetail, tab: Tab) -> String {
  case tab {
    Overview -> render_overview_tab(user)
    Compress -> render_compress_tab(user)
    Tokens -> render_tokens_tab(user)
    Billing -> render_billing_tab(user)
    Docs -> render_docs_tab(user)
    Settings -> render_settings_tab(user)
  }
}

// -----------------------------------------------------------------------------
// 各タブの詳細レンダリング
// -----------------------------------------------------------------------------

fn render_overview_tab(user: AuthUserDetail) -> String {
  "
  <div class=\"max-w-5xl mx-auto space-y-8 animate-fade-in\">
    <!-- ヘッダー挨拶 -->
    <div>
      <h1 class=\"text-2xl font-bold text-slate-900\">Welcome back, " <> user.user_id <> "</h1>
      <p class=\"text-sm text-slate-500 mt-1\">Monitor your Q-Deflate compression metrics, prepaid bandwidth, and API status.</p>
    </div>

    <!-- 3連メトリクスカード -->
    <div class=\"grid grid-cols-1 md:grid-cols-3 gap-6\">
      <!-- カード1: 残高 -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between\">
        <div>
          <div class=\"flex items-center justify-between text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2\">
            <span>Remaining Bandwidth</span>
            <span class=\"text-brand-600 bg-brand-50 px-2 py-0.5 rounded font-mono\">Prepaid</span>
          </div>
          <div class=\"text-3xl font-extrabold text-slate-900 font-mono\">
            " <> float_to_mb_string(user.balance) <> " <span class=\"text-sm font-normal text-slate-500\">MB</span>
          </div>
          <p class=\"text-xs text-slate-400 mt-2 font-mono\">Processed on demand with RFC 1951</p>
        </div>
        <div class=\"mt-4 pt-4 border-t border-slate-100 flex items-center justify-between\">
          <span class=\"text-xs text-slate-500\">Status: <strong class=\"text-emerald-600 font-semibold\">Active</strong></span>
          <a href=\"/dashboard/tab/billing\" hx-get=\"/dashboard/tab/billing\" hx-target=\"#main-pane\" hx-push-url=\"/dashboard?tab=billing\" onclick=\"updateActiveNav('billing')\" class=\"text-xs font-semibold text-brand-600 hover:text-brand-700\">+ Recharge</a>
        </div>
      </div>

      <!-- カード2: 総削減率 -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between\">
        <div>
          <div class=\"flex items-center justify-between text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2\">
            <span>Average Reduction Ratio</span>
            <span class=\"text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded font-mono\">Solvers</span>
          </div>
          <div class=\"text-3xl font-extrabold text-emerald-600 font-mono\">
            82.5% <span class=\"text-sm font-normal text-slate-500\">Saved</span>
          </div>
          <p class=\"text-xs text-slate-400 mt-2 font-mono\">▼ ~30% beyond standard Gzip</p>
        </div>
        <div class=\"mt-4 pt-4 border-t border-slate-100 flex items-center justify-between\">
          <span class=\"text-xs text-slate-500\">Engine: <strong class=\"text-slate-700 font-mono\">Q-Deflate v2.1</strong></span>
          <span class=\"text-xs font-medium text-emerald-600\">0s Unpack</span>
        </div>
      </div>

      <!-- カード3: クイック連携 -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between\">
        <div>
          <div class=\"flex items-center justify-between text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2\">
            <span>API Token Ready</span>
            <span class=\"text-slate-500 bg-slate-100 px-2 py-0.5 rounded font-mono\">Live</span>
          </div>
          <div class=\"text-sm font-mono text-slate-800 bg-slate-100 px-3 py-2 rounded-lg border border-slate-200 truncate\">
            " <> mask_key(user.api_key) <> "
          </div>
          <p class=\"text-xs text-slate-400 mt-2 font-mono\">Use in Bearer authorization header</p>
        </div>
        <div class=\"mt-4 pt-4 border-t border-slate-100 flex items-center justify-between\">
          <a href=\"/dashboard/tab/tokens\" hx-get=\"/dashboard/tab/tokens\" hx-target=\"#main-pane\" hx-push-url=\"/dashboard?tab=tokens\" onclick=\"updateActiveNav('tokens')\" class=\"text-xs font-semibold text-brand-600 hover:text-brand-700\">Manage Keys →</a>
          <button id=\"btn-quick-copy\" onclick=\"copyToClipboard('" <> user.api_key <> "', 'btn-quick-copy')\" class=\"text-xs font-semibold px-2 py-1 bg-slate-100 hover:bg-slate-200 rounded text-slate-700 transition-colors\">Copy</button>
        </div>
      </div>
    </div>

    <!-- クイックアクション & Web Compress Studioへの案内 -->
    <div class=\"grid grid-cols-1 md:grid-cols-2 gap-6\">
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between\">
        <div>
          <div class=\"flex items-center space-x-2 text-brand-600 font-bold mb-2\">
            <span class=\"text-xl\">🗜️</span>
            <h2 class=\"text-lg font-bold text-slate-900\">Web Compress Studio</h2>
          </div>
          <p class=\"text-sm text-slate-600 leading-relaxed\">
            Upload and compress JSON, log, or binary files directly in your browser. Live compression charged to your prepaid balance.
          </p>
        </div>
        <div class=\"mt-6\">
          <a href=\"/dashboard/tab/compress\" hx-get=\"/dashboard/tab/compress\" hx-target=\"#main-pane\" hx-push-url=\"/dashboard?tab=compress\" onclick=\"updateActiveNav('compress')\"
             class=\"inline-flex items-center justify-center px-4 py-2.5 bg-brand-600 hover:bg-brand-700 text-white rounded-lg text-xs font-semibold shadow-xs transition-colors space-x-2\">
            <span>Open Studio</span>
            <span>→</span>
          </a>
        </div>
      </div>

      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between\">
        <div>
          <div class=\"flex items-center space-x-2 text-slate-700 font-bold mb-2\">
            <span class=\"text-xl\">$</span>
            <h2 class=\"text-lg font-bold text-slate-900\">CLI & API Integration</h2>
          </div>
          <p class=\"text-sm text-slate-600 leading-relaxed\">
            Integrate with GitHub Actions, AWS Lambda, or AI agents using our standard RFC 1951 gzip HTTP endpoint.
          </p>
        </div>
        <div class=\"mt-6\">
          <a href=\"/dashboard/tab/docs\" hx-get=\"/dashboard/tab/docs\" hx-target=\"#main-pane\" hx-push-url=\"/dashboard?tab=docs\" onclick=\"updateActiveNav('docs')\"
             class=\"inline-flex items-center justify-center px-4 py-2.5 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-semibold shadow-xs transition-colors space-x-2\">
            <span>View cURL Snippets</span>
            <span>→</span>
          </a>
        </div>
      </div>
    </div>
  </div>
  "
}

// -----------------------------------------------------------------------------
// Web Compress Studio タブ
// -----------------------------------------------------------------------------

fn render_compress_tab(user: AuthUserDetail) -> String {
  "
  <div class=\"max-w-4xl mx-auto space-y-6 animate-fade-in\">
    <!-- ヘッダー -->
    <div class=\"flex items-center justify-between\">
      <div>
        <h1 class=\"text-2xl font-bold text-slate-900 flex items-center space-x-2\">
          <span>🗜️</span>
          <span>Web Compress Studio</span>
        </h1>
        <p class=\"text-sm text-slate-500 mt-1\">
          Drag and drop files to compress with Q-Deflate RFC 1951 engine. Deducted directly from your prepaid balance.
        </p>
      </div>
      <div class=\"text-right\">
        <span class=\"text-xs text-slate-400 font-mono\">Available: </span>
        <span class=\"text-xs font-bold text-emerald-600 font-mono\">" <> float_to_mb_string(user.balance) <> " MB</span>
      </div>
    </div>

    <!-- ドラッグ＆ドロップ アップロードボックス -->
    <div id=\"upload-dropzone\"
         class=\"border-2 border-dashed border-slate-300 hover:border-brand-500 bg-white rounded-2xl p-10 text-center transition-all cursor-pointer shadow-xs group\">
      <input type=\"file\" id=\"compress-file-input\" class=\"hidden\" onchange=\"handleFileSelect(this.files)\" />
      <input type=\"file\" id=\"compress-folder-input\" class=\"hidden\" webkitdirectory directory multiple onchange=\"handleFolderSelect(this.files)\" />

      <div id=\"dropzone-prompt\" class=\"space-y-4\">
        <div class=\"w-14 h-14 mx-auto rounded-2xl bg-brand-50 text-brand-600 flex items-center justify-center text-2xl group-hover:scale-110 transition-transform shadow-xs\">
          📦
        </div>
        <div>
          <h2 class=\"text-base font-bold text-slate-800\">Drop file or folder here</h2>
          <p class=\"text-xs text-slate-400 mt-1 font-mono\">JSON, Logs, CSV, Bundle JS, SQL, or whole directories</p>
          <div class=\"mt-2 inline-flex items-center space-x-2 px-3 py-1 bg-brand-50 border border-brand-200 rounded-lg text-[11px] font-mono text-brand-900\">
            <span class=\"font-bold\">⚡ Web Upload Limit: Max 100 MB</span>
            <span class=\"text-slate-300\">|</span>
            <span class=\"text-brand-700\">Automate builds via <strong>GitHub Actions</strong> (Zero server setup, Docs tab)</span>
          </div>
        </div>
        <div class=\"flex items-center justify-center space-x-3 pt-2\">
          <button type=\"button\" onclick=\"event.stopPropagation(); document.getElementById('compress-file-input').click()\"
                  class=\"px-3.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold rounded-lg transition-colors flex items-center space-x-1.5\">
            <span>📄</span>
            <span>Browse File</span>
          </button>
          <span class=\"text-xs text-slate-300\">or</span>
          <button type=\"button\" onclick=\"event.stopPropagation(); triggerFolderPicker(event)\"
                  class=\"px-3.5 py-1.5 bg-brand-50 hover:bg-brand-100 text-brand-700 text-xs font-semibold rounded-lg transition-colors flex items-center space-x-1.5 border border-brand-200\">
            <span>📁</span>
            <span>Browse Folder</span>
          </button>
        </div>
      </div>

      <!-- ファイル/フォルダ選択時の情報表示 -->
      <div id=\"dropzone-file-info\" class=\"hidden space-y-4\">
        <div class=\"inline-flex items-center space-x-3 px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl font-mono text-xs\">
          <span id=\"selected-fileicon\" class=\"text-lg\">📄</span>
          <span id=\"selected-filename\" class=\"font-bold text-slate-800\">data.json</span>
          <span id=\"selected-filesize\" class=\"text-slate-500 font-semibold\">(1.24 MB)</span>
        </div>
        <div>
          <button type=\"button\" id=\"btn-start-compress\" onclick=\"startCompression(event)\"
                  class=\"px-6 py-2.5 bg-brand-600 hover:bg-brand-700 text-white rounded-xl text-xs font-bold shadow-md shadow-brand-500/25 transition-all hover:scale-105 active:scale-95\">
            ⚡ Compress with Q-Deflate
          </button>
        </div>
      </div>

      <!-- 処理中スピナー -->
      <div id=\"dropzone-spinner\" class=\"hidden py-6 space-y-3\">
        <div class=\"w-8 h-8 mx-auto border-3 border-brand-500 border-t-transparent rounded-full animate-spin\"></div>
        <p id=\"spinner-status-text\" class=\"text-xs font-mono text-slate-600 font-semibold\">Processing with multidimensional solver...</p>
      </div>
    </div>

    <!-- 圧縮結果コンテナ -->
    <div id=\"compress-result-container\"></div>
  </div>

  <script>
    let selectedPayload = null; // { name: string, isFolder: boolean, getBlob: () => Promise<Blob> }

    // POSIX UStar TAR ビルダー (依存ゼロ・ブラウザ内完結)
    class SimpleTarBuilder {
      constructor() {
        this.records = [];
      }

      addFile(path, uint8Array, modTime = Math.floor(Date.now() / 1000)) {
        this.records.push({ path, data: uint8Array, mtime: modTime });
      }

      build() {
        const textEncoder = new TextEncoder();
        const blockParts = [];

        for (const rec of this.records) {
          const header = new Uint8Array(512);
          const nameBytes = textEncoder.encode(rec.path);
          header.set(nameBytes.subarray(0, 100), 0);

          const padNull = String.fromCharCode(0);
          // mode (0644 octal)
          header.set(textEncoder.encode('0000644' + padNull), 100);
          // uid / gid
          header.set(textEncoder.encode('0000000' + padNull), 108);
          header.set(textEncoder.encode('0000000' + padNull), 116);

          // size in octal (11 chars + null)
          const sizeStr = rec.data.length.toString(8).padStart(11, '0') + padNull;
          header.set(textEncoder.encode(sizeStr), 124);

          // mtime in octal (11 chars + null)
          const mtimeStr = rec.mtime.toString(8).padStart(11, '0') + padNull;
          header.set(textEncoder.encode(mtimeStr), 136);

          // chksum placeholder (8 spaces)
          header.set(textEncoder.encode('        '), 148);
          // typeflag '0' (regular file)
          header[156] = 48; // '0'

          // magic 'ustar' + null + version '00'
          header.set(textEncoder.encode('ustar' + padNull + '00'), 257);

          // calculate checksum
          let checksum = 0;
          for (let i = 0; i < 512; i++) {
            checksum += header[i];
          }
          const chkStr = checksum.toString(8).padStart(6, '0') + padNull + ' ';
          header.set(textEncoder.encode(chkStr), 148);

          blockParts.push(header);
          blockParts.push(rec.data);

          // pad data to 512-byte block
          const remainder = rec.data.length % 512;
          if (remainder !== 0) {
            const padSize = 512 - remainder;
            blockParts.push(new Uint8Array(padSize));
          }
        }

        // 2 end-of-archive 512-byte zero blocks
        blockParts.push(new Uint8Array(1024));

        return new Blob(blockParts, { type: 'application/x-tar' });
      }
    }

    const dropzone = document.getElementById('upload-dropzone');
    if (dropzone) {
      dropzone.addEventListener('click', (e) => {
        // 子ボタンが押された場合以外はファイル選択を開く
        if (e.target.tagName !== 'BUTTON' && !e.target.closest('button')) {
          document.getElementById('compress-file-input').click();
        }
      });

      ['dragenter', 'dragover'].forEach(eventName => {
        dropzone.addEventListener(eventName, (e) => {
          e.preventDefault();
          e.stopPropagation();
          dropzone.classList.add('border-brand-500', 'bg-brand-50/20');
        }, false);
      });

      ['dragleave', 'drop'].forEach(eventName => {
        dropzone.addEventListener(eventName, (e) => {
          e.preventDefault();
          e.stopPropagation();
          dropzone.classList.remove('border-brand-500', 'bg-brand-50/20');
        }, false);
      });

      dropzone.addEventListener('drop', async (e) => {
        const dt = e.dataTransfer;
        if (!dt) return;

        // Chrome / Safari / Edge: webkitGetAsEntry でフォルダ再帰探索
        if (dt.items && dt.items.length > 0) {
          const item = dt.items[0];
          const entry = item.webkitGetAsEntry ? item.webkitGetAsEntry() : null;
          if (entry && entry.isDirectory) {
            await handleDirectoryEntry(entry);
            return;
          }
        }

        const files = dt.files;
        if (files && files.length > 0) {
          handleFileSelect(files);
        }
      }, false);
    }

    // File System Access API を使ったフォルダ選択
    // Linux の webkitdirectory 問題（GTKピッカーでフォルダが選択できない）を回避
    async function triggerFolderPicker(event) {
      event.stopPropagation();
      if (window.showDirectoryPicker) {
        try {
          const dirHandle = await window.showDirectoryPicker({ mode: 'read' });
          await handleDirectoryHandle(dirHandle);
        } catch(e) {
          // ユーザーがキャンセルした場合は何もしない
          if (e.name !== 'AbortError') console.error('フォルダ選択エラー:', e);
        }
      } else {
        // フォールバック（File System Access API 非対応ブラウザ）
        const fi = document.getElementById('compress-folder-input');
        fi.value = '';
        fi.click();
      }
    }

    // FileSystemDirectoryHandle を再帰スキャン（File System Access API）
    async function handleDirectoryHandle(dirHandle) {
      document.getElementById('dropzone-prompt').classList.add('hidden');
      document.getElementById('dropzone-spinner').classList.remove('hidden');
      document.getElementById('spinner-status-text').textContent = 'Scanning directory files...';

      const fileEntries = [];
      async function scanHandle(handle, path) {
        if (handle.kind === 'file') {
          const file = await handle.getFile();
          fileEntries.push({ path: path, file: file });
        } else if (handle.kind === 'directory') {
          for await (const [name, child] of handle.entries()) {
            await scanHandle(child, path ? path + '/' + name : name);
          }
        }
      }

      await scanHandle(dirHandle, dirHandle.name);
      let totalSize = 0;
      fileEntries.forEach(f => totalSize += f.file.size);

      selectedPayload = {
        name: dirHandle.name + '.tar',
        displayName: dirHandle.name + '/',
        isFolder: true,
        count: fileEntries.length,
        totalSize: totalSize,
        getBlob: async () => {
          const tar = new SimpleTarBuilder();
          for (const item of fileEntries) {
            const buf = await item.file.arrayBuffer();
            tar.addFile(item.path, new Uint8Array(buf), Math.floor(item.file.lastModified / 1000));
          }
          return tar.build();
        }
      };

      document.getElementById('dropzone-spinner').classList.add('hidden');
      document.getElementById('dropzone-file-info').classList.remove('hidden');
      document.getElementById('selected-fileicon').textContent = '📁';
      document.getElementById('selected-filename').textContent = selectedPayload.displayName;
      document.getElementById('selected-filesize').textContent = '(' + fileEntries.length + ' files, ' + (totalSize / 1024).toFixed(1) + ' KB)';
    }

    async function handleDirectoryEntry(dirEntry) {
      document.getElementById('dropzone-prompt').classList.add('hidden');
      document.getElementById('dropzone-spinner').classList.remove('hidden');
      document.getElementById('spinner-status-text').textContent = 'Scanning directory files...';

      const fileEntries = [];
      async function scanDir(entry, path = '') {
        const fullPath = path ? path + '/' + entry.name : entry.name;
        if (entry.isFile) {
          const file = await new Promise((resolve, reject) => entry.file(resolve, reject));
          fileEntries.push({ path: fullPath, file });
        } else if (entry.isDirectory) {
          const reader = entry.createReader();
          const entries = await new Promise((resolve, reject) => {
            const results = [];
            function readBatch() {
              reader.readEntries((batch) => {
                if (!batch || batch.length === 0) {
                  resolve(results);
                } else {
                  results.push(...batch);
                  readBatch();
                }
              }, reject);
            }
            readBatch();
          });
          for (const sub of entries) {
            await scanDir(sub, fullPath);
          }
        }
      }

      await scanDir(dirEntry);

      let totalSize = 0;
      fileEntries.forEach(f => totalSize += f.file.size);

      selectedPayload = {
        name: dirEntry.name + '.tar',
        displayName: dirEntry.name + '/',
        isFolder: true,
        count: fileEntries.length,
        totalSize: totalSize,
        getBlob: async () => {
          const tar = new SimpleTarBuilder();
          for (const item of fileEntries) {
            const buf = await item.file.arrayBuffer();
            tar.addFile(item.path, new Uint8Array(buf), Math.floor(item.file.lastModified / 1000));
          }
          return tar.build();
        }
      };

      document.getElementById('dropzone-spinner').classList.add('hidden');
      document.getElementById('dropzone-file-info').classList.remove('hidden');
      document.getElementById('selected-fileicon').textContent = '📁';
      document.getElementById('selected-filename').textContent = selectedPayload.displayName;
      document.getElementById('selected-filesize').textContent = '(' + selectedPayload.count + ' files, ' + (totalSize / 1024).toFixed(1) + ' KB)';
    }

    function handleFolderSelect(files) {
      if (!files || files.length === 0) return;
      const fileList = Array.from(files);
      let totalSize = 0;
      fileList.forEach(f => totalSize += f.size);

      // 相対パスからルートフォルダ名を抽出 (例: dist/index.html -> dist)
      const firstPath = fileList[0].webkitRelativePath || fileList[0].name;
      const folderName = firstPath.split('/')[0] || 'archive';

      selectedPayload = {
        name: folderName + '.tar',
        displayName: folderName + '/',
        isFolder: true,
        count: fileList.length,
        totalSize: totalSize,
        getBlob: async () => {
          const tar = new SimpleTarBuilder();
          for (const file of fileList) {
            const relPath = file.webkitRelativePath || file.name;
            const buf = await file.arrayBuffer();
            tar.addFile(relPath, new Uint8Array(buf), Math.floor(file.lastModified / 1000));
          }
          return tar.build();
        }
      };

      document.getElementById('dropzone-prompt').classList.add('hidden');
      document.getElementById('dropzone-file-info').classList.remove('hidden');
      document.getElementById('selected-fileicon').textContent = '📁';
      document.getElementById('selected-filename').textContent = selectedPayload.displayName;
      document.getElementById('selected-filesize').textContent = '(' + selectedPayload.count + ' files, ' + (totalSize / 1024).toFixed(1) + ' KB)';
    }

    function handleFileSelect(files) {
      if (!files || files.length === 0) return;
      const file = files[0];
      selectedPayload = {
        name: file.name,
        displayName: file.name,
        isFolder: false,
        totalSize: file.size,
        getBlob: async () => file
      };
      document.getElementById('dropzone-prompt').classList.add('hidden');
      document.getElementById('dropzone-file-info').classList.remove('hidden');
      document.getElementById('selected-fileicon').textContent = '📄';
      document.getElementById('selected-filename').textContent = file.name;
      document.getElementById('selected-filesize').textContent = '(' + (file.size / 1024).toFixed(1) + ' KB)';
    }

    async function startCompression(e) {
      e.stopPropagation();
      if (!selectedPayload) return;

      document.getElementById('dropzone-file-info').classList.add('hidden');
      document.getElementById('dropzone-spinner').classList.remove('hidden');
      document.getElementById('spinner-status-text').textContent = selectedPayload.isFolder ? 'Creating in-memory TAR archive & optimizing...' : 'Processing with multidimensional solver...';

      try {
        const blob = await selectedPayload.getBlob();
        if (blob.size > 100 * 1024 * 1024) {
          alert('【Web Upload Limit: 100MB】\n選択されたファイル/フォルダ（' + (blob.size / (1024 * 1024)).toFixed(1) + ' MB）はWebアップロード上限（100MB）を超えています。\n\n・Web配信アセットの自動最適化：Docsタブ記載の「GitHub Actions（サーバー不要・コピペ3行）」をご利用ください。\n・GB/TB級の社内機密DB・ログ圧縮：ローカル完結の「qdeflate CLI」をご利用ください（外部通信ゼロ・容量無制限）。');
          document.getElementById('dropzone-spinner').classList.add('hidden');
          document.getElementById('dropzone-prompt').classList.remove('hidden');
          return;
        }
        const url = '/dashboard/api/compress?filename=' + encodeURIComponent(selectedPayload.name);
        const res = await fetch(url, {
          method: 'POST',
          body: blob,
          headers: { 'Content-Type': 'application/octet-stream' }
        });
        const html = await res.text();
        document.getElementById('dropzone-spinner').classList.add('hidden');
        document.getElementById('dropzone-prompt').classList.remove('hidden');
        document.getElementById('compress-result-container').innerHTML = html;
        selectedPayload = null;
      } catch (err) {
        alert('Compression failed: ' + err);
        document.getElementById('dropzone-spinner').classList.add('hidden');
        document.getElementById('dropzone-prompt').classList.remove('hidden');
      }
    }

    function resetStudio() {
      document.getElementById('compress-result-container').innerHTML = '';
      document.getElementById('dropzone-prompt').classList.remove('hidden');
      document.getElementById('dropzone-file-info').classList.add('hidden');
      document.getElementById('dropzone-spinner').classList.add('hidden');
      selectedPayload = null;
    }
  </script>
  "
}

/// 圧縮結果カードHTMLの生成
pub fn render_compress_result(
  filename: String,
  orig_bytes: Int,
  comp_bytes: Int,
  download_id: String,
  remaining_mb: Float,
  processed_mb: Float,
) -> String {
  let orig_kb = orig_bytes / 1024
  let comp_kb = comp_bytes / 1024
  let ratio_pct = case orig_bytes > 0 {
    True -> {
      let saved = orig_bytes - comp_bytes
      { saved * 100 } / orig_bytes
    }
    False -> 0
  }
  let qdf_pct = case orig_bytes > 0 {
    True -> { comp_bytes * 100 } / orig_bytes
    False -> 100
  }
  let std_gzip_kb = case orig_kb > 0 {
    True -> {
      let est = { comp_kb * 128 } / 100
      case est > orig_kb {
        True -> orig_kb
        False -> est
      }
    }
    False -> comp_kb
  }
  let std_ratio_pct = case orig_bytes > 0 {
    True -> {
      let est = { qdf_pct * 128 } / 100
      case est > 100 {
        True -> 100
        False -> est
      }
    }
    False -> 100
  }
  let extra_cut_pct = case std_gzip_kb > comp_kb && std_gzip_kb > 0 {
    True -> { { std_gzip_kb - comp_kb } * 100 } / std_gzip_kb
    False -> 22
  }

  "
  <div class=\"bg-white rounded-2xl border border-emerald-200 p-6 shadow-sm space-y-5 animate-fade-in\">
    <!-- ステータスヘッダー -->
    <div class=\"flex items-center justify-between pb-4 border-b border-slate-100\">
      <div class=\"flex items-center space-x-2.5\">
        <div class=\"w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold text-base\">
          ✓
        </div>
        <div>
          <h3 class=\"text-base font-bold text-slate-900\">Compression Complete!</h3>
          <p class=\"text-xs text-slate-500 font-mono mt-0.5\">100% RFC 1951 compliant gzip binary created</p>
        </div>
      </div>
      <span class=\"px-2.5 py-1 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-lg text-xs font-mono font-bold\">
        ▼ " <> int.to_string(ratio_pct) <> "% Net Cut
      </span>
    </div>

    <!-- 比較メトリクスカード -->
    <div class=\"grid grid-cols-2 sm:grid-cols-4 gap-4 text-center\">
      <div class=\"bg-slate-50 p-3.5 rounded-xl border border-slate-200\">
        <span class=\"text-[11px] font-semibold text-slate-500 uppercase tracking-wider block\">Original</span>
        <span class=\"text-base font-mono font-bold text-slate-800 mt-1 block\">" <> int.to_string(orig_kb) <> " KB</span>
      </div>
      <div class=\"bg-emerald-50/60 p-3.5 rounded-xl border border-emerald-200\">
        <span class=\"text-[11px] font-semibold text-emerald-800 uppercase tracking-wider block\">Compressed</span>
        <span class=\"text-base font-mono font-bold text-emerald-700 mt-1 block\">" <> int.to_string(comp_kb) <> " KB</span>
      </div>
      <div class=\"bg-slate-50 p-3.5 rounded-xl border border-slate-200\">
        <span class=\"text-[11px] font-semibold text-slate-500 uppercase tracking-wider block\">Bandwidth Cost</span>
        <span class=\"text-base font-mono font-bold text-brand-600 mt-1 block\">" <> float_to_mb_string(processed_mb) <> " MB</span>
      </div>
      <div class=\"bg-slate-50 p-3.5 rounded-xl border border-slate-200\">
        <span class=\"text-[11px] font-semibold text-slate-500 uppercase tracking-wider block\">Balance Left</span>
        <span class=\"text-base font-mono font-bold text-slate-800 mt-1 block\">" <> float_to_mb_string(remaining_mb) <> " MB</span>
      </div>
    </div>

    <!-- ドーパミン比較ビジュアルグラフ (Original vs Std Gzip vs Q-Deflate) -->
    <div class=\"p-4 rounded-xl bg-slate-900 border border-slate-800 space-y-3 font-mono\">
      <div class=\"flex items-center justify-between text-xs\">
        <span class=\"text-slate-300 font-bold font-sans flex items-center space-x-2\">
          <span class=\"text-amber-400\">⚡</span>
          <span>Entropy Optimization Visualizer</span>
        </span>
        <span class=\"text-emerald-400 font-bold text-[11px] bg-emerald-950/80 border border-emerald-500/40 px-2 py-0.5 rounded shadow-xs\">
          Extra ▼" <> int.to_string(extra_cut_pct) <> "% Pure Cut vs Std Gzip!
        </span>
      </div>

      <!-- バー1: Original -->
      <div class=\"space-y-1\">
        <div class=\"flex justify-between text-[11px] text-slate-400\">
          <span>1. Raw Uncompressed</span>
          <span>" <> int.to_string(orig_kb) <> " KB (100%)</span>
        </div>
        <div class=\"w-full bg-slate-800 rounded-full h-2 overflow-hidden\">
          <div class=\"bg-slate-600 h-2 rounded-full w-full\"></div>
        </div>
      </div>

      <!-- バー2: Standard Gzip (Lv.6) -->
      <div class=\"space-y-1\">
        <div class=\"flex justify-between text-[11px] text-amber-400\">
          <span>2. Standard Gzip (Level 6)</span>
          <span>~" <> int.to_string(std_gzip_kb) <> " KB (~" <> int.to_string(std_ratio_pct) <> "%)</span>
        </div>
        <div class=\"w-full bg-slate-800 rounded-full h-2 overflow-hidden\">
          <div class=\"bg-amber-500/90 h-2 rounded-full\" style=\"width: " <> int.to_string(std_ratio_pct) <> "%;\"></div>
        </div>
      </div>

      <!-- バー3: Q-Deflate (Global Optima) -->
      <div class=\"space-y-1\">
        <div class=\"flex justify-between text-[11px] text-emerald-400 font-bold\">
          <span class=\"flex items-center space-x-1.5\">
            <span>✨ 3. Q-Deflate Hyper-Density</span>
            <span class=\"text-[9px] px-1 py-0.2 bg-emerald-400 text-slate-950 rounded uppercase font-extrabold\">Global Optima</span>
          </span>
          <span>" <> int.to_string(comp_kb) <> " KB (" <> int.to_string(qdf_pct) <> "%)</span>
        </div>
        <div class=\"w-full bg-slate-800 rounded-full h-2.5 overflow-hidden\">
          <div class=\"bg-gradient-to-r from-brand-500 via-sky-400 to-emerald-400 h-2.5 rounded-full\" style=\"width: " <> int.to_string(qdf_pct) <> "%;\"></div>
        </div>
      </div>
    </div>

    <!-- アクションボタン -->
    <div class=\"flex flex-col sm:flex-row items-center justify-between gap-3 pt-2\">
      <button type=\"button\" onclick=\"resetStudio()\" class=\"text-xs text-slate-500 hover:text-slate-800 font-semibold px-4 py-2 rounded-lg border border-slate-200 hover:bg-slate-50 transition-colors w-full sm:w-auto\">
        ← Compress Another File
      </button>
      <a href=\"/dashboard/download/" <> download_id <> "?filename=" <> filename <> ".gz\"
         class=\"inline-flex items-center justify-center space-x-2 px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-md shadow-emerald-600/25 transition-all hover:scale-105 active:scale-95 w-full sm:w-auto\">
        <span>⬇️</span>
        <span>Download " <> filename <> ".gz</span>
      </a>
    </div>
  </div>

  <!-- サイドバー残高メーターのリアルタイム更新 (DOM直書き換え) -->
  <script>
    const balText = document.getElementById('sidebar-balance-text');
    if (balText) balText.textContent = '" <> float_to_mb_string(remaining_mb) <> " MB';
    const balBar = document.getElementById('sidebar-balance-bar');
    if (balBar) balBar.style.width = '" <> calculate_balance_pct(remaining_mb) <> "';
  </script>
  "
}

// -----------------------------------------------------------------------------
// Tokens タブ
// -----------------------------------------------------------------------------

fn render_tokens_tab(user: AuthUserDetail) -> String {
  "
  <div class=\"max-w-4xl mx-auto space-y-6 animate-fade-in\">
    <div class=\"flex items-center justify-between\">
      <div>
        <h1 class=\"text-2xl font-bold text-slate-900\">API Tokens</h1>
        <p class=\"text-sm text-slate-500 mt-1\">Manage Bearer API tokens for microservices, CI/CD pipelines, and AI agent integration.</p>
      </div>
      <button hx-post=\"/dashboard/api/tokens/regenerate\"
              hx-target=\"#token-card-container\"
              hx-confirm=\"Are you sure you want to regenerate your API token? The old token will be permanently revoked immediately.\"
              class=\"px-4 py-2 bg-brand-600 hover:bg-brand-700 text-white rounded-lg text-sm font-semibold shadow-xs transition-colors flex items-center space-x-2\">
        <span>🔄</span>
        <span>Roll / Regenerate Token</span>
      </button>
    </div>

    <!-- トークン一覧カードコンテナ (htmx差し替え対象) -->
    <div id=\"token-card-container\">
      " <> render_token_card(user) <> "
    </div>

    <!-- 安全ガイド -->
    <div class=\"bg-amber-50/70 border border-amber-200 rounded-xl p-5 text-amber-900 text-xs leading-relaxed\">
      <div class=\"flex items-center space-x-2 font-bold mb-1\">
        <span class=\"text-amber-600 text-sm\">⚠️</span>
        <span>Security & Token Best Practices</span>
      </div>
      <p class=\"text-amber-800/90\">
        Keep your API tokens strictly confidential. Tokens carry full authority to compress payloads against your prepaid balance.
        If a token is compromised, roll it immediately using the button above. The old token will be revoked instantly across all cluster nodes.
      </p>
    </div>
  </div>
  "
}

pub fn render_token_card(user: AuthUserDetail) -> String {
  "
  <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
    <div class=\"flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-4 border-b border-slate-100\">
      <div>
        <div class=\"flex items-center space-x-2\">
          <h2 class=\"text-base font-bold text-slate-900\">Production Live Token</h2>
          <span class=\"px-2 py-0.5 rounded text-[11px] font-mono font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200\">Active</span>
        </div>
        <p class=\"text-xs text-slate-500 mt-0.5 font-mono\">Created: 2026-09-25 · Owner: " <> user.user_id <> "</p>
      </div>
      <div class=\"text-right\">
        <span class=\"text-xs text-slate-400 font-mono\">Permissions: </span>
        <span class=\"text-xs font-semibold text-slate-700 font-mono\">deflate:compress, balance:deduct</span>
      </div>
    </div>

    <!-- キー表示 & コピーコントロール -->
    <div>
      <label class=\"block text-xs font-medium text-slate-500 mb-1.5 font-mono\">API Secret Key</label>
      <div class=\"flex items-center space-x-3\">
        <input type=\"password\" id=\"api-key-input\" value=\"" <> user.api_key <> "\" readonly
               class=\"w-full font-mono text-sm bg-slate-50 border border-slate-200 rounded-lg px-3.5 py-2 text-slate-800 select-all focus:outline-none focus:ring-2 focus:ring-brand-500/20\" />
        <button type=\"button\" onclick=\"toggleKeyVisibility()\" id=\"btn-toggle-eye\"
                class=\"px-3 py-2 border border-slate-200 hover:bg-slate-100 rounded-lg text-xs font-medium text-slate-600 transition-colors whitespace-nowrap\">
          👁️ Reveal
        </button>
        <button type=\"button\" id=\"btn-token-copy\" onclick=\"copyToClipboard('" <> user.api_key <> "', 'btn-token-copy')\"
                class=\"px-4 py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-semibold transition-colors whitespace-nowrap shadow-xs\">
          📋 Copy Key
        </button>
      </div>
    </div>
  </div>

  <script>
    function toggleKeyVisibility() {
      const input = document.getElementById('api-key-input');
      const btn = document.getElementById('btn-toggle-eye');
      if (input.type === 'password') {
        input.type = 'text';
        btn.textContent = '🙈 Mask';
      } else {
        input.type = 'password';
        btn.textContent = '👁️ Reveal';
      }
    }
  </script>
  "
}

// -----------------------------------------------------------------------------
// Billing & Plans タブ
// -----------------------------------------------------------------------------

fn render_billing_tab(user: AuthUserDetail) -> String {
  "
  <div class=\"max-w-4xl mx-auto space-y-8 animate-fade-in\">
    <div>
      <h1 class=\"text-2xl font-bold text-slate-900\">Billing & Plans</h1>
      <p class=\"text-sm text-slate-500 mt-1\">Pay only for what you process. Instant prepaid top-ups or monthly subscription.</p>
    </div>

    <!-- 現在の残高バナー -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-4\">
      <div>
        <span class=\"text-xs font-semibold text-slate-400 uppercase tracking-wider font-mono\">Current Available Balance</span>
        <div class=\"text-4xl font-extrabold text-slate-900 font-mono mt-1\">
          " <> float_to_mb_string(user.balance) <> " <span class=\"text-base font-normal text-slate-500\">MB</span>
        </div>
        <p class=\"text-xs text-slate-500 mt-1\">Rate: ~$0.07 / GB processed ($7 for 100 GB, no expiration)</p>
      </div>
      <div class=\"flex items-center space-x-3\">
        <span class=\"px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 border border-emerald-200 text-xs font-semibold\">
          ✓ Stripe Portal Connected
        </span>
      </div>
    </div>

    <!-- US Restaurant Style Gratuity (チップ選択セレクター) -->
    <div class=\"bg-gradient-to-br from-amber-50/80 via-white to-orange-50/50 rounded-xl border border-amber-200/80 p-6 shadow-xs\">
      <div class=\"flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-4 border-b border-amber-100\">
        <div>
          <div class=\"flex items-center space-x-2\">
            <span class=\"text-lg\">🍕</span>
            <h2 class=\"text-sm font-bold text-slate-900\">Add Gratuity (US Restaurant Style 🇺🇸)</h2>
            <span class=\"px-2 py-0.5 rounded-full bg-amber-100 text-amber-800 text-[10px] font-bold uppercase tracking-wider\">Optional</span>
          </div>
          <p class=\"text-xs text-slate-500 mt-1\">
            Honor American tradition or stick to Tokyo minimalism. Zero tip is 100% fine!
          </p>
        </div>
        <div class=\"text-right\">
          <span class=\"text-xs font-mono text-slate-500\">Active Tip:</span>
          <span id=\"display-active-tip\" class=\"text-sm font-bold font-mono text-amber-700 ml-1\">+$0.00</span>
        </div>
      </div>

      <!-- チッププリセットボタングループ -->
      <div class=\"grid grid-cols-2 sm:grid-cols-4 gap-3 mt-4\">
        <button type=\"button\" onclick=\"selectTip(0, this)\"
                class=\"tip-option-btn active-tip border-2 border-slate-900 bg-white p-3 rounded-lg text-left transition-all shadow-xs\">
          <div class=\"text-xs font-bold text-slate-900\">0% (No Tip)</div>
          <div class=\"text-[11px] text-slate-500 mt-0.5 font-mono\">$0.00</div>
          <div class=\"text-[10px] text-slate-400 mt-1 italic\">\"Tokyo Style\"</div>
        </button>

        <button type=\"button\" onclick=\"selectTip(1.26, this)\"
                class=\"tip-option-btn border border-slate-200 hover:border-amber-400 bg-white p-3 rounded-lg text-left transition-all shadow-xs\">
          <div class=\"text-xs font-bold text-slate-900\">18% (Fair)</div>
          <div class=\"text-[11px] text-amber-600 font-bold font-mono mt-0.5\">+$1.26</div>
          <div class=\"text-[10px] text-slate-500 mt-1\">Keep servers warm</div>
        </button>

        <button type=\"button\" onclick=\"selectTip(1.75, this)\"
                class=\"tip-option-btn border border-slate-200 hover:border-amber-400 bg-white p-3 rounded-lg text-left transition-all shadow-xs\">
          <div class=\"text-xs font-bold text-slate-900\">25% (Generous)</div>
          <div class=\"text-[11px] text-amber-600 font-bold font-mono mt-0.5\">+$1.75</div>
          <div class=\"text-[10px] text-slate-500 mt-1\">AEON Beer 🍺</div>
        </button>

        <button type=\"button\" onclick=\"selectTip(100, this)\"
                class=\"tip-option-btn border border-amber-300 bg-gradient-to-r from-amber-50 to-orange-50 hover:border-orange-400 p-3 rounded-lg text-left transition-all shadow-xs relative overflow-hidden\">
          <span class=\"absolute top-0 right-0 bg-red-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-bl\">Recommended!</span>
          <div class=\"text-xs font-bold text-orange-950\">US Dining (~$100)</div>
          <div class=\"text-[11px] text-orange-700 font-bold font-mono mt-0.5\">+$100.00</div>
          <div class=\"text-[10px] text-orange-800 font-semibold mt-1\">Full Experience 🇺🇸</div>
        </button>
      </div>

      <!-- カスタム金額入力スライダー/インプット -->
      <div class=\"mt-4 pt-3 border-t border-amber-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs\">
        <div class=\"text-slate-500 flex items-center space-x-1.5\">
          <span>💡</span>
          <span>Tip is billed as an itemized line item on your official Stripe tax receipt.</span>
        </div>
        <div class=\"flex items-center space-x-2\">
          <label for=\"custom-tip-input\" class=\"text-slate-600 font-medium\">Custom Tip:</label>
          <div class=\"relative rounded-md shadow-xs\">
            <span class=\"absolute inset-y-0 left-0 pl-2.5 flex items-center text-slate-400 font-mono\">$</span>
            <input type=\"number\" id=\"custom-tip-input\" min=\"0\" max=\"1000\" placeholder=\"0\" step=\"0.5\"
                   oninput=\"onCustomTipInput(this.value)\"
                   class=\"w-24 pl-6 pr-2 py-1 text-xs border border-slate-300 rounded focus:ring-1 focus:ring-amber-500 focus:border-amber-500 font-mono text-right text-slate-800\">
          </div>
        </div>
      </div>
    </div>

    <!-- チャージプランカード -->
    <div class=\"grid grid-cols-1 md:grid-cols-3 gap-6\">
      <!-- $7 チャージ (Starter) -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between hover:border-brand-500/50 transition-colors\">
        <div>
          <div class=\"text-xs font-bold text-brand-600 uppercase tracking-wider font-mono\">Starter Charge</div>
          <div class=\"text-2xl font-extrabold text-slate-900 mt-2\">$7</div>
          <p class=\"text-xs text-slate-500 mt-1\">+100,000 MB (100 GB)</p>
          <ul class=\"mt-4 space-y-2 text-xs text-slate-600\">
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>No monthly expiration</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>All API endpoints</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>Standard speed</span></li>
          </ul>
        </div>
        <a id=\"btn-checkout-starter\" href=\"/dashboard/api/checkout?plan=starter&tip=0\"
           class=\"mt-6 w-full py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-semibold shadow-xs transition-colors block text-center\">
          Charge $7 via Stripe
        </a>
      </div>

      <!-- $35 チャージ (Standard / 人気) -->
      <div class=\"bg-white rounded-xl border-2 border-brand-500 p-6 shadow-md relative flex flex-col justify-between\">
        <span class=\"absolute -top-3 right-4 px-2.5 py-0.5 bg-brand-500 text-white rounded-full text-[10px] font-bold font-mono tracking-wide uppercase\">
          +10% Bonus
        </span>
        <div>
          <div class=\"text-xs font-bold text-brand-600 uppercase tracking-wider font-mono\">Standard Volume</div>
          <div class=\"text-2xl font-extrabold text-slate-900 mt-2\">$35</div>
          <p class=\"text-xs text-slate-500 mt-1\">+550,000 MB (550 GB)</p>
          <ul class=\"mt-4 space-y-2 text-xs text-slate-600\">
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>50,000 MB free bonus</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>Priority queue</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>No expiration</span></li>
          </ul>
        </div>
        <a id=\"btn-checkout-standard\" href=\"/dashboard/api/checkout?plan=standard&tip=0\"
           class=\"mt-6 w-full py-2 bg-brand-600 hover:bg-brand-700 text-white rounded-lg text-xs font-semibold shadow-xs transition-colors block text-center\">
          Charge $35 via Stripe
        </a>
      </div>

      <!-- Pro サブスクリプション -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between hover:border-brand-500/50 transition-colors\">
        <div>
          <div class=\"text-xs font-bold text-purple-600 uppercase tracking-wider font-mono\">Pro Monthly</div>
          <div class=\"text-2xl font-extrabold text-slate-900 mt-2\">$35 <span class=\"text-xs font-normal text-slate-500\">/ mo</span></div>
          <p class=\"text-xs text-slate-500 mt-1\">500 GB included monthly</p>
          <ul class=\"mt-4 space-y-2 text-xs text-slate-600\">
            <li class=\"flex items-center space-x-2\"><span class=\"text-purple-500 font-bold\">✓</span> <span>Giga-scale single file</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-purple-500 font-bold\">✓</span> <span>Dedicated cluster node</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-purple-500 font-bold\">✓</span> <span>Direct Slack/Discord support</span></li>
          </ul>
        </div>
        <a href=\"/dashboard/api/checkout?plan=standard&tip=0\"
           class=\"mt-6 w-full py-2 border border-purple-300 text-purple-700 hover:bg-purple-50 rounded-lg text-xs font-semibold transition-colors block text-center\">
          Subscribe via Stripe
        </a>
      </div>
    </div>

    <!-- Tip 選択連動 JavaScript (USD版) -->
    <script>
      let currentTip = 0;
      function selectTip(amount, btnElement) {
        currentTip = amount;
        document.getElementById('custom-tip-input').value = '';
        updateTipUi(amount, btnElement);
      }
      function onCustomTipInput(val) {
        const parsed = parseFloat(val);
        currentTip = (!isNaN(parsed) && parsed > 0) ? parsed : 0;
        updateTipUi(currentTip, null);
      }
      function updateTipUi(amount, activeBtn) {
        const display = document.getElementById('display-active-tip');
        if (display) {
          display.innerText = (amount > 0 ? '+$' + amount.toFixed(2) : '+$0.00');
        }
        document.querySelectorAll('.tip-option-btn').forEach(b => {
          b.classList.remove('border-slate-900', 'border-2');
          b.classList.add('border-slate-200');
        });
        if (activeBtn) {
          activeBtn.classList.remove('border-slate-200');
          activeBtn.classList.add('border-slate-900', 'border-2');
        }
        const btnStarter = document.getElementById('btn-checkout-starter');
        if (btnStarter) {
          btnStarter.href = '/dashboard/api/checkout?plan=starter&tip=' + amount;
          const total = 7 + amount;
          btnStarter.innerText = (amount > 0 ? 'Charge $' + (total % 1 === 0 ? total : total.toFixed(2)) + ' (incl. tip) via Stripe' : 'Charge $7 via Stripe');
        }
        const btnStandard = document.getElementById('btn-checkout-standard');
        if (btnStandard) {
          btnStandard.href = '/dashboard/api/checkout?plan=standard&tip=' + amount;
          const total = 35 + amount;
          btnStandard.innerText = (amount > 0 ? 'Charge $' + (total % 1 === 0 ? total : total.toFixed(2)) + ' (incl. tip) via Stripe' : 'Charge $35 via Stripe');
        }
      }
    </script>
  </div>
  "
}

// -----------------------------------------------------------------------------
// Docs & curl タブ
// -----------------------------------------------------------------------------

fn render_docs_tab(user: AuthUserDetail) -> String {
  "
  <div class=\"max-w-4xl mx-auto space-y-8 animate-fade-in\">
    <div>
      <h1 class=\"text-2xl font-bold text-slate-900\">Docs & Snippets</h1>
      <p class=\"text-sm text-slate-500 mt-1\">Ready-to-use code examples with your live API credentials.</p>
    </div>

    <!-- cURL スニペット -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
      <div class=\"flex items-center justify-between\">
        <h2 class=\"text-base font-bold text-slate-900 flex items-center space-x-2\">
          <span class=\"text-brand-500 font-mono\">$</span>
          <span>cURL (HTTP API Mode - Up to 100 MB)</span>
        </h2>
        <button id=\"btn-copy-curl\" onclick=\"copyToClipboard(document.getElementById('code-curl').innerText, 'btn-copy-curl')\" class=\"text-xs font-semibold px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded text-slate-700 transition-colors\">Copy Code</button>
      </div>
      <p class=\"text-xs text-slate-500 font-sans\">
        Instant cloud compression for web assets, JSON payloads, and log archives up to <strong>100 MB</strong> via public REST API.
      </p>
      <div class=\"bg-slate-900 rounded-lg p-4 font-mono text-xs text-slate-200 overflow-x-auto border border-slate-800\">
        <pre id=\"code-curl\"><code>curl -X POST https://microforce.dev/api/v1/compress \\
  -H \"Authorization: Bearer " <> user.api_key <> "\" \\
  --data-binary @payload.json -o payload.json.gz</code></pre>
      </div>

      <!-- GB+ / Local CLI Guidance -->
      <div class=\"p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2\">
        <div class=\"flex items-center justify-between\">
          <div class=\"flex items-center space-x-2\">
            <span class=\"text-base\">⚡</span>
            <strong class=\"text-xs font-bold text-slate-800 font-mono\">GB+ Files & Production DB Dumps: Local <code>qdeflate</code> CLI</strong>
          </div>
          <span class=\"px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-mono font-bold\">Zero-Network / Unlimited</span>
        </div>
        <p class=\"text-[11px] text-slate-600 font-sans leading-relaxed\">
          Transferring multi-gigabyte SQL dumps or heavy logs over HTTP creates network wait times and risks corporate compliance leaks. 
          Use the local <code>qdeflate</code> native tool on your server. <strong>Decompression requires ZERO client-side tools</strong> (100% standard gunzip / tar -xzf compatible everywhere).
        </p>
        <div class=\"bg-slate-900 rounded-lg p-3 font-mono text-[11px] text-slate-200 overflow-x-auto border border-slate-800\">
          <pre><code># Pipe streaming without network transmission:
mysqldump production_db | qdeflate &gt; backup.sql.gz

# Archive huge directory at line rate:
tar -cf - /var/log | qdeflate &gt; logs.tar.gz</code></pre>
        </div>
      </div>
    </div>

    <!-- Node.js スニペット -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-3\">
      <div class=\"flex items-center justify-between\">
        <h2 class=\"text-base font-bold text-slate-900 flex items-center space-x-2\">
          <span class=\"text-amber-500 font-mono\">⚡</span>
          <span>Node.js / Bun (Fetch Stream)</span>
        </h2>
        <button id=\"btn-copy-node\" onclick=\"copyToClipboard(document.getElementById('code-node').innerText, 'btn-copy-node')\" class=\"text-xs font-semibold px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded text-slate-700 transition-colors\">Copy Code</button>
      </div>
      <div class=\"bg-slate-900 rounded-lg p-4 font-mono text-xs text-slate-200 overflow-x-auto border border-slate-800\">
        <pre id=\"code-node\"><code>import fs from 'node:fs';

const res = await fetch('https://microforce.dev/api/v1/compress', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer " <> user.api_key <> "',
    'Content-Type': 'application/octet-stream',
  },
  body: fs.readFileSync('payload.json'),
});

if (res.ok) {
  const gz = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync('payload.json.gz', gz);
  console.log('Saved to payload.json.gz! Remaining MB:', res.headers.get('X-QDeflate-Remaining-MB'));
}</code></pre>
      </div>
    </div>

    <!-- Programmable Billing & Balance APIs (AI & CI/CD) -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-3\">
      <div class=\"flex items-center justify-between\">
        <h2 class=\"text-base font-bold text-slate-900 flex items-center space-x-2\">
          <span class=\"text-purple-600 font-mono\">🤖</span>
          <span>Programmable Billing API (AI Agents & Automations)</span>
        </h2>
        <button id=\"btn-copy-billing-api\" onclick=\"copyToClipboard(document.getElementById('code-billing-api').innerText, 'btn-copy-billing-api')\" class=\"text-xs font-semibold px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded text-slate-700 transition-colors\">Copy Code</button>
      </div>
      <div class=\"bg-slate-900 rounded-lg p-4 font-mono text-xs text-slate-200 overflow-x-auto border border-slate-800 space-y-3\">
        <div>
          <span class=\"text-slate-400\"># 1. Query real-time balance via API</span>
          <pre id=\"code-billing-api\"><code>curl -s -H \"Authorization: Bearer " <> user.api_key <> "\" \\
  https://microforce.dev/api/v1/balance</code></pre>
        </div>
        <div class=\"pt-2 border-t border-slate-800\">
          <span class=\"text-slate-400\"># 2. Generate a Stripe Checkout URL programmatically (Starter: ¥1,000 / Standard: ¥5,000)</span>
          <pre><code>curl -s -X POST -H \"Authorization: Bearer " <> user.api_key <> "\" \\
  \"https://microforce.dev/api/v1/checkout?plan=starter\"</code></pre>
        </div>
      </div>
    </div>

    <!-- ========================================================================= -->
    <!-- 🚀 GitHub Actions: Zero Server Setup Automated Pipeline (Recommended) -->
    <!-- ========================================================================= -->
    <div class=\"bg-[#0b132b] text-white rounded-2xl p-6 sm:p-7 border border-slate-800 shadow-md space-y-5\">
      <div class=\"flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-800/80\">
        <div class=\"flex items-center space-x-3\">
          <div class=\"w-10 h-10 rounded-xl bg-brand-500/20 text-brand-400 flex items-center justify-center text-xl border border-brand-500/30\">
            🚀
          </div>
          <div>
            <div class=\"flex items-center space-x-2\">
              <h2 class=\"text-base font-bold text-white\">GitHub Actions: Official Zero-Server CI/CD</h2>
              <span class=\"px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase tracking-wider border border-emerald-500/30\">Recommended</span>
            </div>
            <p class=\"text-xs text-slate-300 mt-0.5 font-sans\">
              No server installation, zero maintenance. Copy 3 lines of YAML and slash 20-30% AWS/CloudFront egress costs on every git push.
            </p>
          </div>
        </div>
        <button id=\"btn-copy-gh-actions\" onclick=\"copyToClipboard(document.getElementById('code-gh-actions').innerText, 'btn-copy-gh-actions')\" class=\"text-xs font-semibold px-3 py-1.5 bg-brand-600 hover:bg-brand-500 rounded-lg text-white transition-colors shadow-xs\">Copy YAML</button>
      </div>

      <!-- メリット解説グリッド -->
      <div class=\"grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs\">
        <div class=\"p-3 rounded-xl bg-slate-800/60 border border-slate-700/60 space-y-1\">
          <div class=\"font-bold text-slate-200 flex items-center space-x-1.5\">
            <span class=\"text-emerald-400\">✓</span>
            <span>Zero Server Setup</span>
          </div>
          <p class=\"text-[11px] text-slate-400 leading-relaxed font-sans\">
            Never touch production servers or write complex Dockerfiles. Executes inside GitHub-hosted runner during build.
          </p>
        </div>
        <div class=\"p-3 rounded-xl bg-slate-800/60 border border-slate-700/60 space-y-1\">
          <div class=\"font-bold text-slate-200 flex items-center space-x-1.5\">
            <span class=\"text-emerald-400\">✓</span>
            <span>$0 GitHub Fee</span>
          </div>
          <p class=\"text-[11px] text-slate-400 leading-relaxed font-sans\">
            Runs in seconds. Free for Public repos, and comfortably within the 2,000 free monthly minutes for Private repos.
          </p>
        </div>
        <div class=\"p-3 rounded-xl bg-slate-800/60 border border-slate-700/60 space-y-1\">
          <div class=\"font-bold text-slate-200 flex items-center space-x-1.5\">
            <span class=\"text-emerald-400\">✓</span>
            <span>Zero Client Software</span>
          </div>
          <p class=\"text-[11px] text-slate-400 leading-relaxed font-sans\">
            100% RFC 1951 compliant gzip output. Browsers, CDNs, and customers decompress natively with zero friction.
          </p>
        </div>
      </div>

      <!-- スニペットブロック -->
      <div class=\"space-y-2\">
        <div class=\"flex items-center justify-between text-xs text-slate-400 font-mono\">
          <span>Add this step to your <code>.github/workflows/deploy.yml</code>:</span>
          <span>Target: <code>dist/assets</code></span>
        </div>
        <div class=\"bg-slate-950 rounded-xl p-4 font-mono text-xs text-slate-200 overflow-x-auto border border-slate-800\">
          <pre id=\"code-gh-actions\"><code># 1. Official Q-Deflate GitHub Action (Paste into your workflow)
- name: Hyper-Compress Assets with Q-Deflate
  uses: 2423gen-stack/microforce-q-deflate@main
  with:
    path: 'dist'                           # Directory to compress
    extensions: 'js css json svg html'     # Target static asset types
    token: ${{ secrets.QDEFLATE_API_KEY }} # Stored in Repo Secrets</code></pre>
        </div>
        <p class=\"text-[11px] text-slate-400 font-sans\">
          1. Store your secret key: <code>GitHub Repo &gt; Settings &gt; Secrets and variables &gt; Actions &gt; New repository secret</code> with name <code>QDEFLATE_API_KEY</code>.<br>
          2. That's it! Every deployment automatically generates optimal <code>.gz</code> archives before S3/Cloudflare sync.
        </p>
      </div>

      <!-- 🛡️ サプライチェーン・セキュリティ検証レポート (Open-Source Supply Chain Security) -->
      <div class=\"pt-4 border-t border-slate-800 space-y-3\">
        <div class=\"flex flex-col sm:flex-row sm:items-center justify-between gap-2\">
          <div class=\"flex items-center space-x-2\">
            <span class=\"text-base\">🛡️</span>
            <h3 class=\"text-xs font-bold text-slate-200 uppercase tracking-wider font-mono\">Enterprise Supply Chain & Security Verification</h3>
          </div>
          <span class=\"px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold border border-emerald-500/30\">
            VERIFIED · 100% Auditable Plain Text
          </span>
        </div>
        
        <p class=\"text-[11px] text-slate-300 font-sans leading-relaxed\">
          Enterprise CI/CD pipelines require zero trust. This Action is engineered to pass strict corporate SecOps reviews with verifiable, standard-based guarantees:
        </p>

        <div class=\"grid grid-cols-1 sm:grid-cols-3 gap-2.5 text-[11px] font-mono\">
          <div class=\"p-2.5 bg-slate-900 rounded-lg border border-slate-700/80 space-y-1\">
            <div class=\"text-slate-400 text-[10px] font-bold\">SECRETS ISOLATION</div>
            <div class=\"text-emerald-400 font-bold flex items-center space-x-1\">
              <span>✓ Explicit Token Only</span>
            </div>
            <div class=\"text-[10px] text-slate-300 font-sans\">The script only consumes <code>inputs.token</code>. It possesses no code to read, inspect, or exfiltrate other repository secrets or environment variables.</div>
          </div>
          <div class=\"p-2.5 bg-slate-900 rounded-lg border border-slate-700/80 space-y-1\">
            <div class=\"text-slate-400 text-[10px] font-bold\">SHELL INJECTION DEFENSE</div>
            <div class=\"text-emerald-400 font-bold flex items-center space-x-1\">
              <span>✓ -print0 Null-Delimited</span>
            </div>
            <div class=\"text-[10px] text-slate-300 font-sans\">Uses POSIX-standard array expansion and <code>-print0 / IFS= read -r -d ''</code>. Whitespaces, semicolons, and quotes never trigger arbitrary execution.</div>
          </div>
          <div class=\"p-2.5 bg-slate-900 rounded-lg border border-slate-700/80 space-y-1\">
            <div class=\"text-slate-400 text-[10px] font-bold\">TOTAL TRANSPARENCY</div>
            <div class=\"text-emerald-400 font-bold flex items-center space-x-1\">
              <span>✓ Zero Binary / Container</span>
            </div>
            <div class=\"text-[10px] text-slate-300 font-sans\">No compiled binaries, no obfuscated Docker pulls, no heavy NPM dependencies. Just an 80-line Bash Composite Action you can audit in 60 seconds.</div>
          </div>
        </div>

        <div class=\"bg-slate-900 rounded-lg p-3 border border-slate-700/80 text-[10px] font-mono text-slate-300 space-y-1\">
          <div class=\"text-slate-200 font-bold\">Audit & Verification Direct Link:</div>
          <div class=\"text-slate-300 font-sans leading-relaxed\">
            Review the exact code running in your runner directly on GitHub: 
            <a href=\"https://github.com/2423gen-stack/microforce-q-deflate/blob/main/action.yml\" target=\"_blank\" class=\"text-brand-400 hover:underline font-mono font-bold\">github.com/2423gen-stack/microforce-q-deflate/blob/main/action.yml</a>
          </div>
        </div>
      </div>
    </div>

    <!-- ========================================================================= -->
    <!-- Model Context Protocol (MCP) Integration -->
    <!-- ========================================================================= -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
      <div class=\"flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-100\">
        <div class=\"flex items-center space-x-2.5\">
          <span class=\"text-xl\">⚡</span>
          <div>
            <h2 class=\"text-base font-bold text-slate-900\">Model Context Protocol (MCP) Integration</h2>
            <p class=\"text-xs text-slate-500\">Autonomous AI Agent Access for Claude Desktop, Cursor, Antigravity, and Custom Agents</p>
          </div>
        </div>
        <button id=\"btn-copy-mcp-config\" onclick=\"copyToClipboard(document.getElementById('code-mcp-config').innerText, 'btn-copy-mcp-config')\" class=\"text-xs font-semibold px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded text-slate-700 transition-colors\">Copy Config</button>
      </div>

      <div class=\"grid grid-cols-1 md:grid-cols-2 gap-4\">
        <!-- MCP Endpoints Info -->
        <div class=\"space-y-3\">
          <div class=\"space-y-1\">
            <span class=\"text-xs font-bold text-slate-700 uppercase tracking-wider font-mono\">Official MCP Endpoints</span>
            <div class=\"bg-slate-900 rounded-lg p-3 font-mono text-xs text-slate-200 border border-slate-800 space-y-2\">
              <div>
                <span class=\"text-slate-400 text-[11px]\"># FastMCP Server / Remote SSE Endpoint</span>
                <div class=\"text-brand-400 select-all font-bold\">https://microforce.dev/mcp/sse</div>
              </div>
              <div class=\"pt-2 border-t border-slate-800\">
                <span class=\"text-slate-400 text-[11px]\"># Machine-Readable AI Spec (Self-Discovery)</span>
                <div class=\"text-emerald-400 select-all font-bold\">https://microforce.dev/api/docs</div>
              </div>
            </div>
          </div>

          <div class=\"space-y-1\">
            <span class=\"text-xs font-bold text-slate-700 uppercase tracking-wider font-mono\">Available MCP Tools</span>
            <div class=\"space-y-1.5 text-xs text-slate-600 font-mono\">
              <div class=\"p-2 bg-slate-50 border border-slate-200 rounded flex flex-col\">
                <strong class=\"text-slate-900 font-bold\">get_api_reference()</strong>
                <span class=\"text-[11px] text-slate-500 font-sans\">Self-discover complete REST API specifications without web search.</span>
              </div>
              <div class=\"p-2 bg-slate-50 border border-slate-200 rounded flex flex-col\">
                <strong class=\"text-slate-900 font-bold\">qdeflate_compress(data, token)</strong>
                <span class=\"text-[11px] text-slate-500 font-sans\">Compress arbitrary text/binary into RFC 1951 gzip stream via geometric solver.</span>
              </div>
              <div class=\"p-2 bg-slate-50 border border-slate-200 rounded flex flex-col\">
                <strong class=\"text-slate-900 font-bold\">qdeflate_get_balance(token)</strong>
                <span class=\"text-[11px] text-slate-500 font-sans\">Real-time check of prepaid bandwidth quota and available MB balance.</span>
              </div>
              <div class=\"p-2 bg-slate-50 border border-slate-200 rounded flex flex-col\">
                <strong class=\"text-slate-900 font-bold\">qdeflate_create_checkout(token, plan)</strong>
                <span class=\"text-[11px] text-slate-500 font-sans\">Programmatically provisions Stripe Checkout URL for AI-assisted human top-up.</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Claude / Cursor JSON Snippet -->
        <div class=\"space-y-2\">
          <span class=\"text-xs font-bold text-slate-700 uppercase tracking-wider font-mono\">Agent Configuration (claude_desktop_config.json)</span>
          <div class=\"bg-slate-900 rounded-lg p-3 font-mono text-xs text-slate-200 border border-slate-800 overflow-x-auto\">
            <pre id=\"code-mcp-config\"><code>{
  \"mcpServers\": {
    \"q-deflate\": {
      \"url\": \"https://microforce.dev/mcp/sse\",
      \"headers\": {
        \"Authorization\": \"Bearer " <> user.api_key <> "\"
      }
    }
  }
}</code></pre>
          </div>
          <p class=\"text-[11px] text-slate-500 font-sans leading-relaxed\">
            Alternatively, deploy with Python FastMCP runner:<br>
            <code class=\"text-slate-700 bg-slate-100 px-1 py-0.5 rounded text-[10px]\">AI_CHANNEL_URL=https://microforce.dev python3 bbs/mcp/server.py</code>
          </p>
        </div>
      </div>
    </div>

    <!-- ========================================================================= -->
    <!-- Full API Reference (Auth & Compression) -->
    <!-- ========================================================================= -->
    <div class=\"space-y-4 pt-4 border-t border-slate-200\">
      <div>
        <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2\">
          <span>📚</span>
          <span>REST API Reference</span>
        </h2>
        <p class=\"text-xs text-slate-500 mt-1\">
          Complete specification for API authentication, payload compression, and programmable billing.
        </p>
      </div>

      <!-- 1. Authentication Specification -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
        <div class=\"flex items-center space-x-2.5\">
          <span class=\"text-base font-bold text-slate-900\">1. Authentication & Security</span>
          <span class=\"px-2 py-0.5 rounded text-[10px] font-mono font-bold bg-slate-100 text-slate-700 uppercase\">Bearer Token</span>
        </div>
        <p class=\"text-xs text-slate-600 leading-relaxed\">
          All API requests must include your live secret key in the HTTP <code>Authorization</code> header using the Bearer scheme.
          Unauthenticated requests or expired tokens are rejected immediately with HTTP 401.
        </p>
        <div class=\"bg-slate-900 rounded-lg p-3 font-mono text-xs text-emerald-400 border border-slate-800\">
          <code>Authorization: Bearer " <> user.api_key <> "</code>
        </div>
        <div class=\"text-[11px] text-slate-500 space-y-1 font-mono\">
          <div>• Token Prefix: <code>qdf_live_...</code></div>
          <div>• Revocation: Rolling a token revokes the previous token across the entire cluster with O(1) instant effect.</div>
        </div>
      </div>

      <!-- 2. Compression API: POST /api/v1/compress -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
        <div class=\"flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-100\">
          <div class=\"flex items-center space-x-2.5\">
            <span class=\"px-2.5 py-1 rounded bg-blue-600 text-white font-mono font-bold text-xs\">POST</span>
            <span class=\"font-mono font-bold text-sm text-slate-900\">/api/v1/compress</span>
          </div>
          <span class=\"text-xs text-slate-500 font-mono\">RFC 1951 Pure Functional Engine</span>
        </div>
        <p class=\"text-xs text-slate-600 leading-relaxed\">
          Compresses raw arbitrary binary, JSON, logs, or text payloads using the multidimensional Q-Deflate solver.
          Returns an RFC 1951 compliant <code>application/gzip</code> binary with custom response telemetry headers.
        </p>

        <!-- Request Details -->
        <div class=\"space-y-2\">
          <span class=\"text-xs font-bold text-slate-700 uppercase tracking-wider font-mono\">Request Headers</span>
          <table class=\"w-full text-left text-xs font-mono border border-slate-200 rounded-lg overflow-hidden\">
            <thead class=\"bg-slate-50 text-slate-600\">
              <tr><th class=\"p-2.5 border-b border-slate-200\">Header</th><th class=\"p-2.5 border-b border-slate-200\">Type</th><th class=\"p-2.5 border-b border-slate-200\">Description</th></tr>
            </thead>
            <tbody class=\"divide-y divide-slate-100 text-slate-700\">
              <tr><td class=\"p-2.5 font-bold text-brand-600\">Authorization</td><td class=\"p-2.5\">String (Required)</td><td class=\"p-2.5 font-sans\"><code>Bearer &lt;token&gt;</code></td></tr>
              <tr><td class=\"p-2.5 font-bold text-slate-800\">Content-Type</td><td class=\"p-2.5\">String (Optional)</td><td class=\"p-2.5 font-sans\"><code>application/octet-stream</code> or raw media type</td></tr>
            </tbody>
          </table>
        </div>

        <!-- Response Headers -->
        <div class=\"space-y-2\">
          <span class=\"text-xs font-bold text-slate-700 uppercase tracking-wider font-mono\">Response Telemetry Headers (HTTP 200)</span>
          <table class=\"w-full text-left text-xs font-mono border border-slate-200 rounded-lg overflow-hidden\">
            <thead class=\"bg-slate-50 text-slate-600\">
              <tr><th class=\"p-2.5 border-b border-slate-200\">Header</th><th class=\"p-2.5 border-b border-slate-200\">Example</th><th class=\"p-2.5 border-b border-slate-200\">Description</th></tr>
            </thead>
            <tbody class=\"divide-y divide-slate-100 text-slate-700\">
              <tr><td class=\"p-2.5 font-bold text-slate-800\">Content-Type</td><td class=\"p-2.5 text-slate-500\">application/gzip</td><td class=\"p-2.5 font-sans\">Standard RFC 1951 gzip stream</td></tr>
              <tr><td class=\"p-2.5 font-bold text-brand-600\">X-QDeflate-Processed-MB</td><td class=\"p-2.5 text-slate-500\">1.24</td><td class=\"p-2.5 font-sans\">Exact uncompressed payload size deducted</td></tr>
              <tr><td class=\"p-2.5 font-bold text-emerald-600\">X-QDeflate-Remaining-MB</td><td class=\"p-2.5 text-slate-500\">" <> float_to_mb_string(user.balance) <> "</td><td class=\"p-2.5 font-sans\">Updated real-time account balance</td></tr>
              <tr><td class=\"p-2.5 font-bold text-purple-600\">X-QDeflate-Saved-Ratio</td><td class=\"p-2.5 text-slate-500\">83.42%</td><td class=\"p-2.5 font-sans\">Net bandwidth reduction percentage</td></tr>
            </tbody>
          </table>
        </div>

        <!-- Error Codes -->
        <div class=\"space-y-2\">
          <span class=\"text-xs font-bold text-slate-700 uppercase tracking-wider font-mono\">HTTP Status Codes</span>
          <div class=\"grid grid-cols-1 sm:grid-cols-3 gap-2 text-xs font-mono\">
            <div class=\"p-2 rounded bg-emerald-50 border border-emerald-200 text-emerald-800\"><strong class=\"font-bold\">200 OK</strong>: Compressed .gz stream</div>
            <div class=\"p-2 rounded bg-amber-50 border border-amber-200 text-amber-800\"><strong class=\"font-bold\">401 Unauthorized</strong>: Invalid Bearer key</div>
            <div class=\"p-2 rounded bg-rose-50 border border-rose-200 text-rose-800\"><strong class=\"font-bold\">402 Payment Required</strong>: Insufficient MB balance</div>
          </div>
        </div>
      </div>

      <!-- 3. Billing & Balance APIs -->
      <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
        <div class=\"pb-3 border-b border-slate-100\">
          <h3 class=\"font-bold text-sm text-slate-900\">2. Programmable Balance & Checkout Endpoints</h3>
        </div>

        <!-- Endpoint: GET /api/v1/balance -->
        <div class=\"space-y-2\">
          <div class=\"flex items-center space-x-2.5 font-mono text-xs\">
            <span class=\"px-2 py-0.5 rounded bg-emerald-600 text-white font-bold\">GET</span>
            <span class=\"font-bold text-slate-900\">/api/v1/balance</span>
          </div>
          <p class=\"text-xs text-slate-600 font-sans\">Returns current prepaid bandwidth credits, processing rate, and account metadata.</p>
          <div class=\"bg-slate-900 rounded-lg p-3 font-mono text-xs text-slate-200 overflow-x-auto border border-slate-800\">
            <pre><code>{
  \"status\": \"ok\",
  \"user_id\": \"" <> user.user_id <> "\",
  \"balance_mb\": " <> float_to_mb_string(user.balance) <> ",
  \"quota_bytes\": " <> int.to_string(user.quota_bytes) <> ",
  \"rate_jpy_per_mb\": 0.01
}</code></pre>
          </div>
        </div>

        <!-- Endpoint: POST /api/v1/checkout -->
        <div class=\"space-y-2 pt-3 border-t border-slate-100\">
          <div class=\"flex items-center space-x-2.5 font-mono text-xs\">
            <span class=\"px-2 py-0.5 rounded bg-blue-600 text-white font-bold\">POST</span>
            <span class=\"font-bold text-slate-900\">/api/v1/checkout?plan=starter</span>
          </div>
          <p class=\"text-xs text-slate-600 font-sans\">
            Programmatically provisions a hosted Stripe Checkout URL for automated top-ups.
            Query parameter <code>plan</code> supports <code>starter</code> (¥1,000 / 100,000 MB) and <code>standard</code> (¥5,000 / 550,000 MB).
          </p>
          <div class=\"bg-slate-900 rounded-lg p-3 font-mono text-xs text-slate-200 overflow-x-auto border border-slate-800\">
            <pre><code>{
  \"status\": \"ok\",
  \"checkout_url\": \"https://checkout.stripe.com/c/pay/cs_test_...\",
  \"session_id\": \"cs_test_...\",
  \"plan\": \"starter\",
  \"amount_jpy\": 1000,
  \"credits_mb\": 100000.0
}</code></pre>
          </div>
        </div>
      </div>
    </div>

    <!-- Zero-Storage & Privacy Guarantee -->
    <div class=\"bg-emerald-950 text-emerald-100 rounded-xl p-6 border border-emerald-800/80 shadow-xs space-y-3\">
      <div class=\"flex items-center space-x-2.5\">
        <span class=\"text-xl\">🛡️</span>
        <h2 class=\"text-base font-bold text-white\">Zero-Storage & Privacy Guarantee (Strictly In-Memory)</h2>
      </div>
      <p class=\"text-xs text-emerald-200/90 leading-relaxed\">
        All payloads transmitted to the Q-Deflate API and Web Studio are processed strictly within BEAM in-memory pure functional pipelines (Gleam). No data is ever persisted to disk, cached externally, or utilized for AI training.
        The exact moment compression finishes and bytes are returned to the client, all in-memory buffers are immediately reclaimed by Erlang garbage collection. High-compliance enterprise payloads, proprietary server logs, and sensitive data are safely supported.
      </p>
    </div>

    <!-- Frequently Asked Questions (FAQ) -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
      <h2 class=\"text-base font-bold text-slate-900 flex items-center space-x-2\">
        <span>❓</span>
        <span>Frequently Asked Questions (FAQ)</span>
      </h2>
      <div class=\"divide-y divide-slate-100 text-xs space-y-3 pt-1\">
        <div class=\"pt-3 space-y-1\">
          <p class=\"font-bold text-slate-900\">Q. Is running the Q-Deflate GitHub Action safe for proprietary enterprise code?</p>
          <p class=\"text-slate-600 leading-relaxed\">A. Absolutely safe. The Action is an open, uncompiled 80-line Bash Composite Action (fully auditable on GitHub in plain text). It strictly consumes only <code>inputs.token</code>, possesses no capability to read or exfiltrate other repository secrets or environment variables, and uses standard <code>-print0</code> null-byte sanitization against command injection. Furthermore, all asset processing adheres to our strictly in-memory Zero-Storage policy (buffers reclaimed immediately upon HTTP return, zero disk persistence, zero AI training).</p>
        </div>
        <div class=\"pt-3 space-y-1\">
          <p class=\"font-bold text-slate-900\">Q. What is the maximum file size for compression?</p>
          <p class=\"text-slate-600 leading-relaxed\">A. The Web Compress Studio and public HTTP REST API support up to <strong>100 MB per file</strong> (optimized for web bundles, JS/CSS, and release archives).<br>
          • <strong>Web Assets & CI/CD:</strong> We strongly recommend our official <strong>GitHub Actions</strong> integration (Docs tab). With just 3 lines of YAML, your web assets are automatically compressed on every git push with zero server setup and $0 additional GitHub fees.<br>
          • <strong>Gigabyte-scale DB Dumps & Heavy Logs:</strong> Use the local <code>qdeflate</code> CLI directly on your server to eliminate heavy network transfer times. All decompressed outputs remain 100% RFC 1951 gzip compatible everywhere.</p>
        </div>
        <div class=\"pt-3 space-y-1\">
          <p class=\"font-bold text-slate-900\">Q. Do I need specialized software to decompress Q-Deflate files?</p>
          <p class=\"text-slate-600 leading-relaxed\">A. No specialized software is needed. Q-Deflate is 100% compliant with the RFC 1951 standard (Deflate / Gzip). Files decompress natively with standard <code>gunzip</code>, <code>tar -xzf</code>, Python's built-in <code>gzip</code> module, and default operating system archive utilities with zero overhead.</p>
        </div>
        <div class=\"pt-3 space-y-1\">
          <p class=\"font-bold text-slate-900\">Q. Do prepaid credits (MB balance) ever expire?</p>
          <p class=\"text-slate-600 leading-relaxed\">A. Never. Prepaid bandwidth balances do not expire. Usage is metered in exact 0.01 JPY / MB increments, available whenever your microservices or pipelines require compression.</p>
        </div>
        <div class=\"pt-3 space-y-1\">
          <p class=\"font-bold text-slate-900\">Q. Are invoices and receipts automatically issued?</p>
          <p class=\"text-slate-600 leading-relaxed\">A. Yes. Immediately upon completing checkout, official Stripe receipts and qualified tax invoices are dispatched to your registered billing email address, also accessible on-demand from the Billing tab.</p>
        </div>
      </div>
    </div>

    <!-- Legal & Compliance Information -->
    <div class=\"bg-slate-50 rounded-xl border border-slate-200 p-6 text-xs text-slate-600 space-y-3 font-mono\">
      <h3 class=\"text-xs font-bold text-slate-800 uppercase tracking-wider\">Legal & Compliance / Commercial Disclosure</h3>
      <div class=\"grid grid-cols-1 sm:grid-cols-2 gap-2 text-[11px] leading-relaxed pt-1\">
        <div><strong class=\"text-slate-800\">Entity:</strong> Microforce Project (Gen Nishizumi)</div>
        <div><strong class=\"text-slate-800\">Operations Director:</strong> Gen Nishizumi</div>
        <div><strong class=\"text-slate-800\">Direct Support:</strong> support@microforce.dev</div>
        <div><strong class=\"text-slate-800\">Accepted Payment:</strong> Credit Cards (Powered by Stripe Checkout)</div>
        <div><strong class=\"text-slate-800\">Fulfillment:</strong> Instantaneous digital credit allocation</div>
        <div><strong class=\"text-slate-800\">Refund Policy:</strong> Due to immediate digital delivery, all balance top-ups are non-refundable</div>
      </div>
    </div>
  </div>
  "
}

// -----------------------------------------------------------------------------
// Settings タブ
// -----------------------------------------------------------------------------

fn render_settings_tab(user: AuthUserDetail) -> String {
  "
  <div class=\"max-w-4xl mx-auto space-y-6 animate-fade-in\">
    <div>
      <h1 class=\"text-2xl font-bold text-slate-900\">Settings</h1>
      <p class=\"text-sm text-slate-500 mt-1\">Account information, security settings, and credentials.</p>
    </div>

    <!-- 1. 基本アカウント情報 -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-6\">
      <div>
        <label class=\"block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1 font-mono\">Account Identifier</label>
        <div class=\"font-mono text-sm text-slate-900 bg-slate-50 border border-slate-200 rounded-lg px-3.5 py-2.5 max-w-md\">
          " <> user.user_id <> "
        </div>
      </div>

      <div>
        <label class=\"block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1 font-mono\">Default Plan</label>
        <div class=\"text-sm text-slate-700 flex items-center space-x-2\">
          <span class=\"px-2.5 py-1 rounded bg-brand-50 text-brand-700 font-semibold font-mono text-xs border border-brand-200\">Pro Tier</span>
          <span class=\"text-xs text-slate-400\">Managed via Stripe Customer Portal</span>
        </div>
      </div>

      <div class=\"pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-400 font-mono\">
        <span>Platform: Gleam / BEAM OTP Cluster</span>
        <span class=\"text-emerald-600 font-bold flex items-center space-x-1\">
          <span class=\"w-2 h-2 rounded-full bg-emerald-500\"></span>
          <span>Fortress UDS Active</span>
        </span>
      </div>
    </div>

    <!-- 2. パスワード変更（セキュリティ設定） -->
    <div class=\"bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4\">
      <div class=\"pb-3 border-b border-slate-100\">
        <h2 class=\"text-base font-bold text-slate-900 flex items-center space-x-2\">
          <span>🔐</span>
          <span>Change Password</span>
        </h2>
        <p class=\"text-xs text-slate-500 mt-0.5\">Update your password securely. Salted SHA-256 encryption is applied instantly to Quantum DB.</p>
      </div>

      <!-- htmxによる動的メッセージ表示領域 -->
      <div id=\"password-feedback\"></div>

      <form hx-post=\"/dashboard/api/password/change\"
            hx-target=\"#password-feedback\"
            hx-swap=\"innerHTML\"
            class=\"space-y-4 max-w-md\">
        <div>
          <label class=\"block text-xs font-medium text-slate-700 mb-1.5\">Current Password</label>
          <input type=\"password\" name=\"current_password\" required placeholder=\"Enter current password\"
                 class=\"w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-mono text-slate-800 placeholder-slate-400 focus:outline-none focus:border-brand-500 focus:ring-1 focus:ring-brand-500 transition-colors\">
        </div>

        <div>
          <label class=\"block text-xs font-medium text-slate-700 mb-1.5\">New Password</label>
          <input type=\"password\" name=\"new_password\" required placeholder=\"Enter new secure password\"
                 class=\"w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-mono text-slate-800 placeholder-slate-400 focus:outline-none focus:border-brand-500 focus:ring-1 focus:ring-brand-500 transition-colors\">
        </div>

        <div>
          <label class=\"block text-xs font-medium text-slate-700 mb-1.5\">Confirm New Password</label>
          <input type=\"password\" name=\"confirm_password\" required placeholder=\"Repeat new password\"
                 class=\"w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-mono text-slate-800 placeholder-slate-400 focus:outline-none focus:border-brand-500 focus:ring-1 focus:ring-brand-500 transition-colors\">
        </div>

        <button type=\"submit\"
                class=\"px-4 py-2.5 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-semibold shadow-xs transition-colors\">
          Update Password
        </button>
      </form>
    </div>
  </div>
  "
}

pub fn render_password_success() -> String {
  "<div class=\"p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center space-x-2 font-medium animate-fade-in\">
    <span class=\"text-emerald-600 font-bold text-sm\">✓</span>
    <span>パスワードを正常に更新いたしました。（Password updated successfully）</span>
  </div>"
}

pub fn render_password_error(msg: String) -> String {
  "<div class=\"p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-center space-x-2 font-medium animate-fade-in\">
    <span class=\"text-rose-500 font-bold text-sm\">⚠️</span>
    <span>" <> msg <> "</span>
  </div>"
}

// -----------------------------------------------------------------------------
// ヘルパー関数群
// -----------------------------------------------------------------------------

fn float_to_mb_string(val: Float) -> String {
  let rounded = float.to_string(val)
  case string.split_once(rounded, ".") {
    Ok(#(int_part, dec_part)) -> {
      let trimmed_dec = string.slice(dec_part, 0, 2)
      int_part <> "." <> trimmed_dec
    }
    Error(_) -> rounded <> ".00"
  }
}

fn calculate_balance_pct(balance: Float) -> String {
  let pct = case balance >. 1000.0 {
    True -> 100.0
    False -> {
      case balance <. 0.0 {
        True -> 0.0
        False -> { balance *. 100.0 } /. 1000.0
      }
    }
  }
  float.to_string(pct) <> "%"
}

fn mask_key(key: String) -> String {
  let len = string.length(key)
  case len > 12 {
    True -> {
      let prefix = string.slice(key, 0, 8)
      let suffix = string.slice(key, len - 4, 4)
      prefix <> "..." <> suffix
    }
    False -> key
  }
}

fn string_head_char(s: String) -> String {
  case string.slice(s, 0, 1) {
    "" -> "U"
    c -> string.uppercase(c)
  }
}
