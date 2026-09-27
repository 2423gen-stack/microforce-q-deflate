#!/usr/bin/env bash
# ==============================================================================
# Q-Deflate / ai-channel: 保守用ログ収集＆障害切り分けスクリプト
#
# 用途:
#   本番・保守環境において、問題発生時の原因切り分け（[HTTP], [AUTH_UDS], [ENGINE], [STRIPE]）
#   およびシステム健全性を即座にスキャンし、タイムスタンプ付きログとして logs/ に保存する。
#
# 使用法:
#   ./scripts/save_logs.sh           # ワンショット診断＆ログ保存
#   ./scripts/save_logs.sh -e        # エラー・警告のみ抽出して保存
#   ./scripts/save_logs.sh -f        # リアルタイム色付きログストリーミング監視
# ==============================================================================

set -euo pipefail

# スクリプトの配置ディレクトリを起点にプロジェクトルートを特定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOGS_DIR="${PROJECT_ROOT}/logs"
mkdir -p "${LOGS_DIR}"

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
TARGET_LOG="${LOGS_DIR}/maintenance_${TIMESTAMP}.log"
LATEST_LOG="${LOGS_DIR}/latest.log"

# カラー定義（ターミナル出力用）
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_RED="\033[31m"
C_CYAN="\033[36m"
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"

# コンテナ・サービス名の自動判別
if docker ps -a --format '{{.Names}}' | grep -q "qdeflate_web"; then
    WEB_CONTAINER="qdeflate_web"
    AUTH_CONTAINER="qdeflate_auth"
    FILTER_PREFIX="qdeflate"
    COMPOSE_SERVICES="web auth"
elif docker ps -a --format '{{.Names}}' | grep -q "ai_channel_bbs"; then
    WEB_CONTAINER="ai_channel_bbs"
    AUTH_CONTAINER="ai_channel_auth"
    FILTER_PREFIX="ai_channel"
    COMPOSE_SERVICES="bbs auth"
else
    WEB_CONTAINER="web"
    AUTH_CONTAINER="auth"
    FILTER_PREFIX="qdeflate"
    COMPOSE_SERVICES="web auth"
fi

# 引数処理
MODE="summary"
if [[ "${1:-}" == "-f" || "${1:-}" == "--follow" ]]; then
    MODE="follow"
elif [[ "${1:-}" == "-e" || "${1:-}" == "--errors-only" ]]; then
    MODE="errors"
fi

# ------------------------------------------------------------------------------
# 1. リアルタイムストリーミング監視モード (-f / --follow)
# ------------------------------------------------------------------------------
if [[ "${MODE}" == "follow" ]]; then
    echo -e "${C_BOLD}${C_CYAN}=== Q-Deflate リアルタイム・レイヤー別ログストリーミング ===${C_RESET}"
    echo -e "監視対象コンテナ: ${WEB_CONTAINER}, ${AUTH_CONTAINER} (Ctrl+C で終了)"
    echo "----------------------------------------------------------------------"
    
    docker compose -f "${PROJECT_ROOT}/docker-compose.yml" logs -f --tail=50 ${COMPOSE_SERVICES} 2>&1 | while read -r line; do
        if [[ "${line}" =~ (ERROR|error|CRITICAL) ]]; then
            echo -e "${C_RED}${C_BOLD}${line}${C_RESET}"
        elif [[ "${line}" =~ (WARN|warning|WARNING) ]]; then
            echo -e "${C_YELLOW}${line}${C_RESET}"
        elif [[ "${line}" =~ \[ENGINE\] ]]; then
            echo -e "${C_GREEN}${line}${C_RESET}"
        elif [[ "${line}" =~ \[AUTH_UDS\] ]]; then
            echo -e "${C_BLUE}${line}${C_RESET}"
        elif [[ "${line}" =~ \[STRIPE\] ]]; then
            echo -e "${C_MAGENTA}${line}${C_RESET}"
        else
            echo "${line}"
        fi
    done
    exit 0
fi

# ------------------------------------------------------------------------------
# 2. ワンショット診断＆ログファイル保存モード
# ------------------------------------------------------------------------------

echo -e "${C_BOLD}${C_CYAN}======================================================================${C_RESET}"
echo -e "${C_BOLD}${C_CYAN} 🚀 Q-Deflate / ai-channel システム保守診断 ＆ ログ採取${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}======================================================================${C_RESET}"
echo -e "日時: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo -e "保存先: ${C_YELLOW}${TARGET_LOG}${C_RESET}"
echo ""

{
    echo "======================================================================"
    echo " Q-Deflate / ai-channel Maintenance Diagnostic Snapshot"
    echo " Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo " Host: $(hostname) ($(uname -srm))"
    echo "======================================================================"
    echo ""

    echo "--- [1. システムリソース] ---"
    uptime
    echo ""
    free -h || true
    echo ""

    echo "--- [2. Docker コンテナ健全性] ---"
    docker ps -a --filter "name=${FILTER_PREFIX}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.RunningFor}}"
    echo ""

    echo "--- [3. UDS 要塞ソケット & ストレージ] ---"
    if [[ -S "/tmp/qdeflate/auth.sock" ]]; then
        echo "UDS Socket (/tmp/qdeflate/auth.sock): 存在確認 OK"
        ls -l /tmp/qdeflate/auth.sock
    else
        echo "UDS Socket (/tmp/qdeflate/auth.sock): ホスト側直結未検出 (コンテナ内共有ボリュームを確認)"
    fi
    echo ""

    echo "--- [4. レイヤー別ログ統計 (直近 1000 行)] ---"
    WEB_LOGS="$(docker logs --tail=1000 "${WEB_CONTAINER}" 2>&1 || true)"
    AUTH_LOGS="$(docker logs --tail=1000 "${AUTH_CONTAINER}" 2>&1 || true)"

    COUNT_ERRORS="$(echo "${WEB_LOGS}" "${AUTH_LOGS}" | grep -Ei 'ERROR|CRITICAL' | wc -l || true)"
    COUNT_WARNS="$(echo "${WEB_LOGS}" "${AUTH_LOGS}" | grep -Ei 'WARN|WARNING' | wc -l || true)"
    COUNT_ENGINE="$(echo "${WEB_LOGS}" | grep -F '[ENGINE]' | wc -l || true)"
    COUNT_AUTH_UDS="$(echo "${WEB_LOGS}" | grep -F '[AUTH_UDS]' | wc -l || true)"
    COUNT_STRIPE="$(echo "${WEB_LOGS}" | grep -F '[STRIPE]' | wc -l || true)"

    echo "エラー検出件数    (ERROR)    : ${COUNT_ERRORS}"
    echo "警告検出件数      (WARN)     : ${COUNT_WARNS}"
    echo "圧縮エンジンイベント [ENGINE]  : ${COUNT_ENGINE}"
    echo "UDS認証・残高イベント [AUTH_UDS]: ${COUNT_AUTH_UDS}"
    echo "Stripe決済イベント  [STRIPE]   : ${COUNT_STRIPE}"
    echo ""

    echo "--- [5. 検出されたエラー・警告イベント抜粋] ---"
    echo ">>> [ERROR ログ] <<<"
    echo "${WEB_LOGS}" "${AUTH_LOGS}" | grep -Ei 'ERROR|CRITICAL' | tail -n 20 || echo "エラーは検出されませんでした (Clean)"
    echo ""
    echo ">>> [WARN ログ] <<<"
    echo "${WEB_LOGS}" "${AUTH_LOGS}" | grep -Ei 'WARN|WARNING' | tail -n 20 || echo "警告は検出されませんでした (Clean)"
    echo ""

    echo "--- [6. レイヤー別最新アクティビティ (直近 10 行)] ---"
    echo ">>> [ENGINE (圧縮炉心)] <<<"
    echo "${WEB_LOGS}" | grep -F '[ENGINE]' | tail -n 10 || echo "アクティビティなし"
    echo ""
    echo ">>> [AUTH_UDS (要塞認証・残高)] <<<"
    echo "${WEB_LOGS}" | grep -F '[AUTH_UDS]' | tail -n 10 || echo "アクティビティなし"
    echo ""
    echo ">>> [STRIPE (決済・Webhook)] <<<"
    echo "${WEB_LOGS}" | grep -F '[STRIPE]' | tail -n 10 || echo "アクティビティなし"
    echo ""

    echo "--- [7. コンテナ完全ダンプ (最新 500 行)] ---"
    echo "=== ${WEB_CONTAINER} ==="
    echo "${WEB_LOGS}" | tail -n 500
    echo ""
    echo "=== ${AUTH_CONTAINER} ==="
    echo "${AUTH_LOGS}" | tail -n 500
    echo ""
    echo "======================================================================"
    echo " End of Diagnostic Log"
    echo "======================================================================"
} > "${TARGET_LOG}"

# latest.log を更新
cp -f "${TARGET_LOG}" "${LATEST_LOG}"

# ターミナルへサマリーを表示
echo -e "${C_BOLD}【システム診断サマリー】${C_RESET}"

# コンテナ状態
CONTAINER_STATUS="$(docker ps --filter "name=${FILTER_PREFIX}" --format "{{.Names}}: {{.Status}}")"
echo -e "コンテナ状態: "
while IFS= read -r line; do
    if [[ "${line}" =~ Up ]]; then
        echo -e "  - ${C_GREEN}✓ ${line}${C_RESET}"
    else
        echo -e "  - ${C_RED}✗ ${line}${C_RESET}"
    fi
done <<< "${CONTAINER_STATUS}"

# エラー件数サマリー
WEB_LOGS="$(docker logs --tail=500 "${WEB_CONTAINER}" 2>&1 || true)"
AUTH_LOGS="$(docker logs --tail=500 "${AUTH_CONTAINER}" 2>&1 || true)"
COUNT_ERRORS="$(echo "${WEB_LOGS}" "${AUTH_LOGS}" | grep -Ei 'ERROR|CRITICAL' | wc -l || true)"
COUNT_WARNS="$(echo "${WEB_LOGS}" "${AUTH_LOGS}" | grep -Ei 'WARN|WARNING' | wc -l || true)"

if [[ "${COUNT_ERRORS}" -gt 0 ]]; then
    echo -e "エラー件数: ${C_RED}${C_BOLD}${COUNT_ERRORS} 件 ⚠️  (詳細はログを確認)${C_RESET}"
else
    echo -e "エラー件数: ${C_GREEN}0 件 (異常なし・正常稼働中)${C_RESET}"
fi

if [[ "${COUNT_WARNS}" -gt 0 ]]; then
    echo -e "警告件数  : ${C_YELLOW}${COUNT_WARNS} 件 (残高不足や認証失敗等)${C_RESET}"
else
    echo -e "警告件数  : ${C_GREEN}0 件${C_RESET}"
fi

echo ""
echo -e "最新エラー/警告のプレビュー (直近5件):"
echo "----------------------------------------------------------------------"
RECENT_ISSUES="$(echo "${WEB_LOGS}" "${AUTH_LOGS}" | grep -Ei 'ERROR|CRITICAL|WARN|WARNING' | tail -n 5 || true)"
if [[ -n "${RECENT_ISSUES}" ]]; then
    while IFS= read -r line; do
        if [[ "${line}" =~ (ERROR|CRITICAL) ]]; then
            echo -e "  ${C_RED}${line}${C_RESET}"
        else
            echo -e "  ${C_YELLOW}${line}${C_RESET}"
        fi
    done <<< "${RECENT_ISSUES}"
else
    echo -e "  ${C_GREEN}直近のエラー・警告はありません。${C_RESET}"
fi
echo "----------------------------------------------------------------------"

# 古いログのローテーション（直近20件のみ保持）
LOG_COUNT="$(find "${LOGS_DIR}" -name "maintenance_*.log" | wc -l)"
if [[ "${LOG_COUNT}" -gt 20 ]]; then
    echo -e "${C_CYAN}古くなったログを整理中 (最新20件を保持)...${C_RESET}"
    find "${LOGS_DIR}" -name "maintenance_*.log" | sort | head -n -20 | xargs -r rm -f
fi

echo ""
echo -e "${C_GREEN}✓ 保守ログを正常に保存しました: ${C_BOLD}${TARGET_LOG}${C_RESET}"
echo -e "  （最新ログは ${C_YELLOW}${LATEST_LOG}${C_RESET} からも参照できます）"
echo ""
