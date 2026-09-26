// Copyright (c) 2026 Gen Nishizumi (西住玄)
// SPDX-License-Identifier: MIT

//// Q-Deflate SaaS: ログイン＆新規登録画面コンポーネント

import gleam/option.{type Option, None, Some}

pub fn render_login_page(error_msg: Option(String)) -> String {
  let err_banner = case error_msg {
    Some(msg) ->
      "<div class=\"mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-center space-x-2.5 font-medium\">
        <span class=\"text-rose-500 font-bold text-sm\">⚠️</span>
        <span>" <> msg <> "</span>
      </div>"
    None -> ""
  }

  "<!DOCTYPE html>
<html lang=\"ja\" class=\"h-full bg-slate-900\">
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>Sign In · Q-Deflate Cloud Console</title>
  <link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
  <link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
  <link href=\"https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap\" rel=\"stylesheet\">
  <script src=\"https://cdn.tailwindcss.com\"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            sans: ['\"Plus Jakarta Sans\"', 'sans-serif'],
            mono: ['\"JetBrains Mono\"', 'monospace'],
          },
          colors: {
            brand: {
              50: '#eff6ff',
              100: '#dbeafe',
              500: '#0069ff',
              600: '#0055d4',
              900: '#0b132b',
            }
          }
        }
      }
    }
  </script>
</head>
<body class=\"h-full flex flex-col justify-center items-center p-6 antialiased bg-[#0b132b] text-slate-200 select-none\">

  <!-- バックリンク -->
  <div class=\"absolute top-6 left-6\">
    <a href=\"/compress\" class=\"inline-flex items-center space-x-2 text-xs font-mono text-slate-400 hover:text-white transition-colors bg-slate-800/60 px-3 py-1.5 rounded-lg border border-slate-700/60\">
      <span>←</span>
      <span>Back to Q-Deflate</span>
    </a>
  </div>

  <div class=\"w-full max-w-md\">
    <!-- ロゴヘッダー -->
    <div class=\"text-center mb-8\">
      <div class=\"inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-brand-500 text-white font-mono font-bold text-2xl shadow-xl shadow-brand-500/30 mb-4\">
        Q
      </div>
      <h1 class=\"text-2xl font-bold tracking-tight text-white\">Sign in to Q-Deflate</h1>
      <p class=\"text-xs text-slate-400 mt-2 font-normal\">Cloud Entropy Compression & Autonomous AI Agent Gateway</p>
    </div>

    <!-- ログインカード -->
    <div class=\"bg-slate-900/90 backdrop-blur-xl border border-slate-800 rounded-2xl p-8 shadow-2xl shadow-black/50\">
      " <> err_banner <> "

      <!-- タブ切り替え（Sign In / Quick Create） -->
      <div class=\"flex rounded-lg bg-slate-800/80 p-1 mb-6 border border-slate-700/50\">
        <button type=\"button\" onclick=\"switchTab('signin')\" id=\"tab-signin-btn\" class=\"flex-1 py-1.5 text-xs font-semibold rounded-md transition-all bg-brand-500 text-white shadow-xs\">
          Sign In
        </button>
        <button type=\"button\" onclick=\"switchTab('signup')\" id=\"tab-signup-btn\" class=\"flex-1 py-1.5 text-xs font-semibold rounded-md transition-all text-slate-400 hover:text-white\">
          Create Account
        </button>
      </div>

      <!-- 1. Sign In フォーム -->
      <form id=\"signin-form\" method=\"POST\" action=\"/login\" class=\"space-y-4\">
        <input type=\"hidden\" name=\"action\" value=\"signin\">
        <div>
          <label class=\"block text-xs font-medium text-slate-300 mb-1.5\">User ID or API Token</label>
          <input type=\"text\" name=\"identifier\" required placeholder=\"e.g. gen or qdf_live_...\" class=\"w-full px-3.5 py-2.5 bg-slate-800 border border-slate-700 rounded-lg text-xs font-mono text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 focus:ring-1 focus:ring-brand-500 transition-colors\">
        </div>
        <div>
          <label class=\"block text-xs font-medium text-slate-300 mb-1.5\">Password <span class=\"text-slate-500 text-[10px]\">(optional if using API Token)</span></label>
          <input type=\"password\" name=\"password\" placeholder=\"Enter your password\" class=\"w-full px-3.5 py-2.5 bg-slate-800 border border-slate-700 rounded-lg text-xs font-mono text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 focus:ring-1 focus:ring-brand-500 transition-colors\">
        </div>

        <button type=\"submit\" class=\"w-full py-2.5 px-4 bg-brand-500 hover:bg-brand-600 active:scale-[0.99] text-white text-xs font-semibold rounded-lg shadow-lg shadow-brand-500/25 transition-all\">
          Sign In to Dashboard
        </button>
      </form>

      <!-- 2. Create Account フォーム -->
      <form id=\"signup-form\" method=\"POST\" action=\"/login\" class=\"space-y-4 hidden\">
        <input type=\"hidden\" name=\"action\" value=\"signup\">
        <div>
          <label class=\"block text-xs font-medium text-slate-300 mb-1.5\">Desired User ID</label>
          <input type=\"text\" name=\"new_user_id\" required placeholder=\"e.g. gen\" class=\"w-full px-3.5 py-2.5 bg-slate-800 border border-slate-700 rounded-lg text-xs font-mono text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 focus:ring-1 focus:ring-brand-500 transition-colors\">
        </div>
        <div>
          <label class=\"block text-xs font-medium text-slate-300 mb-1.5\">Password</label>
          <input type=\"password\" name=\"new_password\" required placeholder=\"Create a strong password\" class=\"w-full px-3.5 py-2.5 bg-slate-800 border border-slate-700 rounded-lg text-xs font-mono text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 focus:ring-1 focus:ring-brand-500 transition-colors\">
          <p class=\"text-[11px] text-slate-500 mt-1.5 font-sans\">Includes 1,000 MB free compression bandwidth bonus.</p>
        </div>

        <button type=\"submit\" class=\"w-full py-2.5 px-4 bg-emerald-600 hover:bg-emerald-500 active:scale-[0.99] text-white text-xs font-semibold rounded-lg shadow-lg shadow-emerald-600/25 transition-all\">
          Create Account & Enter
        </button>
      </form>


    </div>

    <!-- フッター -->
    <div class=\"mt-6 text-center text-xs text-slate-500 font-mono\">
      <span>Q-Deflate Cloud Console · Zero-Storage Guaranteed</span>
    </div>
  </div>

  <script>
    function switchTab(mode) {
      const signinBtn = document.getElementById('tab-signin-btn');
      const signupBtn = document.getElementById('tab-signup-btn');
      const signinForm = document.getElementById('signin-form');
      const signupForm = document.getElementById('signup-form');

      if (mode === 'signin') {
        signinBtn.className = 'flex-1 py-1.5 text-xs font-semibold rounded-md transition-all bg-brand-500 text-white shadow-xs';
        signupBtn.className = 'flex-1 py-1.5 text-xs font-semibold rounded-md transition-all text-slate-400 hover:text-white';
        signinForm.classList.remove('hidden');
        signupForm.classList.add('hidden');
      } else {
        signupBtn.className = 'flex-1 py-1.5 text-xs font-semibold rounded-md transition-all bg-brand-500 text-white shadow-xs';
        signinBtn.className = 'flex-1 py-1.5 text-xs font-semibold rounded-md transition-all text-slate-400 hover:text-white';
        signupForm.classList.remove('hidden');
        signinForm.classList.add('hidden');
      }
    }
  </script>
</body>
</html>"
}
