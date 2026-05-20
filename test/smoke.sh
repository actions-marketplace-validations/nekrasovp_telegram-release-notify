#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/send-telegram.sh"

pass() { echo "ok - $*"; }
fail() { echo "not ok - $*" >&2; exit 1; }

make_fake_curl() {
  local bin_dir="$1"
  local mode="${2:-success}"

  cat > "$bin_dir/curl" <<'FAKE'
#!/usr/bin/env bash
set -euo pipefail
: "${FAKE_CURL_ARGS:?FAKE_CURL_ARGS is required}"
: "${FAKE_CURL_MODE:=success}"

printf '%s\n' "$@" > "$FAKE_CURL_ARGS"

out_file=""
write_out=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      out_file="$2"
      shift 2
      ;;
    --write-out)
      write_out="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$out_file" ]]; then
  echo "fake curl expected --output" >&2
  exit 2
fi

case "$FAKE_CURL_MODE" in
  success)
    printf '{"ok":true,"result":{"message_id":123}}' > "$out_file"
    printf '200'
    ;;
  telegram-error)
    printf '{"ok":false,"error_code":400,"description":"Bad Request: chat not found"}' > "$out_file"
    printf '400'
    ;;
  bad-json)
    printf '{"ok":false}' > "$out_file"
    printf '200'
    ;;
  network)
    printf '' > "$out_file"
    printf '000'
    exit 7
    ;;
  *)
    echo "unknown FAKE_CURL_MODE=$FAKE_CURL_MODE" >&2
    exit 2
    ;;
esac
FAKE
  chmod +x "$bin_dir/curl"
  export FAKE_CURL_MODE="$mode"
}

run_with_fake_curl() {
  local mode="$1"
  shift
  local tmp
  tmp="$(mktemp -d)"
  export FAKE_CURL_ARGS="$tmp/curl-args.txt"
  export GITHUB_OUTPUT="$tmp/github-output.txt"
  make_fake_curl "$tmp" "$mode"
  PATH="$tmp:$PATH" "$@"
}

bash -n "$SCRIPT"
pass "send script syntax is valid"

# Custom text path.
tmp="$(mktemp -d)"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" success
PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="-100123" \
INPUT_TEXT=$'hello\nworld' \
INPUT_DISABLE_NOTIFICATION="true" \
INPUT_DISABLE_LINK_PREVIEW="true" \
INPUT_PROTECT_CONTENT="false" \
INPUT_INCLUDE_RELEASE_BODY="true" \
INPUT_MAX_BODY_CHARS="1200" \
INPUT_MAX_MESSAGE_CHARS="3900" \
"$SCRIPT" >/dev/null

grep -q 'chat_id=-100123' "$FAKE_CURL_ARGS" || fail "custom text sends chat_id"
grep -q 'text=hello' "$FAKE_CURL_ARGS" || fail "custom text sends text argument"
grep -q 'disable_notification=true' "$FAKE_CURL_ARGS" || fail "custom text sends disable_notification"
grep -q 'link_preview_options={"is_disabled":true}' "$FAKE_CURL_ARGS" || fail "custom text sends link preview options"
grep -q 'sent=true' "$GITHUB_OUTPUT" || fail "custom text sets sent output"
pass "custom text request is formed correctly"

# Default release message path.
tmp="$(mktemp -d)"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" success
PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="@my_channel" \
INPUT_TEXT="" \
INPUT_RELEASE_TITLE="" \
INPUT_RELEASE_TAG="" \
INPUT_RELEASE_URL="" \
INPUT_RELEASE_BODY="" \
INPUT_DISABLE_NOTIFICATION="false" \
INPUT_DISABLE_LINK_PREVIEW="false" \
INPUT_PROTECT_CONTENT="false" \
INPUT_INCLUDE_RELEASE_BODY="true" \
INPUT_MAX_BODY_CHARS="20" \
INPUT_MAX_MESSAGE_CHARS="3900" \
EVENT_RELEASE_TITLE="Version 1.0.0" \
EVENT_RELEASE_TAG="v1.0.0" \
EVENT_RELEASE_URL="https://github.com/example/project/releases/tag/v1.0.0" \
EVENT_RELEASE_BODY=$'first line\nsecond line that will be truncated' \
EVENT_RELEASE_AUTHOR="octocat" \
GITHUB_REPOSITORY_NAME="example/project" \
"$SCRIPT" >/dev/null

grep -q 'chat_id=@my_channel' "$FAKE_CURL_ARGS" || fail "default message sends channel chat_id"
grep -q 'New release: Version 1.0.0' "$FAKE_CURL_ARGS" || fail "default message contains release title"
grep -q 'Repository: example/project' "$FAKE_CURL_ARGS" || fail "default message contains repository"
grep -q 'Tag: v1.0.0' "$FAKE_CURL_ARGS" || fail "default message contains release tag"
pass "default release message request is formed correctly"

# Explicit release inputs path for workflows that create the release themselves.
tmp="$(mktemp -d)"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" success
PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="-100123" \
INPUT_TEXT="" \
INPUT_RELEASE_TITLE="Manual v1.0.0" \
INPUT_RELEASE_TAG="v1.0.0" \
INPUT_RELEASE_URL="https://github.com/example/project/releases/tag/v1.0.0" \
INPUT_RELEASE_BODY="created in the same workflow" \
INPUT_DISABLE_NOTIFICATION="false" \
INPUT_DISABLE_LINK_PREVIEW="false" \
INPUT_PROTECT_CONTENT="false" \
INPUT_INCLUDE_RELEASE_BODY="true" \
INPUT_MAX_BODY_CHARS="1200" \
INPUT_MAX_MESSAGE_CHARS="3900" \
GITHUB_REPOSITORY_NAME="example/project" \
"$SCRIPT" >/dev/null

grep -q 'New release: Manual v1.0.0' "$FAKE_CURL_ARGS" || fail "explicit release inputs contain release title"
grep -q 'Tag: v1.0.0' "$FAKE_CURL_ARGS" || fail "explicit release inputs contain release tag"
grep -q 'created in the same workflow' "$FAKE_CURL_ARGS" || fail "explicit release inputs contain release body"
pass "explicit release input request is formed correctly"

# Optional parse mode and message thread.
tmp="$(mktemp -d)"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" success
PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="-100123" \
INPUT_MESSAGE_THREAD_ID="42" \
INPUT_TEXT="<b>Release</b>" \
INPUT_PARSE_MODE="HTML" \
INPUT_DISABLE_NOTIFICATION="false" \
INPUT_DISABLE_LINK_PREVIEW="false" \
INPUT_PROTECT_CONTENT="true" \
INPUT_INCLUDE_RELEASE_BODY="false" \
INPUT_MAX_BODY_CHARS="0" \
INPUT_MAX_MESSAGE_CHARS="4096" \
"$SCRIPT" >/dev/null

grep -q 'message_thread_id=42' "$FAKE_CURL_ARGS" || fail "message_thread_id is sent"
grep -q 'parse_mode=HTML' "$FAKE_CURL_ARGS" || fail "parse_mode is sent"
grep -q 'protect_content=true' "$FAKE_CURL_ARGS" || fail "protect_content is sent"
pass "optional Telegram fields are sent correctly"

# Invalid inputs fail fast.
if INPUT_BOT_TOKEN="" INPUT_CHAT_ID="1" "$SCRIPT" >/dev/null 2>&1; then
  fail "missing bot token should fail"
fi
pass "missing bot token fails"

if INPUT_BOT_TOKEN="123:secret" INPUT_CHAT_ID="" "$SCRIPT" >/dev/null 2>&1; then
  fail "missing chat id should fail"
fi
pass "missing chat id fails"

if INPUT_BOT_TOKEN="123:secret" INPUT_CHAT_ID="1" INPUT_DISABLE_NOTIFICATION="maybe" "$SCRIPT" >/dev/null 2>&1; then
  fail "invalid boolean should fail"
fi
pass "invalid boolean fails"

if INPUT_BOT_TOKEN="123:secret" INPUT_CHAT_ID="1" INPUT_MESSAGE_THREAD_ID="abc" "$SCRIPT" >/dev/null 2>&1; then
  fail "invalid message_thread_id should fail"
fi
pass "invalid message_thread_id fails"

# Telegram non-2xx response fails.
tmp="$(mktemp -d)"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" telegram-error
if PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="-100123" \
INPUT_TEXT="hello" \
INPUT_DISABLE_NOTIFICATION="false" \
INPUT_DISABLE_LINK_PREVIEW="false" \
INPUT_PROTECT_CONTENT="false" \
INPUT_INCLUDE_RELEASE_BODY="true" \
INPUT_MAX_BODY_CHARS="1200" \
INPUT_MAX_MESSAGE_CHARS="3900" \
"$SCRIPT" >/dev/null 2>&1; then
  fail "Telegram HTTP error should fail"
fi
pass "Telegram HTTP error fails"

# curl transport failure fails even when no Telegram response body exists.
tmp="$(mktemp -d)"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" network
if PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="-100123" \
INPUT_TEXT="hello" \
INPUT_DISABLE_NOTIFICATION="false" \
INPUT_DISABLE_LINK_PREVIEW="false" \
INPUT_PROTECT_CONTENT="false" \
INPUT_INCLUDE_RELEASE_BODY="true" \
INPUT_MAX_BODY_CHARS="1200" \
INPUT_MAX_MESSAGE_CHARS="3900" \
"$SCRIPT" >/dev/null 2>&1; then
  fail "curl transport error should fail"
fi
pass "curl transport error fails"

# Telegram 2xx but ok=false fails.
tmp="$(mktemp -d)"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" bad-json
if PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="-100123" \
INPUT_TEXT="hello" \
INPUT_DISABLE_NOTIFICATION="false" \
INPUT_DISABLE_LINK_PREVIEW="false" \
INPUT_PROTECT_CONTENT="false" \
INPUT_INCLUDE_RELEASE_BODY="true" \
INPUT_MAX_BODY_CHARS="1200" \
INPUT_MAX_MESSAGE_CHARS="3900" \
"$SCRIPT" >/dev/null 2>&1; then
  fail "Telegram ok=false response should fail"
fi
pass "Telegram ok=false response fails"

# GitHub event text is passed as data and must never be evaluated as shell code.
tmp="$(mktemp -d)"
sentinel="$tmp/should-not-exist"
export FAKE_CURL_ARGS="$tmp/curl-args.txt"
export GITHUB_OUTPUT="$tmp/github-output.txt"
make_fake_curl "$tmp" success
PATH="$tmp:$PATH" \
INPUT_BOT_TOKEN="123:secret" \
INPUT_CHAT_ID="-100123" \
INPUT_TEXT="" \
INPUT_RELEASE_TITLE="" \
INPUT_RELEASE_TAG="" \
INPUT_RELEASE_URL="" \
INPUT_RELEASE_BODY="" \
INPUT_DISABLE_NOTIFICATION="false" \
INPUT_DISABLE_LINK_PREVIEW="false" \
INPUT_PROTECT_CONTENT="false" \
INPUT_INCLUDE_RELEASE_BODY="true" \
INPUT_MAX_BODY_CHARS="1200" \
INPUT_MAX_MESSAGE_CHARS="3900" \
EVENT_RELEASE_TITLE="literal command substitution" \
EVENT_RELEASE_TAG="v1.0.0" \
EVENT_RELEASE_BODY="\$(touch ${sentinel})" \
GITHUB_REPOSITORY_NAME="example/project" \
"$SCRIPT" >/dev/null

[[ ! -e "$sentinel" ]] || fail "event text should not execute shell code"
grep -q "\$(touch ${sentinel})" "$FAKE_CURL_ARGS" || fail "event text is sent literally"
pass "event text is not evaluated as shell code"
