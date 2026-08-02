#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[telegram-send-gate] $*"
}

# Defaults (can be overridden per workflow)
: "${TELEGRAM_SEND_GATE_ENABLED:=true}"
: "${TELEGRAM_SEND_GATE_LOOKBACK_MESSAGES:=5}"
: "${TELEGRAM_SEND_GATE_MIN_HUMAN_MESSAGES:=1}"
: "${TELEGRAM_SEND_GATE_ON_ERROR:=skip}"

write_outputs() {
  local should_send=$1
  local reason=$2
  local human_count=$3
  local sampled_count=$4

  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "telegram_send_gate=${should_send}"
      echo "telegram_send_gate_reason=${reason}"
      echo "telegram_send_gate_human_messages=${human_count}"
      echo "telegram_send_gate_sampled_messages=${sampled_count}"
    } >> "$GITHUB_OUTPUT"
  fi
}

skip_send() {
  local reason=$1
  local human_count=${2:-0}
  local sampled_count=${3:-0}

  write_outputs false "$reason" "$human_count" "$sampled_count"
  exit 0
}

if [[ "${TELEGRAM_SEND_GATE_ENABLED,,}" != "true" ]]; then
  log "Send gate disabled; allowing send."
  write_outputs true disabled 0 0
  exit 0
fi

if [[ -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  log "Missing TELEGRAM_CHAT_ID."
  skip_send missing_chat_id
fi

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  log "Missing TELEGRAM_BOT_TOKEN."
  skip_send missing_bot_token
fi

if ! command -v jq >/dev/null 2>&1; then
  log "jq is required for send gate logic and is not available."
  if [[ "${TELEGRAM_SEND_GATE_ON_ERROR,,}" == "allow" ]]; then
    write_outputs true missing_dependency_jq_allow 0 0
    exit 0
  fi

  skip_send missing_dependency_jq_skip
fi

if ! [[ "$TELEGRAM_SEND_GATE_LOOKBACK_MESSAGES" =~ ^[0-9]+$ ]] || (( TELEGRAM_SEND_GATE_LOOKBACK_MESSAGES == 0 )); then
  log "Invalid TELEGRAM_SEND_GATE_LOOKBACK_MESSAGES: '$TELEGRAM_SEND_GATE_LOOKBACK_MESSAGES'."
  skip_send invalid_lookback
fi

if ! [[ "$TELEGRAM_SEND_GATE_MIN_HUMAN_MESSAGES" =~ ^[0-9]+$ ]]; then
  log "Invalid TELEGRAM_SEND_GATE_MIN_HUMAN_MESSAGES: '$TELEGRAM_SEND_GATE_MIN_HUMAN_MESSAGES'."
  skip_send invalid_min_human
fi

API_BASE="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}"
set +e
RESP=$(curl -sS --max-time 30 --retry 2 --retry-delay 2 "${API_BASE}/getUpdates?limit=100&timeout=0")
CURL_CODE=$?
set -e
if (( CURL_CODE != 0 )); then
  log "Telegram getUpdates call failed with exit code $CURL_CODE."
  if [[ "${TELEGRAM_SEND_GATE_ON_ERROR,,}" == "allow" ]]; then
    write_outputs true api_curl_error_allow 0 0
    exit 0
  fi
  skip_send api_curl_error_skip
fi

if [[ -z "$RESP" ]]; then
  log "Telegram API returned empty response."
  if [[ "${TELEGRAM_SEND_GATE_ON_ERROR,,}" == "allow" ]]; then
    write_outputs true api_empty_allow 0 0
    exit 0
  fi

  skip_send api_empty_skip
fi

if ! echo "$RESP" | jq -e '.ok == true' >/dev/null 2>&1; then
  DESCRIPTION=$(echo "$RESP" | jq -r '.description // "unknown"')
  log "Telegram API error: $DESCRIPTION"
  if [[ "${TELEGRAM_SEND_GATE_ON_ERROR,,}" == "allow" ]]; then
    write_outputs true api_error_allow 0 0
    exit 0
  fi

  skip_send api_error_skip
fi

CHAT_MESSAGES=$(echo "$RESP" | jq --arg chat_id "$TELEGRAM_CHAT_ID" --argjson lookback "$TELEGRAM_SEND_GATE_LOOKBACK_MESSAGES" '
  .result
  | map(
      if has("message") then .message
      elif has("channel_post") then .channel_post
      else empty
      end
    )
  | map(select((.chat.id|tostring) == $chat_id))
  | sort_by(.date)
  | reverse
  | .[:$lookback]
')

SAMPLED_COUNT=$(echo "$CHAT_MESSAGES" | jq 'length')
HUMAN_COUNT=$(echo "$CHAT_MESSAGES" | jq '[.[] | select(.from and (.from.is_bot == false))] | length')

if (( HUMAN_COUNT >= TELEGRAM_SEND_GATE_MIN_HUMAN_MESSAGES )); then
  log "Allowed. Checked ${SAMPLED_COUNT} recent update(s), found ${HUMAN_COUNT} human message(s)."
  write_outputs true human_presence_ok "$HUMAN_COUNT" "$SAMPLED_COUNT"
  exit 0
fi

log "Blocked. Checked ${SAMPLED_COUNT} recent update(s), found ${HUMAN_COUNT} human message(s) (minimum required: ${TELEGRAM_SEND_GATE_MIN_HUMAN_MESSAGES})."
skip_send human_presence_low "$HUMAN_COUNT" "$SAMPLED_COUNT"
