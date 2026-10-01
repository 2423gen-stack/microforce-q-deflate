// Copyright (c) 2026 Gen Nishizumi (西住玄)
// SPDX-License-Identifier: MIT

//// Q-Deflate SaaS: プライバシーポリシー (Privacy Policy) 描画モジュール
//// 日本語 (JA) / 英語 (EN) バイリンガル対応
//// DigitalOcean風のクリーン＆テックデザイン

pub type Lang {
  Ja
  En
}

pub fn render_privacy(lang: Lang) -> String {
  let is_en = case lang {
    En -> True
    Ja -> False
  }

  let html_lang = case is_en {
    True -> "en"
    False -> "ja"
  }

  let page_title = case is_en {
    True -> "Privacy Policy · Q-Deflate"
    False -> "プライバシーポリシー · Q-Deflate"
  }

  let nav_back = case is_en {
    True -> "Back to Q-Deflate"
    False -> "トップページに戻る"
  }

  let lang_switch_html = case is_en {
    True ->
      "<div class=\"flex items-center text-xs font-mono border border-slate-200 rounded-lg p-0.5 bg-slate-100/80\">
         <a href=\"/privacy/ja\" class=\"px-2 py-1 text-slate-500 hover:text-slate-900 rounded transition-colors\">JA</a>
         <span class=\"px-2 py-1 bg-white font-bold text-brand-600 rounded shadow-xs\">EN</span>
       </div>"
    False ->
      "<div class=\"flex items-center text-xs font-mono border border-slate-200 rounded-lg p-0.5 bg-slate-100/80\">
         <span class=\"px-2 py-1 bg-white font-bold text-brand-600 rounded shadow-xs\">JA</span>
         <a href=\"/privacy\" class=\"px-2 py-1 text-slate-500 hover:text-slate-900 rounded transition-colors\">EN</a>
       </div>"
  }

  let header_badge = case is_en {
    True -> "Zero-Storage Guaranteed · Global Standard"
    False -> "ゼロストレージ保証 · グローバル基準"
  }

  let header_h1 = case is_en {
    True -> "Privacy Policy"
    False -> "プライバシーポリシー"
  }

  let effective_date = case is_en {
    True -> "Effective Date: October 1, 2026"
    False -> "施行日: 2026年10月1日"
  }

  let content_html = case is_en {
    True -> render_en_content()
    False -> render_ja_content()
  }

  "<!DOCTYPE html>
<html lang=\"" <> html_lang <> "\" class=\"scroll-smooth\">
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>" <> page_title <> "</title>
  <!-- Tailwind CSS CDN -->
  <script src=\"https://cdn.tailwindcss.com\"></script>
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

  <!-- 1. ナビゲーションバー -->
  <header class=\"sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-slate-200\">
    <div class=\"max-w-4xl mx-auto px-6 h-16 flex items-center justify-between\">
      <a href=\"/compress\" class=\"flex items-center space-x-3 group\">
        <div class=\"w-8 h-8 rounded bg-brand-500 flex items-center justify-center text-white font-mono font-bold text-lg shadow-sm shadow-brand-500/30 group-hover:bg-brand-600 transition-colors\">
          Q
        </div>
        <span class=\"font-mono font-bold text-xl tracking-tight text-slate-900 group-hover:text-brand-600 transition-colors\">Q-Deflate</span>
      </a>

      <div class=\"flex items-center space-x-4\">
        " <> lang_switch_html <> "
        <a href=\"/compress\" class=\"text-xs font-semibold text-slate-600 hover:text-brand-600 transition-colors flex items-center space-x-1.5 px-3 py-1.5 rounded-lg border border-slate-200 hover:border-brand-500 hover:bg-brand-50/50\">
          <span>←</span>
          <span>" <> nav_back <> "</span>
        </a>
      </div>
    </div>
  </header>

  <!-- 2. メインコンテンツ -->
  <main class=\"max-w-4xl mx-auto px-6 py-12\">
    <!-- ページ見出し -->
    <div class=\"border-b border-slate-200 pb-8 mb-10\">
      <div class=\"inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-brand-50 border border-brand-200 text-xs font-mono text-brand-700 mb-4\">
        <span class=\"w-2 h-2 rounded-full bg-brand-500\"></span>
        <span>" <> header_badge <> "</span>
      </div>
      <h1 class=\"text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight\">" <> header_h1 <> "</h1>
      <p class=\"text-xs font-mono text-slate-500 mt-2\">" <> effective_date <> "</p>
    </div>

    <!-- 本文 -->
    <div class=\"bg-white rounded-2xl border border-slate-200 p-8 sm:p-12 shadow-sm space-y-10 leading-relaxed text-slate-700 text-sm sm:text-base\">
      " <> content_html <> "
    </div>
  </main>

  <!-- 3. フッター -->
  <footer class=\"py-10 border-t border-slate-200 bg-white text-xs text-slate-500 mt-16 font-mono text-center\">
    <div class=\"max-w-4xl mx-auto px-6 space-y-2\">
      <div>&copy; 2026 Microforce Project. Built with Gleam &amp; Erlang/BEAM. All rights reserved.</div>
      <div class=\"text-[11px] text-slate-400\">support@microforce.dev · Zero-Storage Guaranteed</div>
    </div>
  </footer>

</body>
</html>"
}

fn render_en_content() -> String {
  "<section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">01.</span>
      <span>Introduction & Philosophy</span>
    </h2>
    <p>
      At <strong>Q-Deflate</strong> (operated by the Microforce Project, \"we\", \"us\", or \"our\"), we believe privacy is not an afterthought—it is a fundamental engineering constraint. We provide an RFC 1951-compatible, high-density entropy compression service for modern web developers, DevOps pipelines, and autonomous AI agents.
    </p>
    <p>
      This Privacy Policy describes what minimal information we collect, why we collect it, and our unwavering commitment to our <strong>Zero-Storage Guarantee</strong>.
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">02.</span>
      <span>The Zero-Storage Guarantee (Payload Privacy)</span>
    </h2>
    <div class=\"p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs sm:text-sm\">
      <strong>🛡️ Zero-Storage Architectural Commitment:</strong>
      <p class=\"mt-1\">
        We never permanently store, inspect, copy, or index the contents of any files, datasets, or payloads sent to our compression endpoints.
      </p>
    </div>
    <ul class=\"list-disc pl-5 space-y-2 text-xs sm:text-sm text-slate-600\">
      <li><strong>In-Memory / Ephemeral Processing:</strong> Uploaded raw data is compressed in RAM or transient scratch space strictly for the duration required to compute optimal LZ77 matches and dynamic Huffman trees.</li>
      <li><strong>Immediate Cleanup:</strong> Once the compressed archive (.gz) is returned via HTTP stream or transient sandbox download (retained up to 10 minutes for user convenience), all raw and intermediate representations are irrevocably purged.</li>
      <li><strong>No Machine Learning Training:</strong> Your payload data is never used to train, tune, or evaluate any third-party or proprietary AI models.</li>
    </ul>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">03.</span>
      <span>Information We Collect</span>
    </h2>
    <p>We only collect the absolute minimum data required to deliver reliable infrastructure:</p>
    <div class=\"overflow-x-auto border border-slate-200 rounded-xl text-xs\">
      <table class=\"w-full text-left divide-y divide-slate-200\">
        <thead class=\"bg-slate-50 font-mono text-slate-700\">
          <tr>
            <th class=\"py-2.5 px-4\">Category</th>
            <th class=\"py-2.5 px-4\">Data Elements</th>
            <th class=\"py-2.5 px-4\">Purpose</th>
          </tr>
        </thead>
        <tbody class=\"divide-y divide-slate-100 text-slate-600\">
          <tr>
            <td class=\"py-2.5 px-4 font-semibold text-slate-800\">Account Credentials</td>
            <td class=\"py-2.5 px-4 font-mono\">User ID, Password hash (bcrypt/argon2), API Tokens</td>
            <td class=\"py-2.5 px-4\">Authentication and secure API authorization</td>
          </tr>
          <tr>
            <td class=\"py-2.5 px-4 font-semibold text-slate-800\">Usage Metrics</td>
            <td class=\"py-2.5 px-4 font-mono\">Bytes compressed, balance quota</td>
            <td class=\"py-2.5 px-4\">Billing enforcement and prepaid balance tracking</td>
          </tr>
          <tr>
            <td class=\"py-2.5 px-4 font-semibold text-slate-800\">Operational Telemetry</td>
            <td class=\"py-2.5 px-4 font-mono\">IP address, HTTP method, status code, timestamp</td>
            <td class=\"py-2.5 px-4\">DDoS mitigation, rate limiting, and ephemeral diagnostic logs (auto-rotated)</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">04.</span>
      <span>Payment Information & Stripe Protection</span>
    </h2>
    <p>
      Payment transactions are processed entirely through <strong>Stripe, Inc.</strong> via Stripe Checkout.
    </p>
    <p class=\"text-xs sm:text-sm text-slate-600\">
      We never collect, store, or transmit your credit card numbers, expiration dates, or CVC security codes on our servers. All financial transaction handling complies with PCI-DSS Tier 1 standards enforced directly by Stripe.
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">05.</span>
      <span>Cookies & Tracking Technologies</span>
    </h2>
    <p>
      We value clean engineering. <strong>We do not use tracking pixels, analytics beacons, or advertising cookies.</strong>
    </p>
    <p class=\"text-xs sm:text-sm text-slate-600\">
      We exclusively issue essential, encrypted HTTP-only session cookies strictly required for dashboard authentication and security state management.
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">06.</span>
      <span>Security Architecture</span>
    </h2>
    <p>
      Our production systems leverage a defense-in-depth architecture:
    </p>
    <ul class=\"list-disc pl-5 space-y-1.5 text-xs sm:text-sm text-slate-600\">
      <li><strong>TLS 1.3 Encryption:</strong> All data in transit across public networks is encrypted using modern cipher suites.</li>
      <li><strong>UDS Fortification:</strong> Internal account validation and token verification operate within an isolated Unix Domain Socket (UDS) layer with zero external network port exposure.</li>
      <li><strong>Immutable Actor Model:</strong> Built on Gleam and the Erlang BEAM virtual machine, preventing shared-memory corruption and concurrent race conditions.</li>
    </ul>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">07.</span>
      <span>Your Rights & Data Erasure</span>
    </h2>
    <p>
      Regardless of your jurisdiction (including GDPR, CCPA, and Japanese APPI), you retain full sovereignty over your account. You may at any time request the total deletion of your User ID, API tokens, and operational records by contacting our support desk.
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">08.</span>
      <span>Sub-processors & Third-Party Infrastructure</span>
    </h2>
    <p>
      To deliver global low-latency availability and secure transactions, we partner with vetted infrastructure providers who comply with rigorous security standards:
    </p>
    <ul class=\"list-disc pl-5 space-y-1.5 text-xs sm:text-sm text-slate-600\">
      <li><strong>Cloudflare, Inc.:</strong> Global Anycast DNS, DDoS mitigation, edge network routing, and secure tunnel ingress.</li>
      <li><strong>Stripe, Inc.:</strong> Payment tokenization, subscription invoicing, and payment processing (PCI-DSS Level 1 certified).</li>
    </ul>
    <p class=\"text-xs text-slate-500\">
      None of these providers are granted rights to store, harvest, or utilize customer payload data beyond what is strictly necessary to transit network packets or process payments.
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">09.</span>
      <span>Limitation of Liability & Governing Law</span>
    </h2>
    <p class=\"text-xs sm:text-sm text-slate-600 leading-relaxed\">
      While Q-Deflate employs rigorous mathematical validation conforming to RFC 1951 lossless specifications, the service is provided on an \"AS IS\" and \"AS AVAILABLE\" basis. Users are strongly advised to maintain redundant primary copies of all raw data. To the maximum extent permitted by applicable law, the Microforce Project shall not be liable for any indirect, incidental, or consequential damages resulting from network latency, service interruptions, or force majeure events.
    </p>
    <p class=\"text-xs sm:text-sm text-slate-600 leading-relaxed\">
      <strong>Jurisdiction:</strong> This Privacy Policy and any related disputes shall be governed by and construed in accordance with the laws of <strong>Japan</strong>. The <strong>Fukuoka District Court</strong> shall have exclusive primary jurisdiction for any legal proceedings arising out of or in connection with this service.
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">10.</span>
      <span>Contact & Operator Details</span>
    </h2>
    <div class=\"bg-slate-50 rounded-xl p-5 border border-slate-200 text-xs sm:text-sm font-mono space-y-1.5\">
      <div><span class=\"text-slate-400\">Entity:</span> <strong class=\"text-slate-800\">Microforce Project (Gen Nishizumi)</strong></div>
      <div><span class=\"text-slate-400\">Inquiries:</span> <a href=\"mailto:support@microforce.dev\" class=\"text-brand-600 hover:underline\">support@microforce.dev</a></div>
      <div><span class=\"text-slate-400\">Domain:</span> <span class=\"text-slate-700\">microforce.dev</span></div>
    </div>
  </section>"
}

fn render_ja_content() -> String {
  "<section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">01.</span>
      <span>はじめに・基本理念</span>
    </h2>
    <p>
      <strong>Q-Deflate</strong>（運営者: Microforce Project 西住玄、以下「当サービス」）は、プライバシーの保護を後付けの機能ではなく、<strong>システム設計の根幹をなすエンジニアリング上の絶対制約</strong>と定義しています。当サービスは、開発者、CI/CDパイプライン、自律型AIエージェント向けにRFC 1951規格完全互換の超高密度エントロピー圧縮を提供します。
    </p>
    <p>
      本プライバシーポリシーでは、当サービスが収集する最小限の情報、その利用目的、および当サービスの核心である<strong>「ゼロストレージ保証（Zero-Storage Guarantee）」</strong>について定めます。
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">02.</span>
      <span>ゼロストレージ保証（ペイロードデータの非保持原則）</span>
    </h2>
    <div class=\"p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs sm:text-sm\">
      <strong>🛡️ ゼロストレージ・アーキテクチャの誓約:</strong>
      <p class=\"mt-1\">
        当サービスは、圧縮処理のために送信されたファイル、アーカイブ、テキストデータ等のペイロード内容を、サーバー上に恒久保存、閲覧、複製、またはインデックス化することは一切いたしません。
      </p>
    </div>
    <ul class=\"list-disc pl-5 space-y-2 text-xs sm:text-sm text-slate-600\">
      <li><strong>オンメモリ・一時処理:</strong> 送信された生データは、最長一致探索および動的ハフマン木の最適化計算を行うためだけに、RAMまたは一時領域上で揮発的に処理されます。</li>
      <li><strong>即時消去:</strong> 圧縮済みデータ（.gz）の通信完了、または一時ダウンロード提供（最大10分間の一時バッファ）の完了後、元の生データおよび中間データは完全に自動消去されます。</li>
      <li><strong>AI学習への不使用:</strong> アップロードされたデータが、第三者または当サービスのAIモデル学習・評価に使用されることは一切ございません。</li>
    </ul>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">03.</span>
      <span>取得する情報とその目的</span>
    </h2>
    <p>当サービスは、安定したインフラ運用のために必要不可欠な最小限の情報のみを取り扱います。</p>
    <div class=\"overflow-x-auto border border-slate-200 rounded-xl text-xs\">
      <table class=\"w-full text-left divide-y divide-slate-200\">
        <thead class=\"bg-slate-50 font-mono text-slate-700\">
          <tr>
            <th class=\"py-2.5 px-4\">項目</th>
            <th class=\"py-2.5 px-4\">具体的なデータ</th>
            <th class=\"py-2.5 px-4\">利用目的</th>
          </tr>
        </thead>
        <tbody class=\"divide-y divide-slate-100 text-slate-600\">
          <tr>
            <td class=\"py-2.5 px-4 font-semibold text-slate-800\">認証情報</td>
            <td class=\"py-2.5 px-4 font-mono\">ユーザーID、パスワードハッシュ、APIトークン</td>
            <td class=\"py-2.5 px-4\">ユーザー認証およびAPIアクセスの正当性確認</td>
          </tr>
          <tr>
            <td class=\"py-2.5 px-4 font-semibold text-slate-800\">利用実績メトリクス</td>
            <td class=\"py-2.5 px-4 font-mono\">圧縮処理バイト数、残高クォータ</td>
            <td class=\"py-2.5 px-4\">従量課金および前払い残高の適正な減算・管理</td>
          </tr>
          <tr>
            <td class=\"py-2.5 px-4 font-semibold text-slate-800\">運用テレメトリ</td>
            <td class=\"py-2.5 px-4 font-mono\">IPアドレス、HTTPメソッド、レスポンスコード、日時</td>
            <td class=\"py-2.5 px-4\">不正アクセス防止（DDoS対策）、レートリミット、診断ログ（自動ローテーション）</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">04.</span>
      <span>決済情報の取扱い（Stripe完全委託）</span>
    </h2>
    <p>
      当サービスの決済処理は、グローバル決済プラットフォーム <strong>Stripe, Inc.</strong>（Stripe Checkout）に完全に委託しております。
    </p>
    <p class=\"text-xs sm:text-sm text-slate-600\">
      お客様のクレジットカード番号、有効期限、セキュリティコード等はStripe社側でのみ安全に処理され、当サービスのサーバーには一切保持・通過いたしません（PCI-DSS準拠）。
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">05.</span>
      <span>Cookieおよびトラッキング技術について</span>
    </h2>
    <p>
      当サービスは、広告配信や行動追跡を目的とした<strong>サードパーティCookie、トラッキングピクセル、外部アナリティクスビーコンを一切使用いたしません。</strong>
    </p>
    <p class=\"text-xs sm:text-sm text-slate-600\">
      ダッシュボードのログインセッション維持に必要な、暗号化された必要最小限のファーストパーティCookie（HTTP-only）のみを使用します。
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">06.</span>
      <span>セキュリティ・アーキテクチャ</span>
    </h2>
    <p>
      当サービスは多層防御アーキテクチャにより運用されています。
    </p>
    <ul class=\"list-disc pl-5 space-y-1.5 text-xs sm:text-sm text-slate-600\">
      <li><strong>通信の完全暗号化:</strong> すべての通信はTLS 1.3等の強固な暗号化プロトコルにより保護されます。</li>
      <li><strong>UDS要塞層:</strong> 認証および残高管理コアは、外部ネットワークポートを一切開口しないUNIXドメインソケット（UDS）密室レイヤーに隔離されています。</li>
      <li><strong>不変アクターモデル:</strong> GleamおよびErlang/BEAM仮想マシンを採用し、競合状態やメモリ破壊リスクを原理的に排除しています。</li>
    </ul>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">07.</span>
      <span>データの開示・訂正・削除請求</span>
    </h2>
    <p>
      お客様は、ご自身のアカウント情報やAPIトークンについて、いつでも削除（退会）を求めることができます。退会時は、関連する認証情報および残高データがシステムから完全に破棄されます。
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">08.</span>
      <span>外部委託先・インフラストラクチャ</span>
    </h2>
    <p>
      当サービスは、世界規模の低遅延配信、DDoS攻撃防御、および安全な決済を実現するため、厳格なセキュリティ基準を満たす以下の外部事業者に一部インフラを委託しています。
    </p>
    <ul class=\"list-disc pl-5 space-y-1.5 text-xs sm:text-sm text-slate-600\">
      <li><strong>Cloudflare, Inc.:</strong> グローバルAnycast DNS、エッジルーティング、DDoS攻撃緩和、Cloudflare Tunnel暗号化通信網。</li>
      <li><strong>Stripe, Inc.:</strong> クレジットカード決済代行、サブスクリプション請求管理（PCI-DSS レベル1認定）。</li>
    </ul>
    <p class=\"text-xs text-slate-500\">
      これらの事業者が、ネットワーク転送や決済処理の目的を超えてお客様の圧縮ペイロードデータを閲覧・保持・利用することはございません。
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">09.</span>
      <span>免責事項および準拠法・管轄裁判所</span>
    </h2>
    <p class=\"text-xs sm:text-sm text-slate-600 leading-relaxed\">
      当サービスはRFC 1951規格完全準拠の可逆圧縮アルゴリズムを採用し細心の注意を払って提供されますが、本質的に「現状有姿（AS IS）」にて提供されます。お客様は必ず元データの適切なバックアップを自ら保持するものとします。天災地変、通信回線の障害、サイバー攻撃等の不可抗力に起因するサービスの一時停止や損害について、当サービスは法令上認められる最大限の範囲において責任を負いかねます。
    </p>
    <p class=\"text-xs sm:text-sm text-slate-600 leading-relaxed\">
      <strong>準拠法および管轄裁判所:</strong> 本プライバシーポリシーおよび当サービスの利用に関する一切の解釈・紛争には、<strong>日本法</strong>が適用されます。当サービスに起因または関連して生じたすべての紛争については、<strong>福岡地方裁判所</strong>を第一審の専属的合意管轄裁判所とします。
    </p>
  </section>

  <section class=\"space-y-4\">
    <h2 class=\"text-xl font-bold text-slate-900 flex items-center space-x-2 border-b border-slate-100 pb-2\">
      <span class=\"text-brand-500 font-mono text-sm\">10.</span>
      <span>お問い合わせ窓口・運営者情報</span>
    </h2>
    <div class=\"bg-slate-50 rounded-xl p-5 border border-slate-200 text-xs sm:text-sm font-mono space-y-1.5\">
      <div><span class=\"text-slate-400\">事業者:</span> <strong class=\"text-slate-800\">Microforce Project (西住 玄)</strong></div>
      <div><span class=\"text-slate-400\">お問い合わせ:</span> <a href=\"mailto:support@microforce.dev\" class=\"text-brand-600 hover:underline\">support@microforce.dev</a></div>
      <div><span class=\"text-slate-400\">ドメイン:</span> <span class=\"text-slate-700\">microforce.dev</span></div>
    </div>
  </section>"
}
