// Copyright (c) 2026 Gen Nishizumi (西住玄)
// SPDX-License-Identifier: MIT

//// Q-Deflate ランディングページ (LP) 描画モジュール
//// DigitalOcean風のクリーン＆テックデザイン（スレート×シアンブルー、1枚刃の機能美）
//// 日本語 (JA) / 英語 (EN) のバイリンガル対応

import gleam/int

pub type Lang {
  Ja
  En
}

pub fn render_lp(lang: Lang) -> String {
  let is_en = case lang {
    En -> True
    Ja -> False
  }

  let html_lang = case is_en {
    True -> "en"
    False -> "ja"
  }

  let page_title = case is_en {
    True -> "Q-Deflate - High-Density RFC 1951 Compatible Compression SaaS"
    False -> "Q-Deflate - Zip / Gzip 互換、超高密度圧縮SaaS"
  }

  let nav_benchmark = case is_en {
    True -> "Benchmarks"
    False -> "ベンチマーク"
  }

  let nav_how_it_works = case is_en {
    True -> "How It Works"
    False -> "仕組み"
  }

  let nav_pricing = case is_en {
    True -> "Pricing"
    False -> "料金プラン"
  }

  let nav_cta = case is_en {
    True -> "Sign Up"
    False -> "新規登録"
  }

  let lang_switch_html = case is_en {
    True ->
      "<div class=\"flex items-center text-xs font-mono border border-slate-200 rounded-lg p-0.5 bg-slate-100/80\">
         <a href=\"/compress\" class=\"px-2 py-1 text-slate-500 hover:text-slate-900 rounded transition-colors\">JA</a>
         <span class=\"px-2 py-1 bg-white font-bold text-brand-600 rounded shadow-xs\">EN</span>
       </div>"
    False ->
      "<div class=\"flex items-center text-xs font-mono border border-slate-200 rounded-lg p-0.5 bg-slate-100/80\">
         <span class=\"px-2 py-1 bg-white font-bold text-brand-600 rounded shadow-xs\">JA</span>
         <a href=\"/compress/en\" class=\"px-2 py-1 text-slate-500 hover:text-slate-900 rounded transition-colors\">EN</a>
       </div>"
  }

  let hero_badge = case is_en {
    True -> "World's First Gleam / BEAM Commercial Cluster"
    False -> "国内初・Gleam / BEAM商用稼働クラスター"
  }

  let hero_h1 = case is_en {
    True ->
      "RFC 1951 Compatible,<br class=\"hidden sm:inline\" />
      <span class=\"text-transparent bg-clip-text bg-gradient-to-r from-brand-500 to-sky-500\">High-Density Entropy Compression</span>"
    False ->
      "Zip / Gzip 互換、<br class=\"hidden sm:inline\" />
      <span class=\"text-transparent bg-clip-text bg-gradient-to-r from-brand-500 to-sky-500\">超高密度エントロピー圧縮</span>"
  }

  let hero_desc = case is_en {
    True ->
      "Approaching the theoretical limits of RFC 1951. Our proprietary multidimensional geometric solver finds global optima for LZ77 matches and dynamic Huffman partitioning, slashing an extra 20–30% from standard gzip archives."
    False ->
      "RFC 1951規格の理論限界へ。独自の多次元幾何学ソルバーが、最長一致とハフマン木ブロック分割の最適解を導出し、いつものgzipをさらに10〜20%削ぎ落とします。"
  }

  let hero_cta_playground = case is_en {
    True -> "Register Now"
    False -> "利用者登録へ"
  }

  let hero_cta_curl = case is_en {
    True -> "View curl API"
    False -> "curl APIを確認"
  }

  let killer_copy_title = case is_en {
    True -> "Zstd-level compression, 0-second decompression with standard gzip."
    False -> "Zstd並に小さく、解凍は標準gzipで0秒。"
  }

  let killer_copy_body = case is_en {
    True ->
      "Never force custom decompression binaries onto your clients. Standard OS tools and browsers unpack it instantly. Cut 20–30% off your monthly AWS Egress bills directly."
    False ->
      "相手システムに専用解凍ソフトを求めず、ブラウザや標準コマンドですぐ解凍。AWS Egress（データ転送量）請求書から直接コストを削ぎ落とします。"
  }

  let pg_title = case is_en {
    True -> "Web Playground"
    False -> "Web Playground"
  }

  let pg_subtitle = case is_en {
    True -> "Drop your local file to benchmark Q-Deflate in browser right now (Up to 10MB)"
    False -> "手元のファイルをドロップして、Q-Deflateの圧縮率を今すぐブラウザで体験（最大10MB）"
  }

  let pg_no_signup = case is_en {
    True -> "No Signup Required"
    False -> "登録不要"
  }

  let pg_drop_label = case is_en {
    True -> "Drag & drop file or folder here"
    False -> "ファイルまたはフォルダをドラッグ＆ドロップ"
  }

  let pg_supported = case is_en {
    True -> "Supported: JSON, CSV, Logs, Text, JS, CSS, SVG, or whole directories"
    False -> "対応: JSON, CSV, ログ, テキスト, JS, CSS, またはフォルダ丸ごと"
  }

  let pg_btn = case is_en {
    True -> "Execute Q-Deflate Compression"
    False -> "Q-Deflate で圧縮を実行する"
  }

  let pg_spinner = case is_en {
    True -> "Geometric solver is searching optimal entropy blocks..."
    False -> "多次元幾何学ソルバーが最適ブロックを探索中..."
  }

  let bench_heading = case is_en {
    True -> "Quantitative Benchmark & Compatibility"
    False -> "圧縮率・互換性の定量的比較"
  }

  let bench_sub = case is_en {
    True -> "The only option that delivers extreme compaction without client friction"
    False -> "「小ささ」と「受け取り側の手軽さ」を両立する唯一の選択肢"
  }

  let th_method = case is_en {
    True -> "Compression Method"
    False -> "圧縮方式"
  }

  let th_size = case is_en {
    True -> "Data Size (1GB raw basis)"
    False -> "データサイズ (1GB生データ換算)"
  }

  let th_savings = case is_en {
    True -> "Added Savings vs Gzip"
    False -> "対Gzip追加削減率"
  }

  let th_decomp = case is_en {
    True -> "Client Decompressor"
    False -> "クライアント側解凍環境"
  }

  let th_notes = case is_en {
    True -> "Compatibility & Characteristics"
    False -> "特徴・互換性"
  }

  let row_raw_label = case is_en {
    True -> "Raw Data (JSON, Logs, etc.)"
    False -> "生データ (JSON / ログ等)"
  }

  let row_raw_decomp = case is_en {
    True -> "None"
    False -> "不要"
  }

  let row_raw_notes = case is_en {
    True -> "Egress transfer cost is maximized"
    False -> "転送量（Egress）コストが最大化"
  }

  let row_gzip_label = case is_en {
    True -> "Standard Gzip (Level 6)"
    False -> "標準 Gzip (Level 6)"
  }

  let row_gzip_decomp = case is_en {
    True -> "Standard (0s)"
    False -> "標準搭載 (0秒)"
  }

  let row_gzip_notes = case is_en {
    True -> "Real-time compromise mode. Entropy gaps left unoptimized."
    False -> "速度重視のリアルタイム用設定。無駄な隙間が残る"
  }

  let row_zstd_label = case is_en {
    True -> "Zstandard (Zstd Level 19)"
    False -> "Zstandard (Zstd Level 19)"
  }

  let row_zstd_decomp = case is_en {
    True -> "Custom lib required"
    False -> "専用ライブラリ必須"
  }

  let row_zstd_notes = case is_en {
    True -> "Small size, but fails on clients without Zstd runtime."
    False -> "極めて小さいが、相手側クライアントが非対応で詰まる"
  }

  let row_qdf_label = case is_en {
    True -> "Q-Deflate (Our Service)"
    False -> "Q-Deflate (当サービス)"
  }

  let row_qdf_savings = case is_en {
    True -> "▼ ~30% Less!"
    False -> "▼ 約 30% カット!"
  }

  let row_qdf_decomp = case is_en {
    True -> "Standard (0s!)"
    False -> "標準搭載 (0秒!)"
  }

  let row_qdf_notes = case is_en {
    True -> "100% RFC 1951 compliant. Clients unpack with standard gzip instantly!"
    False -> "RFC 1951完全互換。相手は標準gzipで即解凍可能！"
  }

  let row_gzip_size = case is_en {
    True -> "250 MB (~25%)"
    False -> "250 MB (約 25%)"
  }

  let row_zstd_size = case is_en {
    True -> "180 MB (~18%)"
    False -> "180 MB (約 18%)"
  }

  let row_qdf_size = case is_en {
    True -> "175 MB (~17.5%)"
    False -> "175 MB (約 17.5%)"
  }

  let why_badge = "Why Q-Deflate"

  let why_title = case is_en {
    True -> "Why Standard Gzip (Level 6) Leaves Money on the Table"
    False -> "なぜ標準Gzip（Level 6）ではいけないのか？"
  }

  let why_card1_title = case is_en {
    True -> "~30% Net Egress Reduction vs Gzip"
    False -> "Gzip比でさらに「約30%」純減"
  }

  let why_card1_body = case is_en {
    True ->
      "The leap from 25% to 17.5% is not minor. It means **cutting an additional 30% of bytes after standard gzip is already finished**. If you distribute 10TB/month, you instantly save ~750GB of egress and S3 billing."
    False ->
      "「25%」から「17.5%」への差は、生データ基準のわずかな差ではありません。<strong>『標準Gzipで圧縮しきった状態から、さらに約3割のデータ転送量を削ぎ落とす』</strong>ことを意味します。月間10TBの配信なら、毎月約750GB分のEgress費用とS3料金がそのまま浮きます。"
  }

  let why_card2_title = case is_en {
    True -> "Asymmetric 1-to-N Delivery Leverage"
    False -> "「1対N配信」の圧倒的非対称性"
  }

  let why_card2_body = case is_en {
    True ->
      "Standard gzip is configured for live server response speed. But CI/CD caches, JS bundles, and static assets follow: **Compress once, decompress millions of times**. We invest deep geometric compute once; your users unpack in 0 seconds everywhere."
    False ->
      "標準GzipはWebサーバーが通信の瞬間に返すための<strong>「速度妥協設定」</strong>です。しかしCI/CDキャッシュや配信アセットは<strong>『圧縮は1回、解凍は何万回・何億回』</strong>。圧縮に幾何学最適化をかけて極限まで絞り尽くしても、<strong>受け手側は世界中すべてのOS・ブラウザでCPU負荷ゼロ・0秒解凍</strong>できます。"
  }

  let why_card3_title = case is_en {
    True -> "Bypassing the Zstd Compatibility Barrier"
    False -> "Zstdの「互換性の壁」を完全突破"
  }

  let why_card3_body = case is_en {
    True ->
      "Zstd is powerful, but forces every client and downstream pipeline to install non-standard runtimes. Q-Deflate packs entropy to the limit **inside RFC 1951 standard specification**. You gain Zstd-tier payload size with zero client friction."
    False ->
      "Zstandardは高圧縮ですが、相手先クライアントすべてに専用ライブラリのインストールを強要します。Q-Deflateは<strong>RFC 1951（標準gzip）の規格枠内で限界までエントロピーを最密充填</strong>するため、相手に一切のツール導入を求めず、既存のインフラのままZstd級のサイズを享受できます。"
  }

  let why_conclusion = case is_en {
    True -> "<strong>Conclusion:</strong> World-class density without distributing flame-throwers (custom decoders); standard scissors (gzip) unpack it instantly."
    False -> "<strong>結論:</strong> 相手に火炎放射器（専用解凍ツール）を配らず、ハサミ（標準gzip）で0秒解凍できる世界最強の圧縮。"
  }

  let why_cta = case is_en {
    True -> "Experience on Playground now →"
    False -> "今すぐPlaygroundで体感する →"
  }

  let arch_h2 = case is_en {
    True -> "Cut AWS Egress by 20–30% with 1-to-N Leverage"
    False -> "1対N配信レバレッジでAWS Egressを20〜30%削減"
  }

  let arch_sub = case is_en {
    True -> "Compress once at build time. ROI scales automatically with every download."
    False -> "圧縮コストは1回だけ。配信すればするほど元が取れる投資対効果（ROI）"
  }

  let uc1_title = case is_en {
    True -> "CI/CD Build & Web Asset Delivery"
    False -> "CI/CD ビルド＆アセット配信"
  }

  let uc1_desc = case is_en {
    True -> "Pre-compress JSON/JS/CSS bundles with Q-Deflate before deploying to S3/Cloudflare. Slash global egress transfer fees permanently."
    False -> "デプロイ直前のビルド成果物（JSON/JS/CSS）をQ-Deflateで一度極限まで充填。世界中のユーザーへの配信転送量を永続的に削減します。"
  }

  let uc2_title = case is_en {
    True -> "Massive Log & Backup Archival"
    False -> "巨大ログ・バックアップ保管"
  }

  let uc2_desc = case is_en {
    True -> "Shrink cold archive volumes on S3 Glacier or GCS, while reducing query scan transfer costs in BigQuery and Athena."
    False -> "S3やGCSへアーカイブ保管する際のストレージ料金と、Athena/BigQueryへ転送する際のネットワーク費用を確実に圧縮します。"
  }

  let uc3_title = case is_en {
    True -> "AI Agent Context & Payload Optimization"
    False -> "AIエージェントのコンテキスト節約"
  }

  let uc3_desc = case is_en {
    True -> "Compress scraped corpus and web memory before feeding into LLM pipelines. Save both token billing and network roundtrip time."
    False -> "WebスクレイピングデータやナレッジをLLMへ供給する直前に極小化。入力トークン消費とレイテンシをダブルで削減します。"
  }

  let pricing_heading = case is_en {
    True -> "Simple, Transparent Pricing"
    False -> "シンプルで透明な料金プラン"
  }

  let pricing_sub = case is_en {
    True -> "Pay only for what you compress. No surprise egress charges. Standard corporate expense friendly."
    False -> "圧縮処理したデータ量だけの従量課金。経費精算しやすい安心の買い切り・月額プラン"
  }

  let price_free_title = case is_en {
    True -> "Free Sandbox"
    False -> "無料お試し"
  }

  let price_free_desc = case is_en {
    True -> "Instant testing via Web Playground"
    False -> "Web上で今すぐ無制限に体験"
  }

  let price_starter_title = case is_en {
    True -> "Starter Charge"
    False -> "スターターチャージ"
  }

  let price_starter_desc = case is_en {
    True -> "Prepaid +100 GB balance (No expiry)"
    False -> "100GB買い切り残高（有効期限なし）"
  }

  let price_standard_title = case is_en {
    True -> "Standard Volume"
    False -> "スタンダードチャージ"
  }

  let price_standard_desc = case is_en {
    True -> "Prepaid +550 GB (+10% free bonus)"
    False -> "550GB買い切り（50GB無料ボーナス付）"
  }

  let price_pro_title = case is_en {
    True -> "Pro Monthly"
    False -> "プロ月額サブスク"
  }

  let price_pro_desc = case is_en {
    True -> "500 GB / mo included + Priority Node"
    False -> "月500GB込み ＋ 優先クラスタノード"
  }

  let btn_get_started = case is_en {
    True -> "Get Started Free"
    False -> "無料で始める"
  }

  let btn_purchase = case is_en {
    True -> "Sign Up & Purchase"
    False -> "登録してチャージ"
  }

  let footer_free = case is_en {
    True -> "1GB / month free"
    False -> "月1GBまで無料"
  }

  let footer_contact_title = case is_en {
    True -> "Support & Inquiries"
    False -> "サポート・お問い合わせ"
  }

  let footer_legal_title = case is_en {
    True -> "Commercial Disclosure"
    False -> "特定商取引法に基づく表記・運営者情報"
  }

  let footer_entity_label = case is_en {
    True -> "Entity / Operator"
    False -> "事業者・運営責任者"
  }

  let footer_entity_val = case is_en {
    True -> "Microforce Project (Gen Nishizumi)"
    False -> "Microforce Project (西住 玄)"
  }

  let footer_payment_label = case is_en {
    True -> "Payment Methods"
    False -> "支払方法"
  }

  let footer_payment_val = case is_en {
    True -> "Credit Cards (Stripe Checkout)"
    False -> "クレジットカード (Stripe Checkout)"
  }

  let footer_refund_label = case is_en {
    True -> "Refund Policy"
    False -> "返金・キャンセル"
  }

  let footer_refund_val = case is_en {
    True -> "Instant digital credit delivery; top-ups are non-refundable."
    False -> "デジタルクレジットの即時付与特性上、チャージ完了後の返金は致しかねます。"
  }

  let playground_endpoint = case is_en {
    True -> "/compress/try?lang=en"
    False -> "/compress/try?lang=ja"
  }

  "<!DOCTYPE html>
<html lang=\"" <> html_lang <> "\" class=\"scroll-smooth\">
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>" <> page_title <> "</title>
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
</head>
<body class=\"bg-slate-50 text-slate-800 font-sans antialiased selection:bg-brand-500 selection:text-white\">

  <!-- 1. ナビゲーションバー (DigitalOcean風・清潔な白背景＋極細ボーダー) -->
  <header class=\"sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-slate-200\">
    <div class=\"max-w-6xl mx-auto px-6 h-16 flex items-center justify-between\">
      <div class=\"flex items-center space-x-3\">
        <div class=\"w-8 h-8 rounded bg-brand-500 flex items-center justify-center text-white font-mono font-bold text-lg shadow-sm shadow-brand-500/30\">
          Q
        </div>
        <span class=\"font-mono font-bold text-xl tracking-tight text-slate-900\">Q-Deflate</span>
        <span class=\"hidden sm:inline-block px-2 py-0.5 text-xs font-medium bg-brand-50 text-brand-700 border border-brand-100 rounded-full\">RFC 1951 Compatible</span>
      </div>
      <nav class=\"flex items-center space-x-4 sm:space-x-6 text-sm font-medium text-slate-600\">
        <a href=\"#benchmark\" class=\"hover:text-brand-500 transition-colors hidden sm:inline-block\">" <> nav_benchmark <> "</a>
        <a href=\"#architecture\" class=\"hover:text-brand-500 transition-colors hidden sm:inline-block\">" <> nav_how_it_works <> "</a>
        <a href=\"#pricing\" class=\"hover:text-brand-500 transition-colors hidden sm:inline-block\">" <> nav_pricing <> "</a>
        " <> lang_switch_html <> "
        <a href=\"/dashboard\" class=\"text-sm font-semibold text-slate-700 hover:text-brand-600 transition-colors flex items-center space-x-1 px-2.5 py-1.5 rounded-lg border border-slate-200 hover:border-brand-500 hover:bg-brand-50/50\">
          <span>📊</span>
          <span>Dashboard</span>
        </a>
        <a href=\"/login\" class=\"inline-flex items-center justify-center px-4 py-2 text-sm font-semibold text-white bg-brand-500 hover:bg-brand-600 rounded-lg shadow-sm shadow-brand-500/20 transition-all hover:scale-[1.02] active:scale-[0.98]\">
          " <> nav_cta <> "
        </a>
      </nav>
    </div>
  </header>

  <!-- 2. ヒーローセクション (看板・サブタイトル・理論的証明コピー) -->
  <section class=\"pt-20 pb-16 px-6 text-center max-w-4xl mx-auto\">
    <div class=\"inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-slate-100 border border-slate-200 text-xs font-mono text-slate-600 mb-8\">
      <span class=\"w-2 h-2 rounded-full bg-emerald-500 animate-pulse\"></span>
      <span>" <> hero_badge <> "</span>
    </div>
    <h1 class=\"text-4xl sm:text-5xl lg:text-6xl font-extrabold text-slate-950 tracking-tight leading-[1.15] mb-6\">
      " <> hero_h1 <> "
    </h1>
    <p class=\"text-lg sm:text-xl text-slate-600 leading-relaxed mb-10 max-w-2xl mx-auto font-normal\">
      " <> hero_desc <> "
    </p>

    <!-- クイックコールトゥアクション -->
    <div class=\"flex flex-col sm:flex-row items-center justify-center gap-4\">
      <a href=\"#playground\" class=\"w-full sm:w-auto px-8 py-3.5 text-base font-semibold text-white bg-brand-500 hover:bg-brand-600 rounded-lg shadow-lg shadow-brand-500/25 transition-all hover:-translate-y-0.5\">
        " <> hero_cta_playground <> "
      </a>
      <a href=\"#curl-sample\" class=\"w-full sm:w-auto px-6 py-3.5 text-base font-mono font-medium text-slate-700 bg-white hover:bg-slate-100 border border-slate-200 rounded-lg transition-colors flex items-center justify-center space-x-2\">
        <span>" <> hero_cta_curl <> "</span>
      </a>
    </div>

    <!-- キラーコピー（エビデンス） -->
    <div class=\"mt-12 p-4 rounded-xl bg-brand-50/60 border border-brand-100 max-w-xl mx-auto text-left flex items-start space-x-3\">
      <div class=\"text-brand-500 mt-0.5 text-lg\">⚡</div>
      <p class=\"text-xs sm:text-sm text-brand-900 leading-relaxed font-medium\">
        <strong>" <> killer_copy_title <> "</strong><br>
        " <> killer_copy_body <> "
      </p>
    </div>
  </section>

  <!-- 3. Web Playground & Dropzone (人間用ブラウザ即時圧縮＆ダウンロード) -->
  <section id=\"playground\" class=\"py-12 px-6 max-w-3xl mx-auto scroll-mt-20\">
    <div class=\"bg-white rounded-2xl border border-slate-200 p-8 shadow-xl shadow-slate-200/50\">
      <div class=\"flex items-center justify-between mb-6\">
        <div>
          <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2\">
            <span>📁</span>
            <span>" <> pg_title <> "</span>
          </h2>
          <p class=\"text-xs text-slate-500 mt-1\">" <> pg_subtitle <> "</p>
        </div>
        <span class=\"px-2.5 py-1 text-xs font-mono font-medium bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-md\">
          " <> pg_no_signup <> "
        </span>
      </div>

      <!-- ドロップゾーン (HTMX & Native JS 連携) -->
      <div id=\"playground-dropzone\"
           class=\"relative border-2 border-dashed border-slate-200 hover:border-brand-500 rounded-xl p-8 sm:p-12 text-center transition-colors bg-slate-50/50 hover:bg-brand-50/30 cursor-pointer group\">
        
        <input type=\"file\" id=\"pg-file-input\" class=\"hidden\" onchange=\"handlePgFileSelect(this.files)\">
        <input type=\"file\" id=\"pg-folder-input\" class=\"hidden\" webkitdirectory directory multiple onchange=\"handlePgFolderSelect(this.files)\">
        
        <div id=\"pg-prompt\" class=\"space-y-4\">
          <div class=\"w-12 h-12 rounded-full bg-brand-50 group-hover:bg-brand-100 text-brand-500 mx-auto flex items-center justify-center text-xl transition-colors\">
            ☁️
          </div>
          <div>
            <p id=\"pg-label\" class=\"text-sm font-semibold text-slate-700 group-hover:text-brand-600 transition-colors\">
              " <> pg_drop_label <> "
            </p>
            <p class=\"text-xs text-slate-400 mt-1 font-mono\">
              " <> pg_supported <> "
            </p>
          </div>
          <div class=\"flex items-center justify-center space-x-3 pt-2\">
            <button type=\"button\" onclick=\"event.stopPropagation(); document.getElementById('pg-file-input').click()\"
                    class=\"px-3.5 py-1.5 bg-white hover:bg-slate-100 text-slate-700 text-xs font-semibold rounded-lg shadow-2xs border border-slate-200 transition-colors flex items-center space-x-1.5\">
              <span>📄</span>
              <span>" <> case is_en { True -> "Browse File" False -> "ファイル選択" } <> "</span>
            </button>
            <span class=\"text-xs text-slate-300\">or</span>
            <button type=\"button\" onclick=\"event.stopPropagation(); triggerPgFolderPicker(event)\"
                    class=\"px-3.5 py-1.5 bg-brand-50 hover:bg-brand-100 text-brand-700 text-xs font-semibold rounded-lg border border-brand-200 transition-colors flex items-center space-x-1.5\">
              <span>📁</span>
              <span>" <> case is_en { True -> "Browse Folder" False -> "フォルダ選択" } <> "</span>
            </button>
          </div>
        </div>

        <!-- 選択時の情報表示 -->
        <div id=\"pg-file-info\" class=\"hidden space-y-4\">
          <div class=\"inline-flex items-center space-x-2 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs font-mono text-slate-700 shadow-2xs\">
            <span id=\"pg-fileicon\">📄</span>
            <span id=\"pg-filename\" class=\"font-bold\">data.json</span>
            <span id=\"pg-filesize\" class=\"text-slate-400\">(1.2 MB)</span>
          </div>
          <div>
            <button type=\"button\" id=\"pg-submit-btn\" onclick=\"startPgCompression(event)\"
                    class=\"px-6 py-2.5 text-xs font-bold text-white bg-brand-500 hover:bg-brand-600 rounded-lg shadow-md shadow-brand-500/25 transition-all hover:scale-105 active:scale-95\">
              " <> pg_btn <> "
            </button>
          </div>
        </div>
      </div>

      <!-- スピナー (処理中インジケータ) -->
      <div id=\"compress-spinner\" class=\"htmx-indicator mt-6 text-center py-4\">
        <div class=\"inline-flex items-center space-x-2 text-sm font-medium text-brand-600 font-mono\">
          <svg class=\"animate-spin h-5 w-5 text-brand-500\" xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\">
            <circle class=\"opacity-25\" cx=\"12\" cy=\"12\" r=\"10\" stroke=\"currentColor\" stroke-width=\"4\"></circle>
            <path class=\"opacity-75\" fill=\"currentColor\" d=\"M4 12a8 8 0 018-8v8H4z\"></path>
          </svg>
          <span>" <> pg_spinner <> "</span>
        </div>
      </div>

      <!-- 結果表示エリア (htmxで差し替え) -->
      <div id=\"playground-result\" class=\"mt-6\">
        <!-- 初回は空 -->
      </div>
    </div>
  </section>

  <!-- 4. 定量的ベンチマーク比較表 (対生データ / Gzip / Zstd) -->
  <section id=\"benchmark\" class=\"py-16 px-6 max-w-5xl mx-auto scroll-mt-20\">
    <div class=\"text-center mb-10\">
      <h2 class=\"text-2xl sm:text-3xl font-bold text-slate-900\">" <> bench_heading <> "</h2>
      <p class=\"text-sm text-slate-500 mt-2\">" <> bench_sub <> "</p>
    </div>

    <!-- 比較表 -->
    <div class=\"overflow-x-auto bg-white rounded-xl border border-slate-200 shadow-sm mb-10\">
      <table class=\"w-full text-left text-sm border-collapse\">
        <thead>
          <tr class=\"bg-slate-50 border-b border-slate-200 text-xs font-mono text-slate-500\">
            <th class=\"py-3.5 px-6 font-semibold\">" <> th_method <> "</th>
            <th class=\"py-3.5 px-4 font-semibold text-center\">" <> th_size <> "</th>
            <th class=\"py-3.5 px-4 font-semibold text-center\">" <> th_savings <> "</th>
            <th class=\"py-3.5 px-6 font-semibold\">" <> th_decomp <> "</th>
            <th class=\"py-3.5 px-6 font-semibold\">" <> th_notes <> "</th>
          </tr>
        </thead>
        <tbody class=\"divide-y divide-slate-100 text-slate-700\">
          <tr>
            <td class=\"py-4 px-6 font-medium text-slate-900\">" <> row_raw_label <> "</td>
            <td class=\"py-4 px-4 text-center font-mono font-bold\">1,000 MB (100%)</td>
            <td class=\"py-4 px-4 text-center font-mono text-slate-400\">-</td>
            <td class=\"py-4 px-6 text-slate-400\">" <> row_raw_decomp <> "</td>
            <td class=\"py-4 px-6 text-rose-600 text-xs font-medium\">" <> row_raw_notes <> "</td>
          </tr>
          <tr>
            <td class=\"py-4 px-6 font-medium text-slate-900\">" <> row_gzip_label <> "</td>
            <td class=\"py-4 px-4 text-center font-mono font-semibold text-slate-700\">" <> row_gzip_size <> "</td>
            <td class=\"py-4 px-4 text-center font-mono text-slate-500\">±0%</td>
            <td class=\"py-4 px-6 text-emerald-600 font-medium\">" <> row_gzip_decomp <> "</td>
            <td class=\"py-4 px-6 text-xs text-slate-500\">" <> row_gzip_notes <> "</td>
          </tr>
          <tr>
            <td class=\"py-4 px-6 font-medium text-slate-900\">" <> row_zstd_label <> "</td>
            <td class=\"py-4 px-4 text-center font-mono font-semibold text-slate-700\">" <> row_zstd_size <> "</td>
            <td class=\"py-4 px-4 text-center font-mono text-emerald-600 font-semibold\">▼ 28%</td>
            <td class=\"py-4 px-6 text-rose-600 font-medium text-xs\">" <> row_zstd_decomp <> "</td>
            <td class=\"py-4 px-6 text-xs text-slate-500\">" <> row_zstd_notes <> "</td>
          </tr>
          <tr class=\"bg-brand-50/60 border-l-4 border-l-brand-500\">
            <td class=\"py-4 px-6 font-bold text-brand-900 flex items-center space-x-2\">
              <span class=\"text-brand-500\">★</span>
              <span>" <> row_qdf_label <> "</span>
            </td>
            <td class=\"py-4 px-4 text-center font-mono font-bold text-brand-700 text-base\">" <> row_qdf_size <> "</td>
            <td class=\"py-4 px-4 text-center font-mono font-bold text-brand-600 bg-brand-100/60 rounded py-1\">
              " <> row_qdf_savings <> "
            </td>
            <td class=\"py-4 px-6 text-emerald-700 font-bold flex items-center space-x-1\">
              <span>✓</span>
              <span>" <> row_qdf_decomp <> "</span>
            </td>
            <td class=\"py-4 px-6 text-xs text-brand-900 font-medium\">
              <strong>" <> row_qdf_notes <> "</strong>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 【重要解説】なぜ標準Gzipのままでは大損なのか？ Q-Deflateが圧倒的利点を持つ3つの理由 -->
    <div class=\"bg-slate-900 text-white rounded-2xl p-8 sm:p-10 shadow-xl border border-slate-800\">
      <div class=\"flex items-center space-x-3 mb-6\">
        <span class=\"px-3 py-1 text-xs font-mono font-bold uppercase tracking-wider bg-brand-500 text-white rounded-md\">" <> why_badge <> "</span>
        <h3 class=\"text-xl sm:text-2xl font-bold tracking-tight text-white\">" <> why_title <> "</h3>
      </div>

      <div class=\"grid grid-cols-1 md:grid-cols-3 gap-6 text-sm text-slate-300 leading-relaxed\">
        
        <!-- 利点 1 -->
        <div class=\"bg-slate-800/80 rounded-xl p-5 border border-slate-700/60\">
          <div class=\"text-brand-400 font-mono font-bold text-base mb-2 flex items-center space-x-2\">
            <span>01</span>
            <span>" <> why_card1_title <> "</span>
          </div>
          <p class=\"text-xs sm:text-sm text-slate-300\">
            " <> why_card1_body <> "
          </p>
        </div>

        <!-- 利点 2 -->
        <div class=\"bg-slate-800/80 rounded-xl p-5 border border-slate-700/60\">
          <div class=\"text-brand-400 font-mono font-bold text-base mb-2 flex items-center space-x-2\">
            <span>02</span>
            <span>" <> why_card2_title <> "</span>
          </div>
          <p class=\"text-xs sm:text-sm text-slate-300\">
            " <> why_card2_body <> "
          </p>
        </div>

        <!-- 利点 3 -->
        <div class=\"bg-slate-800/80 rounded-xl p-5 border border-slate-700/60\">
          <div class=\"text-brand-400 font-mono font-bold text-base mb-2 flex items-center space-x-2\">
            <span>03</span>
            <span>" <> why_card3_title <> "</span>
          </div>
          <p class=\"text-xs sm:text-sm text-slate-300\">
            " <> why_card3_body <> "
          </p>
        </div>

      </div>

      <!-- ひと目でわかる結論バー -->
      <div class=\"mt-8 pt-6 border-t border-slate-800 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs sm:text-sm\">
        <div class=\"flex items-center space-x-2 text-slate-300 font-medium\">
          <span class=\"text-emerald-400 text-base\">✓</span>
          <span>" <> why_conclusion <> "</span>
        </div>
        <a href=\"#playground\" class=\"font-semibold text-brand-400 hover:text-brand-300 transition-colors inline-flex items-center space-x-1\">
          <span>" <> why_cta <> "</span>
        </a>
      </div>
    </div>
  </section>

  <!-- 5. アーキテクチャ ＆ 1対N配信レバレッジ図解 -->
  <section id=\"architecture\" class=\"py-16 px-6 max-w-5xl mx-auto border-t border-slate-200/80 scroll-mt-20\">
    <div class=\"text-center mb-12\">
      <h2 class=\"text-2xl sm:text-3xl font-bold text-slate-900\">" <> arch_h2 <> "</h2>
      <p class=\"text-sm text-slate-500 mt-2\">" <> arch_sub <> "</p>
    </div>

    <div class=\"grid grid-cols-1 md:grid-cols-3 gap-6 mb-12\">
      <div class=\"bg-white p-6 rounded-xl border border-slate-200 shadow-sm\">
        <div class=\"text-brand-500 font-mono text-xs font-bold mb-2\">USE CASE 01</div>
        <h3 class=\"font-bold text-slate-900 mb-2\">" <> uc1_title <> "</h3>
        <p class=\"text-xs text-slate-600 leading-relaxed\">
          " <> uc1_desc <> "
        </p>
      </div>

      <div class=\"bg-white p-6 rounded-xl border border-slate-200 shadow-sm\">
        <div class=\"text-brand-500 font-mono text-xs font-bold mb-2\">USE CASE 02</div>
        <h3 class=\"font-bold text-slate-900 mb-2\">" <> uc2_title <> "</h3>
        <p class=\"text-xs text-slate-600 leading-relaxed\">
          " <> uc2_desc <> "
        </p>
      </div>

      <div class=\"bg-white p-6 rounded-xl border border-slate-200 shadow-sm\">
        <div class=\"text-brand-500 font-mono text-xs font-bold mb-2\">USE CASE 03</div>
        <h3 class=\"font-bold text-slate-900 mb-2\">" <> uc3_title <> "</h3>
        <p class=\"text-xs text-slate-600 leading-relaxed\">
          " <> uc3_desc <> "
        </p>
      </div>
    </div>

    <!-- 開発者向け curl 1行コードブロック -->
    <div id=\"curl-sample\" class=\"bg-slate-900 rounded-xl p-6 text-white shadow-xl max-w-2xl mx-auto\">
      <div class=\"flex items-center justify-between pb-3 mb-3 border-b border-slate-800 text-xs font-mono text-slate-400\">
        <span>CLI / CI Integration</span>
        <span class=\"text-emerald-400\">● HTTP API ready</span>
      </div>
      <pre class=\"font-mono text-xs sm:text-sm text-slate-200 overflow-x-auto leading-relaxed\"><code><span class=\"text-sky-400\">curl</span> -X POST https://api.qdeflate.io/v1/compress \\
     -H <span class=\"text-amber-300\">\"Authorization: Bearer $QDF_API_KEY\"</span> \\
     --data-binary @bundle.json -o bundle.json.gz</code></pre>
    </div>
  </section>

  <!-- 6. 料金プラン (Pricing & Plans) -->
  <section id=\"pricing\" class=\"py-20 px-6 max-w-6xl mx-auto border-t border-slate-200/80 scroll-mt-20\">
    <div class=\"text-center mb-16\">
      <h2 class=\"text-2xl sm:text-3xl font-bold text-slate-900 tracking-tight\">" <> pricing_heading <> "</h2>
      <p class=\"text-sm text-slate-500 mt-2 max-w-2xl mx-auto\">" <> pricing_sub <> "</p>
    </div>

    <div class=\"grid grid-cols-1 md:grid-cols-4 gap-6\">
      <!-- 0. Free Sandbox -->
      <div class=\"bg-white rounded-2xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between hover:border-slate-300 transition-colors\">
        <div>
          <span class=\"text-xs font-bold text-slate-500 uppercase tracking-wider font-mono\">" <> price_free_title <> "</span>
          <div class=\"text-3xl font-extrabold text-slate-900 mt-2\">¥0</div>
          <p class=\"text-xs text-slate-500 mt-1 font-mono\">" <> price_free_desc <> "</p>
          <ul class=\"mt-6 space-y-2.5 text-xs text-slate-600\">
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>Web D&D Playground</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>Up to 10MB per file</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>Instant .gz download</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>No account needed</span></li>
          </ul>
        </div>
        <a href=\"#playground\" class=\"mt-8 w-full py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-800 rounded-xl text-xs font-bold transition-colors block text-center\">
          " <> btn_get_started <> "
        </a>
      </div>

      <!-- 1. Starter Charge -->
      <div class=\"bg-white rounded-2xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between hover:border-brand-500/50 transition-colors\">
        <div>
          <span class=\"text-xs font-bold text-brand-600 uppercase tracking-wider font-mono\">" <> price_starter_title <> "</span>
          <div class=\"text-3xl font-extrabold text-slate-900 mt-2\">$7 <span class=\"text-xs font-normal text-slate-500 font-mono\">(~¥1,000)</span></div>
          <p class=\"text-xs text-slate-500 mt-1 font-mono\">" <> price_starter_desc <> "</p>
          <ul class=\"mt-6 space-y-2.5 text-xs text-slate-600\">
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>100 GB (100,000 MB)</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>~$0.07 per 1GB processed</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>No expiration date</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>FastMCP & REST API</span></li>
          </ul>
        </div>
        <a href=\"/login\" class=\"mt-8 w-full py-2.5 bg-slate-900 hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-colors block text-center shadow-xs\">
          " <> btn_purchase <> "
        </a>
      </div>

      <!-- 2. Standard Volume (Popular) -->
      <div class=\"bg-white rounded-2xl border-2 border-brand-500 p-6 shadow-lg shadow-brand-500/10 relative flex flex-col justify-between\">
        <span class=\"absolute -top-3 right-4 px-2.5 py-0.5 bg-brand-500 text-white rounded-full text-[10px] font-bold font-mono tracking-wide uppercase\">
          +10% Free Bonus
        </span>
        <div>
          <span class=\"text-xs font-bold text-brand-600 uppercase tracking-wider font-mono\">" <> price_standard_title <> "</span>
          <div class=\"text-3xl font-extrabold text-slate-900 mt-2\">$35 <span class=\"text-xs font-normal text-slate-500 font-mono\">(~¥5,000)</span></div>
          <p class=\"text-xs text-slate-500 mt-1 font-mono\">" <> price_standard_desc <> "</p>
          <ul class=\"mt-6 space-y-2.5 text-xs text-slate-600\">
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>550 GB (550,000 MB)</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>50GB free bonus included</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>Priority queue</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-emerald-500 font-bold\">✓</span> <span>Automated receipts & invoices</span></li>
          </ul>
        </div>
        <a href=\"/login\" class=\"mt-8 w-full py-2.5 bg-brand-600 hover:bg-brand-700 text-white rounded-xl text-xs font-bold transition-colors block text-center shadow-md shadow-brand-500/20\">
          " <> btn_purchase <> "
        </a>
      </div>

      <!-- 3. Pro Monthly (Subscription) -->
      <div class=\"bg-white rounded-2xl border border-purple-200 p-6 shadow-xs flex flex-col justify-between hover:border-purple-400 transition-colors\">
        <div>
          <span class=\"text-xs font-bold text-purple-600 uppercase tracking-wider font-mono\">" <> price_pro_title <> "</span>
          <div class=\"text-3xl font-extrabold text-slate-900 mt-2\">$35 <span class=\"text-xs font-normal text-slate-500 font-mono\">/ mo (~¥5,000)</span></div>
          <p class=\"text-xs text-slate-500 mt-1 font-mono\">" <> price_pro_desc <> "</p>
          <ul class=\"mt-6 space-y-2.5 text-xs text-slate-600\">
            <li class=\"flex items-center space-x-2\"><span class=\"text-purple-500 font-bold\">✓</span> <span>500 GB included / month</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-purple-500 font-bold\">✓</span> <span>Giga-scale single file</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-purple-500 font-bold\">✓</span> <span>Dedicated cluster node</span></li>
            <li class=\"flex items-center space-x-2\"><span class=\"text-purple-500 font-bold\">✓</span> <span>Direct Slack/Discord channel</span></li>
          </ul>
        </div>
        <a href=\"/login\" class=\"mt-8 w-full py-2.5 bg-purple-600 hover:bg-purple-700 text-white rounded-xl text-xs font-bold transition-colors block text-center shadow-md shadow-purple-500/20\">
          " <> btn_purchase <> "
        </a>
      </div>
    </div>
  </section>

  <!-- 7. フッター（サポート窓口・特定商取引法に基づく表記） -->
  <footer class=\"py-12 px-6 border-t border-slate-200 bg-white text-xs text-slate-500\">
    <div class=\"max-w-6xl mx-auto space-y-8\">
      <!-- 上段: ナビゲーション & お問い合わせ -->
      <div class=\"flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6 pb-6 border-b border-slate-100\">
        <div class=\"space-y-1\">
          <div class=\"flex items-center space-x-2 font-mono\">
            <span class=\"font-bold text-slate-800 text-sm\">Q-Deflate</span>
            <span class=\"text-slate-400\">— RFC 1951 Compatible High-Density Compression</span>
          </div>
          <div class=\"text-[11px] text-slate-500\">
            <span>" <> footer_contact_title <> ": </span>
            <a href=\"mailto:support@microforce.dev\" class=\"font-mono font-medium text-blue-600 hover:underline\">support@microforce.dev</a>
          </div>
        </div>
        <div class=\"flex flex-wrap items-center gap-6 text-slate-500 text-xs font-mono\">
          <a href=\"#playground\" class=\"hover:text-slate-900 transition-colors\">Web Playground</a>
          <a href=\"/dashboard\" class=\"hover:text-slate-900 transition-colors\">Dashboard</a>
          <a href=\"/login\" class=\"hover:text-slate-900 transition-colors\">Sign In</a>
          <a href=\"/privacy\" class=\"hover:text-slate-900 transition-colors\">Privacy Policy</a>
          <span class=\"px-2 py-0.5 rounded bg-emerald-50 text-emerald-700 border border-emerald-200\">" <> footer_free <> "</span>
        </div>
      </div>

      <!-- 下段: 特定商取引法に基づく表記 / Commercial Disclosure -->
      <div class=\"bg-slate-50 rounded-xl p-5 border border-slate-100 font-mono text-[11px] text-slate-500 space-y-2\">
        <div class=\"font-bold text-slate-700 uppercase tracking-wider text-[10px]\">" <> footer_legal_title <> "</div>
        <div class=\"grid grid-cols-1 md:grid-cols-2 gap-y-1.5 gap-x-6\">
          <div><span class=\"text-slate-400\">" <> footer_entity_label <> ":</span> <span class=\"text-slate-700 font-medium\">" <> footer_entity_val <> "</span></div>
          <div><span class=\"text-slate-400\">Email:</span> <a href=\"mailto:support@microforce.dev\" class=\"text-blue-600 hover:underline\">support@microforce.dev</a></div>
          <div><span class=\"text-slate-400\">" <> footer_payment_label <> ":</span> <span class=\"text-slate-700\">" <> footer_payment_val <> "</span></div>
          <div><span class=\"text-slate-400\">" <> footer_refund_label <> ":</span> <span class=\"text-slate-700\">" <> footer_refund_val <> "</span></div>
        </div>
      </div>

      <!-- コピーライト -->
      <div class=\"text-center text-[11px] text-slate-400 font-mono\">
        &copy; 2026 Microforce Project. Built with Gleam &amp; Erlang/BEAM. All rights reserved.
      </div>
    </div>
  <script>
    let pgPayload = null;

    class PgSimpleTarBuilder {
      constructor() { this.records = []; }
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
          header.set(textEncoder.encode('0000644' + padNull), 100);
          header.set(textEncoder.encode('0000000' + padNull), 108);
          header.set(textEncoder.encode('0000000' + padNull), 116);
          const sizeStr = rec.data.length.toString(8).padStart(11, '0') + padNull;
          header.set(textEncoder.encode(sizeStr), 124);
          const mtimeStr = rec.mtime.toString(8).padStart(11, '0') + padNull;
          header.set(textEncoder.encode(mtimeStr), 136);
          header.set(textEncoder.encode('        '), 148);
          header[156] = 48;
          header.set(textEncoder.encode('ustar' + padNull + '00'), 257);
          let checksum = 0;
          for (let i = 0; i < 512; i++) checksum += header[i];
          const chkStr = checksum.toString(8).padStart(6, '0') + padNull + ' ';
          header.set(textEncoder.encode(chkStr), 148);
          blockParts.push(header);
          blockParts.push(rec.data);
          const remainder = rec.data.length % 512;
          if (remainder !== 0) blockParts.push(new Uint8Array(512 - remainder));
        }
        blockParts.push(new Uint8Array(1024));
        return new Blob(blockParts, { type: 'application/x-tar' });
      }
    }

    const pgDropzone = document.getElementById('playground-dropzone');
    if (pgDropzone) {
      pgDropzone.addEventListener('click', (e) => {
        if (e.target.tagName !== 'BUTTON' && !e.target.closest('button')) {
          document.getElementById('pg-file-input').click();
        }
      });
      ['dragenter', 'dragover'].forEach(name => {
        pgDropzone.addEventListener(name, (e) => {
          e.preventDefault(); e.stopPropagation();
          pgDropzone.classList.add('border-brand-500', 'bg-brand-50/20');
        }, false);
      });
      ['dragleave', 'drop'].forEach(name => {
        pgDropzone.addEventListener(name, (e) => {
          e.preventDefault(); e.stopPropagation();
          pgDropzone.classList.remove('border-brand-500', 'bg-brand-50/20');
        }, false);
      });
      pgDropzone.addEventListener('drop', async (e) => {
        const dt = e.dataTransfer;
        if (!dt) return;
        if (dt.items && dt.items.length > 0) {
          const item = dt.items[0];
          const entry = item.webkitGetAsEntry ? item.webkitGetAsEntry() : null;
          if (entry && entry.isDirectory) {
            await handlePgDirectoryEntry(entry);
            return;
          }
        }
        if (dt.files && dt.files.length > 0) {
          handlePgFileSelect(dt.files);
        }
      }, false);
    }

    async function handlePgDirectoryEntry(dirEntry) {
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
                if (!batch || batch.length === 0) resolve(results);
                else { results.push(...batch); readBatch(); }
              }, reject);
            }
            readBatch();
          });
          for (const sub of entries) await scanDir(sub, fullPath);
        }
      }
      await scanDir(dirEntry);
      let totalSize = 0;
      fileEntries.forEach(f => totalSize += f.file.size);

      pgPayload = {
        name: dirEntry.name + '.tar',
        displayName: dirEntry.name + '/',
        isFolder: true,
        count: fileEntries.length,
        totalSize: totalSize,
        getBlob: async () => {
          const tar = new PgSimpleTarBuilder();
          for (const item of fileEntries) {
            const buf = await item.file.arrayBuffer();
            tar.addFile(item.path, new Uint8Array(buf), Math.floor(item.file.lastModified / 1000));
          }
          return tar.build();
        }
      };

      document.getElementById('pg-prompt').classList.add('hidden');
      document.getElementById('pg-file-info').classList.remove('hidden');
      document.getElementById('pg-fileicon').textContent = '📁';
      document.getElementById('pg-filename').textContent = pgPayload.displayName;
      document.getElementById('pg-filesize').textContent = '(' + pgPayload.count + ' files, ' + (totalSize / 1024).toFixed(1) + ' KB)';
    }

    // File System Access API を使ったフォルダ選択（LP Playground用）
    // Linux の webkitdirectory 問題（GTKピッカーでフォルダが選択できない）を回避
    async function triggerPgFolderPicker(event) {
      event.stopPropagation();
      if (window.showDirectoryPicker) {
        try {
          const dirHandle = await window.showDirectoryPicker({ mode: 'read' });
          await handlePgDirectoryHandle(dirHandle);
        } catch(e) {
          // ユーザーがキャンセルした場合は何もしない
          if (e.name !== 'AbortError') console.error('フォルダ選択エラー:', e);
        }
      } else {
        // フォールバック（File System Access API 非対応ブラウザ）
        const fi = document.getElementById('pg-folder-input');
        fi.value = '';
        fi.click();
      }
    }

    // FileSystemDirectoryHandle を再帰スキャン（LP Playground用）
    async function handlePgDirectoryHandle(dirHandle) {
      document.getElementById('pg-prompt').classList.add('hidden');
      document.getElementById('compress-spinner').classList.remove('htmx-indicator');

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

      pgPayload = {
        name: dirHandle.name + '.tar',
        displayName: dirHandle.name + '/',
        isFolder: true,
        count: fileEntries.length,
        totalSize: totalSize,
        getBlob: async () => {
          const tar = new PgSimpleTarBuilder();
          for (const item of fileEntries) {
            const buf = await item.file.arrayBuffer();
            tar.addFile(item.path, new Uint8Array(buf), Math.floor(item.file.lastModified / 1000));
          }
          return tar.build();
        }
      };

      document.getElementById('compress-spinner').classList.add('htmx-indicator');
      document.getElementById('pg-file-info').classList.remove('hidden');
      document.getElementById('pg-fileicon').textContent = '📁';
      document.getElementById('pg-filename').textContent = pgPayload.displayName;
      document.getElementById('pg-filesize').textContent = '(' + fileEntries.length + ' files, ' + (totalSize / 1024).toFixed(1) + ' KB)';
    }

    function handlePgFolderSelect(files) {
      if (!files || files.length === 0) return;
      const fileList = Array.from(files);
      let totalSize = 0;
      fileList.forEach(f => totalSize += f.size);
      const firstPath = fileList[0].webkitRelativePath || fileList[0].name;
      const folderName = firstPath.split('/')[0] || 'archive';

      pgPayload = {
        name: folderName + '.tar',
        displayName: folderName + '/',
        isFolder: true,
        count: fileList.length,
        totalSize: totalSize,
        getBlob: async () => {
          const tar = new PgSimpleTarBuilder();
          for (const file of fileList) {
            const relPath = file.webkitRelativePath || file.name;
            const buf = await file.arrayBuffer();
            tar.addFile(relPath, new Uint8Array(buf), Math.floor(file.lastModified / 1000));
          }
          return tar.build();
        }
      };

      document.getElementById('pg-prompt').classList.add('hidden');
      document.getElementById('pg-file-info').classList.remove('hidden');
      document.getElementById('pg-fileicon').textContent = '📁';
      document.getElementById('pg-filename').textContent = pgPayload.displayName;
      document.getElementById('pg-filesize').textContent = '(' + pgPayload.count + ' files, ' + (totalSize / 1024).toFixed(1) + ' KB)';
    }

    function handlePgFileSelect(files) {
      if (!files || files.length === 0) return;
      const file = files[0];
      pgPayload = {
        name: file.name,
        displayName: file.name,
        isFolder: false,
        totalSize: file.size,
        getBlob: async () => file
      };
      document.getElementById('pg-prompt').classList.add('hidden');
      document.getElementById('pg-file-info').classList.remove('hidden');
      document.getElementById('pg-fileicon').textContent = '📄';
      document.getElementById('pg-filename').textContent = file.name;
      document.getElementById('pg-filesize').textContent = '(' + (file.size / 1024).toFixed(1) + ' KB)';
    }

    async function startPgCompression(e) {
      e.stopPropagation();
      if (!pgPayload) return;
      document.getElementById('pg-file-info').classList.add('hidden');
      document.getElementById('compress-spinner').classList.remove('htmx-indicator');

      try {
        const blob = await pgPayload.getBlob();
        const baseEndpoint = '" <> playground_endpoint <> "';
        const url = baseEndpoint + '&filename=' + encodeURIComponent(pgPayload.name);
        const res = await fetch(url, {
          method: 'POST',
          body: blob,
          headers: { 'Content-Type': 'application/octet-stream' }
        });
        const html = await res.text();
        document.getElementById('compress-spinner').classList.add('htmx-indicator');
        document.getElementById('pg-prompt').classList.remove('hidden');
        document.getElementById('playground-result').innerHTML = html;
        pgPayload = null;
      } catch (err) {
        alert('Compression failed: ' + err);
        document.getElementById('compress-spinner').classList.add('htmx-indicator');
        document.getElementById('pg-prompt').classList.remove('hidden');
      }
    }
  </script>
</body>
</html>"
}

/// Playground圧縮完了時の部分置換用HTML
pub fn render_playground_result(
  filename: String,
  orig_size: Int,
  comp_size: Int,
  download_id: String,
  lang: Lang,
) -> String {
  let orig_f = int_to_kb(orig_size)
  let comp_f = int_to_kb(comp_size)
  let ratio = case orig_size > 0 {
    True -> {
      let saved = orig_size - comp_size
      { saved * 100 } / orig_size
    }
    False -> 0
  }

  let is_en = case lang {
    En -> True
    Ja -> False
  }

  let status_text = case is_en {
    True -> "✓ Compression Finished"
    False -> "✓ 圧縮完了"
  }

  let orig_label = case is_en {
    True -> "Original: "
    False -> "元サイズ: "
  }

  let comp_label = case is_en {
    True -> "➔ Output: "
    False -> "➔ 圧縮後: "
  }

  let saved_badge = case is_en {
    True -> "▼ " <> int.to_string(ratio) <> "% Saved!"
    False -> "▼ " <> int.to_string(ratio) <> "% 削減!"
  }

  let dl_btn = case is_en {
    True -> "⬇️ Download .gz"
    False -> "⬇️ .gz をダウンロード"
  }

  "
    <div class=\"p-6 rounded-xl bg-emerald-50/60 border border-emerald-200 animate-fade-in\">
      <div class=\"flex flex-col sm:flex-row sm:items-center justify-between gap-4\">
        <div>
          <div class=\"flex items-center space-x-2\">
            <span class=\"text-emerald-600 font-bold text-base\">" <> status_text <> "</span>
            <span class=\"text-xs font-mono text-slate-600 font-semibold\">" <> filename <> "</span>
          </div>
          <p class=\"text-xs text-slate-500 mt-1 font-mono\">
            " <> orig_label <> "<span class=\"text-slate-700 font-semibold\">" <> orig_f <> " KB</span> 
            " <> comp_label <> "<span class=\"text-emerald-700 font-bold\">" <> comp_f <> " KB</span>
            <span class=\"ml-2 px-1.5 py-0.5 rounded bg-emerald-200/60 text-emerald-800 text-[11px] font-bold\">" <> saved_badge <> "</span>
          </p>
        </div>
        <div class=\"flex items-center space-x-2\">
          <a href=\"/compress/download/" <> download_id <> "?filename=" <> filename <> ".gz\" download=\"" <> filename <> ".gz\"
             class=\"inline-flex items-center justify-center px-4 py-2 text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 rounded-lg shadow-sm transition-all hover:scale-105 active:scale-95\">
            " <> dl_btn <> "
          </a>
        </div>
      </div>
    </div>
  "
}

fn int_to_kb(bytes: Int) -> String {
  let kb = bytes / 1024
  int.to_string(kb)
}
